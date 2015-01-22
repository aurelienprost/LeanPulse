function loadSyD()
%LOADSYD Load the SyD java library.
%   LOADSYD dynamically loads the SyD java library if not already loaded.

% Copyright (c) 2011 LeanPulse. All rights reserved.
% 
% Author: Aurélien PROST (a.prost@leanpulse.com)


if ~exist('com.leanpulse.syd.api.Generator','class')

    % We should be able to use the two lines below
    %   -> javaaddpath(fullfile(fileparts(which('sydGenerate')),'lib','syd-core.jar'));
    %   -> javaaddpath(fullfile(fileparts(which('sydGenerate')),'lib','syd-matlab.jar'));
    % But a bug in java 1.6.0 (R2007b) prevents from using spaces in classpath
    % entries used with RMI.
    % Therefore we use reference the library with its URL

    jCoreJarFile = java.io.File(fullfile(fileparts(which('sydGenerate')),'lib','syd-core.jar'));
    sydCoreJarUrl = char(jCoreJarFile.toURI().toString());
    jMatlabJarFile = java.io.File(fullfile(fileparts(which('sydGenerate')),'lib','syd-matlab.jar'));
    sydMatlabJarUrl = char(jMatlabJarFile.toURI().toString());
    
    jloader = com.mathworks.jmi.ClassLoaderManager.getClassLoaderManager;
    jloader.setEnabled(1);
    com.mathworks.jmi.OpaqueJavaInterface.enableClassReloading(1);
    dyncp = {};
    jdyncp = jloader.getClassPath;
    if ~isempty(jdyncp)
        dyncp = cell(jdyncp);
    end
    jloader.setClassPath([dyncp ; sydCoreJarUrl ; sydMatlabJarUrl]);
    if verLessThan('matlab', '7.12')
        feature('clearjava',1);
    end
    clear('java');
    
end