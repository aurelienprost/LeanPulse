function sydRender(varargin)
%SYDRENDER Renders SyD XML to PDF.
%   SYDRENDER('XMLFILE','PROFILEID',REFMDLS) renders the SyD XML file to
%   PDF by applying the specified profile.
%   
%       XMLFILE     The full path to a valid XML file, previously extracted
%                   from a model by SyD (see sydSnap).
%       PROFILEID   A valid ID of a generation profile, as defined in the
%                   sydProfiles.xml file.
%       REFMDLS     A cell array of strings giving the full paths to model
%                   files referenced by the source model from where the XML
%                   was extracted. This is necessary to compute the
%                   relative paths to cross-linked document.
%   
%   In the case of a profile with an output path relative to the model, the
%   XML file replaces the model to determine where to render and how to
%   name the output document.
%    
%   A fourth input argument can be specified to externally report the
%   progress of the rendering. This must be an Object compatible with
%   the IProgressMonitor API, as defined by the corresponding Java class. 
%   
%   See also sydSnap.

% Copyright (c) 2011 LeanPulse. All rights reserved.
% 
% Author: Aurélien PROST (a.prost@leanpulse.com)


% Dinamically load the SyD java library.
loadSyD;

% Manage input arguments.
switch nargin
    case 3
        xmlFile = varargin{1};
        profile = varargin{2};
        refMdls = varargin{3};
        jProgMon = com.leanpulse.syd.internal.progress.ThrowExStubMonitor;
    case 4
        xmlFile = varargin{1};
        profile = varargin{2};
        refMdls = varargin{3};
        jProgMon = varargin{4};
    otherwise
        error('SyD:WrongArguments','Wrong number of input arguments');
end

if ~exist(xmlFile,'file')
    error('SyD:FileNotFound','File %s not found',xmlFile);
else
    jXmlFile = java.io.File(xmlFile);
end

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
switch class(refMdls)
    case 'cell'
        jRefMdls = java.util.ArrayList(length(refMdls));
        for i=1:length(refMdls)
            jRefMdls.add(java.io.File(refMdls{i}));
        end
    otherwise
        error('SyD:InvalidArgument','The third argument should be a cell array of strings');
end

jRenderConfs = jProfile.getRenderConfs;
confsNum = length(jRenderConfs);
subProgInc = 100/confsNum;
for i=1:confsNum
    jSubMon = jProgMon.createSubProgress(['Rendering document ' num2str(i) '/' num2str(confsNum)],subProgInc);
    jRenderConfs(i).render(jXmlFile,jRefMdls,jSubMon);
end

end