% Central_COV ["", "APGAR", "APGAR__log(WEIGHT/mean(WEIGHT))", "log(WEIGHT/mean(WEIGHT))"]
% Cl_Central_COV 
% Peripheral_COV 
% Cl_Peripheral_COV 
% Q12_COV )
% 
% Central_RE false, true
% NumCompartment 1, 2
% ElimPeriphType first-order, none
% ErrorModel constant proportional combined
% 3^5 * 2^2 * 3 = 2916

%% Test CovariateExpressionGenerator
c = CovariateExpressionGenerator();

addCovariateExpression(c, "Central", Covariate="log(WEIGHT/70)",...
    IncludeRandomEffect=true, ParameterTransform="log");
addCovariateExpression(c, "CL", Covariate="APGAR", ...
    IncludeRandomEffect=false, ParameterTransform="log");
addCovariateExpression(c, "ka_Central");
c
c.CovariateExpression
c.ThetaNames


%% Test fit program 
params = struct;
params.Central_COV = "APGAR"; 
params.Cl_Central_COV = "";
params.Peripheral_COV = "";
params.Cl_Peripheral_COV = "APGAR__log(WEIGHT/mean(WEIGHT))";
params.Q12_COV = "APGAR"; 

params.Central_RE = true; 
params.Cl_Central_RE = false;
params.Peripheral_RE = false;
params.Cl_Peripheral_RE = false;
params.Q12_RE = false; 


params.NumCompartments = 2;
params.ElimPeriphType = "first-order";
params.ErrorModel = "constant";
params.RandomSeed = 5;

monitor = experiments.Monitor;

output = runprogram(params, monitor)
