
clc;
clearvars;
close all;

%% PATHS

paths.file_fullpath = matlab.desktop.editor.getActiveFilename;
[paths.file_path, ~, ~] = fileparts(paths.file_fullpath);
paths.mainfolder_path    = strsplit(paths.file_path, 'ACL_LABisca');
paths.mainfolder_path    = fullfile(string(paths.mainfolder_path(1)), 'ACL_LABisca');
paths.data_folder        = fullfile(string(paths.mainfolder_path), "Data");
paths.parsed_data_folder = fullfile(string(paths.data_folder), "Parsed_Data");
paths.resim_parsed_data_folder = fullfile(string(paths.data_folder), "Resim_Parsed_Data");
paths.scripts_folder     = fullfile(string(paths.mainfolder_path), "Scripts");
paths.simulation_folder  = fullfile(string(paths.mainfolder_path), "Simulation");
addpath(genpath(paths.file_path        ));
addpath(genpath(paths.data_folder      ));
addpath(genpath(paths.scripts_folder   ));
addpath(genpath(paths.simulation_folder));


%% SETTINGS

run('graphics_options.m');


%% SIMULATION PARAMETERS

dt = 2e-4;
dt_control = 2e-3;
run('m0405_params.m');

%% DATASET SELECTION

[filename, path] = uigetfile(fullfile(paths.parsed_data_folder, "*Lyapunov_pt*"), 'MultiSelect', 'on');
filename = string(filename)';

for file_idx = 1:length(filename)
    
    log_data = load(filename(file_idx));

    %% SIMULATION

    start_idx = find(log_data.controller_switch == 1, 1, 'first') - 1;
    
    T_sim = log_data.time(end) - log_data.time(start_idx);
    simin.theta_ref = [0, log_data.theta_ref(start_idx); T_sim, log_data.theta_ref(start_idx)];
    simin.alpha_ref = 0;
    PARAMS.th_0 = -log_data.theta(start_idx);
    PARAMS.al_0 = log_data.alpha(start_idx);
    
    theta_dot = lsim(der_filt, log_data.theta, log_data.time);
    alpha_dot = lsim(der_filt, log_data.alpha, log_data.time);
    
    PARAMS.th_dot_0 = -theta_dot(start_idx);
    PARAMS.al_dot_0 = alpha_dot(start_idx);
    
    PARAMS.k_th = log_data.k_th(start_idx);
    PARAMS.k_delta = log_data.k_delta(start_idx);
    PARAMS.k_ome = log_data.k_ome(start_idx);

    simout = sim('s0603_Lyapunov_resim.slx');

    log_data.alpha_sim = interp1(simout.alpha.Time + log_data.time(start_idx), simout.alpha.Data, log_data.time);
    log_data.alpha_dot_sim = interp1(simout.alpha_dot.Time + log_data.time(start_idx), simout.alpha_dot.Data, log_data.time);
    log_data.theta_sim = interp1(simout.theta.Time + log_data.time(start_idx), simout.theta.Data, log_data.time);
    log_data.theta_dot_sim = interp1(simout.theta_dot.Time + log_data.time(start_idx), simout.theta_dot.Data, log_data.time);
    log_data.controller_switch_sim = interp1(simout.controller_switch.Time + log_data.time(start_idx), simout.controller_switch.Data, log_data.time);
    log_data.voltage_sim = interp1(simout.voltage.Time + log_data.time(start_idx), simout.voltage.Data, log_data.time);


    %% SAVE FILE

    tmp = char(filename(file_idx));
    date_string = tmp(1:14);
    label = tmp(15:end);
    save_filename = fullfile(paths.resim_parsed_data_folder, string(date_string) + ...
        "RESIM_" + string(label));
    save(save_filename, '-struct', 'log_data');
end