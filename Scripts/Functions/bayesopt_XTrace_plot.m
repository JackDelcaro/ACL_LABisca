function stop = bayesopt_XTrace_plot(results,state, max_colorbar)
    persistent fig_handle is_first_iteration subplots_handles colored_graphs_handles impossible_graphs_handles;
    stop = false;
    if nargin == 2
        max_colorbar = inf;
    end
    switch state
        case 'initial'
            fig_handle = figure;
            is_first_iteration = 1;
        case 'iteration'
            if is_first_iteration == 1
                is_first_iteration = 0;
                figure(fig_handle);
                [~, colored_graphs_handles, subplots_handles] = my_plot_table(results.XTrace, [],...
                    min(results.ObjectiveTrace, max_colorbar),...
                    'Marker','.','LineWidth', 1.2,...
                    'Title','Optimization Trace'); hold on;
                labels = string(results.XTrace.Properties.VariableNames)';
                for i = 1:size(colored_graphs_handles, 1)
                    for j = 1:i
                        subplot(subplots_handles(i,j));
                        impossible_graphs_handles(i,j) = scatter(...
                            results.XTrace.(labels(j)),results.XTrace.(labels(i)),...
                            'Marker','x','LineWidth',0.8,'MarkerEdgeColor',0.4*[1 1 1]);
                        set(impossible_graphs_handles(i,j),  'Visible', 'off');
                        set(colored_graphs_handles(i,j),  'Visible', 'off');
                    end
                end
            else
                labels = string(results.XTrace.Properties.VariableNames)';
                plot_number = length(labels);
                colored_range = ~isnan(results.ObjectiveTrace) &  ~isinf(results.ObjectiveTrace);
                impossible_range = ~colored_range;
                colored_objective = results.ObjectiveTrace(colored_range);
                colored_trace = results.XTrace(colored_range,:);
                impossible_trace = results.XTrace(impossible_range,:);
                for i = 1:plot_number
                    for j = 1:i
                        if any(colored_range)
                            set(colored_graphs_handles(i,j),...
                                'XData', colored_trace.(labels(j)),...
                                'YData', colored_trace.(labels(i)),...
                                'CData', min(colored_objective, max_colorbar));
                            set(colored_graphs_handles(i,j),  'Visible', 'on');
                        end
                        if any(impossible_range)
                            set(impossible_graphs_handles(i,j),...
                                'XData', impossible_trace.(labels(j)),...
                                'YData', impossible_trace.(labels(i)));
                            set(impossible_graphs_handles(i,j),  'Visible', 'on');
                        end
                    end
                end
            end
    end
end