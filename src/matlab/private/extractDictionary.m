function [xmlDico, dataNames] = extractDictionary(sysH, params)
%EXTRACTDICTIONARY Extract as XML the data dictionary from the model workspace.
%   [xmlDico, dataNames] = EXTRACTDICTIONARY(SYSH, PARAMS) extracts the data
%   dictionary from the model workspace (Simulink.Signal and
%   Simulink.Parameters) and returns it as an UTF-8 XML string as well as
%   the list of data names.

% Copyright (c) 2013 LeanPulse. All rights reserved.
% 
% Author: Aurélien PROST (a.prost@leanpulse.com)


%**************************************************************************
%                      !!!! DEVELOPER NOTES !!!!
%--------------------------------------------------------------------------
% The code below might be modified to retrieve the data dictionary from
% another source than the model workspace.
%
% As this script is part of the SyD generation process, developers must be
% aware that their code must fulfil the following conditions:
%
% - NEVER THROW ANY ERRORS or the entire generation process will be
%   stopped.
%
% - The "xmlDico" output must be a VALID UTF-8 XML STRING.
%     It is advised to either use the Java XML API to correctly build the
%     XML or, if text is preferred, to use the "toXmlAttribute" and
%     "toXmlText" utility methods in order to ensure the correct conversion
%     of user data. The default code below builds the XML this way.
%     We also recommend to use a prefix for all XML elements, in order to
%     avoid elements confusion during the XML transformation.
%     The structure of the XML string returned might be modified but the
%     XSL stylesheet will have to be updated accordingly, by overriding the
%     "AddDicoSignals" and "AddDicoParameters" templates from <default.xsl>
%     in <template.xsl>.
%
% - The "dataNames" output must be a (N,1) CELL ARRAY containing only
%   strings.
%     This list of data names is used to add links in the block diagram
%     snapshots. If the name of a data is missing, no link to the data
%     dictionary will be available.
% 
% The input parameter "sysH" is the handle of the subsystem from where the
% snapshots are started.
% The input "params" is a structure containing all the extra paramaters
% defined for the snapper in the profiles configuration file.
%**************************************************************************


% Initialization
dataNames = {};

% Open the dictionary
xmlDico = ['<syd:dictionary>' char(13) char(10)];

% Handle Signals and Parameters
mdlWS = get_param(bdroot(sysH),'ModelWorkspace');
if ~isempty(mdlWS) % If library, the model workspace is empty
    if ~isempty(mdlWS.data)

        % Iterate through model workspace to find Simulink.Signal and
        % Simulink.Parameter.
        signals = mdlWS.data;
        parameters = mdlWS.data;
        if ~isempty(signals)
            for i=length(signals):-1:1
                if isa(signals(i).Value,'Simulink.Signal')
                    parameters(i) = [];
                elseif isa(parameters(i).Value,'Simulink.Parameter')
                    signals(i) = [];
                else
                    signals(i) = [];
                    parameters(i) = [];
                end
            end
        end

        % Compute data names
        if ~isempty(signals)
            [unused, order] = sort({signals.Name});
            signals = signals(order);
            dataNames = {signals.Name}';
        end
        if ~isempty(parameters)
            [unused, order] = sort({parameters.Name});
            parameters = parameters(order);
            dataNames = [dataNames ; {parameters.Name}'];
        end

        % Build the XML dictionary
        for i=1:length(signals)
            xmlDico = [xmlDico '<syd:signal name="' toXmlAttribute(signals(i).Name) '"' ...
                ' dtype="' toXmlAttribute(signals(i).Value.DataType) '"' ...
                ' min="' num2str(signals(i).Value.Min) '"' ...
                ' max="' num2str(signals(i).Value.Max) '"' ...
                ' units="' toXmlAttribute(signals(i).Value.DocUnits) '"' ...
                ' dim="' mat2str(signals(i).Value.Dimensions) '"' ...
                ' complex="' signals(i).Value.Complexity '"' ...
                ' samptime="' num2str(signals(i).Value.SampleTime) '"' ...
                ' sampmode="' signals(i).Value.SamplingMode '"' ...
                ' initval="' toXmlAttribute(signals(i).Value.InitialValue) '">' ...
                toXmlText(signals(i).Value.Description) '</syd:signal>' char(13) char(10)];
        end
        for i=1:length(parameters)
            xmlDico = [xmlDico '<syd:parameter name="' toXmlAttribute(parameters(i).Name) '"' ...
                ' value="' mat2str(parameters(i).Value.Value) '"' ...
                ' dtype="' toXmlAttribute(parameters(i).Value.DataType) '"' ...
                ' min="' num2str(parameters(i).Value.Min) '"' ...
                ' max="' num2str(parameters(i).Value.Max) '"' ...
                ' units="' toXmlAttribute(parameters(i).Value.DocUnits) '"' ...
                ' dim="' mat2str(parameters(i).Value.Dimensions) '"' ...
                ' complex="' parameters(i).Value.Complexity '">' ...
                toXmlText(parameters(i).Value.Description) '</syd:parameter>' char(13) char(10)];
        end

    end
end

% Close the dictionary
xmlDico = [xmlDico '</syd:dictionary>' char(13) char(10)];