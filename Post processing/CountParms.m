function [Nparms] = CountParms(model,xtrain,num_covars,OrigParms)
x=sym('X',[1 4]);
b=sym('beta',[1 numel(OrigParms)]);

%model='@(beta,X)beta(1).*exp(beta(2).*X(:,2)+beta(3).*X(:,4)+beta(4).*log(beta(5).*X(:,4)))';
 model=str2func(model);
model=sym(model(b,x));

xtrain = xtrain(all(xtrain,2),:);

N_skip=round(length(xtrain)/20);
%N_skip=1
if num_covars  == 2
    Vmodel=subs(model,{'X1' 'X2'},{[xtrain(1:N_skip:end,1)],[xtrain(1:N_skip:end,2)]});
end
if num_covars  == 3   
    Vmodel=subs(model,{'X1' 'X2' 'X3'},{[xtrain(1:N_skip:end,1)],[xtrain(1:N_skip:end,2)],[xtrain(1:N_skip:end,3)]});
end  
if num_covars  == 4
    Vmodel=subs(model,{'X1' 'X2' 'X3' 'X4'},{[xtrain(1:N_skip:end,1)],[xtrain(1:N_skip:end,2)],[xtrain(1:N_skip:end,3)],[xtrain(1:N_skip:end,4)]});    
end



Vmodel=Vmodel(Vmodel ~= 0);
Vmodel=Vmodel(~isnan(Vmodel));
logVmodel=log(Vmodel);

A=jacobian(logVmodel,b);

%Avpa=subs(A,b,OrigParms);

%%
%ensure no divisions by zero are occurring
%if(any(OrigParms == 0))
%    OrigParms(OrigParms == 0) = 1e-10;
%end

%try computing rank
try
    Avpa=subs(A,b,OrigParms);
    Avpa(isfinite(Avpa) == false) = 0;
    NparmsVPA=rank(vpa(Avpa));
    Nparms_symbolic = rank(A);
    Nparms = max(NparmsVPA, Nparms_symbolic);
catch
    %In the rare case that this evaluation fails, give a 999 for NparmsVPA
    %so model can be inspected manually
    Nparms = 999;

end

end