function [ output_args ] = delete_model(gp,model_num)
%DELETE_MODEL Summary of this function goes here
%   Detailed explanation goes here

[xs, index] = sort(gp.fitness.values);

model_num=1
[i ii]=find(index==model_num)

gp.fitness.values(i)

end
OrderedModels{10896}
OrderedFitness(10896)=100000000;
OrderedCoefs=gp.models.best_coefs(index);


figure
 SSQ=sum((ytrain-mean(ytrain)).^2);
 scatter(OrderdNcoef,OrderedFitness/SSQ)
 ylim([0,1])
