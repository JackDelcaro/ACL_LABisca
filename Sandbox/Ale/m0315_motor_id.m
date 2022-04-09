
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

load_experiment_name = '20220314_1509_no_pendulum_1V_exp01.mat';
log = load(load_experiment_name);

%% SIGNAL FILTERING

dt = mean(diff(log.time));
s = tf('s');
omega_cut = 20*2*pi;
filter = 1/(1+s/omega_cut);
[num,den] = tfdata(c2d(filter, dt), 'v');

theta_filtered = filtfilt(num, den, log.theta);

%% PLOTS

figure;
sgtitle("Experiment: " + string(strrep(strrep(load_experiment_name, ".mat", ""), "_", "\_")));

sub(1) = subplot(2,1,1);
plot(log.time, log.voltage); hold on; grid on;
ylabel('$Voltage\;[V]$');

sub(2) = subplot(2,1,2);
plot(log.time, log.theta*180/pi); hold on; grid on;
ylabel('$\theta\;[deg]$');

linkaxes(sub, 'x');

figure;
sgtitle("Experiment: " + string(strrep(strrep(load_experiment_name, ".mat", ""), "_", "\_")));

theta_dot = gradient(theta_filtered, log.time);

G_el = PARAMS.ki/(PARAMS.Rm+s*PARAMS.Lm);
tau = lsim(G_el, log.voltage-theta_dot*PARAMS.kv, log.time);
sub(1) = subplot(2,1,1);
plot(log.time, tau); hold on; grid on;
ylabel('$\tau\;[N*m]$');


sub(2) = subplot(2,1,2);
plot(log.time, theta_dot*180/pi); hold on; grid on;
ylabel('$\dot{\theta}\;[deg/s]$');

linkaxes(sub, 'x');

%% TRANSFER FUNCTION ANALYSIS

figure;
title('Unitary Step Response'); legend;
plot(log.time, theta_dot); hold on; grid on;
ylabel('$\dot{\theta}\;[rad/s]$');
gain = abs(mean(theta_dot(log.time>2 & log.time <9)./tau(log.time>2 & log.time <9)));
Cth = 1/gain;
Tinf = 3.3; 
omega_pole = 5/Tinf;
Jnopend = Cth/omega_pole;
G_thdot_tau = 1/(Jnopend*s + Cth);
G_tot = G_el*G_thdot_tau/(1+PARAMS.ki*G_el*G_thdot_tau);
simulated_thdot = step(G_tot, log.time);
simulated_thdot2 = lsim(G_thdot_tau, tau, log.time);
plot(log.time, simulated_thdot);
plot(log.time, simulated_thdot2);
%xlim([0 2]);


%% VALIDATION

load_experiment_name = '20220314_1526_no_pendulum_varin_exp02.mat';
log = load(load_experiment_name);

%% filtering
theta_filtered = filtfilt(num, den, log.theta);
figure;
sgtitle("Experiment: " + string(strrep(strrep(load_experiment_name, ".mat", ""), "_", "\_")));

%% plots
sub(1) = subplot(2,1,1);
plot(log.time, log.voltage); hold on; grid on;
ylabel('$Voltage\;[V]$');

sub(2) = subplot(2,1,2);
plot(log.time, theta_filtered*180/pi); hold on; grid on;
ylabel('$\theta\;[deg]$');

linkaxes(sub, 'x');

figure;
sgtitle("Experiment: " + string(strrep(strrep(load_experiment_name, ".mat", ""), "_", "\_")));

theta_dot = gradient(theta_filtered, log.time);
tau = lsim(G_el, log.voltage-theta_dot*PARAMS.kv, log.time);
sub(1) = subplot(2,1,1);
plot(log.time, tau); hold on; grid on;
ylabel('$\tau\;[N*m]$');


sub(2) = subplot(2,1,2);
plot(log.time, theta_dot*180/pi); hold on; grid on;
ylabel('$\dot{\theta}\;[deg/s]$');

linkaxes(sub, 'x');

%% check
figure;
title('Full Response'); legend;
plot(log.time, theta_dot); hold on; grid on;
ylabel('$\dot{\theta}\;[rad/s]$');
simulated_thdot = lsim(G_tot, log.voltage, log.time);
plot(log.time, simulated_thdot);

%% anotha one
load_experiment_name = '20220314_1536_no_pendulum_sweepsine_exp02.mat';
log = load(load_experiment_name);

%% filtering
theta_filtered = filtfilt(num, den, log.theta);
figure;
sgtitle("Experiment: " + string(strrep(strrep(load_experiment_name, ".mat", ""), "_", "\_")));

%% plots
sub(1) = subplot(2,1,1);
plot(log.time, log.voltage); hold on; grid on;
ylabel('$Voltage\;[V]$');

sub(2) = subplot(2,1,2);
plot(log.time, theta_filtered*180/pi); hold on; grid on;
ylabel('$\theta\;[deg]$');

linkaxes(sub, 'x');

figure;
sgtitle("Experiment: " + string(strrep(strrep(load_experiment_name, ".mat", ""), "_", "\_")));

theta_dot = gradient(theta_filtered, log.time);
tau = lsim(G_el, log.voltage-theta_dot*PARAMS.kv, log.time);
sub(1) = subplot(2,1,1);
plot(log.time, tau); hold on; grid on;
ylabel('$\tau\;[N*m]$');


sub(2) = subplot(2,1,2);
plot(log.time, theta_dot*180/pi); hold on; grid on;
ylabel('$\dot{\theta}\;[deg/s]$');

linkaxes(sub, 'x');

%% check
figure;
title('Full Response'); legend;
plot(log.time, theta_dot); hold on; grid on;
ylabel('$\dot{\theta}\;[rad/s]$');
simulated_thdot = lsim(G_tot, log.voltage, log.time);
plot(log.time, simulated_thdot);
legend('data', 'simulated');
