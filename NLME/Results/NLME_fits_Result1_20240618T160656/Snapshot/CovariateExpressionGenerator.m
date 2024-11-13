classdef CovariateExpressionGenerator < handle

    properties (SetAccess=private)
        CovariateExpression (:,1) cell
    end

    properties (Access=private)
        ThetaIndex (1,1) double 
    end

    properties (Dependent=true, SetAccess=private)
        ThetaNames (:,1) cell
    end

    methods
        function obj = CovariateExpressionGenerator()
                obj.ThetaIndex = 1;
                obj.CovariateExpression = cell.empty;
        end % constructor

        function addCovariateExpression(obj, parametername, options)

            arguments
                obj
                parametername (1,1) string
                options.ParameterTransform (1,1) string ...
                    {mustBeMember(options.ParameterTransform,["none","log","probit","logit"])} = "log"
                options.Covariate (1,:) string = string.empty
                options.IncludeRandomEffect (1,1) logical {mustBeA(options.IncludeRandomEffect,'logical')} = true
            end

            % treat transformation
            switch options.ParameterTransform
                case "log"
                    covstart = "exp(";
                    covend = ")";
                case "probit"
                    covstart = "probitinv(";
                    covend = ")";
                case "logit"
                    covstart = "logitinv(";
                    covend = ")";
                otherwise % "none"
                    covstart = "";
                    covend = "";
            end

            % start covariate expression
            covariateExpression = parametername + " = " + covstart + "theta_i" ;

            % covariates
            for k=1:numel(options.Covariate)
                if options.Covariate(k)~=""
                    covariateExpression = covariateExpression + " + theta_i_" + k + "*" + options.Covariate(k);
                end
            end

            % random effects
            if options.IncludeRandomEffect
                covariateExpression= covariateExpression + " + eta_i";
            end

            % end covariate expression
            covariateExpression = covariateExpression + covend;

            % replace i by theta_index
            covariateExpression = replace(covariateExpression, "theta_i", "theta_" + obj.ThetaIndex);
            covariateExpression = replace(covariateExpression, "eta_i", "eta_" + obj.ThetaIndex);

            % add to list of covariate expressions
            obj.CovariateExpression{obj.ThetaIndex} = char(covariateExpression);
            obj.ThetaIndex = obj.ThetaIndex + 1;

        end % addCovariateExpression

        function thetaNames = get.ThetaNames(obj)

            pat = "theta_" + wildcardPattern + (whitespaceBoundary | "*" | textBoundary);
            thetaNames = extract(strjoin(obj.CovariateExpression," "), pat);
            thetaNames = erase(thetaNames,["*",")"]);

        end % get.ThetaNames

    end % public methods

end % classdef