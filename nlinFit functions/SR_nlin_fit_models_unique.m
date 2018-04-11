function [ gp ] = SR_nlin_fit_models_unique( gp)
%SR_NLIN_FIT_MODELS Summary of this function goes here
%   Detailed explanation goes here
errormodel=gp.runcontrol.fitnessfunc ; 
nruns=5;
c=strings(length(gp.models.predfuncset),1);
for i=1:length(gp.models.predfuncset) 
c{i,1} = func2str(gp.models.predfuncset{i});
end
[~ ,~ ,idx] = unique(c(:,1));
unique_idx = accumarray(idx(:),(1:length(idx))',[],@(x) {sort(x)});

for i=1:length(unique_idx)
 
    mod_num=unique_idx{i}(1);
   % beta= 10*(rand(nruns,gp.models.num_coefs{mod_num,1})-.5);
    beta= (exp(log10(100000)*rand(nruns,gp.models.num_coefs{mod_num,1}))-1).* sign(rand(nruns,gp.models.num_coefs{mod_num,1})-.5);
    model=gp.models.predfuncset{mod_num,1};    

    for j=1:nruns
    [gp.models.coefs{unique_idx{i}(1),j}, gp.models.fit{unique_idx{i}(1),j}]=fmingrad_Rprop(beta(j,:),model,gp.xtrain,gp.ytrain,errormodel);
    end
    
    for ii=1:length(unique_idx{i})
    [gp.fitness.values(unique_idx{i}(ii),1), index]=min(cell2mat(gp.models.fit(unique_idx{i}(1),:)));
    gp.models.best_coefs{unique_idx{i}(ii),1}=gp.models.coefs{unique_idx{i}(1),index};
    end
end

