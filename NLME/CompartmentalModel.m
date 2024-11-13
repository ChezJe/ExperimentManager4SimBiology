classdef CompartmentalModel  < handle & matlab.mixin.CustomDisplay

    properties ( SetAccess = private)
        NumCompartments (1,1) double
        ElimPeriphType  (1,:) string
        ParameterNames  (1,:) string
        Observed        (1,:) string

        Model
    end

    properties ( Dependent, SetAccess = private, GetAccess = public )
        NumParameters   (1,1) double
    end
   
    properties ( Hidden, Access = public )
        PKModelDesignObj 
    end

    methods
        function obj = CompartmentalModel(options)
            % Create a compartmental model for simulation and data fitting.
            
            arguments
                options.NumCompartments (1,1) {mustBeInteger,mustBeInRange(options.NumCompartments,1,2)} = 1
                options.ElimPeriphType  (1,1) string {mustBeMember(options.ElimPeriphType,["first-order","none"])} = "first-order"
            end

            obj.NumCompartments = options.NumCompartments;
            obj.ElimPeriphType  = options.ElimPeriphType;

            generatePKModelDesign(obj);
            generateModel(obj);

        end % constructor


        function nb = get.NumParameters(obj)
            nb = numel(obj.ParameterNames);
        end % get.NumParameters
        
    end % public methods


    methods ( Access = private )

        function generatePKModelDesign(obj)
            % Create PKModelDesign used to generate model.

            % create PKModelDesign object that we will modify
            pkmd = PKModelDesign;
            pkmd.addCompartment('Central',DosingType='FirstOrder',...
                HasResponseVariable=true, EliminationType='linear-clearance');

            if obj.NumCompartments > 1
                % add peripheral compartment
                compPobj = pkmd.addCompartment('Peripheral',DosingType='',...
                    HasResponseVariable=false);

                % add elimination Peripheral compartment
                switch obj.ElimPeriphType
                    case "none"
                        compPobj.EliminationType = '';
                    case "first-order"
                        compPobj.EliminationType = 'linear-clearance';
                end
            end
            
            % save object
            obj.PKModelDesignObj = pkmd;

        end % generatePKModelDesign

        function generateModel(obj)
            % Generate model from PKModelDesign.

            [model, map] = obj.PKModelDesignObj.construct();

            cs = getconfigset(model);
            cs.CompileOptions.UnitConversion = true;
            cs.SolverOptions.AbsoluteTolerance = 1e-9;
            cs.SolverOptions.RelativeTolerance = 1e-6;
            cs.SolverType = 'ode15s';

            % remove unnecessary components in Central comp
            delete(sbioselect(model,'Name','Tk0_Central'));
            delete(sbioselect(model,'Name','TLag_Central'));

            % remove unnecessary components in Periph comp
            if obj.NumCompartments > 1
                delete(sbioselect(model,'Name','Peripheral Absorption')); % reaction
                delete(sbioselect(model,'Name','ka_Peripheral'));   % parameter
                delete(sbioselect(model,'Name','Dose_Peripheral')); % species
                delete(sbioselect(model,'Name','Tk0_Peripheral'));  % parameter
                delete(sbioselect(model,'Name','TLag_Peripheral')); % parameter
            end
            
            obj.Model = model;
            obj.ParameterNames = string(map.Estimated);
            obj.Observed = string(map.Observed);

        end % generateModel

    end % private methods
    
end % classdef
