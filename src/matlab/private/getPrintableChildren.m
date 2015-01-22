function [childIds childPaths] = getPrintableChildren(parId, isSimObj, followLinks, lookUnderMasks, params)
%GETPRINTABLECHILDREN Get the children of the parent that must be printed.
%   [childIds childPaths] = GETPRINTABLECHILDREN(PARID, ISSIMOBJ,
%   FOLLOWLINKS, LOOKUNDERMASKS, PARAMS) gets the list of children of the
%   specified parent that must be printed.
%
%   The function returns as well the full path of each children.
%
%   It works for Simulink (subsystems) as well as Stateflow elements
%   (Chart, State, Box).

% Copyright (c) 2014 LeanPulse. All rights reserved.
% 
% Author: Aurélien PROST (a.prost@leanpulse.com)


if isSimObj %Simulink Obj
    
    if lookUnderMasks
        if followLinks
            childIds = find_system(parId, 'SearchDepth', 1, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'BlockType', 'SubSystem', ...
                'TemplateBlock', '');
            childIds = localFilterReferenceBlock(childIds, params);
            childIds = [childIds ; find_system(parId, 'SearchDepth', 1, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'BlockType', 'ModelReference')];
            childIds = [childIds ; find_system(parId, 'SearchDepth', 1, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'BlockType', 'SubSystem', 'Tag', 'SyDlink')];
        else
            childIds = find_system(parId, 'SearchDepth', 1, 'FollowLinks', 'off', 'LookUnderMasks', 'all', 'BlockType', 'SubSystem', ...
                'TemplateBlock', '', 'LinkStatus' ,'none');
            childIds = [childIds ; find_system(parId, 'SearchDepth', 1, 'FollowLinks', 'off', 'LookUnderMasks', 'all', 'BlockType', 'ModelReference')];
            childIds = [childIds ; find_system(parId, 'SearchDepth', 1, 'FollowLinks', 'off', 'LookUnderMasks', 'all', 'BlockType', 'SubSystem', 'Tag', 'SyDlink')];
        end
        if ~isempty(childIds)
            maskTypes = [{} ; get_param(childIds,'MaskType')];
            toRemove = strcmp(maskTypes,'Stateflow') | strcmp(maskTypes,'DocBlock');
            if isfield(params, 'MaskType')
                filterMaskTypes = textscan(sprintf(params.MaskType), '%q');
                filterMaskTypes = filterMaskTypes{1};
                masks = [{} ; get_param(childIds,'Mask')];
                toRemove = toRemove | (strcmp(masks,'on') & ~ismember(maskTypes, filterMaskTypes));
            end
            childIds(toRemove) = [];
        end
    else
        if followLinks
            childIds = find_system(parId, 'SearchDepth', 1, 'FollowLinks', 'on', 'LookUnderMasks', 'none', 'BlockType', 'SubSystem', ...
                'TemplateBlock', '', 'Mask', 'off', 'MaskDescription', '', 'MaskPromptString', '', 'MaskInitialization', '', 'MaskHelp', '');
            childIds = localFilterReferenceBlock(childIds, params);
            childIds = [childIds ; find_system(parId, 'SearchDepth', 1, 'FollowLinks', 'on', 'LookUnderMasks', 'none', 'BlockType', 'ModelReference')];
            childIds = [childIds ; find_system(parId, 'SearchDepth', 1, 'FollowLinks', 'on', 'LookUnderMasks', 'none', 'BlockType', 'SubSystem', 'Tag', 'SyDlink')];
        else
            childIds = find_system(parId, 'SearchDepth', 1, 'FollowLinks', 'off', 'LookUnderMasks', 'none', 'BlockType', 'SubSystem', ...
                'TemplateBlock', '', 'LinkStatus' ,'none', 'Mask', 'off', 'MaskDescription', '', 'MaskPromptString', '', ...
                'MaskInitialization', '', 'MaskHelp', '');
            childIds = [childIds ; find_system(parId, 'SearchDepth', 1, 'FollowLinks', 'off', 'LookUnderMasks', 'none', 'BlockType', 'ModelReference')];
            childIds = [childIds ; find_system(parId, 'SearchDepth', 1, 'FollowLinks', 'off', 'LookUnderMasks', 'none', 'BlockType', 'SubSystem', 'Tag', 'SyDlink')];
        end
    end
    childIds = unique(childIds);
    childPaths = getfullname(childIds);
    if ~iscell(childPaths)
        childPaths = {childPaths};
    end
    
    if exist('sfprint', 'file') %Stateflow is installed
        % Find StateFlow charts
        if verLessThan('simulink','8.0')
            if followLinks
                stateSubIds = find_system(parId, 'SearchDepth', 1, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'BlockType', 'SubSystem', ...
                    'TemplateBlock', '', 'Mask', 'on', 'MaskType', 'Stateflow');
            else
                stateSubIds = find_system(parId, 'SearchDepth', 1, 'FollowLinks', 'off', 'LookUnderMasks', 'all', 'BlockType', 'SubSystem', ...
                    'LinkStatus' ,'none', 'TemplateBlock', '', 'Mask', 'on', 'MaskType', 'Stateflow');
            end
            stateSubPaths = cell(length(stateSubIds),1);
            for i=1:length(stateSubIds)
                stateSubPaths{i} = getfullname(stateSubIds(i));
                stateSubIds(i) = sfprivate('block2chart', stateSubIds(i)); %Replace simulink handle by chart handle
            end
            childIds = [childIds ; stateSubIds];
            childPaths = [childPaths ; stateSubPaths];
        else
            isSfIdx = find(~strcmp(get_param(childIds,'SFBlockType'),'NONE'));
            for i=1:length(isSfIdx)
                childIds(isSfIdx(i)) = sfprivate('block2chart', childIds(isSfIdx(i))); %Replace simulink handle by chart handle
            end
        end
    end
    
else %Stateflow Obj
    sfObj = sf('IdToHandle', parId);
    
    % Find subcharts
    subCharts = sfObj.find('IsSubchart', true, 'Subviewer', sfObj);
    subChartIds = zeros(length(subCharts),1);
    subChartPaths = cell(length(subCharts),1);
    for i = 1:length(subCharts)
        subChartIds(i) = subCharts(i).Id;
        subChartPaths{i} = [subCharts(i).Path '/' subCharts(i).Name];
    end
    
    % Find truthtables
    subTruthTables = sfObj.find('-isa','Stateflow.TruthTable', 'Subviewer', sfObj);
    subTruthTableIds = zeros(length(subTruthTables),1);
    subTruthTablePaths = cell(length(subTruthTables),1);
    for i = 1:length(subTruthTables)
        subTruthTableIds(i) = subTruthTables(i).Id;
        subTruthTablePaths{i} = [subTruthTables(i).Path '/' subTruthTables(i).Name];
    end
    
    % Find embedded Matlab functions
    subEMFunctions = sfObj.find('-isa','Stateflow.EMFunction', 'Subviewer', sfObj);
    subEMFunctionIds = zeros(length(subEMFunctions),1);
    subEMFunctionPaths = cell(length(subEMFunctions),1);
    for i = 1:length(subEMFunctions)
        subEMFunctionIds(i) = subEMFunctions(i).Id;
        subEMFunctionPaths{i} = [subEMFunctions(i).Path '/' subEMFunctions(i).Name];
    end
    
    childIds = [subChartIds ; subTruthTableIds ; subEMFunctionIds];
    childPaths = [subChartPaths ; subTruthTablePaths ; subEMFunctionPaths];
end

% Remove found occurences of the parent
parIdx = (childIds==parId);
childIds(parIdx) = [];
childPaths(parIdx) = [];

% Sort the results by full path
[childPaths sortIdx] = sort(childPaths);
childIds = childIds(sortIdx);


function childIds = localFilterReferenceBlock(childIds, params)
if ~isempty(childIds) && isfield(params, 'ReferenceBlock')
    filterRefBlocks = textscan(sprintf(params.ReferenceBlock), '%q');
    filterRefBlocks = filterRefBlocks{1};
    refBlocks = [{} ; get_param(childIds, 'ReferenceBlock')];
    childIds = childIds(strcmp(refBlocks, '') | ismember(refBlocks, filterRefBlocks));
end
