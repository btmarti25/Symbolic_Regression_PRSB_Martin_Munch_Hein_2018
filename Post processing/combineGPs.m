gp.frontdata.Nparam=vertcat(gp1.frontdata.Nparam,gp2.frontdata.Nparam,gp3.frontdata.Nparam);
gp.frontdata.R2=vertcat(gp1.frontdata.R2,gp2.frontdata.R2,gp3.frontdata.R2);
gp.frontdata.UniqOrderedModels=vertcat(gp1.frontdata.UniqOrderedModels,gp2.frontdata.UniqOrderedModels,gp3.frontdata.UniqOrderedModels);
gp.frontdata.param_values=vertcat(gp1.frontdata.param_values,gp2.frontdata.param_values,gp3.frontdata.param_values);
gp.frontdata.UniqueOrderedFitness=vertcat(gp1.frontdata.UniqueOrderedFitness,gp2.frontdata.UniqueOrderedFitness,gp3.frontdata.UniqueOrderedFitness);



    [n_rows n_vars ]=size(gp.xtrain);
    for i=1:length(gp.frontdata.UniqOrderedModels) 
    c{i,1} = func2str(gp.frontdata.UniqOrderedModels{i});
    end
   

    [Order,indx] = unique(c);
    gp.frontdata.UniqOrderedModels = c(sort(indx));
    gp.frontdata.param_values= gp.frontdata.param_values(sort(indx));
    gp.frontdata.R2= gp.frontdata.R2(sort(indx));
    gp.frontdata.Nparam= gp.frontdata.Nparam(sort(indx));
    gp.frontdata.UniqueOrderedFitness= gp.frontdata.UniqueOrderedFitness(sort(indx));
    
     UniqOrderedModelStr = UniqOrderedModelStr(isfinite(UniqOrderedFitness));
    UniqOrderedCoef= UniqOrderedCoef(isfinite(UniqOrderedFitness));
    UniqOrderedFitness= UniqOrderedFitness(isfinite(UniqOrderedFitness));