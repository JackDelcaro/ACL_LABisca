
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

%% LOAD DATA

load_experiment_name = '20220314_1640_varin_exp07.mat';
tstart = 0; tend = inf;
log = load(load_experiment_name);

%% SIGNAL PROCESSING

voltage = log.voltage(log.time >= tstart & log.time <= tend);
alpha   = log.alpha(log.time >= tstart & log.time <= tend);
theta   = log.theta(log.time >= tstart & log.time <= tend);
time    = log.time(log.time >= tstart & log.time <= tend);

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
theta_dot = theta_dot(log.time >= tstart & log.time <= tend);
alpha_dot = alpha_dot(log.time >= tstart & log.time <= tend);

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
ylabel('$\tau\;(approx)\;[Nm]$');

sub(2) = subplot(3,1,2);
plot(time, theta_dot*180/pi); hold on; grid on;
ylabel('$\dot{\theta}\;[deg/s]$');

sub(3) = subplot(3,1,3);
plot(time, alpha_dot*180/pi); hold on; grid on;
ylabel('$\dot{\alpha}\;[deg/s]$');
xlabel('$time\;[s]$');

linkaxes(sub, 'x');

Jnopend = 8.138e-6;
Jtot_theoretical = Jnopend + (PARAMS.Lr^2*PARAMS.mr)/3 + PARAMS.Lr^2*PARAMS.mp;

%% FRICTION PLOTS

figure;
plot(time, tau, 'DisplayName', 'tau'); hold on; grid on;
plot(time, theta/max(theta)*max(tau), 'DisplayName', 'Rescaled Theta'); hold on; grid on;
xlabel('$Time\;[s]$'); legend;

tau_st_friction = (7.586 + 8.487 + 8.287 + 7.239)*1e-4/4;