
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
dt_control = 2e-3;
run('m0405_params.m');

%% POLYNOMIAL FITTING

PARAMS.polyfit.order = 2;
PARAMS.polyfit.window = 250;
PARAMS.polyfit.forgetting_factor = (10^-3)^(1/PARAMS.polyfit.window);
PARAMS.polyfit.center_idx = floor(PARAMS.polyfit.window/2);
PARAMS.polyfit.time = (0:dt_control:(PARAMS.polyfit.window-1)*dt_control)';
PARAMS.polyfit.time = PARAMS.polyfit.time - PARAMS.polyfit.time(PARAMS.polyfit.center_idx);
PARAMS.polyfit.powers = PARAMS.polyfit.order:-1:0;
for j = 1:(PARAMS.polyfit.order+1)
    R(:, j) = (PARAMS.polyfit.time.^(PARAMS.polyfit.order - j + 1)) .* (PARAMS.polyfit.forgetting_factor.^((length(PARAMS.polyfit.time)-1):-1:0)');
end
PARAMS.polyfit.pinvR = pinv(R);
clearvars R;

%% LOAD DATASET

dataset = load('20220401_1141_cl_LQ_alpha_theta_pi_int_varin_C1');
dt_dataset = mean(diff(dataset.time));

tmp = sgolayfilt(dataset.theta, 1, 51);
dataset.theta_filtered = sgolayfilt(tmp, 1, 25);

tmp = sgolayfilt(dataset.alpha, 1, 51);
dataset.alpha_filtered = sgolayfilt(tmp, 1, 25);

dataset.theta_dot = gradient(dataset.theta_filtered, dataset.time);
dataset.alpha_dot = gradient(dataset.alpha_filtered, dataset.time);

%% DERIVATIVE FILTER

s = tf('s');
freq_der_filter = 15;
der_filt = s/(s/(2*pi*freq_der_filter)+1);
[num_der_filter, den_der_filter] = tfdata(c2d(der_filt, dt_control), 'v');

%% SIMULATION

simin.alpha = [dataset.time, dataset.alpha];
simin.theta = [dataset.time, dataset.theta];
T_sim = dataset.time(end);
simout = sim('s0506_polynomial_filter');

%% PLOTS

figure;
sgtitle("Simulation Results");

sub(1) = subplot(2,1,1);
plot(dataset.time, dataset.theta*180/pi, 'DisplayName', 'Measured'); hold on; grid on;
plot(simout.poly_theta.Time, simout.poly_theta.Data*180/pi, 'DisplayName', 'Filtered Signal');
legend;
ylabel('$\theta\;[deg]$');

sub(2) = subplot(2,1,2);
plot(dataset.time, dataset.alpha*180/pi, 'DisplayName', 'Simulated'); hold on; grid on;
plot(simout.poly_alpha.Time, simout.poly_alpha.Data*180/pi, 'DisplayName', 'Filtered Signal');
legend;
ylabel('$\alpha\;[deg]$');
xlabel('$time\;[s]$');
linkaxes(sub, 'x');
clearvars sub;

figure;

sub(2) = subplot(2,1,1);
plot(dataset.time, dataset.theta_dot*180/pi, 'DisplayName', 'Reconstructed (non causal)'); hold on; grid on;
plot(simout.poly_der_theta.Time, simout.poly_der_theta.Data*180/pi, 'DisplayName', 'Filtered Signal');
legend;
ylabel('$\dot{\theta}\;[deg/s]$');

sub(3) = subplot(3,1,3);
plot(dataset.time, dataset.alpha_dot*180/pi, 'DisplayName', 'Reconstructed (non causal)'); hold on; grid on;
plot(simout.poly_der_alpha.Time, simout.poly_der_alpha.Data*180/pi, 'DisplayName', 'Filtered Signal');
legend;
ylabel('$\dot{\alpha}\;[deg/s]$');
xlabel('$time\;[s]$');
linkaxes(sub, 'x');
