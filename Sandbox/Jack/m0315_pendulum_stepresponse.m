
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

% load_experiment_name = '20220314_1544_pendulum_0p5V_constrainedalpha_th0eq0_exp03.mat';
% load_experiment_name = '20220314_1545_pendulum_1V_constrainedalpha_th0eq0_exp03.mat';
% load_experiment_name = '20220314_1554_pendulum_1p5V_alphaconstrained_th0eq0_exp03.mat';
% load_experiment_name = '20220314_1558_pendulum_1p5V_alphaconstrained_th0eq135_exp03.mat';
% load_experiment_name = '20220314_1601_pendulum_1V_alphaconstrained_th0eq270_exp03.mat';
load_experiment_name = '20220314_1611_pendulum_1V_alphaconstrained_nocable_exp04.mat'; tend = 0.875;
% load_experiment_name = '20220314_1613_pendulum_0p5V_alphaconstrained_nocable_exp04.mat';
% load_experiment_name = '20220314_1617_pendulum_1p5V_th0eq0_exp03.mat';
log = load(load_experiment_name);

%% SIGNAL PROCESSING

voltage = log.voltage(log.time <= tend);
alpha   = log.alpha(log.time <= tend);
theta   = log.theta(log.time <= tend);
time    = log.time(log.time <= tend);

%% SIGNAL FILTERING

dt = mean(diff(log.time));
s = tf('s');
omega_cut = 25*2*pi;
filter = 1/(1+s/omega_cut);
[num,den] = tfdata(c2d(filter, dt), 'v');

theta_filtered = filtfilt(num, den, log.theta);
alpha_filtered = filtfilt(num, den, log.alpha);
theta_dot = gradient(theta_filtered, log.time);
alpha_dot = gradient(alpha_filtered, log.time);
theta_dot = theta_dot(log.time <= tend);
alpha_dot = alpha_dot(log.time <= tend);

%% PLOTS

figure;
sgtitle("Experiment: " + string(strrep(strrep(load_experiment_name, ".mat", ""), "_", "\_")));

sub(1) = subplot(3,1,1);
plot(time, voltage); hold on; grid on;
ylabel('$Voltage\;[V]$');

sub(2) = subplot(3,1,2);
plot(time, theta*180/pi); hold on; grid on;
ylabel('$\theta\;[deg]$');

sub(3) = subplot(3,1,3);
plot(time, alpha*180/pi); hold on; grid on;
ylabel('$\alpha\;[deg]$');
xlabel('$time\;[s]$');

linkaxes(sub, 'x');

figure;
sgtitle("Experiment: " + string(strrep(strrep(load_experiment_name, ".mat", ""), "_", "\_")));

G_V_tau = PARAMS.ki/(s*PARAMS.Lm + PARAMS.Rm);
tau = lsim(G_V_tau, voltage - PARAMS.kv*theta_dot, time);
sub(1) = subplot(3,1,1);
plot(time, tau); hold on; grid on;
ylabel('$\tau\;[V]$');

sub(2) = subplot(3,1,2);
plot(time, theta_dot*180/pi); hold on; grid on;
ylabel('$\dot{\theta}\;[deg/s]$');

sub(3) = subplot(3,1,3);
plot(time, alpha_dot*180/pi); hold on; grid on;
ylabel('$\dot{\alpha}\;[deg/s]$');
xlabel('$time\;[s]$');

linkaxes(sub, 'x');

%% TRANSFER FUNCTION ANALYSIS

figure;
title('Simulated Response VS Real Response');
plot(time, theta_dot); hold on; grid on;
ylabel('$\dot{\theta}\;[rad/s]$');

Jnoa_tot_theoretical = PARAMS.Jh + PARAMS.Jm + (PARAMS.Lr^2*PARAMS.mr)/3 + PARAMS.Lr^2*PARAMS.mp;
Cth_theoretical = PARAMS.Cth;

% Tinf = 0.21; omega_pole = 5/Tinf;
% Jnopend = Cth/omega_pole;
G_thdot_tau_theoretical = 1/(Jnoa_tot_theoretical*s + Cth_theoretical);
theta_dot_theoretical = lsim(G_thdot_tau_theoretical, tau, time);
plot(time, theta_dot_theoretical);
xlim([0 0.5]);
