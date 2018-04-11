function [ SSQ ] = SR_fitness_calc(beta, model,xtrain,ytrain,errormodel )
%SR_FITNESS_CALC Summary of this function goes here

    if errormodel  == 1
    penalized_deviations            = ytrain - model(beta, xtrain);%AH: added to introduce penalty for imaginary numbers
     else
    penalized_deviations            = ytrain.^(.5) - (model(beta, xtrain)).^(.5) ;
    end
    SSQ                             = sum((penalized_deviations).^2);
    if (isreal(SSQ) == 0 || isnan(SSQ))
            SSQ = 1e20;
    end
end

