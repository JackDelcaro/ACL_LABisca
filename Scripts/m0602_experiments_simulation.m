
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

%% DATASET SELECTION

[filename, path] = uigetfile(paths.parsed_data_folder);
filename = string(filename)';
log_data = load(filename);

%% SIMULATION PARAMETERS

dt = 2e-4;
dt_control = 2e-3;
run('m0405_params.m');

%% SIMULATION

T_sim = log_data.time(end);
simin.theta_ref = [log_data.time, log_data.theta_ref];
simin.alpha_ref = pi;
PARAMS.th_0 = -log_data.theta(1);
PARAMS.al_0 = log_data.alpha(1);

simout = sim('s0602_resim.slx');

log_data.alpha_sim = interp1(simout.alpha.Time, simout.alpha.Data, log_data.time);
log_data.alpha_dot_sim = interp1(simout.alpha_dot.Time, simout.alpha_dot.Data, log_data.time);
log_data.theta_sim = interp1(simout.theta.Time, simout.theta.Data, log_data.time);
log_data.theta_dot_sim = interp1(simout.theta_dot.Time, simout.theta_dot.Data, log_data.time);
log_data.controller_switch_sim = interp1(simout.controller_switch.Time, simout.controller_switch.Data, log_data.time);
log_data.voltage_sim = interp1(simout.voltage.Time, simout.voltage.Data, log_data.time);


%% SAVE FILE

tmp = char(filename);
date_string = tmp(1:14);
label = tmp(15:end);
save_filename = fullfile(paths.resim_parsed_data_folder, string(date_string) + ...
    "RESIM_" + string(label));
save(save_filename, '-struct', 'log_data');
