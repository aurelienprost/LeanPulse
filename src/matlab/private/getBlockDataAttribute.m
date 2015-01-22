function value = getBlockDataAttribute(objH, inUserData, attrName)
%GETBLOCKDATAATTRIBUTE Get the value of an XML attribute stored in the userdata or description of a block.
%   value = GETBLOCKDATAATTRIBUTE(OBJH, INUSERDATA, 'ATTRNAME') returns the
%   value of the attribute whose name is ATTRNAME, in the XML string
%   contained in the UserData or Description field of the block whose
%   handle is OBJH.
%
%   See also SETBLOCKDATAATTRIBUTE.

% Copyright (c) 2011 LeanPulse. All rights reserved.
% 
% Author: Aurélien PROST (a.prost@leanpulse.com)

if inUserData
    field = 'UserData';
else
    field = 'Description';
end

data = get_param(objH,field);
if ~isempty(data)
    try
        dataDOM = xmlread(org.xml.sax.InputSource(java.io.StringReader(data)));
        value = char(dataDOM.getDocumentElement.getAttribute(attrName));
    catch
        value = '';
    end
else
    value = '';
end