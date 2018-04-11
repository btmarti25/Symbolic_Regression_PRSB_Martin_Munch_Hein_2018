function [xopt,fopt]=fmingrad_Rprop(beta,model,xtrain,ytrain,errormodel)

    %fun is a handle to a function that has grad as optional second output

    %this uses the sign of the gradient to determine descent directions 

    %and an adaptive step size - supposedly smoother convergence than

    %conjugate gradients for GP optimization

    p=length(beta);

    

    %optimization parameters for Rprop

    %Delta0 = 0.1*ones(p,1);
    Delta0 = .1+ 0.002*beta';
    Deltamin = 1e-6;

    Deltamax = 50;

    eta_minus = 0.5;eta_minus=eta_minus-1;

    eta_plus = 1.5;eta_plus=eta_plus-1;    

    maxcount=200;

    mincount=10;

    

    %initialize 

    x=beta;

    [f,g]=funGrad(x ,model,xtrain,ytrain,errormodel);
    trys = 0;
   while f >= 1.0000e+20 && trys < 20
   % while isinf(f) && trys < 10
       % x= (exp(log10(1000)*rand(1,length(x)))-1).* sign(rand(1,length(x))-.5);
        x= rand(1,length(x));
       [f,g]=funGrad(x ,model,xtrain,ytrain,errormodel);    
        trys=trys+1;
    end
    
   if f >= 1.0000e+20
  %  if isinf(f) 
        fopt=Inf;
        xopt=x;
        return
   end
    
   
   
    s=sqrt(g'*g);

 

    %loop starts here

    count=0;

    del=Delta0;

    df=10;

    while ((s>.001)&(count<maxcount)&(df>.00001))|(count<mincount)

        

        %step 1-move

        xnew=x-(sign(g).*del)';

        [fnew,gnew]=funGrad(xnew ,model,xtrain,ytrain,errormodel);

        s=sqrt(gnew'*gnew);

        df=abs(fnew/f-1);



        %step 2 - update step size

        gc=g.*gnew;

        del=min(Deltamax,max(Deltamin,del.*(1+eta_plus*(gc>0)+eta_minus*(gc<0))));

        

        x=xnew;

        g=gnew;

        f=fnew;

        count=count+1;

%         [x g]

    end

%count;

% if s>0,%tighten up with fminsearch?

%     [xalt,falt]=fminsearch(fun,x);

%     [falt f]

%     if falt<f, x=xalt;end

% end

xopt=x;[fopt,gradopt]=funGrad(xnew ,model,xtrain,ytrain,errormodel);



    

    