function bytes = toXmlAttribute(text)
%TOXMLATRRIBUTE Convert a string to an XML UTF-8 attribute byte array.
%   TOXMLATRRIBUTE('TEXT') converts the specified string to a char array
%   usable as an attribute in an UTF-8 XML document.

% Copyright (c) 2011 LeanPulse. All rights reserved.
% 
% Author: Aurélien PROST (a.prost@leanpulse.com)

text = strrep(text,'&','&amp;');
text = strrep(text,'<','&lt;');
text = strrep(text,'>','&gt;');
text = strrep(text,'"','&quot;');
text = strrep(text,'''','&apos;');
text = strrep(text,char(173),char(45)); %Ensure soft hyphen replaced by ASCII one
bytes = unicode2native(text, 'UTF-8');