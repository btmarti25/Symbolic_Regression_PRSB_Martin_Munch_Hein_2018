function decodedArray = SR_tree2evalstr(encodedArray,gp,ii)
%CREATED BY AMH 4-18-2017: SR_tree2evalstr Converts encoded tree expressions into math expressions that MATLAB can evaluate directly. BASED ON
%GPTIPS 2 (Copyright (c) 2009-2015 Dominic Searson).

%loop through active function list and replace with function names
for j=1:gp.nodes.functions.num_active
    encodedArray = strrep(encodedArray,gp.nodes.functions.afid(j),gp.nodes.functions.active_name_UC{j});
end

if iscell(encodedArray)
    encodedArray=char(encodedArray);
end
if numel(strfind(encodedArray,'??')) > 0 || numel(strfind(encodedArray,')?'))
    error('?? or )? string shows up in model')
end
 
%AH: find ? token locations and replace with call to covariate matrix
constInd = strfind(encodedArray,'?');
numConstants = numel(constInd);  
%AH: loop through ? token locations and replace with constant values
for k=1:numConstants         
    arg = ['beta(' int2str(k) ')']; 
    %replace token with parameter
    main_tree = extract(constInd(1),encodedArray);
    encodedArray = strrep(main_tree,'$',arg);
    constInd = strfind(encodedArray,'?');
end

%AH:diagnostic to locate common error in model construction. This was
%introduced to fix a bug and may be removeable
if numel(strfind(encodedArray,')b')) > 0 || numel(strfind(encodedArray,')?'))
    error(')beta or )? string shows up in model')
end

decodedArray = lower(encodedArray);