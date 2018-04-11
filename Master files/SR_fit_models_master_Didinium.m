
%CREATED BY AMH & BTM 4-18-2017
%adapted from GPTIPS 2: an open-source software platform for symbolic data mining Searson, D.P.
%RUN Symbolic Regressionwith NONLINEAR OPTIMIZATION ROUTINE 

clear all

%%
Save_gp_as= "Didinium_test" %file name of saved gp structure
rng('shuffle')
gp=gpdefaults();
gp.state.count =0;

%load data; define independent (x) and dependent (y) variables
data=csvread('ParameciumDidinium.csv',1,0);
[y, validation_data ] =datasample(data,round(length(data)/3),'Replace',false);
gp.xtrain=data(:,2:3);
gp.xtrain(validation_data,:)=[];
gp.ytrain=data(:,5);
gp.ytrain(validation_data,:)=[];
gp.xtest=data(validation_data,2:3); 
gp.ytest=data(validation_data,5); 

%set number of models to generate
gp.runcontrol.pop_size = 2500;                     
gp.runcontrol.n_generations = 20;
gp.runcontrol.fitnessfunc = 1 ;% 1 = untransformed RSS (for Paramecium and Didinium datasets); 2 = square root transformed RSS (for flour beetle dataset)

%define functions to include in function set
gp.nodes.functions.name = {'times','plus','rdivide','exp','log'};

%AMH: tree initialization
gp.treedef.max_depth    = 6;                %set maximum tree depth
gp.data.num_covars      = size(gp.xtrain,2);%number of covariates in dataframe
gp.treedef.build_method = 3;                %1=full 2=grow 3=ramped 1/2 and 1/2
gp.nodes.const.p_ERC    = 0.5;              %terminal config. [0=no constants, 0.5=half constants half inputs 1=no inputs]

%BTM popbuild parms
gp.operators.mutation.p_mutate=.20;
gp.operators.crossover.p_cross=.75;
gp.operators.directrepro.p_direct=.05;
gp.selection.tournament.p_pareto
gp.treedef.max_nodes=200;
gp.operators.mutation.cumsum_mutate_par = cumsum(gp.operators.mutation.mutate_par);

%selection
gp.selection.tournament.size = 2;
gp.selection.tournament.p_pareto = 0.2; 
gp.selection.elite_fraction = .05;
gp.nodes.const.p_int= 0.5; 

%initialize structure to save out models and fitness for each generation
gp.history.models=[];
gp.history.fitness=[];
gp.history.coefs=[];
gp.history.num_coefs=[];

%AMH: other input variables needed to generate tree
gp.nodes.inputs.num_inp         = gp.data.num_covars;        %number of variables to inlcude in model construction, should be <= num_covars
if gp.nodes.inputs.num_inp > gp.data.num_covars 
    error('error num_inp > num_covars')
end
       
%by default, make all functions active
gp.nodes.functions.num_active   = numel(gp.nodes.functions.name);
%make all functions active 
gp.nodes.functions.active       = true(1,gp.nodes.functions.num_active);

%run initialization file to get arity of functions
gp                              = SR_tree_model_init(gp);

%% initialize first generation and fit models
%initialize model set
gp.models.modelset = cell(gp.runcontrol.pop_size,1);

%initialize prediction function set (i.e. matlab-interpretable version of model
gp.models.predfuncset = cell(gp.runcontrol.pop_size,1);

%generate model set
for i=1:gp.runcontrol.pop_size   
    gp.models.modelraw{i,1}=SR_treegen(gp,gp.treedef.max_depth);
    gp.models.modelset{i,1} = SR_tree2evalstr(gp.models.modelraw{i,1},gp);
end
gp.models.num_coefs = cell(numel(gp.models.modelset),1);
for i=1:numel(gp.models.modelset)
    gp.models.num_coefs{i} = numel(strfind(gp.models.modelset{i},'beta'));% find number of fitted parameters for each model
    %simplify model and calculate new free parameter count
    [gp.models.num_coefs{i}, gp.models.predfuncset{i}] = SR_generate_simplify_prediction_function(gp.models.modelset{i}, gp.models.num_coefs{i} ,gp.data.num_covars);
end
gp=SR_nlin_fit_models_unique(gp);
gp.pop(:,1)=gp.models.modelraw;   


%% loop through GP algorthm and nlin fitting 
for i=1:gp.runcontrol.n_generations
display(['fitting generation number: ' num2str(i)])
%generate new models using GP tournament
gp=popbuild(gp);
%initialize next gen from previous gen
    for ii=1:length(gp.models.modelraw)
        if iscell(gp.pop{ii})
        gp.models.modelraw{ii}=cell2mat(gp.pop{ii});
        else
        gp.models.modelraw{ii}  =gp.pop{ii};  
        end
    end
% %generate model set from raw models
   for ii=1:gp.runcontrol.pop_size
        gp.models.modelset{ii} = SR_tree2evalstr(gp.models.modelraw{ii,1},gp,ii);
   end
% calc number of coefs
gp.models.num_coefs = cell(numel(gp.models.modelset),1);
    for ii=1:numel(gp.models.modelset)
        gp.models.num_coefs{ii} = numel(strfind(gp.models.modelset{ii},'beta'));% find number of fitted parameters for each model
        %simplify model and calculate new free parameter count
        [gp.models.num_coefs{ii}, gp.models.predfuncset{ii}] = SR_generate_simplify_prediction_function(gp.models.modelset{ii}, gp.models.num_coefs{ii} ,gp.data.num_covars);
    end
gp=SR_nlin_fit_models_unique(gp);
gp.history.models=vertcat(gp.history.models,gp.models.predfuncset);
gp.history.fitness=vertcat(gp.history.fitness,gp.fitness.values);
gp.history.coefs=vertcat(gp.history.coefs,gp.models.best_coefs);
end

%% compile models from all generations, elimate duplicates, count true numbers of degrees of freedom and define the Pareto front
gp=UniqueCheckHistoryFunc(gp);
frontonly = get_pareto_modelsFunc(gp);
gp.frontonly=frontonly;
save(Save_gp_as,"gp")
SimplifyModelsFunc(frontonly,gp)
