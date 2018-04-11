


data=csvread('DerivsShort.csv',0,0);
xtrain=data(1:50,2:3); 
ytrain=data(1:50,4); 
xtest=data(51:71,2:3); 
ytest=data(51:71,4); 
gp.xtrain=xtrain
gp.ytrain=ytrain
gp.xtest=xtest
gp.ytest=ytest

gp.history.models=[];
gp.history.fitness=[];
gp.history.coefs=[];
gp.history.num_coefs=[];

x=sym('X',[1 4]);
b=sym('beta',[1 numel(OrigParms)]);

digits(4)
load("Paramecium_pareto_defined at zero.mat")
for i=1:8
model= frontonly.pmodel{i};
OrigParms=frontonly.pparam{i};
x=sym('X',[1 4]);
b=sym('beta',[1 numel(OrigParms)]);

model=sym(model(b,x));
i;
vpa(subs(model,b,frontonly.pparam{i}))
simplify(vpa(subs(model,b,frontonly.pparam{i})));
expand(vpa(subs(model,b,frontonly.pparam{i})));
simpmod{i}=vpa(subs(model,b,frontonly.pparam{i}));
end
digits(4)
load("DLPA_front.mat")

for i=1:8
model= pd.paretoset{i};
OrigParms=pd.paretocoefs{i};
x=sym('X',[1 4]);
b=sym('beta',[1 numel(OrigParms)]);
model=str2func(model);
model=sym(model(b,x));
i;
vpa(subs(model,b,pd.paretocoefs{i}))

end
