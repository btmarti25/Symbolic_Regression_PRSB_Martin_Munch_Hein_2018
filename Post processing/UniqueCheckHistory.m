%load('gpDidinium.mat')

filename = "LPA_square_root_transformed_outOfSample"


%state whether to count parameters reducing dimension or not
count_parameters = 1;

    [xs, index] = sort(gp.history.fitness);

    OrderedModels=gp.history.models(index);
    OrderedFitness=gp.history.fitness(index);
    OrderedCoefs=gp.history.coefs(index);

    [n_rows n_vars ]=size(gp.xtrain);
    for i=1:length(OrderedModels) 
    c{i,1} = func2str(OrderedModels{i});
    end
   


    [Order,indx] = unique(c);
    UniqOrderedModelStr = c(sort(indx));
    UniqOrderedCoef= OrderedCoefs(sort(indx));
    UniqOrderedFitness= OrderedFitness(sort(indx));

     UniqOrderedModelStr = UniqOrderedModelStr(isfinite(UniqOrderedFitness));
    UniqOrderedCoef= UniqOrderedCoef(isfinite(UniqOrderedFitness));
    UniqOrderedFitness= UniqOrderedFitness(isfinite(UniqOrderedFitness));

 
    for i=1:length(UniqOrderedModelStr)
    UniqOrderedModels{i,1}=str2func(UniqOrderedModelStr{i});
    end


for i=1:length(UniqOrderedModelStr)
UniqOrderedNCoef(i,1)=length(UniqOrderedCoef{i});
end
 
%   for i=1:length(UniqOrderedModelStr)
%   UniqOrderedNCoef_countMethod(i,1)=Count_parameters(UniqOrderedModelStr{i},UniqOrderedCoef{i});
%   end

if count_parameters == 1
    for i=1:length(UniqOrderedModelStr)
     [UniqOrderedNCoef_countMethod(i,1), ] =CountParms(UniqOrderedModelStr{i},gp.xtrain,gp.data.num_covars, UniqOrderedCoef{i});
     end


      for i=1:length(UniqOrderedModelStr)
     UniqOrderedNCoef_min(i,1)=min(UniqOrderedNCoef_countMethod(i,1),UniqOrderedNCoef(i,1));
      end
end

 
figure
SSQ=sum((gp.ytrain.^.5-mean(gp.ytrain.^.5)).^2);

gp.history.UniqOrderedR2 = 1-UniqOrderedFitness/SSQ;

if count_parameters == 1
    gp.history.UniqOrderedNCoef_min = UniqOrderedNCoef_min;
    gp.frontdata.Nparam             = gp.history.UniqOrderedNCoef_min;
    scatter(UniqOrderedNCoef_min,1-UniqOrderedFitness/SSQ)
    ylim([0,1])
end

gp.frontdata.R2                 = gp.history.UniqOrderedR2;
gp.frontdata.UniqOrderedModels  = UniqOrderedModels;
gp.frontdata.param_values       = UniqOrderedCoef;
gp.frontdata.UniqueOrderedFitness = UniqOrderedFitness;
save(filename,"gp")

% 
% UniqOrderedAIC=2*UniqOrderedNCoef + 600* log(UniqOrderedFitness/600);
% 
% bestAIC=min(UniqOrderedAIC)
% 
% UniqOrdereddeltaAIC=bestAIC-UniqOrderedAIC
% 
% UniqOrderedwAIC=exp(.5*UniqOrdereddeltaAIC)
% 
% %sumweights=    sum(UniqOrderedwAIC(1:8000))
% %UniqOrderedwwAIC=UniqOrderedwAIC/sumweights