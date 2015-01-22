function xml = convLatexToXml(latex)
    if isempty(latex)
        xml = '';
        return;
    end
    latex = toLatexDoc(latex);
    texFile = strrep([tempname '.tex'],'\','/');
    texFileId = fopen(texFile, 'w');
    fwrite(texFileId, unicode2native(latex, 'UTF-8'), 'uint8');
    fclose(texFileId);
    tralicsPath = strrep(char(com.leanpulse.syd.internal.Utils.getAbsolutePath('lib\tralics.exe')),'\','/');
    setenv('CYGWIN','nodosfilewarning');
    [status result] = dos(['"' tralicsPath '" -confdir "' tralicsPath '/../tralics-conf" -input_file "' texFile '" -utf8output -noentnames -trivialmath=7']);
    delete(texFile);
    if status == 0 || status == 2
        texmlFile = [texFile(1:end-3) 'xml'];
        xml = readXml(texmlFile, 'tex', 'UTF-8');
        delete(texmlFile);
        delete([texFile(1:end-3) 'log']);
    else
        xml = '';
        warning('SYD:commentConversionFailed',['SYD Generator: LaTeX comment conversion failed !!' char(10) ...
                '> Cause: ' result]);
    end
end