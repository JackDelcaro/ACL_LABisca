
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

dt_control = 2e-3;

%% INPUT EXPERIMENT

dt = 2e-3;
standby_duration = 3; % [s]
% Steps Parameters
steps_amplitude = [0.25 0.5 0.75 1];
steps_duration = 3; % [s]
% Ramps Parameters
ramps_amplitude = [1 1 1 1 1];
ramps_duration = [5 3 2 1 0.5]; % [s]
ramps_backoff_duration = 1;
% Sine Sweep Parameters
sweep_params = [0.05 20/2/pi 180]; % [ initial_frequency [Hz], final_frequency [Hz], duration [s] ]
% sine sweep can be 'linear' or 'exponential'
% Sinusoids Parameters
sinusoid_freq = [0.5 0.4 1 1.5 2 4 6 8]; % frequencies in [Hz]
                
[sim_time,experiment] = input_generator(dt, standby_duration,...
    'steps', steps_amplitude, steps_duration, ...
    'ramps', ramps_amplitude, ramps_duration, ramps_backoff_duration,...
    'sweep', sweep_params, 'exponential');
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

%% SIMULATION

% out = sim("QubeServo2_Template.slx");

%% RESULTS
% 
% figure;
% sgtitle("Simulation Results");
% 
% sub(1) = subplot(3,2,1);
% plot(t_tot, in_voltage(:,2)); hold on; grid on;
% ylabel('$Voltage\;[V]$');
% 
% sub(3) = subplot(3,2,3);
% plot(t_tot, out.theta*180/pi); hold on; grid on;
% ylabel('$\theta\;[deg]$');
% 
% sub(5) = subplot(3,2,5);
% plot(t_tot, out.alpha*180/pi); hold on; grid on;
% ylabel('$\alpha\;[deg]$');
% xlabel('$time\;[s]$');
% 
% sub(2) = subplot(3,2,2);
% plot(t_tot, out.tau); hold on; grid on;
% ylabel('$\tau\;[Nm]$');
% 
% sub(4) = subplot(3,2,4);
% plot(t_tot, out.theta_dot*180/pi); hold on; grid on;
% ylabel('$\dot{\theta}\;[deg/s]$');
% 
% sub(6) = subplot(3,2,6);
% plot(t_tot, out.alpha_dot*180/pi); hold on; grid on;
% ylabel('$\dot{\alpha}\;[deg/s]$');
% xlabel('$time\;[s]$');
% 
% linkaxes(sub, 'x');
% 
% % SIGNAL FILTERING
% 
% dt = mean(diff(log.time));
% s = tf('s');
% omega_cut = 100*2*pi;
% filter = 1/(1+s/omega_cut);
% [num,den] = tfdata(c2d(filter, dt), 'v');
% 
% theta_filtered = filtfilt(num, den, log.theta);
% alpha_filtered = filtfilt(num, den, log.alpha);
% figure;
% sgtitle("Experiment: " + string(strrep(strrep(load_experiment_name, ".mat", ""), "_", "\_")));
% 
% sub(1) = subplot(3,2,1);
% plot(log.time, log.voltage); hold on; grid on;
% ylabel('$Voltage\;[V]$');
% 
% sub(3) = subplot(3,2,3);
% plot(log.time, theta_filtered*180/pi); hold on; grid on;
% ylabel('$\theta\;[deg]$');
% 
% sub(5) = subplot(3,2,5);
% plot(log.time, alpha_filtered*180/pi); hold on; grid on;
% ylabel('$\alpha\;[deg]$');
% xlabel('$time\;[s]$');
% 
% tau = PARAMS.ki/PARAMS.Rm * log.voltage;
% sub(2) = subplot(3,2,2);
% plot(log.time, tau); hold on; grid on;
% ylabel('$\tau\;[Nm]$');
% 
% theta_dot = gradient(theta_filtered, log.time);
% sub(4) = subplot(3,2,4);
% plot(log.time, theta_dot*180/pi); hold on; grid on;
% ylabel('$\dot{\theta}\;[deg/s]$');
% 
% alpha_dot = gradient(alpha_filtered, log.time);
% sub(6) = subplot(3,2,6);
% plot(log.time, alpha_dot*180/pi); hold on; grid on;
% ylabel('$\dot{\alpha}\;[deg/s]$');
% xlabel('$time\;[s]$');
% 
% linkaxes(sub, 'x');