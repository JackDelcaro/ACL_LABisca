
clc
clearvars
close all

%% PATHS
paths.file_fullpath = matlab.desktop.editor.getActiveFilename;
[paths.file_path, ~, ~] = fileparts(paths.file_fullpath);

paths.mainfolder_path       = strsplit(paths.file_path, 'ACL_LABisca');
paths.mainfolder_path       = fullfile(string(paths.mainfolder_path(1)), 'ACL_LABisca');
paths.scripts_folder        = fullfile(string(paths.mainfolder_path), "Scripts");
paths.sim_folder            = fullfile(string(paths.mainfolder_path), "Simulation");
paths.sim_utils_folder      = fullfile(string(paths.sim_folder), "Utils");
addpath(genpath(paths.file_path       ));
addpath(genpath(paths.scripts_folder  ));
addpath(genpath(paths.sim_utils_folder));

run('graphics_options.m');

%% INPUT EXPERIMENT

dt = 2e-3;
standby_duration = 3; % [s]
% Steps Parameters
steps_amplitude = [0.1 0.2 0.5 0.8 1];
steps_duration = 4; % [s]
% Ramps Parameters
ramps_amplitude = [0.1 0.2 0.5 0.8 1];
ramps_duration = [2 2 2 5 5]; % [s]
ramps_backoff_duration = 1;
% Sine Sweep Parameters
sweep_params = [0.05 10 30]; % [ initial_frequency [Hz], final_frequency [Hz], duration [s] ]
% sine sweep can be 'linear' or 'exponential'
% Sinusoids Parameters
sinusoid_freq = [0.1 0.4 1 5 8]; % frequencies in [Hz]

[time1,experiment1] = create_input_experiment(dt, standby_duration,...
                    'steps', steps_amplitude, steps_duration, ...
                    'ramps', ramps_amplitude, ramps_duration, ramps_backoff_duration, ...
                    'sweep', sweep_params, 'exponential', ...
                    'sinusoids', sinusoid_freq);
                
[time2,experiment2] = input_generator(dt, standby_duration,...
                    'sinusoids', sinusoid_freq,...
                    'sweep', sweep_params, 'exponential', ...
                    'steps', steps_amplitude, steps_duration, ...
                    'ramps', ramps_amplitude, ramps_duration, ramps_backoff_duration, ...
                    'steps', steps_amplitude, steps_duration, ...
                    'sweep', sweep_params, 'exponential', ...
                    'sinusoids', sinusoid_freq);
figure;
plot(time1,experiment1); grid on;
figure;
plot(time2,experiment2); grid on;