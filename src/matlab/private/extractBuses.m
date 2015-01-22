function [xmlBuses busNames] = extractBuses(sysH, params)

% Initialization
xmlBuses = '';
busNames = {};

busCreators = find_system(sysH,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','BlockType','BusCreator');
busSelectors = find_system(sysH,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','BlockType','BusSelector');

if ~isempty(busCreators) || ~isempty(busSelectors)
    % Open the buses element
    xmlBuses = ['<syd:buses>' char(13) char(10)];
    
    for i = 1:length(busCreators)
        portHs = get_param(busCreators(i),'PortHandles');
        outbus = localGetOutputSignalName(portHs.Outport(1));
        if isempty(outbus)
            outbus = 'unnamed';
        end
        xmlBuses = [xmlBuses '<syd:bus id="' toXmlAttribute(getfullname(busCreators(i))) '"' ...
            ' out="' toXmlAttribute(outbus) '">' char(13) char(10)];
        for j = 1:length(portHs.Inport)
            sigName = localGetInputSignalName(portHs.Inport(j));
            if isempty(sigName)
                sigName = ['signal' num2str(j)];
            end
            xmlBuses = [xmlBuses '<syd:signal name="' toXmlAttribute(sigName) '"/>' char(13) char(10)];
        end
        xmlBuses = [xmlBuses '</syd:bus>' char(13) char(10)];
    end
    
    for i = 1:length(busSelectors)
        portHs = get_param(busSelectors(i),'PortHandles');
        inbus = localGetInputSignalName(portHs.Inport(1));
        xmlBuses = [xmlBuses '<syd:bus id="' toXmlAttribute(getfullname(busSelectors(i))) '"'...
            ' in="' toXmlAttribute(inbus) '"'];
        if strcmp(get_param(busSelectors(i),'OutputAsBus'),'on')
            outbus = localGetOutputSignalName(busSelectors(i));
            if isempty(outbus)
                outbus = 'unnamed';
            end
            xmlBuses = [xmlBuses ' out="' toXmlAttribute(outbus) '">' char(13) char(10)];
        else
            xmlBuses = [xmlBuses '>' char(13) char(10)];
        end
        selectedSignals = textscan(get_param(busSelectors(i),'OutputSignals'),'%s','Delimiter',',');
        for j = 1:length(selectedSignals{1})
            xmlBuses = [xmlBuses '<syd:signal name="' toXmlAttribute(selectedSignals{1}{j}) '"/>' char(13) char(10)];
        end
        xmlBuses = [xmlBuses '</syd:bus>' char(13) char(10)];
    end
    
    
    % Close the buses element
    xmlBuses = [xmlBuses '</syd:buses>' char(13) char(10)];
end

if nargout > 1
    allBusCreators = [find_system(sysH,'FollowLinks','on','LookUnderMasks','all','BlockType','BusCreator') ; ...
            find_system(sysH,'FollowLinks','on','LookUnderMasks','all','BlockType','BusSelector','OutputAsBus','on')];
    busNames = cell(length(allBusCreators),1);
    for i=1:length(allBusCreators)
        portHs = get_param(allBusCreators(i),'PortHandles');
        busNames{i} = localGetOutputSignalName(portHs.Outport(1));
    end
    busNames(strcmp(busNames,'')) = [];
    busNames = unique(busNames);
end


function name = localGetOutputSignalName(srcPortH)
name = get_param(srcPortH,'Name');
if isempty(name)
    lineH = get_param(srcPortH,'Line');
    if lineH > -1
        dstPortH = get_param(lineH,'DstPortHandle');
        if dstPortH > -1
            dstBlock = get_param(dstPortH,'Parent');
            switch get_param(dstBlock,'BlockType')
                case 'Outport'
                    name = get_param(dstBlock,'Name');
                case 'SubSystem'
                    inport = find_system(dstBlock,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','BlockType','Inport','Port',num2str(get_param(dstPortH,'PortNumber')));
                    name = get_param(inport{1},'Name');
                case 'Goto'
                    name = get_param(dstBlock,'GotoTag');
            end
        end
    end
end


function name = localGetInputSignalName(dstPortH)
name = get_param(dstPortH,'Name');
if isempty(name)
    lineH = get_param(dstPortH,'Line');
    if lineH > -1
        srcPortH = get_param(lineH,'SrcPortHandle');
        if srcPortH > -1
            srcBlock = get_param(srcPortH,'Parent');
            switch get_param(srcBlock,'BlockType')
                case 'Inport'
                    name = get_param(srcBlock,'Name');
                case 'SubSystem'
                    outport = find_system(srcBlock,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','BlockType','Outport','Port',num2str(get_param(srcPortH,'PortNumber')));
                    name = get_param(outport{1},'Name');
                case 'From'
                    name = get_param(srcBlock,'GotoTag');
            end
        end
    end
end
