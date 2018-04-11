function gp = SR_tree_model_init(gp)
%CREATED BY AMH 4-18-2017: SR_TREE_MODEL_INIT INITIALIZES A RUN. BASED ON
%GPTIPS 2 (Copyright (c) 2009-2015 Dominic Searson).

%Dominic Searson: loop through function nodes and generate arity list
for i = 1:length(gp.nodes.functions.name)
    
    arity = nargin(gp.nodes.functions.name{i});
    
    %Dominic Searson: some functions have a variable number of input arguments (e.g. rand)
    %In this case generate an error message and exit
    if arity == -1
        error(['The function ' gp.nodes.functions.name{i} ...
            ' may not be used (directly) as a function node because it has a variable number of arguments.']);
    end
    
    gp.nodes.functions.arity(i) = arity;
end

%Dominic Searson: Generate single char Active Function IDentifiers (afid)(a->z excluding
%x,e,i,j) to stand in for function names whilst processing expressions.
%Exclusions are because 'x' is reserved for input nodes, 'e' is used for
%expressing numbers in standard form by Matlab and, by default, 'i' and 'j'
%represent sqrt(-1).
charnum = 96; skip = 0;
for i=1:numel(gp.nodes.functions.name)
    while true      %e                          %i                    %j                         %x
        if (charnum+i+skip)==101 || (charnum+i+skip)==105 || (charnum+i+skip)==106 || (charnum+i+skip)==120
            skip = skip + 1;
        else
            break
        end
        
    end
    afid(i) = char(charnum+i+skip);
end

%Dominic Searson: extract upper case active function names for later use
gp.nodes.functions.afid = afid;
temp = cell(gp.nodes.functions.num_active,1);

if numel(gp.nodes.functions.name) ~= numel(gp.nodes.functions.active)
    error('There must be the same number of entries in gp.nodes.functions.name and gp.nodes.functions.active. Check your config file.');
end

[temp{:}] = deal(gp.nodes.functions.name{gp.nodes.functions.active});
[gp.nodes.functions.active_name_UC] = upper(temp);

%Dominic Searson: generate index locators for arity >0 and arity == 0 active functions. The
%treegen function needs his info later for identifying which functions are
%terminal and which are internal nodes.
active_ar = (gp.nodes.functions.arity(gp.nodes.functions.active));
fun_argt0 = active_ar > 0;
fun_areq0 =~ fun_argt0;

gp.nodes.functions.afid_argt0 = gp.nodes.functions.afid(fun_argt0); %functions with arity > 0
gp.nodes.functions.afid_areq0 = gp.nodes.functions.afid(fun_areq0); %functions with arity == 0
gp.nodes.functions.arity_argt0 = active_ar(fun_argt0);

gp.nodes.functions.fun_lengthargt0 = numel(gp.nodes.functions.afid_argt0);
gp.nodes.functions.fun_lengthareq0 = numel(gp.nodes.functions.afid_areq0);



