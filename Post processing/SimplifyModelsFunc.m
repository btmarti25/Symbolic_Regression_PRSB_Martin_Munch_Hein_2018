

function [] = SimplifyModelsFunc(frontonly,gp)

x=sym('X',[1 4]);



for i=1:8
model= frontonly.pmodel{i};
OrigParms=frontonly.pparam{i};
x=sym('X',[1 4]);
b=sym('beta',[1 numel(OrigParms)]);
digits(4)
model=sym(model(b,x));
disp(['Simplfied model for ' num2str(i) ' parameters'])
simplify(vpa(subs(model,b,frontonly.pparam{i})))
expand(vpa(subs(model,b,frontonly.pparam{i})));

simpmod{i}=vpa(subs(model,b,frontonly.pparam{i}));
end
% 
% 
% digits(4)
% load("DLPA_front.mat")
% 
% for i=1:8
% model= pd.paretoset{i};
% OrigParms=pd.paretocoefs{i};
% x=sym('X',[1 4]);
% b=sym('beta',[1 numel(OrigParms)]);
% model=str2func(model);
% model=sym(model(b,x));
% i;
% vpa(subs(model,b,pd.paretocoefs{i}))
% 
% end

end