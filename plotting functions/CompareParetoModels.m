function [  ] = CompareParetoModels(gp,OrderedModels,OrderedCoefs, xtrain,UniqOrderedNCoef_countMethod)



[n_rows n_vars ]=size(xtrain);


% for i=1:gp.runcontrol.pop_size 
% OrderdNcoef(i,1)=length(OrderedCoefs{i});
% end

OrderdNcoef=UniqOrderedNCoef_countMethod;


for j=1:8
indx=(OrderdNcoef ==  j);
k(j)=find(OrderdNcoef==j,1);
end

[ind best_coef]=min(k);
figure
for i=1:n_vars
   xdata=repmat(mean(xtrain),n_rows,1);
   xdata(:,i)=xtrain(:,i);
   for j=1:8
       
       pred=OrderedModels{k(j)}(OrderedCoefs{k(j)},xdata);
       subplot(2,2,i)
       hold on
       [xsort ind] =sort(xdata(:,i));
       plot(xsort,pred(ind),'-o')
      % scatter(xdata(:,i),pred)
       legend('show')
   end    
end

end


