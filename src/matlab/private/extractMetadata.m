function xmlMetadata = extractMetadata(sysH, params)
%EXTRACTMETADATA Extract the XML metadata of the system.
%   xmlMetadata = EXTRACTMETADATA(SYSH, PARAMS) extracts the XML metadata of
%   the specified Simulink system. The returned string is UTF-8 encoded.

% Copyright (c) 2012 LeanPulse. All rights reserved.
% 
% Author: Aurélien PROST (a.prost@leanpulse.com)


%**************************************************************************
%                      !!!! DEVELOPER NOTES !!!!
%--------------------------------------------------------------------------
% The code below might be modified to retrieve the metadata from another
% source than the model history.
%
% As this script is part of the SyD generation process, developers must be
% aware that their code must fulfil the following requirements:
%
% - NEVER THROW ANY ERRORS or the entire generation process will be
%   stopped.
%
% - The "xmlMetadata" output must be a VALID UTF-8 XML STRING.
%     It is advised to either use the Java XML API to correctly build the
%     XML or, if text is preferred, to use the "toXmlAttribute" and
%     "toXmlText" utility functions in order to ensure the correct
%     conversion of user data. We also recommend to use a prefix for all
%     XML elements, in order to avoid elements confusion during the XML
%     transformation.
% 
% The input parameter "sysH" is the handle of the subsystem from where the
% snapshots are started.
% The input "params" is a structure containing all the extra paramaters
% defined for the snapper in the profiles configuration file.
% 
% This script is called only once per generation for a given model.
%
% The default code below just copy the metadata that have been saved as XML
% in the history field of the model by the Document Metadata Editor, as
% implemented in the script <docMetadataEditor.m>.
%**************************************************************************

data = get_param(bdroot(sysH), 'ModifiedHistory');
if strncmp(data,'<syd:',5)
    xmlMetadata = [unicode2native(data,'UTF-8') char(13) char(10)];
else
    xmlMetadata = '';
end