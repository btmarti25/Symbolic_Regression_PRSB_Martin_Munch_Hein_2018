function [  ] = CompareModelPreds(OrderedModels,OrderedCoefs, xtrain, n_models )



[n_rows n_vars ]=size(xtrain);
for i=1:length(OrderedModels) 
c{i,1} = func2str(OrderedModels{i});
end

[Order,indx] = unique(c);
UniqOrderedModelStr = c(sort(indx));
UniqOrderedCoef= OrderedCoefs(sort(indx));

for i=1:length(UniqOrderedModelStr)
UniqOrderedModels{i,1}=str2func(UniqOrderedModelStr{i});
end

figure
for i=1:n_vars
   xdata=repmat(mean(xtrain),n_rows,1);
   xdata(:,i)=xtrain(:,i);
   for j=1:n_models
       
       pred=UniqOrderedModels{j}(UniqOrderedCoef{j},xdata);
       subplot(2,2,i)
       hold on
       scatter(xdata(:,i),pred)
   end    
end


end

