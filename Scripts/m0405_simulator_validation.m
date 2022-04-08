
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

dt = 2e-4;
run('m0405_params.m');
dt_control = 2e-3;

%% INPUT EXPERIMENT

% dataset = load('20220321_1748_ol_full_pendulum_swing_90');
% dataset = load('20220314_1650_sinesweep_0p75V_exp07'); % optimization
% dataset_name = '20220314_1640_varin_exp07';
dataset_name = '20220314_1640_varin_exp07_cut_ramps';
dataset_name = '20220314_1640_varin_exp07_cut_squarewaves_ramps';
dataset = load(dataset_name); % validation
run('m0405_fmincon_sim_init');

%% SIMULATION

simout = sim("s0405_fmincon");

%% RESULTS

figure;
sgtitle("Simulation Results");

sub(1) = subplot(3,1,1);
plot(simout.voltage.Time, simout.voltage.Data); hold on; grid on;
ylabel('$Voltage\;[V]$');

sub(2) = subplot(3,1,2);
plot(simout.theta.Time, simout.theta.Data*180/pi, 'DisplayName', 'Simulated'); hold on; grid on;
% plot(simout.theta_ref.Time, simout.theta_ref.Data*180/pi, 'DisplayName', 'Reference');
plot(dataset.time, dataset.theta*180/pi, 'DisplayName', 'Real Data');
legend;
ylabel('$\theta\;[deg]$');

sub(3) = subplot(3,1,3);
plot(simout.alpha.Time, simout.alpha.Data*180/pi, 'DisplayName', 'Simulated'); hold on; grid on;
% plot(simout.alpha_ref.Time, simout.alpha_ref.Data*180/pi, 'DisplayName', 'Reference');
plot(dataset.time, dataset.alpha*180/pi, 'DisplayName', 'Real Data');
legend;
ylabel('$\alpha\;[deg]$');
xlabel('$time\;[s]$');
linkaxes(sub, 'x');
clearvars sub;

figure
sub(1) = subplot(3,1,1);
plot(simout.tau.Time, simout.tau.Data); hold on; grid on;
ylabel('$\tau\;[Nm]$');

sub(2) = subplot(3,1,2);
plot(simout.theta_dot.Time, simout.theta_dot.Data*180/pi, 'DisplayName', 'Simulated'); hold on; grid on;
plot(dataset.time, dataset.theta_dot*180/pi, 'DisplayName', 'Real Data');
legend;
ylabel('$\dot{\theta}\;[deg/s]$');

sub(3) = subplot(3,1,3);
plot(simout.alpha_dot.Time, simout.alpha_dot.Data*180/pi, 'DisplayName', 'Simulated'); hold on; grid on;
plot(dataset.time, dataset.alpha_dot*180/pi, 'DisplayName', 'Real Data');
legend;
ylabel('$\dot{\alpha}\;[deg/s]$');
xlabel('$time\;[s]$');
linkaxes(sub, 'x');