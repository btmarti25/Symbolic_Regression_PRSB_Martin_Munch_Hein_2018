function [coefs, fit ] = getPrediction(beta,model,xtrain,ytrain,id)
%GETPREDICTION Summary of this function goes here
%   Detailed explanation goes here
%k_OptimOptions = optimset('Display','off');
%[coefs, fit]=fminsearch(@SR_fitness_calc,beta,k_OptimOptions,model,xtrain,ytrain,id);
[coefs, fit]=fmingrad_Rprop(beta,model,xtrain,ytrain,id);
% if  ~isreal(fit) 
%     fit=10e6*imag(fit);
% end

