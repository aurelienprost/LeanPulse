function docMetadataEditor(callbackinfo)
% A default graphical user interface to edit specification metadata.
% Enable the user to edit the reference, title, owner and history and save
% all those data directly inside the model.

% Copyright (c) 2012 LeanPulse. All rights reserved.
% 
% Author: Aurélien PROST (a.prost@leanpulse.com)

dlgTag = ['DocMetaDataEditor' strrep(num2str(callbackinfo.model.Handle),'.','_')];

% Focus dialog if already open and return
f = getappdata(0, dlgTag);
if ~isempty(f)
    figure(f);
    return
end

% Create the figure
f = figure('Name',['Document Metadata - ' callbackinfo.model.Name],'Numbertitle','off',...
    'Integerhandle','off','Menubar','none','Resize','off','Color',get(0,'defaultUicontrolBackgroundColor'),'Closerequestfcn',@local_exit);

% Adjust size of dialog to fit menus
set(f,'Units','pixels');
p = get(0,'ScreenSize');
Width = 600;
Height = 470;
set(f,'Position',[(p(3)-Width)/2 (p(4)-Height)/2 Width Height]);

% Initialize the XML element that will be used to save the metadata
ui.dlgTag = dlgTag;
ui.model = callbackinfo.model;
if ~isempty(ui.model.ModifiedHistory)
    try
        % Try to parse previously saved data
        ui.data = xmlread(org.xml.sax.InputSource(java.io.StringReader(ui.model.ModifiedHistory)));
        dataRootNode = ui.data.getDocumentElement();
    catch
        % Can't parse the saved data, recreate blank data
        ui.data = com.mathworks.xml.XMLUtils.createDocument('syd:extradata');
        dataRootNode = ui.data.getDocumentElement();
        dataRootNode.setAttribute('xmlns:syd', 'http://www.leanpulse.com/schemas/syd/2011/core');
    end
else
    % No metadata previously saved, create blank element
    ui.data = com.mathworks.xml.XMLUtils.createDocument('syd:extradata');
    dataRootNode = ui.data.getDocumentElement();
    dataRootNode.setAttribute('xmlns:syd', 'http://www.leanpulse.com/schemas/syd/2011/core');
end

% Create the UI panels and controls
propsPan = uipanel('Parent',f,'Title','Meta Data','Units','pixels','FontWeight','bold','Position',[5 365 590 100]);

uicontrol('Parent',propsPan,'Style','text','String','Reference :','Horizontalalignment','right','Position',[5 60 70 15]);
ui.handles.reference = uicontrol('Parent',propsPan,'Style','edit','TooltipString','Document Unique Reference','Horizontalalignment','left',...
    'BackgroundColor','w','Position',[80 60 500 20],'Callback',@local_editField,'String', char(dataRootNode.getAttribute('ref')));

uicontrol('Parent',propsPan,'Style','text','String','Title :','Horizontalalignment','right','Position',[5 35 70 15]);
ui.handles.title = uicontrol('Parent',propsPan,'Style','edit','TooltipString','Document Title','Horizontalalignment','left',...
    'BackgroundColor','w','Position',[80 35 500 20],'Callback',@local_editField,'String', char(dataRootNode.getAttribute('title')));

uicontrol('Parent',propsPan,'Style','text','String','Owner :','Horizontalalignment','right','Position',[5 10 70 15]);
ui.handles.owner = uicontrol('Parent',propsPan,'Style','edit','TooltipString','Document Owner','Horizontalalignment','left',...
    'BackgroundColor','w','Position',[80 10 500 20],'Callback',@local_editField,'String', char(dataRootNode.getAttribute('owner')));


histPan = uipanel('Parent',f,'Title','History','Units','pixels','FontWeight','bold','Position',[5 50 590 300]);
ui.handles.versions = uicontrol('Parent',histPan,'Style','listbox','TooltipString','Specification Revisions',...
    'BackgroundColor','w','Position',[5 170 60 110],'Callback',@local_versionSelected);

uicontrol('Parent',histPan,'Style','text','String','Author :','Horizontalalignment','right','Position',[70 255 70 15]);
ui.handles.author = uicontrol('Parent',histPan,'Style','edit','TooltipString','Version Author','Horizontalalignment','left',...
    'BackgroundColor','w','Position',[145 255 315 20],'Callback',@local_editField);

uicontrol('Parent',histPan,'Style','text','String','Date :','Horizontalalignment','right','Position',[70 230 70 15]);
ui.handles.date = uicontrol('Parent',histPan,'Style','edit','TooltipString','Version Date','Horizontalalignment','left',...
    'BackgroundColor','w','Position',[145 230 315 20],'Callback',@local_editField);

uicontrol('Parent',histPan,'Style','text','String','Optional 1 :','Horizontalalignment','right','Position',[70 205 70 15]);
ui.handles.opt1 = uicontrol('Parent',histPan,'Style','edit','TooltipString','Version Optional Field 1','Horizontalalignment','left',...
    'BackgroundColor','w','Position',[145 205 315 20],'Callback',@local_editField);

uicontrol('Parent',histPan,'Style','text','String','Optional 2 :','Horizontalalignment','right','Position',[70 180 70 15]);
ui.handles.opt2 = uicontrol('Parent',histPan,'Style','edit','TooltipString','Version Optional Field 2','Horizontalalignment','left',...
    'BackgroundColor','w','Position',[145 180 315 20],'Callback',@local_editField);

uicontrol('Parent',histPan,'Style','pushbutton','String','New Version','Position',[480 255 100 20],'Callback',@local_newVersion);
uicontrol('Parent',histPan,'Style','pushbutton','String','Delete Version','Position',[480 220 100 20],'Callback',@local_deleteVersion);
uicontrol('Parent',histPan,'Style','pushbutton','String','Change Version','Position',[480 185 100 20],'Callback',@local_changeVersion);

ui.handles.log = uicontrol('Parent',histPan,'Style','edit','TooltipString','Version Details','Horizontalalignment','left',...
    'BackgroundColor','w','Position',[5 10 575 150],'Max',2,'Callback',@local_editField);

uicontrol('Parent',f,'Style','pushbutton','String','OK','Position',[210 10 80 25],'Callback',@local_OK);
uicontrol('Parent',f,'Style','pushbutton','String','Cancel','Position',[310 10 80 25],'Callback',@local_Cancel);

% Save the controls structure and figure to application data for later access
setappdata(f,'Userdata',ui);
setappdata(0,ui.dlgTag,f);

local_updateHistPanel(f)



function local_updateHistPanel(f)
% Update the histroy panel

ui = getappdata(f,'Userdata');
versionNodes = ui.data.getDocumentElement().getElementsByTagName('syd:version');
versions = cell(versionNodes.getLength(),1);
for i=0:versionNodes.getLength()-1
    versions{i+1} = char(versionNodes.item(i).getAttribute('num'));
end
set(ui.handles.versions,'String',versions);
set(ui.handles.versions,'Value',length(versions));
local_versionSelected(ui.handles.versions,[]);



function local_versionSelected(list,evd)
% Refresh the history fields according to the version selected in the list

ui = getappdata(get(get(list,'parent'),'parent'),'Userdata');
selIdx = get(ui.handles.versions,'Value');
if selIdx < 1
    set(ui.handles.author,'String','');
    set(ui.handles.date,'String','');
    set(ui.handles.opt1,'String','');
    set(ui.handles.opt2,'String','');
    set(ui.handles.log,'String','');
else
    versionNode = ui.data.getDocumentElement().getElementsByTagName('syd:version').item(selIdx-1);
    set(ui.handles.author,'String',char(versionNode.getAttribute('author')));
    set(ui.handles.date,'String',char(versionNode.getAttribute('date')));
    set(ui.handles.opt1,'String',char(versionNode.getAttribute('opt1')));
    set(ui.handles.opt2,'String',char(versionNode.getAttribute('opt2')));
    set(ui.handles.log,'String',char(versionNode.getTextContent()));
end



function local_editField(field,evd)
% Called when a field is edited by the user to retrieve the new value

f = get(get(field,'parent'),'parent');
ui = getappdata(f,'Userdata');
switch field
    case ui.handles.reference
        ui.data.getDocumentElement().setAttribute('ref',get(ui.handles.reference,'String'));
    case ui.handles.title
        ui.data.getDocumentElement().setAttribute('title',get(ui.handles.title,'String'));
    case ui.handles.owner
        ui.data.getDocumentElement().setAttribute('owner',get(ui.handles.owner,'String'));
    otherwise
        selIdx = get(ui.handles.versions,'Value');
        if selIdx > 0
            versionNode = ui.data.getDocumentElement().getElementsByTagName('syd:version').item(selIdx-1);
            switch field
                case ui.handles.author
                    versionNode.setAttribute('author',get(ui.handles.author,'String'));
                case ui.handles.date
                    versionNode.setAttribute('date',get(ui.handles.date,'String'));
                case ui.handles.opt1
                    versionNode.setAttribute('opt1',get(ui.handles.opt1,'String'));
                case ui.handles.opt2
                    versionNode.setAttribute('opt2',get(ui.handles.opt2,'String'));
                case ui.handles.log
                    matStr = get(ui.handles.log,'String');
                    text = deblank(matStr(1,:));
                    for i = 2:size(matStr,1)
                        text = [text 10 deblank(matStr(i,:))];
                    end
                    versionNode.setTextContent(text);
            end
        end
end



function local_newVersion(button,evd)
% Add a new version

f = get(get(button,'parent'),'parent');
ui = getappdata(f,'Userdata');
versionNodes = ui.data.getDocumentElement().getElementsByTagName('syd:version');
newVersionNode = ui.data.createElement('syd:version');
if versionNodes.getLength() == 0
    newVersionNode.setAttribute('num','1.0');
    newVersionNode.setAttribute('author','Author');
    newVersionNode.setAttribute('opt1','');
    newVersionNode.setAttribute('opt2','');
else
    lastVersionNode = versionNodes.item(versionNodes.getLength()-1);
    lastVer = char(lastVersionNode.getAttribute('num'));
    dotsIdx = strfind(lastVer,'.');
    if isempty(dotsIdx)
        newrev = [lastVer '.0'];
    else
        newrev = [num2str(str2double(lastVer(1:dotsIdx(1)-1))+1) '.0'];
    end
    newVersionNode.setAttribute('num',newrev);
    newVersionNode.setAttribute('author',lastVersionNode.getAttribute('author'));
    newVersionNode.setAttribute('opt1',lastVersionNode.getAttribute('opt1'));
    newVersionNode.setAttribute('opt2',lastVersionNode.getAttribute('opt2'));
end
newVersionNode.setAttribute('date',strrep(date, '-', ' '));
newVersionNode.setTextContent('');
ui.data.getDocumentElement().appendChild(newVersionNode);
local_updateHistPanel(f);



function local_deleteVersion(button,evd)
% Delete the selected version

f = get(get(button,'parent'),'parent');
ui = getappdata(f,'Userdata');
selIdx = get(ui.handles.versions,'Value');
if selIdx > 0
    dataRootNode = ui.data.getDocumentElement();
    versionNodes = dataRootNode.getElementsByTagName('syd:version');
    dataRootNode.removeChild(versionNodes.item(selIdx-1));
    local_updateHistPanel(f);
end



function local_changeVersion(button, evd)
% Change the selected version

f = get(get(button,'parent'),'parent');
ui = getappdata(f,'Userdata');
selIdx = get(ui.handles.versions,'Value');
if selIdx > 0
    versionNode = ui.data.getDocumentElement().getElementsByTagName('syd:version').item(selIdx-1);
    newRev = inputdlg({'Please enter the new version number'},'Version number',1,{char(versionNode.getAttribute('num'))});
    if ~isempty(newRev)
        if isempty(regexp(newRev{1},'^[\d+\.]+\d+$','once'))
            msgbox('The version number must be only composed of digits and dots', 'Error', 'error');
        else
            versionNode.setAttribute('num',newRev{1});
            local_updateHistPanel(f);
        end
    end
end



function local_OK(button, evd)
% Button OK has been pressed, save the data as XML in the model history.

f = get(button,'parent');
ui = getappdata(f,'Userdata');
domSource = javax.xml.transform.dom.DOMSource(ui.data);
writer = java.io.StringWriter();
result = javax.xml.transform.stream.StreamResult(writer);
tf = javax.xml.transform.TransformerFactory.newInstance();
transformer = tf.newTransformer();
transformer.setOutputProperty(javax.xml.transform.OutputKeys.METHOD, 'xml');
transformer.setOutputProperty(javax.xml.transform.OutputKeys.ENCODING, 'UTF-8');
transformer.setOutputProperty(javax.xml.transform.OutputKeys.INDENT, 'no');
transformer.setOutputProperty(javax.xml.transform.OutputKeys.OMIT_XML_DECLARATION, 'yes');
transformer.transform(domSource, result);
ui.model.ModifiedHistory = char(writer.toString());
ui.model.Dirty = 'on';
local_exit(f,evd);



function local_Cancel(button, evd)
% Cancel button has been pressed, just exit.

local_exit(get(button,'parent'),evd);



function local_exit(f,evd)
% Remove the application data and close the window

ui = getappdata(f,'Userdata');
rmappdata(0,ui.dlgTag);
closereq