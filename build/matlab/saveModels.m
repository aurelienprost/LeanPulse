function saveModels(srcDir)
%SAVEMODELS Force to save Simulink models to clean them up.
%   SAVEMODELS(SRCDIR) saves models in the directory SRCDIR recurively to
%   clean them up after a conversion of Simulink version.

% Copyright (c) 2011 LeanPulse. All rights reserved.
% 
% Author: Aurélien PROST (a.prost@leanpulse.com)
% Version: $Rev$

% Save models in srcDir
mdls = dir([srcDir '\*.mdl']);
for i=1:length(mdls)
    open(fullfile(srcDir, mdls(i).name));
    mdl = bdroot(gcs);
    set_param(mdl,'Dirty','on');
    save_system(mdl)
end

% Recursively save sub-directories
files = dir(srcDir);
dirs = files(logical(cat(1,files.isdir)));
for i=1:length(dirs)
   dirname = dirs(i).name;
   if ~strcmp( dirname,'.') && ~strcmp( dirname,'..')
       saveModels(fullfile(srcDir,dirname));
   end
end