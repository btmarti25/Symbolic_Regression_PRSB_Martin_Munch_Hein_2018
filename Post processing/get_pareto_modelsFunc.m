%MUST HAVE gp object loaded to use this script

function frontonly = get_pareto_modelsFunc(gp)
paretodata = gp.frontdata;

pparamcount = [];
pmodel = {};
pparam = {};
R2 = [];
R2_os = [];

SST_os = sum( (gp.ytest.^.5 - mean(gp.ytest.^.5)).^2 );%compute out of sample sst

for i = 1:8
    pparamcount = [pparamcount i];
    bestfit     = max(paretodata.R2(paretodata.Nparam == i));
    bestmod     = paretodata.UniqOrderedModels{paretodata.R2 == bestfit};
    bestcoef    = paretodata.param_values{paretodata.R2 == bestfit};
    pmodel{i}   = bestmod;
    pparam{i}   = bestcoef;
    R2(i)       = bestfit;
  %  bestmod=str2func(bestmod);
    os_predictions = bestmod(bestcoef,gp.xtest);
    SSE_os         = sum( (gp.ytest.^.5 - os_predictions.^.5).^2 );
    R2_os(i)          = 1 - SSE_os/SST_os;
end
frontonly.R2 = R2;
frontonly.R2os = R2_os;%out of sample R2

frontonly.pparamcount = pparamcount;
frontonly.pmodel = pmodel;
frontonly.pparam = pparam;

figure

plot(gp.frontdata.Nparam(gp.frontdata.R2>0),gp.frontdata.R2(gp.frontdata.R2>0), 'ok')
xlim([1 8])
hold on
plot(frontonly.pparamcount, frontonly.R2,'-b')
ylim([0 1])
plot(frontonly.pparamcount, frontonly.R2os,'-r')
hold off
end
