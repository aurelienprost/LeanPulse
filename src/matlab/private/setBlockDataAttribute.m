function setBlockDataAttribute(objH, inUserData, attrName, attrValue)
%SETBLOCKDATAATTRIBUTE Set the value of an XML attribute stored in the userdata or description of a block.
%   GETBLOCKDATAATTRIBUTE(OBJH, INUSERDATA, 'ATTRNAME', 'ATTRVALUE') sets
%   to ATTRVALUE the value of the attribute whose name is ATTRNAME, in the
%   XML string contained in the UserData or Description field of the block
%   whose handle is OBJH.
%
%   See also SETBLOCKDATAATTRIBUTE.

% Copyright (c) 2011 LeanPulse. All rights reserved.
% 
% Author: Aurélien PROST (a.prost@leanpulse.com)


if inUserData
    field = 'UserData';
    set_param(objH,'UserDataPersistent','on');
else
    field = 'Description';
end

data = get_param(objH,field);
if isempty(data)
    [dataDOM dataRootNode] = localCreateBlankData();
else
    try
        dataDOM = xmlread(java.io.InputSource(java.io.StringReader(data)));
        dataRootNode = dataDOM.getDocumentElement();
        if ~strcmp(dataRootNode.getAttribute('xmlns:syd'), 'http://www.leanpulse.com/schemas/syd/2011/core')
            % Conversion to implement if new schema
        end
    catch
        [dataDOM dataRootNode] = localCreateBlankData();
    end
end
dataRootNode.setAttribute(attrName,attrValue)

% Serialize the DOM object to a string.
domSource = javax.xml.transform.dom.DOMSource(dataDOM);
writer = java.io.StringWriter();
result = javax.xml.transform.stream.StreamResult(writer);
tf = javax.xml.transform.TransformerFactory.newInstance();
transformer = tf.newTransformer();
transformer.setOutputProperty(javax.xml.transform.OutputKeys.METHOD, 'xml');
transformer.setOutputProperty(javax.xml.transform.OutputKeys.ENCODING, 'UTF-8');
transformer.setOutputProperty(javax.xml.transform.OutputKeys.INDENT, 'no');
transformer.setOutputProperty(javax.xml.transform.OutputKeys.OMIT_XML_DECLARATION, 'yes');
transformer.transform(domSource, result);

set_param(objH,field, char(writer.toString()));


function [dataDOM dataRootNode] = localCreateBlankData()
dataDOM = com.mathworks.xml.XMLUtils.createDocument('syd:extradata');
dataRootNode = dataDOM.getDocumentElement();
dataRootNode.setAttribute('xmlns:syd', 'http://www.leanpulse.com/schemas/syd/2011/core');