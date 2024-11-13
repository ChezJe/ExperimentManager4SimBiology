params.IncludeRestCompartment = true;
params.Method = "fmincon";
params.ErrorModelProtein = "constant";
params.ErrorModelPlasma = "constant";

params.InitialValue_ka = 0.06;
params.InitialValue_kdeg_RISC = 2e-7;
params.InitialValue_RISC_mRNA_koff = 0.09;

params.InitializationFunctionOutput = Experiment1Initialization1();

output = Experiment1Function1(params)
