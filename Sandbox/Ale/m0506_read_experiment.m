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

%% INITIALIZATION

dt = 2e-5;
dt_control = 2e-3;
run('m0405_params.m');
% mech_simulator_model = "s0318_mechanical_simulator";
% motor_simulator_model = "s0303_motor_simulator";

dataset = load("20220314_1640_varin_exp07.mat");

%% DERIVATIVES

dt_dataset = mean(diff(dataset.time));
omega_cut_1 = 18*2*pi;
omega_cut_2 = 30*2*pi;
s = tf('s');
% filter = 1/(1+s/omega_cut_1)/(1+s/omega_cut_2);
% [num,den] = tfdata(c2d(filter, dt_dataset), 'v');

tmp = sgolayfilt(dataset.theta, 1, 51);
dataset.theta_filtered = sgolayfilt(tmp, 1, 25);

tmp = sgolayfilt(dataset.alpha, 1, 51);
dataset.alpha_filtered = sgolayfilt(tmp, 1, 25);

% dataset.theta_filtered = filtfilt(num, den, dataset.theta);
% dataset.alpha_filtered = filtfilt(num, den, dataset.alpha);

dataset.theta_dot = gradient(dataset.theta_filtered, dataset.time);
dataset.alpha_dot = gradient(dataset.alpha_filtered, dataset.time);


tmp = sgolayfilt(dataset.theta_dot, 1, 51);
dataset.theta_dot_filtered = sgolayfilt(tmp, 1, 25);

tmp = sgolayfilt(dataset.alpha_dot, 1, 51);
dataset.alpha_dot_filtered = sgolayfilt(tmp, 1, 25);

% dataset.theta_filtered = filtfilt(num, den, dataset.theta);
% dataset.alpha_filtered = filtfilt(num, den, dataset.alpha);

dataset.theta_ddot = gradient(dataset.theta_dot_filtered, dataset.time);
dataset.alpha_ddot = gradient(dataset.alpha_dot_filtered, dataset.time);


%% FIGURES

figure;
sgtitle("Experiment Results");

sub(1) = subplot(3,1,1);
plot(dataset.time, dataset.voltage); hold on; grid on;
ylabel('$Voltage\;[V]$');

sub(2) = subplot(3,1,2);
plot(dataset.time, dataset.theta*180/pi); hold on; grid on;
%plot(dataset.time, dataset.theta_ref*180/pi, 'DisplayName', 'Reference');

legend;
ylabel('$\theta\;[deg]$');

sub(3) = subplot(3,1,3);
plot(dataset.time, dataset.alpha*180/pi); hold on; grid on;
%plot(dataset.time, dataset.alpha_ref*180/pi, 'DisplayName', 'Reference');
legend;
ylabel('$\alpha\;[deg]$');
xlabel('$time\;[s]$');
linkaxes(sub, 'x');
clearvars sub;

figure;
sgtitle("Experiment Results");


sub(1) = subplot(2,1,1);
plot(dataset.time, dataset.theta_dot*180/pi); hold on; grid on;
%plot(dataset.time, dataset.theta_ref*180/pi, 'DisplayName', 'Reference');

legend;
ylabel('$\theta_dot\;[deg/s]$');

sub(2) = subplot(2,1,2);
plot(dataset.time, dataset.alpha_dot*180/pi); hold on; grid on;
%plot(dataset.time, dataset.alpha_ref*180/pi, 'DisplayName', 'Reference');
legend;
ylabel('$\alpha_dot\;[deg/s]$');
xlabel('$time\;[s]$');
linkaxes(sub, 'x');
clearvars sub;

figure;
sgtitle("Experiment Results");


sub(1) = subplot(2,1,1);
plot(dataset.time, dataset.theta_ddot*180/pi); hold on; grid on;
%plot(dataset.time, dataset.theta_ref*180/pi, 'DisplayName', 'Reference');

legend;
ylabel('$\theta_ddot\;[deg/s^2]$');

sub(2) = subplot(2,1,2);
plot(dataset.time, dataset.alpha_ddot*180/pi); hold on; grid on;
%plot(dataset.time, dataset.alpha_ref*180/pi, 'DisplayName', 'Reference');
legend;
ylabel('$\alpha_ddot\;[deg/s^2]$');
xlabel('$time\;[s]$');
linkaxes(sub, 'x');
clearvars sub;


