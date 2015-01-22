function sydGenerate(varargin)
%SYDGENERATE Generates system document from Simulink model.
%   SYDGENERATE('MDLFILE','PROFILEID') generates the system documentation
%   from the specified model by applying the specified profile.
%   
%       MDLFILE     The full path to a valid Simunlik model file. If the
%                   model isn't opened and the generation requires to open
%                   it, it will be automatically open and closed after data
%                   extraction.
%       PROFILEID   A valid ID of a generation profile, as defined in the
%                   sydProfiles.xml file.
%   
%   By default, a graphical user interface showing the progress of the
%   generation is displayed. In case of errors, those will be reported
%   directly to the interface and no failure will be reported to the Matlab
%   environment.
%   
%   An optional argument enables to hide the UI and report errors directly
%   to Matlab:
%   
%       % Generate system document without the progress UI and reports
%       % errors directly to Matlab
%       sydGenerate('C:\Users\User\Documents\model.mdl','Portrait',0);
%   
%   See also sydSnap, sydRender.

% Copyright (c) 2011 LeanPulse. All rights reserved.
% 
% Author: Aurélien PROST (a.prost@leanpulse.com)


switch nargin
    case 2 % By default, show the progress user interface.
        mdlFile = varargin{1};
        profile = varargin{2};
        showUI = 1;
    case 3
        mdlFile = varargin{1};
        profile = varargin{2};
        showUI = varargin{3};
    otherwise
        error('SyD:WrongArguments','Wrong number of input arguments');
end

if ~exist(mdlFile,'file')
    error('SyD:FileNotFound','File %s not found',mdlFile);
end

loadSyD; % Dinamically load the SyD java library.
switch class(profile)
    case 'char' % The argument is the profile ID
        jProfile =  com.leanpulse.syd.api.GenProfile.getGenProfile(profile);
        if isempty(jProfile)
            error('SyD:ProfileNotFound','No profile with ID %s found',profile);
        end
    case 'com.leanpulse.syd.internal.ConfProfile'
        jProfile = profile;
    otherwise
        error('SyD:InvalidArgument','The second argument should be a string');
end

% Call the generator API (implemented in Java)
jMdlFile = java.io.File(mdlFile);
jGenerator = com.leanpulse.syd.api.Generator.getDefault();
if showUI
    jFrame = com.mathworks.mde.desk.MLDesktop.getInstance().getMainFrame;
    jGenerator.generateUI(jMdlFile, jProfile, jFrame);
else
    jGenerator.generate(jMdlFile, jProfile);
end
    
end