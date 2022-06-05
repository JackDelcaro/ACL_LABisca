
clc;
clearvars;
close all;

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

%% SIMULATION PARAMETERS

% dataset_name = '20220321_1748_ol_full_pendulum_swing_90';
% dataset_name = '20220314_1650_sinesweep_0p75V_exp07';
% dataset_name = '20220314_1640_varin_exp07_cut_ramps';
dataset_name = '20220314_1640_varin_exp07_cut_squarewaves_ramps';
% dataset_name = '20220411_1533_ol_sinesweep_0p75_8';
dataset = load(dataset_name);
run('m0405_fmincon_sim_init');

%% SETTINGS

save_output = 1;
parallel_pool = 1;
number_of_workers = 8;
iteration_number = 1000;
seed_number = 500;

date_string = datestr(now, 'yyyymmdd_HHMM_');
model_name = 's0405_fmincon';

%% OPTIMIZATION VARIABLES

weights.theta = 1; % 0
weights.alpha = 0; % 1
weights.theta_dot = 0.01; % 0.5
weights.alpha_dot = 0; % 0.05

%% PARPOOL INITIALIZATION

if parallel_pool == 1
    % Check if a pool of worker has already been initialized
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
    
    % We initialize each worker
    spmd
        % load variables into base worksapce of each worker
        assignin('base', "dataset", dataset);
        addpath(genpath(paths.scripts_folder));
        evalin('base', "run('m0405_fmincon_sim_init.m');" );
        
        % Setup tempdir and cd into it
        tmpDir = tempname;
        mkdir(tmpDir);
        cd(tmpDir);
        
        % Load the model on the worker
        load_system(model_name);
    end
end

%% TUNABLE PARAMETERS

tun_pars_limits.Dth = [0.5, 2];
tun_pars_limits.Sth = [0.5, 2];
tun_pars_limits.K = [0.5, 2];
% tun_pars_limits.l1 = [0.5, 2];
% tun_pars_limits.l2 = [0.5, 2];
% tun_pars_limits.Cal = [0.1, 2];
% tun_pars_limits.Cth = [0.1, 2];
% tun_pars_limits.mp = [0.5, 2];
% tun_pars_limits.mr = [0.5, 2];

tun_pars_labels = string(fields(tun_pars_limits));

x_lb_fmincon = nan(size(tun_pars_labels));
x_ub_fmincon = nan(size(tun_pars_labels));
x_0_fmincon = nan(size(tun_pars_labels));

for i = 1:length(tun_pars_labels)
    x_lb_fmincon(i) = PARAMS.(tun_pars_labels(i))*tun_pars_limits.(tun_pars_labels(i))(1);
    x_ub_fmincon(i) = PARAMS.(tun_pars_labels(i))*tun_pars_limits.(tun_pars_labels(i))(2);
    x_0_fmincon(i)  = PARAMS.(tun_pars_labels(i));
end

for i = 1:length(tun_pars_labels)
    opt_vars(i) =  optimizableVariable(tun_pars_labels(i), [x_lb_fmincon(i), x_ub_fmincon(i)], 'Type', 'real'); %#ok<SAGROW>
end

%% FUNCTION HANDLES

fmincon_cost_handle = @(sim_res) fmincon_cost_fcn(sim_res, dataset, weights);
sim_handle = @(x) fmincon_simulate(x, tun_pars_labels, PARAMS, fmincon_cost_handle, model_name);

%% OPTIMIZATION

max_colorbar = inf;
bayesopt_XTrace_clippedplot = @(results,state) bayesopt_XTrace_plot(results,state, max_colorbar);

% Bayesian Optimization
disp('-- OPTIMIZATION START --');
tic;
bayes_res = bayesopt(sim_handle, opt_vars, ...
            'AcquisitionFunctionName', 'expected-improvement-plus', ...
            'ExplorationRatio', 0.5, ...
            'IsObjectiveDeterministic', true, ...
            'MaxObjectiveEvaluations', iteration_number, ...
            'NumSeedPoints', seed_number, ...
            'UseParallel', parallel_pool, ...
            'ParallelMethod', 'clipped-model-prediction', ...
            'PlotFcn', {@plotObjective, bayesopt_XTrace_clippedplot}, ...
            'Verbose', 1);
elapsedTime = toc;
disp('-- OPTIMIZATION END --');
fprintf("\n");
disp(['Elapsed Time: ', num2str(elapsedTime)]);

%% SAVE VARIABLES

if parallel_pool == 1    
    % Clean the temporary working directory
    spmd
        cd(paths.file_path);
        rmdir(tmpDir,'s');
        rmpath(paths.scripts_folder);
        close_system(model_name, 0);
    end
end

if save_output == 1
    save(fullfile(paths.sim_data_folder, string(date_string) + "fmincon_opt_N" + num2str(length(x_0_fmincon))),...
        'dataset_name', 'bayes_res', 'opt_vars', 'x_0_fmincon', 'tun_pars_limits', 'x_lb_fmincon', 'x_ub_fmincon', ...
        'tun_pars_labels');
end

%% DISPLAY RESULTS
run('m0405_params.m');
for i = 1:length(tun_pars_labels)
    fprintf(1, "%s simulator: %f  found: %f  percentage: %f\n", tun_pars_labels(i), PARAMS.(tun_pars_labels(i)), bayes_res.XAtMinObjective.(tun_pars_labels(i)), bayes_res.XAtMinObjective.(tun_pars_labels(i))/PARAMS.(tun_pars_labels(i)));
end