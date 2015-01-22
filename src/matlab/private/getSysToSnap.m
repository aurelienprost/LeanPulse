function sys = getSysToSnap(mdlName)
%GETSYSTOSNAP Get the subsystem from where to start the extraction.
%   sys = GETSYSTOSNAP(MDLNAME) returns the full path of the subsystem from
%   where to start the generation.

% Copyright (c) 2014 LeanPulse. All rights reserved.
% 
% Author: Aurélien PROST (a.prost@leanpulse.com)

% This default implementation just returns the model itself.

sys = mdlName;