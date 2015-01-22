function bytes = toXmlText(text)
%TOXMLTEXT Convert a string to an XML UTF-8 text byte array.
%   TOXMLTEXT('TEXT') converts the specified string to a char array
%   usable as an text element in an UTF-8 XML document.

% Copyright (c) 2011 LeanPulse. All rights reserved.
% 
% Author: Aurélien PROST (a.prost@leanpulse.com)

text = strrep(text,'&','&amp;');
text = strrep(text,'<','&lt;');
text = strrep(text,'>','&gt;');
bytes = unicode2native(text, 'UTF-8');