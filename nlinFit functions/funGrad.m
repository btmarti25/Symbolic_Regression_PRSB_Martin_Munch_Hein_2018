function [ f, g ] = funGrad( beta ,model,xtrain,ytrain,errormodel)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

f=SR_fitness_calc(beta,model,xtrain,ytrain,errormodel);
if  ~isreal(f) 
    f=real(f)+10e6*abs(imag(f));
end

fi=zeros(length(beta),1);
g=zeros(length(beta),1);
betaMat=repmat(beta,length(beta),1);
for i=1:length(beta)
betaMat(i,i)=betaMat(i,i)+1e-6;
fi(i,1)=SR_fitness_calc(betaMat(i,:),model,xtrain,ytrain,errormodel);
%AH:     if  ~isreal(fi(i)) 
%     fi(i)=real(fi(i))+10e6*abs(imag(fi(i)));
%     end
g(i,1)=(fi(i)-f)/+1e-6;
end



