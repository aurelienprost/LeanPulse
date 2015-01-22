function xmlExtraData = extractExtraData(objH, field, params)
    xmlExtraData = '';
    data = get_param(objH, field);
    if strncmp(data,'<syd:',5)
        xmlExtraData = [unicode2native(data,'UTF-8') char(13) char(10)];
    end
end