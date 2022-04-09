
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
run('m0405_params.m');

%% LOAD DATASET

load_experiment_name = '20220314_1724_only_pendulum_exp09.mat';
log = load(load_experiment_name);

%% SIGNAL FILTERING

dt = mean(diff(log.time));
s = tf('s');
omega_cut = 100*2*pi;
filter = 1/(1+s/omega_cut);
[num,den] = tfdata(c2d(filter, dt), 'v');

alpha_filtered = filtfilt(num, den, log.alpha);
alpha_dot = gradient(alpha_filtered, log.time);
init=167.528;
fin=inf;
%% PLOTS

time = log.time(log.time > init & log.time < fin) - max([0,init]);
figure;
sgtitle("Experiment: " + string(strrep(strrep(load_experiment_name, ".mat", ""), "_", "\_")));

sub(1) = subplot(2,1,1);
plot(time, alpha_filtered(log.time > init & log.time < fin)*180/pi); hold on; grid on;
ylabel('$\alpha\;[deg]$');
xlabel('$time\;[s]$');

sub(2) = subplot(2,1,2);
plot(time, alpha_dot(log.time > init & log.time < fin)*180/pi); hold on; grid on;
ylabel('$\dot{\alpha}\;[deg/s]$');
xlabel('$time\;[s]$');

linkaxes(sub, 'x');



Tosc = 1*(178.964-167.528)/20;
omega_cc = 2*pi/Tosc;
Tinf = 205;
sigma_cc = 5/Tinf;

ome_n = sqrt(sigma_cc^2 + omega_cc^2);
csi = sigma_cc/ome_n;

C = 2/3*csi*ome_n*PARAMS.mp*PARAMS.Lp^2;
L = 0.5*(PARAMS.g/ome_n^2+sqrt(PARAMS.g^2/ome_n^4-(PARAMS.Lp+PARAMS.Lp_offset)^2/12))
x0=[13.73 0];
G_al_tau = ome_n^2/(s^2 + 2*csi*ome_n*s + ome_n^2);

al_sim = free_res_in_cond(G_al_tau, time, x0);
figure
plot(time, alpha_filtered(log.time > init & log.time < fin)*180/pi); hold on; grid on;
ylabel('$\alpha\;[deg]$');
xlabel('$time\;[s]$');
plot(time, al_sim(1,:));
legend('data', 'simulated');

PARAMS.Lp/2-PARAMS.Lp_offset-L
