function refMdls = getReferencedModels(sysH, followLinks, lookUnderMasks, params)
%GETREFERENCEDMODELS Get the models referenced under the subsystem.
%   refMdls = GETREFERENCEDMODELS(SYSH, FOLLOWLINKS, LOOKUNDERMASKS, PARAMS))
%   returns a cell array with the names of the models referenced under the
%   given subsystem.

% Copyright (c) 2014 LeanPulse. All rights reserved.
% 
% Author: Aurélien PROST (a.prost@leanpulse.com)

refMdls = localFindReferencedModels(sysH, followLinks, lookUnderMasks, params, {});
refMdls = unique(refMdls);


function refMdls = localFindReferencedModels(sysH, followLinks, lookUnderMasks, params, refMdls)
childIds = getPrintableChildren(sysH, 1, followLinks, lookUnderMasks, params);
for i=1:length(childIds)
    if ishandle(childIds(i))
        blockType = get_param(childIds(i),'BlockType');
        if strcmp(blockType,'ModelReference')
            refMdls = [refMdls ; get_param(childIds(i),'ModelName')];
        elseif strcmp(blockType,'SubSystem') && strcmp(get_param(childIds(i),'Tag'),'SyDlink')
            refMdls = [refMdls ; regexp(get_param(childIds(i),'ReferenceBlock'),'[^/]+','match','once')];
        end
        refMdls = localFindReferencedModels(childIds(i), followLinks, lookUnderMasks, params, refMdls);
    end
end