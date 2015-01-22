function refMdls = sydSnap(varargin)
% SYDSNAP Extracts all documentation data from Simulink model to SyD XML.
%   refMdls = SYDSNAP('MDLFILE',FOLLOWLINKS,LOOKUNDERMASKS,'XMLFILE')
%   extracts all documentation data (snapahots, comments, data dictionary,
%   ...) from the specified model to the given XML file.
%   
%       MDLFILE     The full path to a valid Simunlik model file. If the
%                   model isn't opened, it will be automatically opened and
%                   closed after data extraction.
%       FOLLOWLINKS Boolean to indicate if the extraction should dig into
%                   linked subsystems.
%       LOOKUNDERMASKS Boolean to indicate if the extraction should dig into
%                   masked subsystems.
%       PARAMS      Extra parameters for to tweak the extraction.
%       XMLFILE     (optional) The full path to the output XML file. If not
%                   specified, the XML will be saved in the same directory
%                   and with the name as the model.
%       
%       refMdls     Cell array of strings with the model files referenced
%                   by the input model.
% 
%   A fifth input argument can be specified to externally report the
%   progress of the data extraction. This must be an Object compatible with
%   the IProgressMonitor API, as defined by the corresponding Java class.
%
%   See also sydRender.

% Copyright (c) 2014 LeanPulse. All rights reserved.
% 
% Author: Aurélien PROST (a.prost@leanpulse.com)


% Dinamically load the SyD java library.
loadSyD;

% Manage input arguments.
if nargin < 4
   error('SyD:WrongArguments','Wrong number of input arguments'); 
end
mdlFile = varargin{1};
followLinks = varargin{2};
lookUnderMasks = varargin{3};
params = struct(varargin{4}{:});
[mdlPath mdlName] = fileparts(mdlFile);
if nargin < 5
    xmlFile = fullfile(mdlPath, [mdlName '.xml']);
else
    xmlFile = varargin{5};
end
if nargin < 6
    progMon = com.leanpulse.syd.internal.progress.ThrowExStubMonitor;
else
    progMon = varargin{6};
end

% Open the model if closed.
wasClosed = ~ismember(mdlName,bdroot(find_system('Open','on')));
if wasClosed
    open_system(mdlFile);
end
sysH = get_param(getSysToSnap(mdlName),'Handle');

% Save model state.
origDirty = get_param(mdlName, 'Dirty');
origLock = get_param(mdlName, 'Lock');

% Hide model explorers othwise snapshots very slow !
mdlExpHidden = hideModelExplorers();


xmlfid = fopen(xmlFile, 'w', 'l', 'UTF-8');

try
    
    set_param(mdlName, 'Lock', 'off');
    
    if strcmp(get_param(sysH,'type'), 'block_diagram')
        root = 'model';
    else
        root = 'system';
    end
    path = getfullname(sysH);
    
    snapConf = [char(java.lang.Boolean.toString(followLinks)) '|' char(java.lang.Boolean.toString(lookUnderMasks))];
    for i = 1:2:length(varargin{4})
        snapConf = [snapConf '|' varargin{4}{i} ':' varargin{4}{i+1}];
    end
    snapConf = java.lang.String(snapConf);
    bytes = snapConf.getBytes();
    snapConfCRC = java.util.zip.CRC32();
	snapConfCRC.update(bytes,0,length(bytes));
    
    % Write the XML header and root element.
    fwrite(xmlfid, ['<?xml version="1.0" encoding="utf-8"?>' char(13) char(10) ...
        '<syd:' root ' xmlns:syd="http://www.leanpulse.com/schemas/syd/2011/core"' ...
        ' xmlns:svg="http://www.w3.org/2000/svg"' ...
        ' xmlns:xlink="http://www.w3.org/1999/xlink"' ...
        ' xmlns:tex="http://www-sop.inria.fr/miaou/tralics/"' ...
        ' xmlns:aml="http://schemas.microsoft.com/aml/2001/core"' ...
        ' xmlns:dt="uuid:C2F41010-65B3-11d1-A29F-00AA00C14882"' ...
        ' xmlns:o="urn:schemas-microsoft-com:office:office"' ...
        ' xmlns:sl="http://schemas.microsoft.com/schemaLibrary/2003/core"' ...
        ' xmlns:st1="urn:schemas-microsoft-com:office:smarttags"' ...
        ' xmlns:v="urn:schemas-microsoft-com:vml"' ...
        ' xmlns:w="http://schemas.microsoft.com/office/word/2003/wordml"' ...
        ' xmlns:w10="urn:schemas-microsoft-com:office:word"' ...
        ' xmlns:wsp="http://schemas.microsoft.com/office/word/2003/wordml/sp2"' ...
        ' xmlns:wx="http://schemas.microsoft.com/office/word/2003/auxHint"' ...
        ' snapver="1.4"' ...
        ' snapconf="' num2str(snapConfCRC.getValue()) '"' ...
        ' mdlversion="' toXmlAttribute(get_param(mdlName,'ModelVersion')) '"' ...
        ' id="' toXmlAttribute(path)], 'uint8');
    
    refMdls = getReferencedModels(sysH, followLinks, lookUnderMasks, params);
    if ~isempty(refMdls)
        fwrite(xmlfid, ['" mdldep="' toXmlAttribute(refMdls{1})], 'uint8');
        refMdls{1} = which([refMdls{1} '.mdl']);
        for i=2:length(refMdls)
            fwrite(xmlfid, ['|' toXmlAttribute(refMdls{i})], 'uint8');
            refMdls{i} = which([refMdls{i} '.mdl']);
        end
        refMdls(strcmp(refMdls,'')) = [];
    end
    fwrite(xmlfid, ['">' char(13) char(10)], 'uint8');
    
    progMon.progress(['Snapshot ' path]);
    
    % Get the printable children for the root
    [childHs childPaths] = getPrintableChildren(sysH, 1, followLinks, lookUnderMasks, params);
    
    % Extract specification metadata (reference, history, ...)
    fwrite(xmlfid, extractMetadata(sysH, params), 'uint8');
    
    % Extract root requirement infos
    fwrite(xmlfid, extractReqInfos(sysH, 1, 1, childHs, params), 'uint8');
    
    % Extract root lookups
    fwrite(xmlfid, extractLookups(sysH, params), 'uint8');
    
    % Extract root buses
    [bus busNames] = extractBuses(sysH, params);
    fwrite(xmlfid, bus, 'uint8');
    
    % Extract data dictionary
    [dico, dataNames] = extractDictionary(sysH, params);
    fwrite(xmlfid, dico, 'uint8');
    
    dataNames = [dataNames ; busNames];
    
    % Extract root documentation data 
    localExtractSnap(sysH, xmlfid, childHs, childPaths, dataNames, 1);
    fwrite(xmlfid, extractComments(sysH, path, followLinks, lookUnderMasks, params), 'uint8');
    
    progMon.progress(0.15);
    progMon.checkCanceled();
    
    % Extract children
    localExtractChildren(xmlfid, childHs, childPaths, [], followLinks, lookUnderMasks, params, dataNames, progMon, 0.85);
    
    % Close the root element.
    fprintf(xmlfid, ['</syd:' root '>']);
    
catch exception
    
    % Perform some cleanup first to throw the exception in a safe state
    try
        fclose(xmlfid);
        delete(xmlFile);
        % Close the Word session used to convert RTF comments to XML
        extractComments(-1);
        % Close model if not opened before generation
        if wasClosed
            set_param(mdlName, 'Dirty', origDirty);
            pause(0.1); % Let some time to close figures (stateflow) otherwise Matlab hangs
            close_system(mdlName);
        else
            set_param(mdlName, 'Dirty', origDirty, 'Lock', origLock);
        end
        % Restore the model explorer
        restoreModelExplorers(mdlExpHidden);
    end
    
    rethrow(exception);
    
end

fclose(xmlfid);

% Close the Word session used to convert RTF comments to XML
extractComments(-1);
% Close model if not opened before generation
if wasClosed
    set_param(mdlName, 'Dirty', origDirty);
    pause(0.1); % Let some time to close figures (stateflow) otherwise Matlab hangs
    close_system(mdlName);
else
    set_param(mdlName, 'Dirty', origDirty, 'Lock', origLock);
end
% Restore the model explorer
restoreModelExplorers(mdlExpHidden);

end



% This local function iterates through children to extract documentation
% data for each one of them. Depending on the type of chidren (subsystem,
% StateFlow chart, ...), various kind of data will be extracted.
function localExtractChildren(xmlfid, childHs, childPaths, parTableIR, followLinks, lookUnderMasks, params, dataNames, progMon, waitInc)
    childCount = length(childHs);
    if childCount > 0
        waitInc = waitInc/childCount;
        for i=1:childCount
            progMon.progress(['Snapshot ' childPaths{i}]);
            isSimObj = ishandle(childHs(i));
            
            % Simulink object
            if isSimObj
                blockType = get_param(childHs(i),'BlockType');
                if strcmp(blockType,'ModelReference') || ... % Model reference block
                        (strcmp(blockType,'SubSystem') && strcmp(get_param(childHs(i),'Tag'),'SyDlink') && ~strcmp(get_param(childHs(i),'LinkStatus'),'none')) % Model referenced by library link
                    
                    % Open the modelref element
                    if  strcmp(blockType,'ModelReference')
                        fwrite(xmlfid, ['<syd:modelref id="' toXmlAttribute(childPaths{i}) '" file="' toXmlAttribute(get_param(childHs(i),'ModelName')) '">' char(13) char(10)], 'uint8');
                    else
                        refBlock = get_param(childHs(i),'ReferenceBlock');
                        fwrite(xmlfid, ['<syd:modelref id="' toXmlAttribute(childPaths{i}) '" file="' toXmlAttribute(regexp(refBlock,'[^/]+','match','once')) '"' ...
                            ' system="' toXmlAttribute(refBlock) '">' char(13) char(10)], 'uint8');
                    end
                    
                    % Only extract the extra data
                    fwrite(xmlfid, extractExtraData(childHs(i), 'UserData', params), 'uint8');
                    fwrite(xmlfid, extractReqInfos(childHs(i), 1, 0, [], params), 'uint8');
                    
                    % Close the modelref element
                    fprintf(xmlfid, '</syd:modelref>\r\n');
                    
                    progMon.progress(waitInc);
                    progMon.checkCanceled();
                    
                else % Simulink subsystem
                    
                    % Open the system element
                    fwrite(xmlfid, ['<syd:system id="' toXmlAttribute(childPaths{i}) '"'], 'uint8');
                    maskType = get_param(childHs(i), 'MaskType');
                    if ~isempty(maskType)
                        fwrite(xmlfid, [' mask="' toXmlAttribute(maskType) '">' char(13) char(10)], 'uint8');
                    else
                        fwrite(xmlfid, ['>' char(13) char(10)], 'uint8');
                    end
                    
                    % Get the printable children for the subsystem
                    [newchildHs newChildPaths] = getPrintableChildren(childHs(i), isSimObj, followLinks, lookUnderMasks, params);
                    
                    % Extract subsystem documentation data
                    fwrite(xmlfid, extractExtraData(childHs(i), 'UserData', params), 'uint8');
                    fwrite(xmlfid, extractReqInfos(childHs(i), 1, 1, newchildHs, params), 'uint8');
                    fwrite(xmlfid, extractLookups(childHs(i), params), 'uint8');
                    fwrite(xmlfid, extractBuses(childHs(i), params), 'uint8');
                    localExtractSnap(childHs(i), xmlfid, newchildHs, newChildPaths, dataNames, isSimObj);
                    fwrite(xmlfid, extractComments(childHs(i), childPaths{i}, followLinks, lookUnderMasks, params), 'uint8');
                    
                    newWaitInc = waitInc/(length(newchildHs)+1);
                    progMon.progress(newWaitInc);
                    progMon.checkCanceled();
                    
                    % Loop inside the children hierarchy
                    localExtractChildren(xmlfid, newchildHs, newChildPaths, [], followLinks, lookUnderMasks, params, dataNames, progMon, waitInc - newWaitInc);
                    
                    % close the system element
                    fprintf(xmlfid, '</syd:system>\r\n');
                    
                end
            
            % Stateflow object
            else
                sfObj = sf('IdToHandle', childHs(i));
                
                if isa(sfObj,'Stateflow.TruthTable') || isa(sfObj,'Stateflow.TruthTableChart') % TruthTable
                    
                    % Open the truthtable element
                    fwrite(xmlfid, ['<syd:truthtable id="' toXmlAttribute(childPaths{i}) '">' char(13) char(10)], 'uint8');
                    
                    % Extract truthtable documentation data
                    if isa(sfObj,'Stateflow.TruthTableChart') % In case of a truthtable (which has a Simulink block), extract also extra data
                        fwrite(xmlfid, extractExtraData(sfprivate('chart2block', childHs(i)), 'Description', params), 'uint8');
                    end
                    fwrite(xmlfid, extractReqInfos(childHs(i), 0, 0, [], params), 'uint8');
                    
                    % For truthtable, the internal structure is directly translated as XML elements
                    conditions = sfObj.ConditionTable;
                    for k=1:size(conditions,1)
                        fprintf(xmlfid, '<syd:condition>\r\n');
                        for l=1:size(conditions,2)
                            fwrite(xmlfid, ['<syd:col>' toXmlText(conditions{k,l}) '</syd:col>' char(13) char(10)], 'uint8');
                        end
                        fprintf(xmlfid, '</syd:condition>\r\n');
                    end
                    actions = sfObj.ActionTable;
                    for k=1:size(actions,1)
                        fprintf(xmlfid, '<syd:action>\r\n');
                        for l=1:size(actions,2)
                            fwrite(xmlfid, ['<syd:col>' toXmlText(actions{k,l}) '</syd:col>' char(13) char(10)], 'uint8');
                        end
                        fprintf(xmlfid, '</syd:action>\r\n');
                    end
                    
                    % Close the truthtable element
                    fprintf(xmlfid, '</syd:truthtable>\r\n');
                    
                    progMon.progress(waitInc);
                    progMon.checkCanceled();
                    
                elseif isa(sfObj,'Stateflow.EMFunction') || isa(sfObj,'Stateflow.EMChart') % Embedded Matlab
                    
                    % Open the embedded Matlab element
                    fwrite(xmlfid, ['<syd:mfunction id="' toXmlAttribute(childPaths{i}) '">' char(13) char(10)], 'uint8');
                    
                    % Extract embedded Matlab documentation data
                    if isa(sfObj,'Stateflow.EMChart') % Only in case of a chart (which has a Simulink block), extract extra data
                        fwrite(xmlfid, extractExtraData(sfprivate('chart2block', childHs(i)), 'Description', params), 'uint8');
                    end
                    fwrite(xmlfid, extractReqInfos(childHs(i), 0, 0, [], params), 'uint8');
                    
                    % Directly copy the m script to the XML
                    fwrite(xmlfid, ['<syd:script>' toXmlText(sfObj.Script) '</syd:script>' char(13) char(10)], 'uint8');
                    
                    % Close the embedded Matlab element
                    fprintf(xmlfid, '</syd:mfunction>\r\n');
                    
                    progMon.progress(waitInc);
                    progMon.checkCanceled();
                    
                else % All other Stateflow element (chart, tablechart, state, function, box)
                    
                    % Open the Stateflow element
                    sfClass = class(sfObj);
                    switch(sfClass)
                        case 'Stateflow.State'
                            if isa(sfObj.Chart, 'Stateflow.StateTransitionTableChart')
                                tag = 'tablestate';
                            else
                                tag = 'state';
                            end
                        case 'Stateflow.Box'
                            tag = 'box';
                        case 'Stateflow.Function'
                            tag = 'function';
                        case 'Stateflow.StateTransitionTableChart'
                            tag = 'tablechart';
                        otherwise
                            tag = 'chart';
                    end
                    fwrite(xmlfid, ['<syd:' tag ' id="' toXmlAttribute(childPaths{i}) '">' char(13) char(10)], 'uint8');
                    
                    % Get the printable children for the stateflow element
                    [newchildHs newChildPaths] = getPrintableChildren(childHs(i), isSimObj, followLinks, lookUnderMasks, params);
                    
                    % Extract stateflow element documentation data
                    if isa(sfObj, 'Stateflow.Chart') || isa(sfObj, 'Stateflow.StateTransitionTableChart') % Only in case of a chart (which has a Simulink block), extract extra data
                        fwrite(xmlfid, extractExtraData(sfprivate('chart2block', childHs(i)), 'Description', params), 'uint8');
                    end
                    fwrite(xmlfid, extractReqInfos(childHs(i), 0, 1, newchildHs, params), 'uint8');
                    localExtractSnap(childHs(i), xmlfid, newchildHs, newChildPaths, dataNames, isSimObj);
                    
                    % Extract the state transition matrix in case of table chart
                    newParTableIR = [];
                    if isa(sfObj, 'Stateflow.StateTransitionTableChart')
                        sttMan = Stateflow.STTUtils.STTUtilMan.getManager(sfObj, struct('buildIRfromTable',true));
                        newParTableIR = sttMan.getTableIR();
                        newParTableIR.reduce(true);
                    elseif isa(sfObj, 'Stateflow.State') && isa(sfObj.Chart, 'Stateflow.StateTransitionTableChart')
                        stateIdx = find(strcmp({parTableIR.stateCells.name},sfObj.Name));
                        if ~isempty(stateIdx)
                            newParTableIR = parTableIR.stateCells(stateIdx(1)).childTable;
                        end
                    end
                    if ~isempty(newParTableIR)
                        localExtractSTM(newParTableIR, xmlfid, childPaths{i});
                    end
                    
                    newWaitInc = waitInc/(length(newchildHs)+1);
                    progMon.progress(newWaitInc);
                    progMon.checkCanceled();
                    
                    % Loop inside the children hierarchy
                    localExtractChildren(xmlfid, newchildHs, newChildPaths, newParTableIR, followLinks, lookUnderMasks, params, dataNames, progMon, waitInc - newWaitInc);
                    
                    % Close the Stateflow element
                    fprintf(xmlfid, ['</syd:' tag '>\r\n']);
                    
                end
            end
        end
    else
        progMon.progress(waitInc);
        progMon.checkCanceled();
    end
end


function localExtractSnap(objH, xmlfid, childHs, childPaths, dataNames, isSimObj)
    svgFile = [tempname() '.svg'];
    [paperPositionMode paperSize paperUnits tiledPageScale tiledPaperMargins] = localPrint(objH, svgFile, isSimObj);
    if strcmp(paperPositionMode,'tiled')
        ppi = get(0,'ScreenPixelsPerInch');
        tileWidth = (paperSize(1) - tiledPaperMargins(1) - tiledPaperMargins(3)) * tiledPageScale * ppi;
        tileHeight = (paperSize(2) - tiledPaperMargins(2) - tiledPaperMargins(4)) * tiledPageScale * ppi;
        switch paperUnits
            case 'centimeters'
                unit = 'cm';
                tileWidth = tileWidth / 2.54;
                tileHeight = tileHeight / 2.54;
            case 'points'
                unit = 'pt';
                tileWidth = tileWidth / 72;
                tileHeight = tileHeight / 72;
            otherwise
                unit = 'in';
        end
        pageMargins = mat2str(tiledPaperMargins);
        fprintf(xmlfid, ['<syd:snapshot tilewidth="' num2str(floor(tileWidth)) '" tileheight="' num2str(floor(tileHeight)) '"' ...
            ' pagewidth="' num2str(paperSize(1)) '" pageheight="' num2str(paperSize(2)) '" pagemargins="' pageMargins(2:end-1) '" units="' unit '">\r\n']);
    else
        fprintf(xmlfid, '<syd:snapshot>\r\n');
    end
    svg = readXml(svgFile, 'svg', 'UTF-8');
    delete(svgFile);
    svg = localFixSVG(svg);
    svg = localAddChildrenLinks(svg, isSimObj, childHs, childPaths);
    svg = localAddDataLinks(svg, objH, isSimObj, dataNames);
    svg = svg((svg >= 32 & svg <= 55295) | (svg >= 57344 & svg <= 65533) | svg == 9 | svg == 10 | svg == 13);
    fwrite(xmlfid, svg, 'uint8');
    fprintf(xmlfid, '</syd:snapshot>\r\n');
end


function [paperPositionMode paperSize paperUnits tiledPageScale tiledPaperMargins] = localPrint(objH, filename, isSimObj)
    paperSize = [];
    paperUnits = '';
    tiledPageScale = 1;
    tiledPaperMargins = [];
    if isSimObj %Simulink Obj
        wasOpened = get_param(objH, 'Open');
        paperPositionMode = get_param(objH, 'PaperPositionMode');
        if strcmp(paperPositionMode,'tiled')
            paperSize = get_param(objH, 'PaperSize');
            paperUnits = get_param(objH, 'PaperUnits');
            tiledPageScale = get_param(objH, 'TiledPageScale');
            tiledPaperMargins = get_param(objH, 'TiledPaperMargins');
        end
        paperOrientation = get_param(objH, 'PaperOrientation');
        set_param(objH, 'PaperPositionMode', 'auto');
        set_param(objH, 'PaperOrientation', 'portrait');
        if strcmp(wasOpened, 'off')
            if verLessThan('simulink','8.0')
                openedSys = find_system(bdroot(objH), 'Open', 'on');
                toRemoveIdx = strcmp(get_param(openedSys, 'Type'),'block');
                toRemoveIdx(strcmp(get_param(openedSys(toRemoveIdx), 'BlockType'), 'SubSystem')) = [];
                openedSys(toRemoveIdx) = [];
                open_system(objH, openedSys(1), 'browse', 'force');
            else
                open_system(objH, 'force');
            end
        else
            open_system(objH, 'force');
        end
        pause(0.05);
        print(objH, '-dsvg', filename);
        set_param(objH, 'PaperPositionMode', paperPositionMode, 'paperOrientation', paperOrientation);
        if strcmp(wasOpened, 'off')
            if verLessThan('simulink','8.0')
                open_system(openedSys(1), objH, 'browse', 'force');
            else
                set_param(objH,'Open','off');
            end
        end
    else %Stateflow Obj
        sfObj = sf('IdToHandle', objH);
        subviewer = sfObj;
        while ~isa(subviewer, 'Stateflow.Chart') && ~isa(subviewer, 'Stateflow.StateTransitionTableChart')
            subviewer = subviewer.Subviewer;
        end
        wasOpened = subviewer.Visible;
        paperPositionMode = subviewer.PaperPositionMode;
        if strcmp(paperPositionMode,'tiled')
            paperSize = subviewer.PaperSize;
            paperUnits = subviewer.PaperUnits;
            tiledPageScale = subviewer.TiledPageScale;
            tiledPaperMargins = subviewer.TiledPaperMargins;
        end
        paperOrientation = subviewer.PaperOrientation;
        subviewer.PaperPositionMode = 'auto';
        subviewer.PaperOrientation = 'portrait';
        sfObj.view;
        stateFig = sfprint(sfObj.Id,'default','silent');
        set(stateFig, 'PaperPositionMode', 'auto');
        set(stateFig, 'PaperOrientation', 'portrait');
        localPrintFig(stateFig, filename);
        close(stateFig);
        clear stateFig;
        subviewer.PaperPositionMode = paperPositionMode;
        subviewer.PaperOrientation = paperOrientation;
        if subviewer ~= sfObj
            subviewer.view;
        end
        if ~wasOpened && verLessThan('simulink','8.0')
            subviewer.Visible = 0;
        end
    end
end


function localPrintFig(figH, filename)
    pj = printjob();
    wasErr = 0;

    try
        % Configure sys to print
        pj.Handles = {figH};

        % Configure the driver
        pj.Driver = 'svg';
        pj.DriverExt = 'svg';
        pj.DriverColor = 1;
        pj.DriverColorSet = 1;
        pj.DriverExport = 1;

        % Configure output
        pj.FileName = filename;

        % Prepare pointers
        pj.AllFigures = findall(0,'type','figure');
        if ~isempty(pj.AllFigures)
            pj.AllPointers = get( pj.AllFigures, 'pointer');
            set( pj.AllFigures, 'pointer', 'watch')
        end

        pj.Validated = 1;
        pj.Active = 1;
        pj.Error = 0;

        pj = printprepare( pj, figH );

        % Set Driver only now to avoid error during preparation
        pj.DriverClass = 'QT';

        try
            oldcd = cd();
            cd([matlabroot '\toolbox\matlab\graphics\private']);
            render(pj, figH);
            cd(oldcd);
        catch
            pj.Error = 1;
            wasErr = 1;
        end

        pj = printrestore( pj, figH );

        pj.Active = 0;
    catch
        wasErr = 1;
    end

    % Restore pointers
    switch length(pj.AllFigures)
     case 0
        %NOP
     case 1
       if ishandle(pj.AllFigures), set( pj.AllFigures, 'pointer', pj.AllPointers ); end; 
     otherwise, 
      m = ishandle(pj.AllFigures); 
      pj.AllFigures  = pj.AllFigures(m); % remove bad handles 
      pj.AllPointers = pj.AllPointers(m); 
      set( pj.AllFigures, {'pointer'}, pj.AllPointers ); 
    end

    if wasErr
        error( lasterror );
    end
end


function svg = localFixSVG(svg)
    % Add dimensions to root if necessary (ver < R2011a)
    if isempty(regexp(svg,'^<svg:svg [^<]*width=[''"][^<]+>','once'))
        viewBoxStr = regexp(svg,'viewBox=["'']([0-9 ]+)["'']','tokens','once');
        if ~isempty(viewBoxStr)
            viewBox = str2num(viewBoxStr{1});
            if length(viewBox) == 4
                [startIdx endIdx] = regexp(svg,'<svg:svg[^<]*>','once');
                svg = [svg(1:endIdx-1) 'width=''' num2str(viewBox(3)-viewBox(1)) ''' ' ...
                    'height=''' num2str(viewBox(4)-viewBox(2)) '''' svg(endIdx:end)];
            end
        end
    end
    % Remove white background
    svg = regexprep(svg, 'fill=''rgb\(100%,100%,100%\) ''', 'fill=''none''', 'once');
end


function svg = localAddChildrenLinks(svg, isSimObj, childHs, childPaths)
    if ~isempty(childHs)
        if verLessThan('simulink','8.0') || ~isSimObj
            drawPos = regexp(svg,'<svg:g[^>]*>\s*((?!svg:g).)*\s*</svg:g>','once','tokenExtents');
        else
            drawPos = regexp(svg,'<svg:g[^>]*fill-opacity="0"[^>]*>\s*(((?!svg:g).)*<svg:path[^>]*vector-effect="non-scaling-stroke"[^>]*/>((?!svg:g).)*)\s*</svg:g>','once','tokenExtents');
        end
        if ~isempty(drawPos)
            links = '';
            for i=1:length(childHs)
                if ishandle(childHs(i)) %Simulink Obj
                    position = get_param(childHs(i), 'Position');
                    position(3) = position(3)-position(1);
                    position(4) = position(4)-position(2);
                else %Stateflow Obj
                    sfObj = sf('IdToHandle', childHs(i));
                    if isa(sfObj, 'Stateflow.Chart') || isa(sfObj, 'Stateflow.EMChart') || ...
                            isa(sfObj, 'Stateflow.TruthTableChart') || isa(sfObj, 'Stateflow.StateTransitionTableChart')
                        position = get_param(sfprivate('chart2block', childHs(i)), 'Position');
                        position(3) = position(3)-position(1);
                        position(4) = position(4)-position(2);
                        if isa(sfObj, 'Stateflow.Chart')
                            position(5) = position(3)/11;
                            position(6) = position(4)/8;
                        end
                    else
                        position = sfObj.Position;
                        if isa(sfObj, 'Stateflow.State')
                            position(5) = position(3)/15;
                            position(6) = position(3)/15;
                        end
                    end
                end
                links = [links ...
                    '<svg:a xlink:href=''#' toXmlAttribute(childPaths{i}) '''>' ...
                        '<svg:rect fill=''none'' stroke=''rgb(0%,0%,0%)'' stroke-width=''1'' stroke-opacity=''0'' ' ...
                            'x=''' num2str(position(1)) ''' ' ...
                            'y=''' num2str(position(2)) ''' ' ...
                            'width=''' num2str(position(3)) ''' ' ...
                            'height=''' num2str(position(4)) ''''];
                if length(position) > 4
                    links = [links ' ' ...
                            'rx=''' num2str(position(5)) ''' ' ...
                            'ry=''' num2str(position(6)) '''/>'];
                else
                    links = [links '/>'];
                end
                links = [links ...
                    '</svg:a>' char(13) char(10)];
            end
            svg = [svg(1:drawPos(2)) links svg(drawPos(2)+1:end)];
        end
    end
end


function svg = localAddDataLinks(svg, objH, isSimObj, dataNames)
    if isSimObj
        sysDataNames = unique([ {} ; ... % First element as empty cell to ensure the concatenation is done on cells.
            regexp(get_param(find_system(objH,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','BlockType','Constant'),'Value'),'[\w.]+','match','once') ; ...
            regexp(get_param(find_system(objH,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','BlockType','Inport','IconDisplay','Port number'),'Name'),'[\w.]+','match','once') ; ...
            regexp(get_param(find_system(objH,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','BlockType','Outport','IconDisplay','Port number'),'Name'),'[\w.]+','match','once') ; ...
            regexp(get_param(find_system(objH,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','BlockType','TriggerPort'),'Name'),'[\w.]+','match','once') ; ...
            regexp(get_param(find_system(objH,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','BlockType','EnablePort'),'Name'),'[\w.]+','match','once') ; ...
            regexp(get_param(find_system(objH,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','BlockType','GotoTagVisibility'),'GotoTag'),'[\w.]+','match','once') ; ...
            regexp(get_param(find_system(objH,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','BlockType','Goto'),'GotoTag'),'[\w.]+','match','once') ; ...
            regexp(get_param(find_system(objH,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','BlockType','From'),'GotoTag'),'[\w.]+','match','once') ; ...
            regexp(get_param(find_system(objH,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','BlockType','DataStoreMemory'),'DataStoreName'),'[\w.]+','match','once') ; ...
            regexp(get_param(find_system(objH,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','BlockType','DataStoreRead'),'DataStoreName'),'[\w.]+','match','once') ; ...
            regexp(get_param(find_system(objH,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','BlockType','DataStoreWrite'),'DataStoreName'),'[\w.]+','match','once') ; ...
            regexp(get_param(find_system(objH,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','BlockType','Gain'),'Gain'),'[\w.]+','match','once') ; ...
            regexp(get_param(find_system(objH,'FindAll','on','SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','Type','line','SegmentType','trunk'),'Name'),'[\w.]+','match','once') ; ...
            regexp(get_param(find_system(objH,'FindAll','on','SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','Type','port','ShowPropagatedSignals','on'),'PropagatedSignals'),'[\w.]+','match','once')]);
        sysDataNames = intersect(dataNames, sysDataNames);
        for i=1:length(sysDataNames)
            [startIdxs endIdxs] = regexp(svg,['<svg:text[^>]*>(&lt;|<)?\[?' sysDataNames{i} '\]?(&gt;|>)?</svg:text>']);
            if ~isempty(startIdxs)
                for j=length(startIdxs):-1:1
                    svg = [svg(1:startIdxs(j)-1) '<svg:a xlink:href=''#' sysDataNames{i} '''>' svg(startIdxs(j):endIdxs(j)) '</svg:a>' svg(endIdxs(j)+1:end)];
                end
            end
        end
        lookups = find_system(objH,'SearchDepth',1,'BlockType','Lookup');
        lookup2Ds = find_system(objH,'SearchDepth',1,'BlockType','Lookup2D');
        maskParams = cellfun(@(x) strread(strrep(x,'''',''),'%s','delimiter','|'), [ {} get_param(find_system(objH,'SearchDepth',1,'BlockType','SubSystem','Mask','on'),'MaskValueString') ],'UniformOutput',false);
        sysDataNames = unique([ {} ; ... % First element as empty cell to ensure the concatenation is done on cells.
            regexp(get_param(lookups,'Table'),'[\w.]+','match','once') ; ...
            regexp(get_param(lookups,'InputValues'),'[\w.]+','match','once') ; ...
            regexp(get_param(lookup2Ds,'Table'),'[\w.]+','match','once') ; ...
            regexp(get_param(lookup2Ds,'RowIndex'),'[\w.]+','match','once') ; ...
            regexp(get_param(lookup2Ds,'ColumnIndex'),'[\w.]+','match','once') ; ...
            vertcat(maskParams{:}) ]);
        sysDataNames = intersect(dataNames, sysDataNames);
        for i=1:length(sysDataNames)
            [startIdxs endIdxs] = regexp(svg,['<svg:text[^>]*>([^<]*\W)?' sysDataNames{i} '(\W[^<]*)?</svg:text>']);
            if ~isempty(startIdxs)
                for j=length(startIdxs):-1:1
                    svg = [svg(1:startIdxs(j)-1) '<svg:a xlink:href=''#' sysDataNames{i} '''>' svg(startIdxs(j):endIdxs(j)) '</svg:a>' svg(endIdxs(j)+1:end)];
                end
            end
        end
        
    else
        sfObj = sf('IdToHandle', objH);
        sfDatas = sfObj.find('-isa','Stateflow.Data','-or','-isa','Stateflow.Event','-depth',1);
        sfParent = sfObj;
        while ~isa(sfParent, 'Stateflow.Chart') && ~isa(sfParent, 'Stateflow.StateTransitionTableChart')
            sfParent = sfParent.Subviewer;
            sfDatas = [sfDatas ; sfParent.find('-isa','Stateflow.Data','-or','-isa','Stateflow.Event','-depth',1)];
        end

        mFrame = com.mathworks.mde.desk.MLDesktop.getInstance().getMainFrame;

        for i=1:length(sfDatas)
            if ismember(sfDatas(i).Name,dataNames)
                [startIdxs, endIdxs, tokens] = regexp(svg,['(<svg:text[^>]* x=[''"])' ...
                    '(\d+(\.\d+)?)([^>]* font-size=[''"])(\d+)([''"][^>]* font-family=[''"])([^''"]+)([''"][^>]*>)' ...
                    '([^<]*?)\<' sfDatas(i).Name '\>([^<]*)' ...'
                    '</svg:text>'], 'start', 'end', 'tokens');
                if ~isempty(startIdxs)
                    linkHead = ['<svg:a xlink:href=''#' sfDatas(i).Name '''>'];
                    for j=length(startIdxs):-1:1
                        if isempty(strfind(tokens{j}{5}, ' font-weight=''bold'''))
                            weight = java.awt.Font.PLAIN;
                        else
                            weight = java.awt.Font.BOLD;
                        end

                        fontMetrics = mFrame.getFontMetrics(java.awt.Font(tokens{j}{6}, weight, str2double(tokens{j}{4})));
                        if isempty(tokens{j}{8})
                            if isempty(tokens{j}{9})
                                svg = [svg(1:startIdxs(j)-1) ...
                                    linkHead svg(startIdxs(j):endIdxs(j)) '</svg:a>' ...
                                    svg(endIdxs(j)+1:end)];
                            else
                                x1 = str2double(tokens{j}{2}) + fontMetrics.stringWidth(sfDatas(i).Name);
                                svg = [svg(1:startIdxs(j)-1) ...
                                    linkHead tokens{j}{1} tokens{j}{2} tokens{j}{3} tokens{j}{4} tokens{j}{5} tokens{j}{6} tokens{j}{7} sfDatas(i).Name '</svg:text></svg:a>' char(13) char(10) ...
                                    tokens{j}{1} num2str(x1) tokens{j}{3} tokens{j}{4} tokens{j}{5} tokens{j}{6} tokens{j}{7} tokens{j}{9} '</svg:text>' ...
                                    svg(endIdxs(j)+1:end)];
                            end
                        else
                            x = str2double(tokens{j}{2});
                            x1 = x + fontMetrics.stringWidth(strrep(strrep(strrep(tokens{j}{8},'&lt;','<'),'&gt;','>'),'&amp;','&'));
                            if isempty(tokens{j}{9})
                                svg = [svg(1:startIdxs(j)-1) ...
                                    tokens{j}{1} tokens{j}{2} tokens{j}{3} tokens{j}{4} tokens{j}{5} tokens{j}{6} tokens{j}{7} tokens{j}{8} '</svg:text>' char(13) char(10) ...
                                    linkHead tokens{j}{1} num2str(x1) tokens{j}{3} tokens{j}{4} tokens{j}{5} tokens{j}{6} tokens{j}{7} sfDatas(i).Name '</svg:text></svg:a>' ...
                                    svg(endIdxs(j)+1:end)];
                            else
                                x2 = x1 + fontMetrics.stringWidth(sfDatas(i).Name);
                                svg = [svg(1:startIdxs(j)-1) ...
                                    tokens{j}{1} tokens{j}{2} tokens{j}{3} tokens{j}{4} tokens{j}{5} tokens{j}{6} tokens{j}{7} tokens{j}{8} '</svg:text>' char(13) char(10) ...
                                    linkHead tokens{j}{1} num2str(x1) tokens{j}{3} tokens{j}{4} tokens{j}{5} tokens{j}{6} tokens{j}{7} sfDatas(i).Name '</svg:text></svg:a>' char(13) char(10) ...
                                    tokens{j}{1} num2str(x2) tokens{j}{3} tokens{j}{4} tokens{j}{5} tokens{j}{6} tokens{j}{7} tokens{j}{9} '</svg:text>' ...
                                    svg(endIdxs(j)+1:end)];
                            end
                        end
                    end
                end
            end
        end
    end
end

function localExtractSTM(tableIR, xmlfid, path)
    fwrite(xmlfid, ['<syd:transitionmatrix id="' toXmlAttribute(path) '">' char(13) char(10)], 'uint8');
    cells = [{tableIR.defaultCell} {tableIR.innerCell} num2cell(tableIR.stateCells)];
    cells(cellfun('isempty',cells)) = [];
    conditions = {};
    for i = 1:length(cells)
        conds = {cells{i}.outerTransitions.condition};
        conds(strcmp({cells{i}.outerTransitions.destination},'')) = [];
        conditions = [conditions conds];
    end
    conditions(strcmp(conditions,'')) = [];
    conditions = unique(conditions,'stable');

    for i = 1:length(conditions)
        fprintf(xmlfid, '<syd:conditions>\r\n');
        fwrite(xmlfid, ['<syd:condition>' toXmlText(conditions{i}) '</syd:condition>' char(13) char(10)], 'uint8');
        fprintf(xmlfid, '</syd:conditions>\r\n');
    end
    for i = 1:length(cells)
        cell = cells{i};
        if isa(cell, 'Stateflow.STT.IR.StateCell')
            fwrite(xmlfid, ['<syd:cell type="state" default="' num2str(cell.isDefaultTransitionOwner) '">' char(13) char(10)], 'uint8');
            fwrite(xmlfid, ['<syd:label>' toXmlText(cell.labelString) '</syd:label>' char(13) char(10)], 'uint8');
        elseif isa(cell, 'Stateflow.STT.IR.DefaultCell')
            fwrite(xmlfid, ['<syd:cell type="default" default="1">' char(13) char(10)], 'uint8');
        elseif isa(cell, 'Stateflow.STT.IR.InnerCell')
            fwrite(xmlfid, ['<syd:cell type="inner" default="' num2str(cell.isDefaultTransitionOwner) '">' char(13) char(10)], 'uint8');
            fwrite(xmlfid, ['<syd:label>' toXmlText(cell.masterCondition) '</syd:label>' char(13) char(10)], 'uint8');
        end
        for j = 1:length(conditions)
            matchIdx = find(strcmp({cell.outerTransitions.condition},conditions{j}));
            if ~isempty(matchIdx)
                trans = cell.outerTransitions(matchIdx(1));
                fwrite(xmlfid, ['<syd:action dest="' toXmlAttribute(trans.destination) '">' ...
                    toXmlText(trans.action) '</syd:action>' char(13) char(10)], 'uint8');
            else
                fprintf(xmlfid, '<syd:action/>\r\n');
            end
        end
        fprintf(xmlfid, '</syd:cell>\r\n');
    end
    fprintf(xmlfid, '</syd:transitionmatrix>\r\n');
end


function mdlExpHidden = hideModelExplorers()
    mdlExpHidden = [];
    daRoot = DAStudio.Root;
    explorers = daRoot.find('-isa', 'DAStudio.Explorer');
    for i=1:length(explorers)
        try
            if explorers(i).isVisible % = isVisible prop not exists on R2007b
                mdlExpHidden = [mdlExpHidden ; explorers(i)];
                explorers(i).hide;
            end
        catch
            explorers(i).hide;
        end
    end
end


function restoreModelExplorers(mdlExpHidden)
    for i=1:length(mdlExpHidden)
        mdlExpHidden(i).show;
    end
end
