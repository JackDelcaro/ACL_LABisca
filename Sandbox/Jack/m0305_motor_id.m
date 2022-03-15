
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
run('m0303_params.m');

%% LOAD DATASET

load_experiment_name = '20220304_1205_no_pendulum_1V.mat';
log = load(load_experiment_name);

%% SIGNAL FILTERING

dt = mean(diff(log.time));
s = tf('s');
omega_cut = 100*2*pi;
filter = 1/(1+s/omega_cut);
[num,den] = tfdata(c2d(filter, dt), 'v');

theta_filtered = filtfilt(num, den, log.theta);
alpha_filtered = filtfilt(num, den, log.alpha);

%% PLOTS

figure;
sgtitle("Experiment: " + string(strrep(strrep(load_experiment_name, ".mat", ""), "_", "\_")));

sub(1) = subplot(3,1,1);
plot(log.time, log.voltage); hold on; grid on;
ylabel('$Voltage\;[V]$');

sub(2) = subplot(3,1,2);
plot(log.time, theta_filtered*180/pi); hold on; grid on;
ylabel('$\theta\;[deg]$');

sub(3) = subplot(3,1,3);
plot(log.time, alpha_filtered*180/pi); hold on; grid on;
ylabel('$\alpha\;[deg]$');
xlabel('$time\;[s]$');

linkaxes(sub, 'x');

figure;
sgtitle("Experiment: " + string(strrep(strrep(load_experiment_name, ".mat", ""), "_", "\_")));

tau = PARAMS.ki/PARAMS.Rm * log.voltage;
sub(1) = subplot(3,1,1);
plot(log.time, tau); hold on; grid on;
ylabel('$\tau\;[V]$');

theta_dot = gradient(theta_filtered, log.time);
sub(2) = subplot(3,1,2);
plot(log.time, theta_dot*180/pi); hold on; grid on;
ylabel('$\dot{\theta}\;[deg/s]$');

alpha_dot = gradient(alpha_filtered, log.time);
sub(3) = subplot(3,1,3);
plot(log.time, alpha_dot*180/pi); hold on; grid on;
ylabel('$\dot{\alpha}\;[deg/s]$');
xlabel('$time\;[s]$');

linkaxes(sub, 'x');

%% TRANSFER FUNCTION ANALYSIS

figure;
title('Unitary Step Response');
plot(log.time, theta_dot./tau); hold on; grid on;
ylabel('$\dot{\theta}\;[rad/s]$');
gain = mean(theta_dot(log.time>2 & log.time <9)./tau(log.time>2 & log.time <9));
Cal = 1/gain;
Tinf = 0.21; omega_pole = 5/Tinf;
Jnopend = Cal/omega_pole;
G_thdot_tau = 1/(Jnopend*s + Cal);
simulated_thdot = step(G_thdot_tau, log.time);
plot(log.time, simulated_thdot);
xlim([0 0.5]);
