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

load_experiment_name = '20220314_1544_pendulum_0p5V_constrainedalpha_th0eq0_exp03.mat';
log = load(load_experiment_name);

%% SIGNAL FILTERING

dt = mean(diff(log.time));
s = tf('s');
omega_cut = 20*2*pi;
filter = 1/(1+s/omega_cut);
[num,den] = tfdata(c2d(filter, dt), 'v');

theta_filtered = filtfilt(num, den, log.theta);
alpha_filtered = filtfilt(num, den, log.alpha);

init=-1;
fin=inf;
%% PLOTS

time = log.time(log.time > init) - max([0 init]);
figure;
sgtitle("Experiment: " + string(strrep(strrep(load_experiment_name, ".mat", ""), "_", "\_")));

sub(1) = subplot(3,1,1);
plot(time, log.voltage(log.time > init & log.time < fin)); hold on; grid on;
ylabel('$Voltage\;[V]$');

sub(2) = subplot(3,1,2);
plot(time, theta_filtered(log.time > init & log.time < fin)); hold on; grid on;
ylabel('$\theta\;[rad]$');

sub(3) = subplot(3,1,3);
plot(time, alpha_filtered(log.time > init & log.time < fin)); hold on; grid on;
ylabel('$\alpha\;[rad]$');
xlabel('$time\;[s]$');

linkaxes(sub, 'x');

figure;
sgtitle("Experiment: " + string(strrep(strrep(load_experiment_name, ".mat", ""), "_", "\_")));

theta_dot = gradient(theta_filtered, log.time);
alpha_dot = gradient(alpha_filtered, log.time);

G_el = PARAMS.ki/(PARAMS.Rm+s*PARAMS.Lm);
tau = lsim(G_el, log.voltage-theta_dot*PARAMS.kv, log.time);
sub(1) = subplot(3,1,1);
plot(log.time, tau); hold on; grid on;
ylabel('$\tau\;[N*m]$');

sub(2) = subplot(3,1,2);
plot(log.time, theta_dot*180/pi); hold on; grid on;
ylabel('$\dot{\theta}\;[deg/s]$');

sub(3) = subplot(3,1,3);
plot(log.time, alpha_dot*180/pi); hold on; grid on;
ylabel('$\dot{\alpha}\;[deg/s]$');
xlabel('$time\;[s]$');

linkaxes(sub, 'x');

figure;
sgtitle("Experiment: " + string(strrep(strrep(load_experiment_name, ".mat", ""), "_", "\_")));

theta_ddot = gradient(theta_dot, log.time);
alpha_ddot = gradient(alpha_dot, log.time);

%Jmot=PARAMS.Jh+PARAMS.Jm;
Jmot=8e-6;

Jtot=Jmot+PARAMS.Lr^2*(PARAMS.mr/3+PARAMS.mp);
%Cm=PARAMS.Cth;
Cm=1.5e-3;

K_open_loop=(tau-Jtot*theta_ddot-Cm*theta_dot)./theta_filtered;

sub(1) = subplot(3,1,1);
plot(log.time, theta_ddot*180/pi); hold on; grid on;
ylabel('$\ddot{\theta}\;[deg/s]$');

sub(2) = subplot(3,1,2);
plot(log.time, alpha_ddot*180/pi); hold on; grid on;
ylabel('$\ddot{\alpha}\;[deg/s]$');
xlabel('$time\;[s]$');

sub(3) = subplot(3,1,3);
plot(log.time, K_open_loop); hold on; grid on;
ylabel('$K\;[N/m]$');
xlabel('$time\;[s]$');

linkaxes(sub, 'x');


%% TRANSFER FUNCTION ANALYSIS

K=0.0055;
G_el = PARAMS.ki/(PARAMS.Rm+s*PARAMS.Lm);
G_th_tau = 1/(Jtot*s^2 + Cm*s + K);
G_tot = G_el*G_th_tau/(1+s*PARAMS.ki*G_el*G_th_tau);

figure;
title('Full Response'); legend;
plot(log.time, theta_filtered); hold on; grid on;
ylabel('$\theta\;[rad]$');
simulated_thdot = lsim(G_tot, log.voltage, log.time);
plot(log.time, simulated_thdot);


%% bis

load_experiment_name = '20220314_1545_pendulum_1V_constrainedalpha_th0eq0_exp03.mat';
log = load(load_experiment_name);

%% SIGNAL FILTERING

theta_filtered = filtfilt(num, den, log.theta);
alpha_filtered = filtfilt(num, den, log.alpha);

init=-1;
fin=inf;
%% PLOTS

time = log.time(log.time > init) - max([0 init]);
figure;
sgtitle("Experiment: " + string(strrep(strrep(load_experiment_name, ".mat", ""), "_", "\_")));

sub(1) = subplot(3,1,1);
plot(time, log.voltage(log.time > init & log.time < fin)); hold on; grid on;
ylabel('$Voltage\;[V]$');

sub(2) = subplot(3,1,2);
plot(time, theta_filtered(log.time > init & log.time < fin)); hold on; grid on;
ylabel('$\theta\;[rad]$');

sub(3) = subplot(3,1,3);
plot(time, alpha_filtered(log.time > init & log.time < fin)); hold on; grid on;
ylabel('$\alpha\;[rad]$');
xlabel('$time\;[s]$');

linkaxes(sub, 'x');

figure;
sgtitle("Experiment: " + string(strrep(strrep(load_experiment_name, ".mat", ""), "_", "\_")));

theta_dot = gradient(theta_filtered, log.time);
alpha_dot = gradient(alpha_filtered, log.time);

tau = lsim(G_el, log.voltage-theta_dot*PARAMS.kv, log.time);
sub(1) = subplot(3,1,1);
plot(log.time, tau); hold on; grid on;
ylabel('$\tau\;[N*m]$');

sub(2) = subplot(3,1,2);
plot(log.time, theta_dot*180/pi); hold on; grid on;
ylabel('$\dot{\theta}\;[deg/s]$');

sub(3) = subplot(3,1,3);
plot(log.time, alpha_dot*180/pi); hold on; grid on;
ylabel('$\dot{\alpha}\;[deg/s]$');
xlabel('$time\;[s]$');

linkaxes(sub, 'x');

figure;
sgtitle("Experiment: " + string(strrep(strrep(load_experiment_name, ".mat", ""), "_", "\_")));

theta_ddot = gradient(theta_dot, log.time);
alpha_ddot = gradient(alpha_dot, log.time);


K_open_loop=(tau-Jtot*theta_ddot-Cm*theta_dot)./theta_filtered;

sub(1) = subplot(3,1,1);
plot(log.time, theta_ddot*180/pi); hold on; grid on;
ylabel('$\ddot{\theta}\;[deg/s]$');

sub(2) = subplot(3,1,2);
plot(log.time, alpha_ddot*180/pi); hold on; grid on;
ylabel('$\ddot{\alpha}\;[deg/s]$');
xlabel('$time\;[s]$');

sub(3) = subplot(3,1,3);
plot(log.time, K_open_loop); hold on; grid on;
ylabel('$K\;[N/m]$');
xlabel('$time\;[s]$');

linkaxes(sub, 'x');


%% TRANSFER FUNCTION ANALYSIS

figure;
title('Full Response'); legend;
plot(log.time, theta_filtered); hold on; grid on;
ylabel('$\theta\;[rad]$');
simulated_thdot = lsim(G_tot, log.voltage, log.time);
plot(log.time, simulated_thdot);


