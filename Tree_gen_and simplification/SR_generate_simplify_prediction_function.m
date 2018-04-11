function [parcount, final_function] = SR_generate_simplify_prediction_function(input_model, num_model_coefs, num_model_covars)%(num_gaussians,input_model, num_model_coefs, num_model_covars)
%CREATED BY AMH 4-18-2017: FUNCTION TO TURN INPUT MODEL FROM TREE GENERATOR
%INTO A MODEL INTERPRETABLE BY MATLAB

%restructure input data based on model requrements
covcells = cell(num_model_covars,1);
covcells{1} = 'x1';        %vector of covariate value names
covar_keep = contains(input_model,covcells{1});  %search for covariate in model

if(num_model_covars > 1)
    for i=2:num_model_covars
        covcells{i} = strcat('x',sprintf('%d',i));
        covar_keep = [covar_keep contains(input_model,covcells{i})];
    end
end

covar_indices = (1:num_model_covars);
covar_indices = covar_indices(covar_keep);
outmodel = input_model;

%temporarily add a vector index to each covariate (replaced with matrix
%index below
for i = covar_indices
    repstring   = covcells{i};
    outmodel    = strrep(outmodel,repstring, strcat('X(',sprintf('%d',i), ')'));
end
% for i = covar_indices
%     repstring   = covcells{i};
%     mod    = strrep(mod,repstring, strcat('X(',sprintf('%d',i), ')'));
% end

%define symbolic variables for simplification
X = sym('x%d',[1 num_model_covars]); %define covariates as symbolic variables
if num_model_coefs > 1
    beta = sym('beta%d',[1 num_model_coefs]); %define model coefficients as symbolic variables
else
    beta = sym('beta1');                      %for some reason, vector throws strange value when only one coef is present, this is safer  
end

%outmodel = simplify(eval(sprintf('%s',outmodel)));  %define simplified model
outmodel = eval(sprintf('%s',outmodel));  %define simplified model

if findstr('piece', char(outmodel)) == 1  
outmodel = sym('beta1');
end
if findstr('logbeta', char(outmodel)) == 1
  outmodel = sym('beta1');
end  
if findstr('expbeta', char(outmodel)) == 1
  outmodel = sym('beta1');
end  
% NEW SECTION TO REMOVE UNIDENTIFIABLE PARAMETER PAIRS
%go back into model and remove redundant parameters
betavec = sym2cell(beta);
for zz = 1:length(betavec)
    betavec{zz} = char(betavec{zz});
    if  length(betavec{zz})==5 %BM
    betavec{zz}(6)=" "  ;  
    end
end


parpairs = SR_get_unique_par_pairs(betavec);

%loop over parameter string pairs and reduce to single parameter
%run loop backwards to avoid replacing beta1 before beta10 and end up with
%a 0
for zz = length(parpairs):-1:1
    outmodel = strrep(char(outmodel),parpairs{zz},'?');
end

%loop over parameter set to replace remaining parameters with '?' token
%run loop backwards to avoid replacing beta1 before beta10 and end up with
%a 0
for zz = length(betavec):-1:1
    betavec{zz}=strrep(betavec{zz},' ','');
    outmodel = strrep(char(outmodel),betavec{zz},'?');
end
%BM quick and dirty patch
%custompairs={'? * ? * ? * ? * ?';'? + ? + ? + ? + ?';'? / ? / ? / ? / ?';'? - ? - ? - ? - ?';'?*?*?*?*?';'?+?+?+?+?';'?/?/?/?/?';'?-?-?-?-?';'? * ? * ? * ?';'? + ? + ? + ?';'? / ? / ? / ?';'? - ? - ? - ?';'?*?*?*?';'?+?+?+?';'?/?/?/?';'?-?-?-?';'? * ? * ?';'? + ? + ?';'? / ? / ?';'? - ? - ?';'?*?*?';'?/?/?';'?+?+?';'?-?-?'; '? + ?' ; '? * ?'; '? - ?';'? / ?'}; 
endpair={'??'};
tokenpairs = SR_get_unique_par_pairs({' ? ','(?)'});%generate unique token combinations
tokenpairs=[tokenpairs;endpair];
%tokenpairs=[custompairs;tokenpairs;endpair];
%loop over outmodet to replace remaining functions of '?' token with single
%instance of '?'
while SR_cell_in_string(outmodel,tokenpairs) > 0
    for zz = 1:length(tokenpairs)
        outmodel = strrep(char(outmodel),tokenpairs{zz},'?');
        outmodel = strrep(char(outmodel),tokenpairs{zz},'?');
    end
end

 % outmodel = strrep(char(outmodel),betavec{zz},'?');
% end

%renumber parameters
parcount = numel(strfind(outmodel,'?'));

for zz = 1:parcount
    repstring = strcat('beta',sprintf('%d',zz));
    firstocc = strfind(outmodel,'?'); %find index of first token occurrence
    firstocc = firstocc(1);
    outmodel = sprintf([outmodel(1:(firstocc -1)),repstring ,outmodel((firstocc + 1):end)]);
end

%end  NEW SECTION TO REMOVE UNIDENTIFIABLE PARAMETER PAIRS

%loop through operators to be sure all are element-wise
outmodel1 = strrep(char(outmodel), '^','.^');
outmodel2 = strrep(outmodel1, '*','.*');
outmodel3 = strrep(outmodel2, '/','./');
outmodel  = outmodel3;

%AMH: UNCOMMENT TO DISPLAY ATTEMPT TO SIMPLIFY MESSAGE
%display('Attempted simplify on outmodel')

%clear X variable from the global workspace
clearvars X

%replace vector covariate index with matrix index
for i = covar_indices
    repstring   = covcells{i};
    outmodel    = strrep(outmodel,repstring, strcat('X(:,',sprintf('%d',i), ')'));    
end

%clear beta variable from global environment
clearvars beta

%replace beta values with reference to parameter vector
for i = parcount:-1:1
    repstring = strcat('beta',sprintf('%d',i));
    outmodel  = strrep(outmodel,repstring,strcat('beta(',sprintf('%d',i), ')'));
end

final_function = str2func(strcat('@(beta, X) ',  sprintf('%s',outmodel))); %output function
