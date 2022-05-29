
clc;
clearvars;
% close all;

%% PATHS

paths.file_fullpath = matlab.desktop.editor.getActiveFilename;
[paths.file_path, ~, ~]  = fileparts(paths.file_fullpath);
paths.mainfolder_path    = strsplit(paths.file_path, 'ACL_LABisca');
paths.mainfolder_path    = fullfile(string(paths.mainfolder_path(1)), 'ACL_LABisca');
paths.data_folder        = fullfile(string(paths.mainfolder_path), "Data");
paths.parsed_data_folder = fullfile(string(paths.data_folder), "Parsed_Data");
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
Log_data = load(filename);

%% PLOTS

figure;
sgtitle("Experiment: " + string(strrep(strrep(filename, ".mat", ""), "_", "\_")));

sub(1) = subplot(3,1,1);
plot(Log_data.time, Log_data.voltage); hold on; grid on;
ylabel('$Voltage\;[V]$');

sub(2) = subplot(3,1,2);
if any(fields(Log_data) == "theta_ref")
    plot(Log_data.time, Log_data.theta_ref*180/pi, 'color', colors(2), 'DisplayName', 'reference'); hold on; grid on;
end
plot(Log_data.time, Log_data.theta*180/pi, 'color', colors(1), 'DisplayName', 'data'); hold on; grid on;
ylabel('$\theta\;[deg]$');
legend;

sub(3) = subplot(3,1,3);
if any(fields(Log_data) == "alpha_ref")
    plot(Log_data.time, Log_data.alpha_ref*180/pi, 'color', colors(2), 'DisplayName', 'reference'); hold on; grid on;
end
plot(Log_data.time, Log_data.alpha*180/pi, 'color', colors(1), 'DisplayName', 'data');
legend;
ylabel('$\alpha\;[deg]$');
xlabel('$time\;[s]$');

linkaxes(sub, 'x');