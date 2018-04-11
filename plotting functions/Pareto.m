function [ Pareto ] = Pareto( gp )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

[xs, index] = sort(gp.fitness.values);
OrderedModels=gp.models.predfuncset(index);
OrderedCoefs=gp.models.best_coefs(index);


for i=1:gp.runcontrol.pop_size 
OrderdNcoef(i,1)=length(OrderedCoefs{i});
end

for j=1:max(OrderdNcoef)
indx=(OrderdNcoef ==  j);
    if isempty(find(OrderdNcoef==j,1))
        k(j)=k(j-1) ; 
    else
        k(j)=find(OrderdNcoef==j,1);
end
end
Pareto{:}=OrderedModels(k);

end

