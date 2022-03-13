
clc;
clearvars;
close all;

warning('off','MATLAB:handle_graphics:exceptions:SceneNode');
warning('off','MATLAB:Figure:SetPosition');
warning('off','MATLAB:DELETE:Permission');
warning('off', 'MATLAB:onCleanup:DoNotSave');
% warning('on', 'verbose');

%% PATHS

paths.file_fullpath = matlab.desktop.editor.getActiveFilename;
[paths.file_path, ~, ~] = fileparts(paths.file_fullpath);

paths.mainfolder_path       = strsplit(paths.file_path, 'ACL_LABisca');
paths.mainfolder_path       = fullfile(string(paths.mainfolder_path(1)), 'ACL_LABisca');
paths.data_folder           = fullfile(string(paths.mainfolder_path), "Data");
paths.raw_data_folder       = fullfile(string(paths.data_folder), "Raw_Data");
paths.parsed_data_folder    = fullfile(string(paths.data_folder), "Parsed_Data");
paths.scripts_folder        = fullfile(string(paths.mainfolder_path), "Scripts");
paths.sim_folder            = fullfile(string(paths.mainfolder_path), "Simulation");
paths.sim_log_folder        = fullfile(string(paths.sim_folder), "Log");
paths.sim_data_folder       = fullfile(string(paths.sim_folder), "Data");
addpath(genpath(paths.file_path     ));
addpath(genpath(paths.data_folder   ));
addpath(genpath(paths.scripts_folder));
addpath(genpath(paths.sim_folder    ));

%% SETTINGS

save_log = 1;
save_output = 1;
parallel_pool = 1;
number_of_workers = 2;
iteration_number = 10;
seed_number = 8;
output_folder = paths.sim_data_folder;
date_string = datestr(now, 'yyyymmdd_HHMM_');
max_colorbar = inf;
run('graphics_options.m');
run('m0311_bayesopt_params.m');
loss_weights.theta = 1; loss_weights.alpha = 0;
load_experiment_name = '20220304_1252_all_in_one_05V_cut2.mat';
log = load(load_experiment_name);

%% OPTIMIZATION VARIABLES

tuner.Dth_multiplier = 1;
tuner_limits.Dth_multiplier = [0.2 1.5];
tuner.Sth_multiplier = 1;
tuner_limits.Sth_multiplier = [0.5 1.5];
tuner.K_multiplier = 1;
tuner_limits.K_multiplier = [0.5 1.5];
tuner.Jh_additive = 0;
% tuner_limits.Jh_additive = [0 1]*1e-7;
tuner.Cal_multiplier = 1;
% tuner_limits.Cal_multiplier = [0.5 1.5];
tuner.Cth_multiplier = 1;
% tuner_limits.Cth_multiplier = [0.5 1.5];

%% BAYESIAN OPTIMIZATION

bayesopt_XTrace_clippedplot = @(results,state) bayesopt_XTrace_plot(results,state, max_colorbar);
opt_vars = get_opt_vars(tuner_limits);

cd(paths.sim_folder);

dt = 2e-4;
sim_in.voltage = [log.time, log.voltage];
T_sim = log.time(end);

% The following lines are used to enable the parallel workers
if parallel_pool == 1
    % We check if a pool of worker has already been initialized
    p = gcp('nocreate'); % If no pool is active, do not create new one.
    if isempty(p)
        previous_poolsize = 0;
    else
        previous_poolsize = p.NumWorkers;
    end
    if previous_poolsize ~= number_of_workers
        myCluster = parcluster('local');
        delete(myCluster.Jobs);
        delete(p);
        p = parpool(number_of_workers);
    end
    
    % We save the variables which are needed inside the simulation
    save(string(date_string) + "tmp.mat", 'sim_in',...
        'PARAMS','dt','T_sim','tuner');
end

% We create a mutex for the common resources of the parallel workers
try
    cache_ctrl = mps.cache.control('myMATFileConnection','Redis','Port', 4519);
catch
    cache_ctrl = mps.cache.control('myMATFileConnection');
end
try
    start(cache_ctrl);
catch
end

if save_log == 1 
    sim_handle = @(x) BO_simulation(x, log, loss_weights, save_log, paths.sim_log_folder, parallel_pool, date_string);
else
    sim_handle = @(x) BO_simulation(x, log, loss_weights, save_log, paths.sim_log_folder, parallel_pool, date_string);
end
if save_output == 1
    save_mutex_lock = mps.sync.mutex('mySavefileMutex','Connection','myMATFileConnection');
    savefile_name = fullfile(paths.sim_data_folder, date_string + "optimization_result.mat");
    iteration_savefile_name = fullfile(paths.sim_data_folder, date_string + "iteration_result.mat");
    save(savefile_name, 'sim_in', 'load_experiment_name', 'tuner',...
        'tuner_limits','PARAMS','loss_weights', '-v7.3');
    iterative_save_fcn = @(results,state) bayesopt_iterative_save_fcn(results,state,iteration_savefile_name,save_mutex_lock);
else
    iterative_save_fcn = @(results,state) bayesopt_out_fcn(results,state);
end
tic;
bayesopt_res =  bayesopt(sim_handle, opt_vars, ...
                'AcquisitionFunctionName', 'expected-improvement-plus', ...
                'ExplorationRatio', 0.5,...
                'IsObjectiveDeterministic', true, ...
                'MaxObjectiveEvaluations', iteration_number, ...
                'NumSeedPoints', seed_number, ...
                'UseParallel', parallel_pool, ...
                'ParallelMethod', 'clipped-model-prediction',...
                'OutputFcn', iterative_save_fcn,...
                'PlotFcn', {@bayesopt_xnorm_plot, ...
                            @plotObjective, bayesopt_XTrace_clippedplot},...
                'Verbose', 1);

elapsedTime = toc;
display(['Elapsed Time: ', num2str(elapsedTime)]);

if save_output == 1
    save(savefile_name, 'bayesopt_res', '-append');
    delete(iteration_savefile_name);
end
if parallel_pool == 1
    delete(fullfile(paths.sim_folder,  string(date_string) + "tmp.mat"));
    try
        stop(cache_ctrl);
    catch
    end
end

create_unique_log(paths.sim_log_folder, date_string);


% FUNCTIONS

function  loss_function = BO_simulation(in, real_data, loss_weights, verbose_log, log_folder,...
    parallel_pool, date_string)

    if nargin == 1
        verbose_log = 0;
        log_folder = pwd;
        parallel_pool = 0;
        date_string = '';
    elseif nargin == 2
        log_folder = pwd;
        parallel_pool = 0;
        date_string = '';
    elseif nargin == 3
        parallel_pool = 0;
        date_string = '';
    end
    
    persistent count;
    if isempty(count)
        count = 0;
    end
    count = count + 1;
    
    tuner = table2struct(in);
    tuner_labels = string(fields(tuner));
    if ~any(tuner_labels == "Jh_additive")
        tuner.Jh_additive = 0;
    end
    if ~any(tuner_labels == "Cth_multiplier")
        tuner.Cth_multiplier = 1;
    end
    if ~any(tuner_labels == "Cal_multiplier")
        tuner.Cal_multiplier = 1;
    end
    if ~any(tuner_labels == "Dth_multiplier")
        tuner.Dth_multiplier = 1;
    end
    if ~any(tuner_labels == "K_multiplier")
        tuner.K_multiplier = 1;
    end
    if ~any(tuner_labels == "Sth_multiplier")
        tuner.Sth_multiplier = 1;
    end
    assignin('base','tuner', tuner);
    
    if parallel_pool == 1
        assignin('base', "date_string", date_string);
        evalin('base', "if(~exist('T_sim','var'))  load(string(date_string) + ""tmp.mat""); end");
        t = getCurrentTask();
    end
    % Generate output log filename
    if verbose_log == 1
        if(parallel_pool == 1 && ~isempty(t))
            output_log_filename = string(log_folder) + filesep + string(date_string) + "log" + num2str(t.ID) + ".txt";
        else
            output_log_filename = string(log_folder) + filesep + string(date_string) + "log.txt";
        end
    end
    
    if verbose_log == 1
        if parallel_pool == 1 && ~isempty(t)
            fID = fopen(output_log_filename, 'a');
            if fID ~= -1
                fprintf(fID, "Iteration Number: %d, Worker ID: %d\n", count, t.ID);
                fclose(fID);
            end
        else
            fID = fopen(output_log_filename, 'a');
            if fID ~= -1
                fprintf(fID, "Iteration Number: %d\n", count);
                fclose(fID);
            end
        end
    end
    
        
    if parallel_pool == 1 && verbose_log == 1
%         try
            diary(output_log_filename);
%         catch
%         end
    end
    
    out = sim('s0311_Bayesopt_SimulatorParameters.slx');
    
    if parallel_pool == 1 && verbose_log == 1
        diary off;
        fclose('all');
    end
    
    % We now compute the cost function with the simulation outputs
    range = 2:(length(out.tout)-1);
    time = out.tout(range);
    
    theta_real = interp1(real_data.time, real_data.theta, time, 'linear', 'extrap')*180/pi;
    theta_sim = out.theta(range)*180/pi;
    alpha_real = interp1(real_data.time, real_data.alpha, time, 'linear', 'extrap')*180/pi;
    alpha_sim = out.alpha(range)*180/pi;
    
    rms_theta    = sqrt(mean((theta_real - theta_sim).^2));
    rms_alpha    = sqrt(mean((alpha_real - alpha_sim).^2));
    
    loss_function = loss_weights.theta * rms_theta + loss_weights.alpha * rms_alpha;
    
end

function stop = bayesopt_out_fcn(results,state) %#ok<INUSD>
    stop = false;
end

function stop = bayesopt_iterative_save_fcn(results,state,savefile_name,mutex_lock)
    stop = false;
    if state == "iteration"
        acquire(mutex_lock, 10);
        save(savefile_name, 'results');
        release(mutex_lock);
    end
end

function stop = bayesopt_xnorm_plot(results,state)
    persistent plot_handle is_first_iteration;
    stop = false;
    switch state
        case 'initial'
            figure;
            hold on; grid on;
            xlabel('Iteration number');
            title('Distance between tested points');
            plot_handle = plot(1,1,'marker','.');
            is_first_iteration = 1;
        case 'iteration'
            if is_first_iteration
                is_first_iteration = 0;
            else
                dist = sqrt(sum((table2array(results.XTrace(2:end, :))-...
                    table2array(results.XTrace(1:(end-1), :))).^2, 2));
                set(plot_handle,'XData',1:length(dist),'YData',dist);
            end
    end
end
