function treestr = SR_treegen(gp,fixedDepth)
%%CREATED BY AMH 4-18-2017: CODE TO GENERATE TREES AND CREATE SYMBOLIC
%%MODEL FROM TREE. BASED ON GPTIPS 2 (Copyright (c) 2009-2015 Dominic Searson).

%Dominic Searson: Check input arguments for depth overide parameter
if nargin < 2
    fixedDepth = 0;
end

%Dominic Searson: extract parameters from gp structure
maxDepth = gp.treedef.max_depth;          %will use user max depth unless overridden by input argument
buildMethod = gp.treedef.build_method;    %1=full 2=grow 3=ramped 1/2 and 1/2
p_ERC = gp.nodes.const.p_ERC;             %terminal config. [0=no constants, 0.5=half constants half inputs 1=no inputs]
num_inp = gp.nodes.inputs.num_inp;

afid_argt0  = gp.nodes.functions.afid_argt0; %functions with arity>0
afid_areq0  = gp.nodes.functions.afid_areq0; %functions with arity=0;
arity_argt0 = gp.nodes.functions.arity_argt0; %arities of functions
fun_lengthargt0 = gp.nodes.functions.fun_lengthargt0;
fun_lengthareq0 = gp.nodes.functions.fun_lengthareq0;

%Dominic Searson: if a fixed depth tree is required use 'full' build method
if fixedDepth
    maxDepth = max(fixedDepth,1);
    buildMethod = 1;
end

%Dominic Searson: if using ramped 1/2 and 1/2 then randomly choose max_depth and
%build_method
if buildMethod == 3
    maxDepth = ceil(rand * gp.treedef.max_depth);
    buildMethod = ceil(rand * 2);  %set either to 'full' or 'grow' for duration of function
end

%Dominic Searson: initial string structure (nodes/subtrees to be built are marked with the $
%token)
treestr = '($)';

%AH: get encoding for times operator. This is used later in the code to
%ensure dimensional consistency
times_code = gp.nodes.functions.afid(find(ismember(gp.nodes.functions.name, 'times')));

%Dominic Searson: recurse through branches
while true
    
    %find leftmost node token $ and store string position
    nodeTokenInd = strfind(treestr,'$');
    
    %breakout if no more nodes to fill
    if isempty(nodeTokenInd)
        break
    end
    
    %get next node position and process it
    nodeToken = nodeTokenInd(1);
    
    %replace this node token with 'active' node token, @
    treestr(nodeToken) = '@';
    
    %count brackets from beginning of string to @ to work out depth of @
    left_seg = treestr(1:nodeToken);
    numOpen = numel(strfind(left_seg,'('));
    numClosed = numel(strfind(left_seg,')'));
    depth = numOpen - numClosed;
    
    %Dominic Searson: choose type of node to insert based on depth and building method. If
    %root node then pick a non-terminal node (unless otherwise specified).
    if depth == 1
        nodeType = 1; % 1=internal 2=terminal 3=either
        if maxDepth == 1 %but if max_depth is 1 must always pick a terminal
            nodeType = 2;
        end
        
        %Dominic Searson: if less than max_depth and method is 'full' then only pick a
        %function with arity>0
    elseif buildMethod == 1 && depth < maxDepth
        nodeType = 1;
    elseif depth >= maxDepth % if depth is max_depth then just pick terminals
        nodeType = 2;
    else %pick either with equal prob.
        nodeType = ceil(rand * 2);
    end
    
    if nodeType == 1 %i.e a function with arity>0
        funChoice = ceil(rand * fun_lengthargt0);
        funName = afid_argt0(funChoice);
        numFunArgs = arity_argt0(funChoice);
        
        %Dominic Searson: create appropriate replacement string e.g. a($,$) for 2 argument
        %function
        funRepStr = [funName '($'];
        if numFunArgs > 1
            for j=2:numFunArgs
                funRepStr = [funRepStr ',$'];
            end
            funRepStr = [funRepStr ')'];
        else % for single argument functions
        
            %AH 6-2-2017: add hack to multiply by a parameter if a log or exponential is
            %the function applied

            if ismember(gp.nodes.functions.name{funChoice}, {'log' 'exp'})
                %any(funName == gp.nodes.functions.afid( ismember({'log' 'exp'}, gp.nodes.functions.name) )
                funRepStr = [times_code '(?,' funName '($))'];
            else
                funRepStr = [funName '($)'];
            end
            
        end
        %Dominic Searson: replace active node token @ with replacement string
        treestr = strrep(treestr,'@',funRepStr);

    elseif nodeType == 2 %pick a terminal (or an arity 0 function, if active)
        
        %Dominic Searson: choose a function or input with equal probability
        if fun_lengthareq0 && (rand >= 0.5 || (num_inp==0 && p_ERC==0))
            
            funChoice = ceil(rand * fun_lengthareq0);
            funName = afid_areq0(funChoice);
            
            %create appropriate replacement string for 0 arity function
            funRepStr = [funName '()'];
            
            %now replace active node token @ with replacement string
            treestr = strrep(treestr,'@',funRepStr);
            
        else %choose an input (if it exists) or
            %check if ERCs are switched on, if so pick a ERC
            %node/arithmetic tree token with p_ERC prob.
            term = false;
            
            if rand >= p_ERC
                term = true;
            end
            
            if term %then use an ordinary terminal not a constant
                inpChoice = ceil(rand * num_inp);
                %treestr = strrep(treestr,'@',['x' sprintf('%d',inpChoice)]);
                treestr = strrep(treestr,'@',[times_code '(?,x' sprintf('%d',inpChoice) ')'] );%BM 
            else %use an ERC token (? character)
                treestr = strrep(treestr,'@','?');
                ERCgenerated = true;
            end
        end
        
    end
    
end

%AMH: constant processing -- compress functions of constants to single constant
%find '(?,?)' and '(?)' locations and replace with appropriate model
%coefficients
treegen_input = treestr;

while numel(strfind(treestr,'(?,?)')) > 0 || numel(strfind(treestr,'(?)')) > 0
    
    %check to be sure model does not contain single constant
    if numel(treestr) == 3
        %display('Model contains a single constant, breaking!!!')
        break
    end
    
    %AMH: UNCOMMENT TO DISPLAY WARNING
    %display('WARNING!!! COMPRESSING CONSTANTS. THIS WILL ONLY WORK FOR ARITY <= 2 FUNCTIONS')

    numConstPairs = numel(strfind(treestr,'(?,?)'));
    while numConstPairs > 0
        strlocs     = strfind(treestr,'(?,?)');
        strstart     = strlocs(1);                               %keep only first occurrence of (?,?) string
        clipstring  = treestr((strstart-1):(strstart+4));
        treestr     = strrep(treestr,clipstring,'?');
        numConstPairs = numel(strfind(treestr,'(?,?)'));
        if numel(strfind(treestr,'(?,?)')) == 0  || numel(treestr) == 3             %break out of loop if all '(?,?)' strings have been replaced
            break
        end
    end

    %check to be sure model does not contain single constant
     if numel(treestr) == 3
%         display('Model contains a single constant, breaking!!!')
        break
    end
%     
    %AMH: uncomment to print for diagnostics
    %display(treestr)
    
    numConstPairs = numel(strfind(treestr,'(?)'));
    while numConstPairs > 0
        strlocs     = strfind(treestr,'(?)');
        strstart     = strlocs(1);                               %keep only first occurrence of (?) string
        clipstring  = treestr((strstart-1):(strstart+2));
        treestr     = strrep(treestr,clipstring,'?');
        numConstPairs = numel(strfind(treestr,'(?)'));
        if numel(strfind(treestr,'(?)')) == 0  || numel(treestr) == 3               %break out of loop if all '(?)' strings have been replaced
            break
        end
    end
%uncomment to print for diagnostics
    %display(treestr)
end

%display(treestr)
if numel(strfind(treestr,'??')) > 0 || numel(strfind(treestr,')?'))
    error('?? or )? string shows up in model')
end


%strip off outside brackets
treestr = treestr(2:end-1);