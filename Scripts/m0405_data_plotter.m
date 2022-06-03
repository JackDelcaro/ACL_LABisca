
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

sub(1) = subplot(4,1,1);
plot(Log_data.time, Log_data.voltage); hold on; grid on;
ylabel('$Voltage\;[V]$');

sub(2) = subplot(4,1,2);
if any(fields(Log_data) == "theta_ref")
    plot(Log_data.time, Log_data.theta_ref*180/pi, 'color', colors.matlab(2), 'DisplayName', 'reference'); hold on; grid on;
end
plot(Log_data.time, Log_data.theta*180/pi, 'color', colors.matlab(1), 'DisplayName', 'data'); hold on; grid on;
ylabel('$\theta\;[deg]$');
legend;

sub(3) = subplot(4,1,3);
alpha = Log_data.alpha*180/pi;
while any(alpha > 270 | alpha < -270)
    alpha(alpha > 270) = alpha(alpha > 270) - 360;
    alpha(alpha < -270) = alpha(alpha < -270) + 360;
end
if any(fields(Log_data) == "alpha_ref")
    plot(Log_data.time, Log_data.alpha_ref*180/pi, 'color', colors.matlab(2), 'DisplayName', 'reference'); hold on; grid on;
end
plot(Log_data.time, alpha, 'color', colors.matlab(1), 'DisplayName', 'data');
if any(fields(Log_data) == "controller_switch")
    plot(Log_data.time, Log_data.controller_switch*90, 'color', colors.matlab(3), 'DisplayName', 'switch'); hold on; grid on;
end
legend;
ylabel('$\alpha\;[deg]$');
xlabel('$time\;[s]$');



if any(fields(Log_data) == "k_th") && any(fields(Log_data) == "k_delta") && any(fields(Log_data) == "k_ome")
    
    sub(4) = subplot(4,1,4); hold on;
    plot(Log_data.time, Log_data.k_th/8.4870e-04, 'color', colors.matlab(1), 'DisplayName', 'k\_th');
    plot(Log_data.time, Log_data.k_delta/1.9586e-05, '--', 'color', colors.matlab(2), 'DisplayName', 'k\_delta');
    plot(Log_data.time, Log_data.k_ome/1.1751e-05, ':', 'color', colors.matlab(3), 'DisplayName', 'k\_ome');
    legend;
    xlabel('$time\;[s]$');

end

linkaxes(sub, 'x');