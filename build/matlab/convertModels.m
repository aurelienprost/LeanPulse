function convertModels(srcDir, outDir)
%CONVERTMODELS Convert models saved with later version of Simulink to R2007b.
%   CONVERTMODELS(SRCDIR, OUTDIR) converts to R2007b version models from the
%   directory SRCDIR and stores the output to the OUTDIR directory. The
%   conversion is recursive in the directory structure.

% Copyright (c) 2011 LeanPulse. All rights reserved.
% 
% Author: Aurélien PROST (a.prost@leanpulse.com)
% Version: $Rev$

mkdir(outDir); % Ensure the output directory exists

% Convert models in srcDir
mdls = dir([srcDir '\*.mdl']);
for i=1:length(mdls)
    open(fullfile(srcDir, mdls(i).name));
    save_system(bdroot(gcs),fullfile(outDir, mdls(i).name),'SaveAsVersion','R2007b');
end

% Recursively convert sub-directories
files = dir(srcDir);
dirs = files(logical(cat(1,files.isdir)));
for i=1:length(dirs)
   dirname = dirs(i).name;
   if ~strcmp( dirname,'.') && ~strcmp( dirname,'..')
       convertModels(fullfile(srcDir,dirname),fullfile(outDir,dirname));
   end
end
