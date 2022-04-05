
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

% dataset = load('20220321_1748_ol_full_pendulum_swing_90');
dataset = load('20220314_1650_sinesweep_0p75V_exp07');
run('m0405_fmincon_sim_init');

%% TUNABLE PARAMETERS

tun_pars_limits.l1 = [0.5, 2];
tun_pars_limits.l2 = [0.5, 2];
tun_pars_labels = string(fields(tun_pars_limits));
               
x_fmincon = nan(size(tun_pars_labels));
x_lb_fmincon = nan(size(tun_pars_labels));
x_ub_fmincon = nan(size(tun_pars_labels));
x_0_fmincon = nan(size(tun_pars_labels));

for i = 1:length(tun_pars_labels)
    x_lb_fmincon(i) = PARAMS.(tun_pars_labels(i))*tun_pars_limits.(tun_pars_labels(i))(1);
    x_ub_fmincon(i) = PARAMS.(tun_pars_labels(i))*tun_pars_limits.(tun_pars_labels(i))(2);
    x_0_fmincon(i)  = PARAMS.(tun_pars_labels(i));
end

%% OPTIMIZATION VARIABLES

weights.theta = 1;
weights.alpha = 1;
weights.theta_dot = 1;
weights.alpha_dot = 1;

%% FUNCTION HANDLES

fmincon_cost_handle = @(sim_res) fmincon_cost_fcn(sim_res, dataset, weights);
sim_handle = @(x) fmincon_simulate(x, tun_pars_labels, PARAMS, fmincon_cost_handle);

%% OPTIMIZATION

x_opt = fmincon(sim_handle,x_0_fmincon,[],[],[],[],x_lb_fmincon,x_ub_fmincon);
