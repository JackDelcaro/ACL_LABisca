
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

run('m0303_params.m');

load_experiment_name = '20220304_1252_all_in_one_05V.mat';
log = load(load_experiment_name);

in_voltage = [log.time, log.voltage];
T_sim = log.time(end);
dt_control = 2e-2;
dt = 1e-4;

%% SIMULATION

out = sim("s0310_main.slx");

%% RESULTS

figure;
sgtitle("Simulation Results");

sub(1) = subplot(3,2,1);
plot(t_tot, in_voltage(:,2)); hold on; grid on;
ylabel('$Voltage\;[V]$');

sub(3) = subplot(3,2,3);
plot(t_tot, out.theta*180/pi); hold on; grid on;
ylabel('$\theta\;[deg]$');

sub(5) = subplot(3,2,5);
plot(t_tot, out.alpha*180/pi); hold on; grid on;
ylabel('$\alpha\;[deg]$');
xlabel('$time\;[s]$');

sub(2) = subplot(3,2,2);
plot(t_tot, out.tau); hold on; grid on;
ylabel('$\tau\;[Nm]$');

sub(4) = subplot(3,2,4);
plot(t_tot, out.theta_dot*180/pi); hold on; grid on;
ylabel('$\dot{\theta}\;[deg/s]$');

sub(6) = subplot(3,2,6);
plot(t_tot, out.alpha_dot*180/pi); hold on; grid on;
ylabel('$\dot{\alpha}\;[deg/s]$');
xlabel('$time\;[s]$');

linkaxes(sub, 'x');

% SIGNAL FILTERING

dt = mean(diff(log.time));
s = tf('s');
omega_cut = 100*2*pi;
filter = 1/(1+s/omega_cut);
[num,den] = tfdata(c2d(filter, dt), 'v');

theta_filtered = filtfilt(num, den, log.theta);
alpha_filtered = filtfilt(num, den, log.alpha);
figure;
sgtitle("Experiment: " + string(strrep(strrep(load_experiment_name, ".mat", ""), "_", "\_")));

sub(1) = subplot(3,2,1);
plot(log.time, log.voltage); hold on; grid on;
ylabel('$Voltage\;[V]$');

sub(3) = subplot(3,2,3);
plot(log.time, theta_filtered*180/pi); hold on; grid on;
ylabel('$\theta\;[deg]$');

sub(5) = subplot(3,2,5);
plot(log.time, alpha_filtered*180/pi); hold on; grid on;
ylabel('$\alpha\;[deg]$');
xlabel('$time\;[s]$');

tau = PARAMS.ki/PARAMS.Rm * log.voltage;
sub(2) = subplot(3,2,2);
plot(log.time, tau); hold on; grid on;
ylabel('$\tau\;[Nm]$');

theta_dot = gradient(theta_filtered, log.time);
sub(4) = subplot(3,2,4);
plot(log.time, theta_dot*180/pi); hold on; grid on;
ylabel('$\dot{\theta}\;[deg/s]$');

alpha_dot = gradient(alpha_filtered, log.time);
sub(6) = subplot(3,2,6);
plot(log.time, alpha_dot*180/pi); hold on; grid on;
ylabel('$\dot{\alpha}\;[deg/s]$');
xlabel('$time\;[s]$');

linkaxes(sub, 'x');