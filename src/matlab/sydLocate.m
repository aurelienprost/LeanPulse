function refMdlPaths = sydLocate(refMdlNames)
%SYDLOCATE Resolve model references.
%   SYDLOCATE(REFMDLNAMES) resolves the specified referenced model names and
%   returns the corresponding file paths to the models.
%   
%       REFMDLNAMES Cell array of strings giving Simulink model names
%                   (without the 'mdl' extension) to resolve.
%   
%       returns     Cell array of strings with full file paths to the
%                   resolved models.
%   
%   This function is implemented for internal purpose only and shouldn't be
%   called externally.

% Copyright (c) 2011 LeanPulse. All rights reserved.
% 
% Author: Aurélien PROST (a.prost@leanpulse.com)


% Resolve model references using Matlab paths
refMdlPaths = cell(1,length(refMdlNames));
for i=1:length(refMdlNames)
    refMdlPaths{i} = which([refMdlNames{i} '.mdl']);
end

% Remove model references that haven't been resolved.
refMdlPaths(strcmp(refMdlPaths,'')) = [];