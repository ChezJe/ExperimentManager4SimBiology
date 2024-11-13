function args = runSingleTrial(params,model, cs, data, variantsStruct, dosesStruct)

% Initialize arguments.
args.input.model    = model;
args.input.cs       = cs;
args.input.data     = data;
args.input.variants = variantsStruct;
args.input.doses    = dosesStruct;

% Run fit.
args = runFit(params,args);

end

% -------------------------------------------------------------------------
function args = runFit(params,args)

% Extract the input arguments.
input    = args.input;
data     = input.data;
model    = input.model;
cs       = input.cs;
variants = input.variants.modelStep;
doses    = input.doses.modelStep;

% Set the active configuration set.
originalConfigset = getconfigset(model, 'active');
setactiveconfigset(model, cs);

% Restore the original configset after the task has completed running.
cleanupConfigset = onCleanup(@() restoreActiveConfigset(model, originalConfigset));

% Turn off observables.
observables        = model.Observables;
activateState      = get(observables, {'Active'});
cleanupObservables = onCleanup(@() restoreObservables(observables, activateState));
set(observables, 'Active', false);

% Define a description of the data.
groupedDataObj                                    = groupedData(data);
groupedDataObj.Properties.GroupVariableName       = 'doseGroup';
groupedDataObj.Properties.IndependentVariableName = 'time_hr';

% Define objects being estimated and their initial estimates.
estimatedInfoObj = estimatedInfo({'log(F)', 'log(kdeg_RISC)', 'log(ka)', 'log(RISC_mRNA_koff)'});
estimatedInfoObj(1).InitialValue = 0.2;
estimatedInfoObj(1).Bounds = [0.01,1];
estimatedInfoObj(2).InitialValue = params.InitialValue_kdeg_RISC;
estimatedInfoObj(3).InitialValue = params.InitialValue_ka;
estimatedInfoObj(4).InitialValue = params.InitialValue_RISC_mRNA_koff;

% Create variant to estimate Q_rest or turn off transport to Rest compartment
reacRestObj = sbioselect(model,'Type','Reaction','Name','r_plasma_to_rest');
if params.IncludeRestCompartment
    reacRestObj.Active = true;
    estimatedInfoObj(end+1) = estimatedInfo('log(Q_rest)', InitialValue=100,Bounds=[10,1000]);
else
    reacRestObj.Active = false;
end


% Create the data variant.
variants1 = createVariants(groupedDataObj, 'dose', 'Names', 'dose_mgkg', 'Model', model, 'UnitConversion', 'auto');

% Build table of variants.
variants1   = num2cell(variants1);
variantsForFit = variants1;

% Get the baseline dose.
doses1 = sbioselect(doses, 'Name', 'single dose');

% Build array of doses.
dosesForFit = doses1;

% Define response information.
responseMap = {'plasmadrug_ugml = plasmadrug_ugml', 'protein_mgl = protein_mgl'};


% Define fit problem.
f              = fitproblem('FitFunction', 'sbiofit');
f.Data         = groupedDataObj;
f.Model        = model;
f.Estimated    = estimatedInfoObj;
f.ResponseMap  = responseMap;
f.ErrorModel   = [params.ErrorModelPlasma,params.ErrorModelProtein];
f.Variants     = variantsForFit;
f.Doses        = dosesForFit;
f.FunctionName = params.Method;
f.ProgressPlot = false;
f.UseParallel  = false;
f.Pooled       = true;

% Estimate parameter values.
results = f.fit;

% Assign output arguments.
args.output.results  = results;

end



% -------------------------------------------------------------------------
function restoreActiveConfigset(model, cs)

% Restore active configset.
setactiveconfigset(model, cs);

end

% -------------------------------------------------------------------------
function restoreObservables(observables, active)

for i = 1:length(observables)
    set(observables(i), 'Active', active{i});
end

end

