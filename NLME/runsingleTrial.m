function output = runsingleTrial(params, monitor)

data                    = params.InitializationFunctionOutput.data;
groupVariableName       = params.InitializationFunctionOutput.groupVariableName;
independentVariableName = params.InitializationFunctionOutput.independentVariableName;
dependentVariableName   = params.InitializationFunctionOutput.dependentVariableName;
doseTargets             = params.InitializationFunctionOutput.doseTargets;
doseDataColumns         = params.InitializationFunctionOutput.doseDataColumns;
covariateSeparator      = params.InitializationFunctionOutput.covariateSeparator;


% Make sure the doseDataColumns are in the data itself
[doseDataColumns, idxD] = intersect(doseDataColumns,data.Properties.VariableNames);
doseTargets = doseTargets(idxD);

% Build model
cm = CompartmentalModel(NumCompartments=params.NumCompartments,...
            ElimPeriphType=params.ElimPeriphType);
modelObj = cm.Model;
parameterNames = cm.ParameterNames;

% Remove absorption parameter if no EV dose
if ~any(contains(doseTargets,"Dose_Central"))
    parameterNames = setdiff(parameterNames,"ka_Central");
end

% Build covariate expressions
covgen = CovariateExpressionGenerator;
for currentPar = parameterNames
    addCovariateExpression(covgen, currentPar, ...
        Covariate=split(params.(currentPar + "_COV"), covariateSeparator),...
        IncludeRandomEffect=params.(currentPar + "_RE"), ParameterTransform="log");
end
covExpression = covgen.CovariateExpression;

% Define monitoring
monitor.Info    = ["LL","AIC", "BIC"];
monitor.Metrics = ["Iteration","ErrorConstant", "ErrorProp"];

% Abort if no Random Effect (not supported by nlmefitsa)
% or if covariates for Periph parameters are defined (this case is to avoid
% rerunning the same fits multiple times for one compartment models)
if ( ~params.Central_RE && ~params.Cl_Central_RE && ~params.ka_Central_RE &&...
        ((params.NumCompartments==1 || ...
        (params.NumCompartments==2 && ~params.Cl_Peripheral_RE && params.Q12_RE))) )...
    || (params.NumCompartments==1 && params.Cl_Peripheral_COV~="" &&...
        params.Peripheral_COV~="" && params.Q12_COV~="") ...
    || isempty(doseDataColumns)

    results = {};
    monitor.Progress = 100;
    
    updateInfo(monitor, AIC=Inf, BIC=Inf, LL=-Inf);
    recordMetrics(monitor, 0, ErrorConstant=NaN, ErrorProp=NaN);

    output.Results = results;
    output.CovExpression = covExpression;
    return;
end

% Create CovariateModel objects
covariateModel = CovariateModel(covExpression);
covariateModel.FixedEffectValues = constructDefaultFixedEffectValues(covariateModel);

% Define a description of the data.
groupedDataObj                                    = groupedData(data);
groupedDataObj.Properties.GroupVariableName       = groupVariableName;
groupedDataObj.Properties.IndependentVariableName = independentVariableName;

% Create the dose objects from the dataset
doses = cell(numel(doseDataColumns),1);
for i=1:numel(doseDataColumns)
    dose_template = sbiodose(doseDataColumns(i));
    dose_template.TargetName = doseTargets(i);
    doses{i} = createDoses(groupedDataObj, doseDataColumns(i), '', dose_template);
    doses{i} = num2cell(doses{i});
end
dosesForFit = [doses{:}];

% Define response information.
responseMap = cellstr(cm.Observed + " = " + dependentVariableName);

% Define Algorithm options.
options.ErrorModel        = char(params.ErrorModel);
options.CovPattern        = eye(numel(covariateModel.RandomEffectNames));
options.NBurnIn           = 5;
options.NIterations       = 400;
options.NMCMCIterations   = 2;
options.OptimFun          = 'fminunc';
options.LogLikMethod      = 'is';
options.ComputeStdErrors  = true;
options.Options.TolX      = 0.0001;
options.Options.Streams   = RandStream("mt19937ar", Seed=params.RandomSeed);
options.Options.OutputFcn = @(~,status,state) monitorUpdate(monitor, status, state, options.NIterations, params.ErrorModel);

% Define fit problem.
f              = fitproblem('FitFunction', 'sbiofitmixed');
f.Data         = groupedDataObj;
f.Model        = modelObj;
f.Estimated    = covariateModel;
f.ResponseMap  = responseMap;
f.Doses        = dosesForFit;
f.FunctionName = 'nlmefitsa';
f.Options      = options;
f.ProgressPlot = false;
f.UseParallel  = false;

% Estimate parameter values.
results = f.fit;

monitor.Progress = 100;
updateInfo(monitor, AIC=results.AIC, BIC=results.BIC, LL=results.LogLikelihood);

output.Results = results;
output.CovExpression = covExpression;

plot(results);
set(gcf, 'Name', 'Sim vs. Data');

end 


