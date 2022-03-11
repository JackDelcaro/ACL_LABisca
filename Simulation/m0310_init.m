
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

dt = 2e-4;
T_sweep = 60;

zero_length = ceil(4/dt);

t2_vec = (0:dt:T_sweep)';
w_max = 2*pi;
w_vec = linspace(0,w_max,length(t2_vec))';
in2_vec = sin(w_vec.*t2_vec);

step_vec = [zeros(zero_length,1); ones(zero_length,1); zeros(zero_length,1); -ones(zero_length,1)];
in1_vec = [step_vec*0.05; step_vec*0.2; step_vec*0.6; step_vec*0.8; step_vec; zeros(zero_length,1)];
t1_vec = (0:dt:(dt*(length(in1_vec)-1)))';

t2_vec = t2_vec + t1_vec(end) + dt;

omega = [0.05; 0.2; 0.5; 0.8; 1.2; 1.5; 1.9; 2.3; 2.6; 3; 3.5; 4; 6; 10; 20]*2*pi;
sin_vec = [];
for i = 1:length(omega)
    tested_ome = omega(i);
    time_sin = (0:dt:(2*pi/tested_ome))';
    sin_vec = [sin_vec; zeros(zero_length,1); sin(tested_ome * time_sin)];
end
sin_vec = [sin_vec; zeros(zero_length,1)];
time_sin_vec = (0:dt:(dt*(length(sin_vec)-1)))' + dt + t2_vec(end);

t_tot = [t1_vec; t2_vec; time_sin_vec];
in_tot = [in1_vec; in2_vec; sin_vec];

% plot(t_tot, in_tot);

in_voltage = [t_tot, 0.5*in_tot];
T_sim = t_tot(end);


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


% LOAD DATASET

load_experiment_name = '20220304_1252_all_in_one_05V.mat';
log = load(load_experiment_name);

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