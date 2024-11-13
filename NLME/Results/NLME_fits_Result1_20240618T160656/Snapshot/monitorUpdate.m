function stop = monitorUpdate(monitor, status, state, niter, errormodeltype)

% keep track of iteration because iteration number can be the same twice at the
% beginning or at the end but monitor will complain
persistent currentIter

monitor.Progress = 100*status.iteration*(status.iteration>=0)/niter;
if status.iteration <= 0
    currentIter = 0;
end
if status.iteration > currentIter
    
    switch(errormodeltype)
        case {"constant", "exponential"}
            ErrorConstantP = status.mse(1);
            ErrorPropP = NaN;
        case "proportional"
            ErrorConstantP = NaN;
            ErrorPropP = status.mse(2);
        case "combined"
            ErrorConstantP = status.mse(1);
            ErrorPropP = status.mse(2);
    end

    recordMetrics(monitor, status.iteration, Iteration=status.iteration, ErrorConstant=ErrorConstantP, ErrorProp=ErrorPropP);
    currentIter = status.iteration;
end

switch state
    case 'done'
        stop = true;
    otherwise
        stop = false;
end

end % monitorUpdate