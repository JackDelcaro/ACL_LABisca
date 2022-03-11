function opt_vars = get_opt_vars(tuner_limits)

    tuner_labels = string(fields(tuner_limits));

    for i = 1:length(tuner_labels)
        opt_vars(i) = optimizableVariable(tuner_labels(i), tuner_limits.(tuner_labels(i)), 'Type', 'real'); %#ok<AGROW>
    end
    
end