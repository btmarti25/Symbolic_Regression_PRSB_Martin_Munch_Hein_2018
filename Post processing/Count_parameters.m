


function Nparms = Count_parameters(model,beta)


  % model='@(beta,X)(beta(1).*X(:,3)-beta(2)+beta(3).*X(:,1).*X(:,3)).*(beta(4)-beta(5).*X(:,2)+beta(6).*X(:,2)+beta(7).*X(:,1))'
   %  beta = [12, 1, 3, 5, .1, .2 .5];
   
 
  if length(beta) == 1
       Nparms = 1;
      return 
  end
  
  if isnan(beta) == 1
         Nparms = 10;
      return 
  end  
      
      
   for i=1:length(beta)
       replace = ['beta(' num2str(i) ')'];
     model=  strrep(model,replace ,num2str(beta(i)));
     
   end
   
    model=  strrep(model,'beta,','');
    
    model=str2func(model);
    
    Z=sym('X',[1 3]);
    
    if count(func2str(model),'X')==1
        Nparms = 1;
      return 
    end 
        model=simplify(model(Z));
        model=func2str(matlabFunction(model));
        model=strrep(model, '.*','*');
        model=strrep(model, './','/');
        Nparms=count(model,'.');
    
      
    