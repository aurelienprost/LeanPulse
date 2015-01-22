function sl_customization(cm)
%SL_CUSTOMIZATION simulink menu entries and callbacks for SyD.

% Copyright (c) 2011 LeanPulse. All rights reserved.
% 
% Author: Aurélien PROST (a.prost@leanpulse.com)


% Register File menu entries
cm.addCustomMenuFcn('Simulink:FileMenu', @localGetFileItems);

% Register Edit menu entries
cm.addCustomMenuFcn('Simulink:EditMenu', @localGetEditItems);

% Register context menu entries
cm.addCustomMenuFcn('Simulink:ContextMenu', @localGetContextItems);

end


%---------------------------------------------------------
% File menu entries
%---------------------------------------------------------
function schemaFcns = localGetFileItems(callbackInfo)
    schemaFcns = {@localGetModelPropsItem ; @localGetGenDocGroup}; 
end

function schema = localGetModelPropsItem(callbackInfo)
    schema = sl_action_schema;
    schema.tag = 'SyD:EditMetadata';
    schema.label = 'Edit SyD Metadata';
    schema.callback = @docMetadataEditor; 
end

function schema = localGetGenDocGroup(callbackInfo)
    schema = sl_container_schema;
    schema.tag = 'SyD:GenerateDoc';
    schema.label = 'LeanPulse SyD';
    loadSyD;
    profiles = com.leanpulse.syd.api.GenProfile.getGenProfiles();
    if ~isempty(profiles)
        schema.state = 'Enabled';
        fcns = cell(length(profiles),1);
        for i=1:length(profiles)
            fcns{i} = {@localGetGenDocItem, profiles(i)};
        end
        schema.childrenFcns = fcns;
    else
        schema.state = 'Disabled';
    end
end

function schema = localGetGenDocItem(callbackInfo)
    schema = sl_action_schema;
    schema.tag = ['SyD:GenerateProfile' char(callbackInfo.userdata.getId)];
    schema.label = char(callbackInfo.userdata.getName);
    schema.accelerator = char(callbackInfo.userdata.getShortcut);
    schema.callback = @localGenerate;
    schema.userdata = callbackInfo.userdata;
end

function localGenerate(callbackInfo)
    jGenerator = com.leanpulse.syd.api.Generator.getDefault();
    jMdlFile = java.io.File(callbackInfo.model.FileName);
    jProfile = callbackInfo.userdata;
    jFrame = com.mathworks.mde.desk.MLDesktop.getInstance().getMainFrame;
    jGenerator.asyncGenerateUI(jMdlFile, jProfile, jFrame);
end


%---------------------------------------------------------
% Edit menu entries
%---------------------------------------------------------
function schemaFcns = localGetEditItems(callbackInfo) 
    schemaFcns = {@localGetDocSecurityEditGroup}; 
end

function schema = localGetDocSecurityEditGroup(callbackInfo)
    schema = sl_container_schema;
    schema.tag = 'SyD:EditSecurityGroup';
    if callbackInfo.uiObject.Handle ~= callbackInfo.model.Handle
        secLevel = localGetSecurityLevel(callbackInfo.uiObject.Handle, 1);
        schema.state = 'Enabled';
        schema.label = ['Document Security (' localGetSecurityLabel(secLevel) ')'];
        schema.childrenFcns = {{@localGetDocSecurityItem, [secLevel==-1 -1 callbackInfo.uiObject.Handle 1]};...
            {@localGetDocSecurityItem, [secLevel==0 0 callbackInfo.uiObject.Handle 1]};...
            {@localGetDocSecurityItem, [secLevel==1 1 callbackInfo.uiObject.Handle 1]};...
            {@localGetDocSecurityItem, [secLevel==2 2 callbackInfo.uiObject.Handle 1]}};
    else
        schema.label = 'Document Security';
        schema.state = 'Disabled';
    end
end


%---------------------------------------------------------
% Context menu entries
%---------------------------------------------------------
function schemaFcns = localGetContextItems(callbackInfo) 
    schemaFcns = {@localGetDocSecurityContextGroup}; 
end

function schema = localGetDocSecurityContextGroup(callbackInfo)
    schema = sl_container_schema;
    schema.tag = 'SyD:ContextSecurityGroup';
    sel = find_system(callbackInfo.uiObject.Handle,'SearchDepth',1,'selected','on');
    isNotMasked = 1;
    if length(sel) == 1 % Only show security context menu if one element is selected.
        if strcmp(get_param(sel,'Type'), 'block')
            blockType = get_param(sel,'BlockType');
            if strcmp(blockType, 'SubSystem')
                maskType = get_param(sel,'MaskType');
                if strcmp(maskType,'DocBlock') || strcmp(maskType,'Stateflow') || ...
                      (strcmp(get_param(sel,'LinkStatus'),'none') && strcmp(get_param(sel,'TemplateBlock'),'') && ...
                       strcmp(get_param(sel,'Mask'),'off') && strcmp(get_param(sel,'MaskDescription'),''))
                    isNotMasked = isempty(maskType);
                else
                    sel = [];
                end
            elseif ~strcmp(blockType, 'ModelReference')
                sel = [];
            end
        end
    else
        sel = [];
    end
    if isempty(sel)
        schema.state = 'Hidden';
    else
        secLevel = localGetSecurityLevel(sel, isNotMasked);
        schema.state = 'Enabled';
        schema.label = ['Document Security (' localGetSecurityLabel(secLevel) ')'];
        schema.childrenFcns = {{@localGetDocSecurityItem, [secLevel==-1 -1 sel isNotMasked]};...
            {@localGetDocSecurityItem, [secLevel==0 0 sel isNotMasked]};...
            {@localGetDocSecurityItem, [secLevel==1 1 sel isNotMasked]};...
            {@localGetDocSecurityItem, [secLevel==2 2 sel isNotMasked]}};
    end
end


%---------------------------------------------------------
% Security edition shared functions
%---------------------------------------------------------
function schema = localGetDocSecurityItem(callbackInfo)
    schema = sl_toggle_schema;
    if callbackInfo.userdata(1)
        schema.checked = 'checked';
    else
        schema.checked = 'unchecked';
    end
    schema.label = localGetSecurityLabel(callbackInfo.userdata(2));
    schema.tag = ['SyD:Security' schema.label];
    schema.callback = @localSubSysSecurityCallback;
    schema.userdata = callbackInfo.userdata(2:4);
end

function secLevel = localGetSecurityLevel(handle, isNotMasked)
    secLevel = str2double(getBlockDataAttribute(handle,isNotMasked,'security'));
    if isnan(secLevel)
        secLevel = -1;
    end
end

function secLabel = localGetSecurityLabel(secLevel)
    switch secLevel
        case 0
            secLabel = 'Low';
        case 1
            secLabel = 'Medium';
        case 2
            secLabel = 'High';
        otherwise
            secLabel = 'Inherit';
    end
end

function localSubSysSecurityCallback(callbackInfo)
    setBlockDataAttribute(callbackInfo.userdata(2),callbackInfo.userdata(3),'security',num2str(callbackInfo.userdata(1)));
    callbackInfo.model.Dirty = 'on';
end