
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
run('m0318_params.m');

%% LOAD DATA

load_experiment_name = '20220314_1650_sinesweep_0p75V_exp07.mat';
tstart = 72.95; tend = 160;
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

omega_cut = 5*2*pi;
filter = 1/(1+s/omega_cut);
[num,den] = tfdata(c2d(filter, dt), 'v');
theta_ultrafiltered = filtfilt(num, den, log.theta);
theta_dot_ultrafiltered = gradient(theta_ultrafiltered, log.time);
theta_dot_ultrafiltered = theta_dot_ultrafiltered(log.time >= tstart & log.time <= tend);

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

G_V_tau = PARAMS.ki/(s*PARAMS.Lm + PARAMS.Rm);
Gel_dt = c2d(G_V_tau, 2e-3);
[num_Gel_dt, den_Gel_dt] = tfdata(G_V_tau, 'v');

my_sign = @(x) sign(x) .* (abs(x) > PARAMS.Sth_vel_threshold); 

tau_frictionless = tau - PARAMS.Dth*my_sign(theta_dot_ultrafiltered) - PARAMS.Sth*(my_sign(theta_dot_ultrafiltered) == 0);

coeffs = den_Gel_dt/num_Gel_dt(end);
tmp = [tau_frictionless; 0];
voltage_frictionless = NaN(size(voltage));
for i = 1:length(voltage)
    voltage_frictionless(i) = coeffs(2)*tmp(i); % + coeffs(1)*tmp(i+1);
end
voltage_frictionless = voltage_frictionless + PARAMS.kv*theta_dot;

figure;
clearvars sub;
sub(1) = subplot(2,1,1);
plot(time, tau,'DisplayName','tau'); hold on; grid on;
plot(time, tau_frictionless,'DisplayName','tau frictionless');
legend;
ylabel('$\tau\;(approx)\;[Nm]$');

sub(2) = subplot(2,1,2);
plot(time, voltage,'DisplayName','voltage'); hold on; grid on;
ylabel('$voltage\;[V]$');
plot(time, voltage_frictionless,'DisplayName','voltage frictionless');
legend;
ylabel('$voltage\;[V]$');


%% TRANSFER FUNCTIONS

% G_tau_th = 1/(Jtot_theoretical*s^2 + PARAMS.Cth*s + 0*PARAMS.K);
% Gel = PARAMS.ki/(PARAMS.Lm*s + PARAMS.Rm);
% G_V_th = G_tau_th*Gel/(1+PARAMS.kv*s*G_tau_th*Gel);
% figure;
% bode(G_V_th); grid on; hold on;

% G_tau_th = 1/(Jtot_theoretical*s^2 + PARAMS.Cth*s + 0.1*PARAMS.K);
% Gel = PARAMS.ki/(PARAMS.Lm*s + PARAMS.Rm);
% G_V_th = G_tau_th*Gel/(1+PARAMS.kv*s*G_tau_th*Gel);
% 
% bode(G_V_th); grid on; hold on;
% G_tau_th = 1/(Jtot_theoretical*s^2 + PARAMS.Cth*s + PARAMS.K);
% Gel = PARAMS.ki/(PARAMS.Lm*s + PARAMS.Rm);
% G_V_th = G_tau_th*Gel/(1+PARAMS.kv*s*G_tau_th*Gel);
% 
% bode(G_V_th); grid on; hold on;
% G_tau_th = 1/(Jtot_theoretical*s^2 + PARAMS.Cth*s + 10*PARAMS.K);
% Gel = PARAMS.ki/(PARAMS.Lm*s + PARAMS.Rm);
% G_V_th = G_tau_th*Gel/(1+PARAMS.kv*s*G_tau_th*Gel);
% 
% bode(G_V_th); grid on; hold on;
% 
% G_tau_th = 1/(Jtot_theoretical*s^2 + PARAMS.Cth*s + 100*PARAMS.K);
% Gel = PARAMS.ki/(PARAMS.Lm*s + PARAMS.Rm);
% G_V_th = G_tau_th*Gel/(1+PARAMS.kv*s*G_tau_th*Gel);
% 
% bode(G_V_th); grid on; hold on;

%% BEST FITTED TF

% G_best_fit = 14.78/(s^2 + 2.399*s + 6.018); % old without friction
% considerations
G_best_fit = 14.02/(s^2 + 1.615*s + 6.211);
gain = dcgain(G_best_fit);
% gain = PARAMS.ki/PARAMS.Rm/PARAMS.K
% term which multiplies s (CthR + KiKv)/Ki (numerator of tf is 1)
% term which multiplies s^2 RJ/Ki (numerator of tf is 1)

K_id = PARAMS.ki/PARAMS.Rm/gain;
J_id = 1/14.02*PARAMS.ki/PARAMS.Rm;
C_th_id = (1.615/14.02*PARAMS.ki - PARAMS.ki*PARAMS.kv)/PARAMS.Rm;

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

%% VALIDATION PLOT

G_tau_th = 1/(J_id*s^2 + C_th_id*s + K_id);
Gel = PARAMS.ki/(PARAMS.Lm*s + PARAMS.Rm);
G_V_th = G_tau_th*Gel/(1+PARAMS.kv*s*G_tau_th*Gel);

figure;
plot(time, theta*180/pi); hold on; grid on;
plot(time, lsim(G_V_th, voltage, time)*180/pi); hold on;
ylabel('$\theta\;[deg]$');


G_tau_th = 1/(Jtot_theoretical*s^2 + C_th_id*s + K_id);
Gel = PARAMS.ki/(PARAMS.Lm*s + PARAMS.Rm);
G_V_th = G_tau_th*Gel/(1+PARAMS.kv*s*G_tau_th*Gel);

plot(time, lsim(G_V_th, voltage, time)*180/pi);
legend;

G_tau_th = 1/(Jtot_theoretical*s^2 + 1.7e-3*s + K_id);
Gel = PARAMS.ki/(PARAMS.Lm*s + PARAMS.Rm);
G_V_th = G_tau_th*Gel/(1+PARAMS.kv*s*G_tau_th*Gel);

plot(time, lsim(G_V_th, voltage, time)*180/pi);
legend;

% Decisione finale: teniamo C identificato ora, K identificato ora e J
% precedentemente identificato

%% VALIDATION PLOT

figure;
plot(time, theta*180/pi, 'Color', colors.blue(4)); hold on; grid on;
ylabel('$\theta\;[deg]$');
PARAMS.Dth = 0.55*7.9e-4;

G_tau_th = 1/(Jtot_theoretical*s^2 + C_th_id*s + K_id);
Gel = PARAMS.ki/(PARAMS.Lm*s + PARAMS.Rm);
G_V_th = G_tau_th*Gel/(1+PARAMS.kv*s*G_tau_th*Gel);

v_f = voltage-PARAMS.Rm/PARAMS.ki*PARAMS.Dth*(1-exp(-abs(theta_dot*15))).*sign(theta_dot*15);
plot(time, lsim(G_V_th, v_f, time)*180/pi, 'Color', colors.blue(1));
legend('data', 'simulated');
xlim([220 300]);