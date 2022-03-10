
clc;
clearvars;
close all;

%% PATHS

paths.file_fullpath = matlab.desktop.editor.getActiveFilename;
[paths.file_path, ~, ~] = fileparts(paths.file_fullpath);
paths.mainfolder_path   = strsplit(paths.file_path, 'ACL_LABisca');
paths.mainfolder_path   = fullfile(string(paths.mainfolder_path(1)), 'ACL_LABisca');
paths.data_folder       = fullfile(string(paths.mainfolder_path), "Data");
paths.scripts_folder    = fullfile(string(paths.mainfolder_path), "Scripts");
paths.simulation_folder = fullfile(string(paths.mainfolder_path), "Simulation");
addpath(genpath(paths.file_path        ));
addpath(genpath(paths.data_folder      ));
addpath(genpath(paths.scripts_folder   ));
addpath(genpath(paths.simulation_folder));

%% SETTINGS

run('graphics_options.m');

%% LOAD DATASET

load_experiment_name = '20220304_1252_all_in_one_05V.mat';
log = load(load_experiment_name);

%% PLOTS

figure;
sgtitle("Experiment: " + string(strrep(strrep(load_experiment_name, ".mat", ""), "_", "\_")));

sub(1) = subplot(3,1,1);
plot(log.time, log.voltage); hold on; grid on;
ylabel('$Voltage\;[V]$');

sub(2) = subplot(3,1,2);
plot(log.time, log.theta*180/pi); hold on; grid on;
ylabel('$\theta\;[deg]$');

sub(3) = subplot(3,1,3);
plot(log.time, log.alpha*180/pi); hold on; grid on;
ylabel('$\alpha\;[deg]$');
xlabel('$time\;[s]$');

linkaxes(sub, 'x');
