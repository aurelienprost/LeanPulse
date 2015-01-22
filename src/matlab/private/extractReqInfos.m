function xmlReqInfos = extractReqInfos(objH, isSimObj, lookInside, childHs, params)

if isSimObj
    
    blocksWithReq = [];
    
    if lookInside
        blocksWithReq = find_system(objH,'RegExp','on','SearchDepth', 1,'FollowLinks','on','LookUnderMasks','all','RequirementInfo','.+');
        blocksWithReq = blocksWithReq(~ismember(blocksWithReq,childHs)); % Filter out children
    else
        if ~isempty(get_param(objH,'RequirementInfo'))
            blocksWithReq = objH;
        end
    end
    
    if ~isempty(blocksWithReq)
        xmlReqInfos = ['<syd:reqinfos>' char(13) char(10)];
        for i=1:length(blocksWithReq)
            xmlReqInfos = [xmlReqInfos '<syd:req from="' toXmlAttribute(getfullname(blocksWithReq(i))) '">' ...
                toXmlText(get_param(blocksWithReq(i),'RequirementInfo')) '</syd:req>' char(13) char(10)];
        end
        xmlReqInfos = [xmlReqInfos '</syd:reqinfos>' char(13) char(10)];
    else
        xmlReqInfos = '';
    end
    
else %Stateflow Obj

    sfObj = sf('IdToHandle', objH);
    sfobjsWithReq = [];
    
    if lookInside
        sfobjsWithReq = sfObj.find('-depth',1,'-regexp','RequirementInfo','.+');
        toKeep = true(length(sfobjsWithReq),1);
        for i=1:length(sfobjsWithReq)
            toKeep(i) = ~ismember(sfobjsWithReq(i).Id,childHs);
        end
        sfobjsWithReq = sfobjsWithReq(toKeep);
    else
        if isfield(sfObj,'RequirementInfo') && ~isempty(sfObj.RequirementInfo)
            sfobjsWithReq = objH;
        end
    end
    
    if ~isempty(sfobjsWithReq)
        xmlReqInfos = ['<syd:reqinfos>' char(13) char(10)];
        for i=1:length(sfobjsWithReq)
            if isprop(sfobjsWithReq(i),'Path') && isprop(sfobjsWithReq(i),'Name')
                fullpath = [sfobjsWithReq(i).Path '/' sfobjsWithReq(i).Name];
            else
                fullpath = [class(sfobjsWithReq(i)) '/' num2str(sfobjsWithReq(i).Id)];
            end
            xmlReqInfos = [xmlReqInfos '<syd:req from="' toXmlAttribute(fullpath) '">' ...
                toXmlText(sfobjsWithReq(i).RequirementInfo) '</syd:req>' char(13) char(10)];
        end
        xmlReqInfos = [xmlReqInfos '</syd:reqinfos>' char(13) char(10)];
    else
        xmlReqInfos = '';
    end
    
end



