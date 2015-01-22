%FINISH stops the SyD remote renderer when Matlab closes.
%   FINISH stops the SyD remote renderer when Matlab closes if it was
%   loaded during the session.

% Copyright (c) 2011 LeanPulse. All rights reserved.
% 
% Author: Aurélien PROST (a.prost@leanpulse.com)

if exist('com.leanpulse.syd.api.RendererManager','class') == 8
    com.leanpulse.syd.api.RendererManager.killRemoteRenderer();
end