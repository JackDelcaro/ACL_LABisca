
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
run('m0318_params.m');
% mech_simulator_model = "s0318_mechanical_simulator";
% motor_simulator_model = "s0303_motor_simulator";
dt_control = 2e-3;

%% INPUT EXPERIMENT
% log = load("20220314_1825_cl_PID_20_15_10_varin_exp14.mat");
% 
% loadfile_name = "20220321_1748_ol_full_pendulum_swing_90.mat";
% log = load(loadfile_name);
% log.time = log.time(84:end) - log.time(84);
% log.alpha = log.alpha(84:end);
% log.theta = log.theta(84:end);
% log.voltage = log.voltage(84:end);
% simin.voltage = [log.time, log.voltage];
% PARAMS.al_0 = log.alpha(1);
% PARAMS.th_0 = log.theta(1);
% T_sim = log.time(end);

% loadfile_name = "20220321_1748_ol_full_pendulum_swing_180.mat";
% log = load(loadfile_name);
% init_idx = 845;
% log.time = log.time(init_idx:end) - log.time(init_idx);
% log.alpha = log.alpha(init_idx:end);
% log.theta = log.theta(init_idx:end);
% log.voltage = log.voltage(init_idx:end);
% simin.voltage = [log.time, log.voltage];
% PARAMS.al_0 = log.alpha(1);
% PARAMS.th_0 = log.theta(1);
% T_sim = log.time(end);

% 
res_theoretical = sqrt(1.5*PARAMS.g/PARAMS.Lp)/2/pi;
standby_duration = 3; % [s]
% Steps Parameters
steps_amplitude = [0.3 0.5 0.8 1];
steps_duration = 3; % [s]
% Ramps Parameters
 ramps_amplitude = [1 1];
 ramps_duration = [8 5]; % [s]
 ramps_backoff_duration = 1;
% Sine Sweep Parameters
sweep_params = [0.5 8 50]; % [ initial_frequency [Hz], final_frequency [Hz], duration [s] ]
                
[sim_time_th, experiment_th] = input_generator(dt, standby_duration,...
                               'steps', steps_amplitude, steps_duration,...
                               'ramps', ramps_amplitude, ramps_duration, ramps_backoff_duration,...
                               'sweep', sweep_params, 'linear');

                
% [sim_time, experiment] = input_generator(dt, standby_duration,...
%                     'sinusoids', sinusoid_freq,...
%                     'sweep', sweep_params, 'exponential', ...
%                     'steps', steps_amplitude, steps_duration, ...
%                     'ramps', ramps_amplitude, ramps_duration, ramps_backoff_duration, ...
%                     'steps', steps_amplitude, steps_duration, ...
%                     'sweep', sweep_params, 'exponential', ...
%                     'sinusoids', sinusoid_freq);
%                 
% T_sim = 180;
% sim_time = (0:dt:T_sim-dt)';
% experiment = 0*1.5*ones(size(sim_time));

simin.voltage = [sim_time_th, 10*experiment_th];
simin.theta_ref = [sim_time_th, pi/2*experiment_th];
% figure;
% plot(sim_time,experiment); grid on;
T_sim = simin.theta_ref(end, 1);

%% DERIVATIVE FILTER

s = tf('s');
freq_der_filter = 15;
der_filt = s/(s/(2*pi*freq_der_filter)+1);
[num_der_filter, den_der_filter] = tfdata(c2d(der_filt, dt_control), 'v');

%% FILTER

s = tf('s');
freq_filter = 15;
filt = 1/(s/(2*pi*freq_filter)+1);
[num_filter, den_filter] = tfdata(c2d(filt, dt_control), 'v');

%% REF FILTER

s = tf('s');
freq_ref_filter = 1;
ref_filt = 1/(s/(2*pi*freq_ref_filter)+1);
[num_ref_filter, den_ref_filter] = tfdata(c2d(ref_filt, dt_control), 'v');

%% SIMULATION

simout = sim("s0318_main.slx");

%% RESULTS

figure;
sgtitle("Simulation Results");

sub(1) = subplot(3,1,1);
plot(simout.voltage.Time, simout.voltage.Data); hold on; grid on;
ylabel('$Voltage\;[V]$');

sub(2) = subplot(3,1,2);
plot(simout.theta.Time, simout.theta.Data*180/pi, 'DisplayName', 'Simulated'); hold on; grid on;
% plot(simout.theta_ref.Time, simout.theta_ref.Data*180/pi, 'DisplayName', 'Reference');
% plot(log.time, log.theta*180/pi, 'DisplayName', 'Real Data');
legend;
ylabel('$\theta\;[deg]$');

sub(3) = subplot(3,1,3);
plot(simout.alpha.Time, simout.alpha.Data*180/pi, 'DisplayName', 'Simulated'); hold on; grid on;
% plot(simout.alpha_ref.Time, simout.alpha_ref.Data*180/pi, 'DisplayName', 'Reference');
% plot(log.time, log.alpha*180/pi, 'DisplayName', 'Real Data');
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
plot(simout.theta_dot.Time, simout.theta_dot.Data*180/pi); hold on; grid on;
ylabel('$\dot{\theta}\;[deg/s]$');

sub(3) = subplot(3,1,3);
plot(simout.alpha_dot.Time, simout.alpha_dot.Data*180/pi); hold on; grid on;
ylabel('$\dot{\alpha}\;[deg/s]$');
xlabel('$time\;[s]$');
linkaxes(sub, 'x');