
h=.000001

n_vars=4
%SSQ=sum((mean(gp.ytrain)-gp.ytrain).^2)
SSQ=sum((gp.ytrain.^.5-mean(gp.ytrain.^.5)).^2);


TSS         = sum( (gp.ytrain.^.5 - mean(gp.ytrain.^.5)).^2);
RSS         = TSS.*(1- gp.frontdata.R2);
num_data    = numel(gp.ytrain);
sigmasqrd   = RSS./num_data;
LogLik      = -num_data*log(2*pi)/2 - num_data.*log(sigmasqrd)./2 - num_data/2;
AIC = -2 * gp.frontdata.Nparam + LogLik;
%[-2731.35528147202]
DAic= max(AIC) - AIC

AICw=exp(-.5*DAic);
AICww=AICw/sum(AICw);
UniqOrderedModels=gp.frontdata.UniqOrderedModels;
UniqOrderedCoef=gp.frontdata.param_values;
UniqOrderedR2=gp.frontdata.R2;

Dif=zeros(length(UniqOrderedModels),n_vars);
for i=1:n_vars
   xdata=gp.xtrain;
   xdata(:,i)=mean(gp.xtrain(:,i));
   for j=1:length(UniqOrderedModels)
       model=str2func(UniqOrderedModels{j});   
       pred=model(UniqOrderedCoef{j},gp.xtrain);
       Dpred=model(UniqOrderedCoef{j},xdata);
       R2orig= 1 - sum((pred.^.5-gp.ytrain.^.5).^2) /SSQ;
       R2mean= 1 - sum((Dpred.^.5-gp.ytrain.^.5).^2) /SSQ;
       R2dif(j,i)=R2orig-R2mean;
       Dif(j,i)=mean(abs((pred-Dpred)));
   end    
end


figure
subplot(2,2,1)
scatter(LogLik,Dif(:,1))
xlim([-1900,-1000])
ylim([0,500])

subplot(2,2,2)
scatter(LogLik,Dif(:,2))
xlim([-1900,-1000])
ylim([0,500])



subplot(2,2,3)
scatter(LogLik,Dif(:,3))
xlim([-1900,-1000])
ylim([0,500])

subplot(2,2,4)
scatter(LogLik,Dif(:,4))
xlim([-1900,-1000])
ylim([0,500])


dataout=horzcat(LogLik,Dif);

csvwrite('Var_Import_revision_4A_revision',dataout)

selectedmodels=find(AICww>.01)
PlotSelectedModels( UniqOrderedModels, UniqOrderedCoef,selectedmodels,gp.xtrain,gp.ytrain,gp.xtest,gp.ytest,AICww)
