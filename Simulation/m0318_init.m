
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

% loadfile_name = "20220314_1640_varin_exp07.mat";
% log = load(loadfile_name);
% simin.voltage = [log.time, log.voltage];
% T_sim = log.time(end);

standby_duration = 3; % [s]
% Steps Parameters
steps_amplitude = [0.5 1];
steps_duration = 3; % [s]
% Ramps Parameters
ramps_amplitude = [1 1];
ramps_duration = [5 3]; % [s]
ramps_backoff_duration = 1;
% Sine Sweep Parameters
sweep_params = [0.05 0.3 176]; % [ initial_frequency [Hz], final_frequency [Hz], duration [s] ]
% sine sweep can be 'linear' or 'exponential'
% Sinusoids Parameters
% sinusoid_freq = [0.5 0.4 1 1.5 2 4 6 8]; % frequencies in [Hz]
                
[sim_time,experiment] = input_generator(dt_control, standby_duration,...
    'sweep', sweep_params, 'exponential',...
    'ramps', ramps_amplitude, ramps_duration, ramps_backoff_duration,...
    'steps', steps_amplitude, steps_duration);
% [sim_time,in_voltage] = input_generator(dt, standby_duration,...
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

simin.theta_ref = [sim_time,pi/2*experiment];
figure;
plot(sim_time,experiment); grid on;
T_sim = sim_time(end);

%% DERIVATIVE FILTER

s = tf('s');
freq_der_filter = 18;
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

% %% SIMULATION
% 
% simout = sim("s0318_main.slx");
% 
% %% RESULTS
% 
% figure;
% sgtitle("Simulation Results");
% 
% sub(1) = subplot(3,1,1);
% plot(simout.voltage.Time, simout.voltage.Data); hold on; grid on;
% ylabel('$Voltage\;[V]$');
% 
% sub(2) = subplot(3,1,2);
% plot(simout.theta.Time, simout.theta.Data*180/pi, 'DisplayName', 'Simulated'); hold on; grid on;
% % plot(simout.theta_ref.Time, simout.theta_ref.Data*180/pi, 'DisplayName', 'Reference');
% plot(log.time, log.theta*180/pi, 'DisplayName', 'Real Data');
% legend;
% ylabel('$\theta\;[deg]$');
% 
% sub(3) = subplot(3,1,3);
% plot(simout.alpha.Time, simout.alpha.Data*180/pi, 'DisplayName', 'Simulated'); hold on; grid on;
% % plot(simout.alpha_ref.Time, simout.alpha_ref.Data*180/pi, 'DisplayName', 'Reference');
% plot(log.time, log.alpha*180/pi, 'DisplayName', 'Real Data');
% legend;
% ylabel('$\alpha\;[deg]$');
% xlabel('$time\;[s]$');
% linkaxes(sub, 'x');
% clearvars sub;
% 
% figure
% sub(1) = subplot(3,1,1);
% plot(simout.tau.Time, simout.tau.Data); hold on; grid on;
% ylabel('$\tau\;[Nm]$');
% 
% sub(2) = subplot(3,1,2);
% plot(simout.theta_dot.Time, simout.theta_dot.Data*180/pi); hold on; grid on;
% ylabel('$\dot{\theta}\;[deg/s]$');
% 
% sub(3) = subplot(3,1,3);
% plot(simout.alpha_dot.Time, simout.alpha_dot.Data*180/pi); hold on; grid on;
% ylabel('$\dot{\alpha}\;[deg/s]$');
% xlabel('$time\;[s]$');
% linkaxes(sub, 'x');