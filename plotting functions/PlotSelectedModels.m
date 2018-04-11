function [ dataout ] = PlotSelectedModels( OrderedModels, OrderedCoefs,model_list,xtrain,ytrain,xtest,ytest,UniqOrderedwwAIC)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here



[n_rows n_vars ]=size(xtrain);
dataout=[];
figure
for i=2:2:n_vars
   xdata=repmat(median(xtrain),n_rows,1);
   xdata(:,i)=xtrain(:,i);
   
      g=[2 5]
      h=[4 2]
       subplot(2,3,g(i/2))
       hold on
        for j=1:length(model_list)
         model   =str2func(OrderedModels{model_list(j)});
       pred=model(OrderedCoefs{model_list(j)},xdata);
       [xsort ind] =sort(xdata(:,i));
       plot(xsort,pred(ind))
       
        AA=[i*ones(length(xdata),1),UniqOrderedwwAIC(j)*ones(length(xdata),1), xdata(:,h(i/2)),xsort,pred(ind)];
        dataout=vertcat(dataout,AA);
        end
       ylim([-100,300])
       
   
end



%figure
for i=2:2:n_vars
   
   xdata=repmat(quantile(xtrain,.25),n_rows,1);
   xdata(:,1)=repmat(median(xtrain(:,1)),n_rows,1)
    xdata(:,3)=repmat(median(xtrain(:,3)),n_rows,1)
   xdata(:,i)=xtrain(:,i);
   
          g=[1 4]
       subplot(2,3,g(i/2))
       hold on
        for j=1:length(model_list)
        model   =str2func(OrderedModels{model_list(j)});
       pred=model(OrderedCoefs{model_list(j)},xdata);
       [xsort ind] =sort(xdata(:,i));
       plot(xsort,pred(ind))
        AA=[i*ones(length(xdata),1),UniqOrderedwwAIC(j)*ones(length(xdata),1), xdata(:,h(i/2)),xsort,pred(ind)];
        dataout=vertcat(dataout,AA);
        end
      ylim([-100,300])
       
   
end

%figure
for i=2:2:n_vars
   xdata=repmat(quantile(xtrain,.75),n_rows,1);
     xdata(:,1)=repmat(median(xtrain(:,1)),n_rows,1)
    xdata(:,3)=repmat(median(xtrain(:,3)),n_rows,1)
   xdata(:,i)=xtrain(:,i);
   
           g=[3 6]
       subplot(2,3,g(i/2))
       hold on
        for j=1:length(model_list)
                  model   =str2func(OrderedModels{model_list(j)});
       pred=model(OrderedCoefs{model_list(j)},xdata);
         [xsort ind] =sort(xdata(:,i));
       plot(xsort,pred(ind))
        AA=[i*ones(length(xdata),1),UniqOrderedwwAIC(j)*ones(length(xdata),1), xdata(:,h(i/2)),xsort,pred(ind)];
        dataout=vertcat(dataout,AA);
        end
      ylim([-100,300])
   
end

csvwrite('Var_Import_revision_2',dataout)
% figure
%  
%  subplot(2,2,1) 
%  hold on
%   scatter(1:length(ytrain),ytrain)
%      for j=1:length(model_list)
%      pred_train=OrderedModels{model_list(j)}(OrderedCoefs{model_list(j)},xtrain);
%      plot(pred_train)
%      end
%         legend('show')
%  title("Traning data time series")
%  xlabel("time")
%  ylabel("dX/dt")
%  subplot(2,2,3) 
%  hold on
%  scatter(1:length(ytest),ytest)
%      for j=1:length(model_list)
%      pred_test=OrderedModels{model_list(j)}(OrderedCoefs{model_list(j)},xtest);
%      plot(pred_test)
%      end
%        legend('show')
%  title("Testing data time series")
%  xlabel("time")
%  ylabel("dX/dt")
%  subplot(2,2,2) 
%  hold on
%   plot(pred_train,pred_train)
%    for j=1:length(model_list)
%      pred_train=OrderedModels{model_list(j)}(OrderedCoefs{model_list(j)},xtrain);
%  scatter(pred_train,ytrain)
%    end
%      legend('show')
% 
%   title("Traning data obs. vs. pred")
%  xlabel("Predicted")
%  ylabel("Observed")
%  subplot(2,2,4) 
%  hold on
%   plot(pred_test,pred_test)
%   for j=1:length(model_list)
%      pred_test=OrderedModels{model_list(j)}(OrderedCoefs{model_list(j)},xtest);
%  scatter(pred_test,ytest)
%   end
%    legend('show')
% 
%  title("Testing data obs. vs. pred")
%  xlabel("Predicted")
%  ylabel("Observed")
 
end

