function [  ] = PlotSelectedModel( OrderedModels, OrderedCoefs,model_number,xtrain,ytrain,xtest,ytest)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here



[n_rows n_vars ]=size(xtrain);

figure
for i=1:n_vars
   xdata=repmat(mean(xtrain),n_rows,1);
   xdata(:,i)=xtrain(:,i);
   
       
       pred=OrderedModels{model_number}(OrderedCoefs{model_number},xdata);
       subplot(2,2,i)
       hold on
       scatter(xdata(:,i),pred)
       legend('show')
   
end



figure
 
 pred_train=OrderedModels{model_number}(OrderedCoefs{model_number},xtrain);
 pred_test= OrderedModels{model_number}(OrderedCoefs{model_number},xtest);

 subplot(2,2,1) 
 hold on
 plot(ytrain)
 plot(pred_train)
 title("Traning data time series")
 xlabel("time")
 ylabel("dX/dt")
 subplot(2,2,3) 
 hold on
 plot(ytest)
 plot(pred_test)
 title("Testing data time series")
 xlabel("time")
 ylabel("dX/dt")
 subplot(2,2,2) 
 hold on
 scatter(pred_train,ytrain)
 plot(pred_train,pred_train)
  title("Traning data obs. vs. pred")
 xlabel("Predicted")
 ylabel("Observed")
 subplot(2,2,4) 
 hold on
 scatter(pred_test,ytest)
 plot(pred_test,pred_test)
 title("Testing data obs. vs. pred")
 xlabel("Predicted")
 ylabel("Observed")
end

