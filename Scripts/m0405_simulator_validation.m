
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
% run('m0405_params.m');
dt_control = 2e-3;

%% INPUT EXPERIMENT

% dataset_name = '20220321_1748_ol_full_pendulum_swing_90';
% dataset_name = '20220314_1650_sinesweep_0p75V_exp07'; % optimization
% dataset_name = '20220314_1640_varin_exp07';
% dataset_name = '20220314_1640_varin_exp07_cut_ramps';
dataset_name = '20220314_1640_varin_exp07_cut_squarewaves_ramps';
% dataset_name = '20220411_1533_ol_sinesweep_0p75_8';
% dataset_name ='20220411_1527_ol_sinesweep_1p11_20';
dataset = load(dataset_name); % validation
run('m0405_fmincon_sim_init');

%% SIMULATION

simout = sim("s0405_fmincon");

%% RESULTS

f(1) = figure;
reference_color = "#767676";
data_color = colors.blue(4);
simulation_color = colors.blue(1);
   
subplot_handles(1) = subplot(3,1,1); hold on;
plot(dataset.time, dataset.theta*180/pi, 'color', data_color, 'DisplayName', 'Real Data');
plot(simout.theta.Time, simout.theta.Data*180/pi, 'color', simulation_color, 'DisplayName', 'Simulation', 'LineWidth', 1.5);
ylabel('$\theta\;[deg]$');
set(gca,'Xticklabel',[]);
legend;

subplot_handles(2) = subplot(3,1,2); hold on;
plot(dataset.time, dataset.alpha*180/pi, 'color', data_color, 'DisplayName', 'Real Data');
plot(simout.alpha.Time, simout.alpha.Data*180/pi, 'color', simulation_color, 'DisplayName', 'Simulation', 'LineWidth', 1.5);
ylabel('$\alpha\;[deg]$');
set(gca,'Xticklabel',[]);

subplot_handles(3) = subplot(3,1,3); hold on;
plot(dataset.time, dataset.voltage, 'color', data_color, 'DisplayName', 'Voltage'); hold on; grid on;
ylabel('$Voltage\;[V]$');
xlabel('$time\;[s]$');


linkaxes(subplot_handles, 'x');
tmp = get(subplot_handles(1), 'Position');
left_pos = tmp(1);
top_pos = tmp(2);
width = tmp(3);
height = tmp(4);
spacing = 0.025;
set(subplot_handles(2), 'Position', [left_pos, top_pos-height-spacing, width, height]);
set(subplot_handles(3), 'Position', [left_pos, top_pos-2*height-2*spacing, width, height]);
clearvars subplot_handles;
% xlim([8 245])
% xlim([4 37])
xlim([0 216])
drawnow;

f(2) = figure;
   
subplot_handles(1) = subplot(2,1,1); hold on;
plot(dataset.time, dataset.theta*180/pi, 'color', data_color, 'DisplayName', 'Real Data');
plot(simout.theta.Time, simout.theta.Data*180/pi, 'color', simulation_color, 'DisplayName', 'Simulation');
ylabel('$\theta\;[deg]$');
set(gca,'Xticklabel',[]);
legend('Position', [0.827888172197799,0.891084461159731,0.099121976123825,0.097421285966705]);

subplot_handles(2) = subplot(2,1,2); hold on;
plot(dataset.time, dataset.voltage, 'color', data_color, 'DisplayName', 'Voltage'); hold on; grid on;
ylabel('$Voltage\;[V]$');
xlabel('$time\;[s]$');


linkaxes(subplot_handles, 'x');
% xlim([8 245])
% xlim([4 37])
xlim([0 216])
drawnow;

tmp = get(subplot_handles(1), 'Position');
left_pos = tmp(1);
top_pos = tmp(2);
width = tmp(3);
height = tmp(4);
spacing = 0.025;
set(subplot_handles(2), 'Position', [left_pos, top_pos-height-spacing, width, height]);
clearvars subplot_handles;
saveas(f(2), 'tmp2.png');

figure;
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