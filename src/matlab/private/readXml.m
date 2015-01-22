function xml = readXml(xmlFile, prefix, encoding)
    fid = fopen(xmlFile,'r','l',encoding);
    try
        xml = fread(fid,'*char')';
    catch exception
        try
            fclose(fid);
        end
        rethrow(exception);
    end
    fclose(fid);
    xml = xml(regexp(xml,'<\w+','once'):end); % Remove declarations
    if ~isempty(prefix)
        xml = regexprep(xml,' (xmlns=["''][^"'']*["''])','','once'); % Remove main namespace
        xml = strrep(xml,'<',['<' prefix ':']); % Add prefix to all opening tags
        xml = strrep(xml,['<' prefix ':/'],['</' prefix ':']); % Add prefix to all closing tags
    end
    xml = char(unicode2native(xml,encoding));
end