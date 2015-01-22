function xmlLookups = extractLookups(sysH, params)
%EXTRACTLOOKUPS Extract as XML the parameters of the lookups in the given
%   subsystem (but not in its children).
%   xmlLookups = EXTRACTLOOKUPS(SYSH, PARAMS) extracts the lookup parameters
%   from the current subsystem and returns them as an UTF-8 XML string.

% Copyright (c) 2014 LeanPulse. All rights reserved.
% 
% Author: Aurélien PROST (a.prost@leanpulse.com)


% Initialization
xmlLookups = '';

% Get lookups
[lookups1D lookups2D] = localGetLookups(sysH, params);

if size(lookups1D,1) > 0 || size(lookups2D,1) > 0
    % Open the lookups element
    xmlLookups = ['<syd:lookups>' char(13) char(10)];
    
    for i=1:size(lookups1D,1)
        xmlLookups = [xmlLookups '<syd:lookup type="1D" table="' toXmlAttribute(lookups1D{i,1}) '"' ...
            ' xaxis="' toXmlAttribute(lookups1D{i,2}) '"' ...
            ' xsignal="' toXmlAttribute(lookups1D{i,3}) '"/>' char(13) char(10)];
    end
    for i=1:size(lookups2D,1)
        xmlLookups = [xmlLookups '<syd:lookup type="2D" table="' toXmlAttribute(lookups2D{i,1}) '"' ...
            ' xaxis="' toXmlAttribute(lookups2D{i,2}) '"' ...
            ' yaxis="' toXmlAttribute(lookups2D{i,3}) '"' ...
            ' xsignal="' toXmlAttribute(lookups2D{i,4}) '"' ...
            ' ysignal="' toXmlAttribute(lookups2D{i,5}) '"/>' char(13) char(10)];
    end
    
    % Close the lookups element
    xmlLookups = [xmlLookups '</syd:lookups>' char(13) char(10)];
end



function [lookups1D lookups2D] = localGetLookups(sysH, params)

% Initialization
lookups1D = cell(0,3);
lookups2D = cell(0,5);

% Standard Simulink lookups
lookupSlBlocks = find_system(sysH,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','BlockType','Lookup');
if ~isempty(lookupSlBlocks)
    xsignals = get_param(lookupSlBlocks,'InputSignalNames');
    if length(lookupSlBlocks) > 1
        xsignals = vertcat(xsignals{:});
    end
    lookups1D = [lookups1D ; [ get_param(lookupSlBlocks,'Table') get_param(lookupSlBlocks,'InputValues') xsignals ] ];
end
lookup2DSlBlocks = find_system(sysH,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','BlockType','Lookup2D');
if ~isempty(lookup2DSlBlocks)
    xysignals = get_param(lookup2DSlBlocks,'InputSignalNames');
    if length(lookup2DSlBlocks) > 1
        xysignals = vertcat(xysignals{:});
    end
    lookups2D = [lookups2D ; [ get_param(lookup2DSlBlocks,'Table') get_param(lookup2DSlBlocks,'RowIndex') get_param(lookup2DSlBlocks,'ColumnIndex') xysignals ] ];
end

% Clean up parameters and signals names
lookups1D = regexp(lookups1D,'[\w.]+','match','once');
lookups2D = regexp(lookups2D,'[\w.]+','match','once');