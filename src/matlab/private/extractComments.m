function xmlComments = extractComments(sysH, path, followLinks, lookUnderMasks, params)

xmlComments = '';

if sysH < 0 % The extraction is finished
    
    localWordUtils('closeInstance');
    
    
else        % Extracts comments
    
    xpath = toXmlAttribute(path);
    count = 0;
    
    % Add comments from description
    des = get_param(sysH,'Description');
    if ~isempty(des)
        xmlComments = [xmlComments '<syd:comment id="' xpath '#' num2str(count) '" name="Description" type="text">' char(13) char(10) ...
            '<syd:text>' toXmlText(des) '</syd:text>' char(13) char(10) ...
            '</syd:comment>' char(13) char(10)];
        count = count + 1;
    end

    % Add comments from docblocks
    if followLinks
        if lookUnderMasks
            comments = find_system(sysH,'SearchDepth', 1, 'FollowLinks', 'on', 'LookUnderMasks','all', 'MaskType', 'DocBlock');
        else
            comments = find_system(sysH,'SearchDepth', 1, 'FollowLinks', 'on', 'LookUnderMasks','none', 'MaskType', 'DocBlock');
        end
    else
        if lookUnderMasks
            comments = find_system(sysH,'SearchDepth', 1, 'FollowLinks', 'off', 'LookUnderMasks','all', 'MaskType', 'DocBlock');
        else
            comments = find_system(sysH,'SearchDepth', 1, 'FollowLinks', 'off', 'LookUnderMasks','none', 'MaskType', 'DocBlock');
        end
    end
    for i = 1:length(comments)
        try
            switch get_param(comments(i),'DocumentType')
                case 'Text'
                    text = docblock('getContent',comments(i));
                    xmlComments = [xmlComments '<syd:comment id="' xpath '#' num2str(count) '" name="' toXmlAttribute(get_param(comments(i),'Name')) '" type="text">' char(13) char(10) ...
                        extractExtraData(comments(i), 'Description', params) ...
                        '<syd:text>' toXmlText(text) '</syd:text>' char(13) char(10) ...
                    	'</syd:comment>' char(13) char(10)];
                otherwise
                    hWord = localWordUtils('getInstance');
                    if ~isempty(hWord)
                        comFileName = docblock('getBlockFileName',comments(i));
                        if ~exist(comFileName,'file')
                            docblock('blk2file',comments(i),comFileName); %the file does not exist - create it
                        end
                        wordMlFile = [comFileName(1:end-4) '.xml'];
                        hDoc = hWord.documents.Add(comFileName);
                        try
                            hDoc.SaveAs2(wordMlFile,11); % This will work on Word 2010.
                        catch
                            hDoc.SaveAs(wordMlFile,11);
                        end
                        hDoc.Close;
                        wordml = readXml(wordMlFile, '', 'UTF-8');
                        delete(wordMlFile);
                        xmlComments = [xmlComments '<syd:comment id="' xpath '#' num2str(count) '" name="' toXmlAttribute(get_param(comments(i),'Name')) '" type="wordml">' char(13) char(10) ...
                            extractExtraData(comments(i), 'Description', params) ...
                            wordml ...
                            '</syd:comment>' char(13) char(10)];
                    else
                        warning('SYD:commentConversionNotAvailable',['SYD Generator: ' ...
                            'comment conversion not available (MS Word not installed), content skipped on DocBlock "' getfullname(comments(i)) '".']);
                    end
            end
            count = count + 1;
        catch exception
            warning('SYD:commentConversionFailed',['SYD Generator: comment conversion failed on DocBlock "' getfullname(comments(i)) '" !!' char(10) ...
                '> Cause: ' exception.message]);
        end

    end
end


function hWord = localWordUtils(command)
persistent hWordInstance;
if strcmp(command, 'getInstance')
    if isempty(hWordInstance)
        try
            hWordInstance = actxserver('word.application');
            hWordInstance.Visible = 0; %Hide Word
            hWord = hWordInstance;
        catch
            hWord = [];
        end
    else
        hWord = hWordInstance;
    end
else
    if ~isempty(hWordInstance)
        hWordInstance.Quit;
        hWordInstance.release;
        clear hWordInstance;
    end
end