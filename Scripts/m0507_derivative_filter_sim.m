
clc;
clearvars;
% close all;

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
run('m0507_derivative_filter_tests_init.m');

%% OVERWRITE PARAMETERS

PARAMS.polyfit.order = 2;
PARAMS.polyfit.window = 120;    
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

%% SiL PARAMETERS
k_theta = 1.5;
k_alpha = 1;

%% SIMULATION
simout = sim('s0506_polynomial_filter');

%% PLOTS

figure;
sgtitle("Simulation Results");

sub(1) = subplot(4,1,1);
plot(dataset.time, dataset.theta*180/pi, 'DisplayName', 'Measured'); hold on; grid on;
plot(simout.poly_theta.Time, simout.poly_theta.Data*180/pi, 'DisplayName', 'Poly Filtered Signal');
legend('show', 'Location', 'eastoutside');
ylabel('$\theta\;[deg]$');

sub(2) = subplot(4,1,2);
plot(dataset.time, dataset.alpha*180/pi, 'DisplayName', 'Simulated'); hold on; grid on;
plot(simout.poly_alpha.Time, simout.poly_alpha.Data*180/pi, 'DisplayName', 'Poly Filtered Signal');
legend('show', 'Location', 'eastoutside');
ylabel('$\alpha\;[deg]$');

sub(3) = subplot(4,1,3);
plot(dataset.time, dataset.theta_dot*180/pi, 'DisplayName', 'Reconstructed (non causal)'); hold on; grid on;
plot(simout.der_theta.Time, simout.der_theta.Data*180/pi, 'DisplayName', 'Filtered Signal');
plot(simout.poly_der_theta.Time, simout.poly_der_theta.Data*180/pi, 'DisplayName', 'Poly Filtered Signal');
legend('show', 'Location', 'eastoutside');
ylabel('$\dot{\theta}\;[deg/s]$');

sub(4) = subplot(4,1,4);
plot(dataset.time, dataset.alpha_dot*180/pi, 'DisplayName', 'Reconstructed (non causal)'); hold on; grid on;
plot(simout.der_alpha.Time, simout.der_alpha.Data*180/pi, 'DisplayName', 'Filtered Signal');
plot(simout.poly_der_alpha.Time, simout.poly_der_alpha.Data*180/pi, 'DisplayName', 'Poly Filtered Signal');
legend('show', 'Location', 'eastoutside');
ylabel('$\dot{\alpha}\;[deg/s]$');
xlabel('$time\;[s]$');
linkaxes(sub, 'x');

%% PLOTS

figure;

sub(1) = subplot(1,2,1);
start_time = 79;
end_time = 84;

plot(dataset.time, dataset.alpha*180/pi, 'Color', colors.matlab(1), 'DisplayName', 'Reconstructed');
ylabel('$\alpha\;[deg]$');
xlabel('$time\;[s]$')
xlim([start_time, end_time]);

sub(2) = subplot(1,2,2);

start_time = 133;
end_time = 140;

plot(dataset.time, dataset.alpha*180/pi, 'Color', colors.matlab(1), 'DisplayName', 'Reconstructed');
ylabel('$\alpha\;[deg]$');
xlabel('$time\;[s]$')
xlim([start_time, end_time]);

%%
figure;

sub(1) = subplot(1,2,1);
start_time = 79;
end_time = 84;

plot(dataset.time, dataset.alpha*180/pi, 'Color', colors.matlab(1), 'DisplayName', 'Reconstructed'); hold on; grid on;
plot(simout.poly_alpha.Time, simout.poly_alpha.Data*180/pi, 'Color', colors.matlab(3), 'DisplayName', 'Polyfit');
ylabel('$\alpha\;[deg]$');
xlabel('$time\;[s]$')
xlim([start_time, end_time]);

sub(2) = subplot(1,2,2);

start_time = 133;
end_time = 140;

plot(dataset.time, dataset.alpha*180/pi, 'Color', colors.matlab(1), 'DisplayName', 'Reconstructed'); hold on; grid on;
plot(simout.poly_alpha.Time, simout.poly_alpha.Data*180/pi, 'Color', colors.matlab(3), 'DisplayName', 'Polyfit');
ylabel('$\alpha\;[deg]$');
xlabel('$time\;[s]$')
legend;
xlim([start_time, end_time]);

%%

figure;

sub(1) = subplot(1,2,1);
start_time = 79;
end_time = 84;

plot(simout.der_alpha.Time, simout.der_alpha.Data*180/pi, 'Color', colors.matlab(2), 'DisplayName', 'Filtered Derivative'); hold on; grid on;
plot(dataset.time, dataset.alpha_dot*180/pi, 'Color', colors.matlab(1), 'DisplayName', 'Reconstructed');
ylabel('$\dot{\alpha}\;[deg/s]$');
xlabel('$time\;[s]$')
xlim([start_time, end_time]);

sub(2) = subplot(1,2,2);

start_time = 133;
end_time = 140;

plot(simout.der_alpha.Time, simout.der_alpha.Data*180/pi, 'Color', colors.matlab(2), 'DisplayName', 'Filtered Derivative'); hold on; grid on;
plot(dataset.time, dataset.alpha_dot*180/pi, 'Color', colors.matlab(1), 'DisplayName', 'Reconstructed');
ylabel('$\dot{\alpha}\;[deg/s]$');
xlabel('$time\;[s]$')
legend;
xlim([start_time, end_time]);

%%

figure;

sub(1) = subplot(1,2,1);
start_time = 79;
end_time = 84;

plot(simout.der_alpha.Time, simout.der_alpha.Data*180/pi, 'Color', colors.matlab(2), 'DisplayName', 'Filtered Derivative'); hold on; grid on;
plot(dataset.time, dataset.alpha_dot*180/pi, 'Color', colors.matlab(1), 'DisplayName', 'Reconstructed');
plot(simout.poly_der_alpha.Time, simout.poly_der_alpha.Data*180/pi, 'Color', colors.matlab(3), 'DisplayName', 'Polyfit derivative');
ylabel('$\dot{\alpha}\;[deg/s]$');
xlabel('$time\;[s]$')
xlim([start_time, end_time]);

sub(2) = subplot(1,2,2);

start_time = 133;
end_time = 140;

plot(simout.der_alpha.Time, simout.der_alpha.Data*180/pi, 'Color', colors.matlab(2), 'DisplayName', 'Filtered Derivative'); hold on; grid on;
plot(dataset.time, dataset.alpha_dot*180/pi, 'Color', colors.matlab(1), 'DisplayName', 'Reconstructed');
plot(simout.poly_der_alpha.Time, simout.poly_der_alpha.Data*180/pi, 'Color', colors.matlab(3), 'DisplayName', 'Polyfit derivative');
ylabel('$\dot{\alpha}\;[deg/s]$');
xlabel('$time\;[s]$')
legend;
xlim([start_time, end_time]);

%%

figure;

sub(1) = subplot(1,2,1);
start_time = 79;
end_time = 84;

plot(simout.der_alpha.Time, simout.der_alpha.Data*180/pi, 'Color', colors.matlab(2), 'DisplayName', 'Filtered Derivative'); hold on; grid on;
plot(dataset.time, dataset.alpha_dot*180/pi, 'Color', colors.matlab(1), 'DisplayName', 'Reconstructed');
plot(simout.KF_alpha_dot.Time, simout.KF_alpha_dot.Data*180/pi, 'Color', colors.matlab(4), 'DisplayName', 'KF');
ylabel('$\dot{\alpha}\;[deg/s]$');
xlabel('$time\;[s]$')
xlim([start_time, end_time]);

sub(2) = subplot(1,2,2);

start_time = 133;
end_time = 140;

plot(simout.der_alpha.Time, simout.der_alpha.Data*180/pi, 'Color', colors.matlab(2), 'DisplayName', 'Filtered Derivative'); hold on; grid on;
plot(dataset.time, dataset.alpha_dot*180/pi, 'Color', colors.matlab(1), 'DisplayName', 'Reconstructed');
plot(simout.KF_alpha_dot.Time, simout.KF_alpha_dot.Data*180/pi, 'Color', colors.matlab(4), 'DisplayName', 'KF');
ylabel('$\dot{\alpha}\;[deg/s]$');
xlabel('$time\;[s]$')
legend;
xlim([start_time, end_time]);

%% 
figure;

sub(1) = subplot(1,2,1);
start_time = 79;
end_time = 84;

plot(simout.der_alpha.Time, simout.der_alpha.Data*180/pi, 'Color', colors.matlab(2), 'DisplayName', 'Filtered Derivative'); hold on; grid on;
plot(dataset.time, dataset.alpha_dot*180/pi, 'Color', colors.matlab(1), 'DisplayName', 'Reconstructed');
plot(simout.KF_alpha_dot.Time, simout.KFct_alpha_dot.Data*180/pi, 'Color', colors.matlab(4), 'DisplayName', 'KF');
ylabel('$\dot{\alpha}\;[deg/s]$');
xlabel('$time\;[s]$')
xlim([start_time, end_time]);

sub(2) = subplot(1,2,2);

start_time = 133;
end_time = 140;

plot(simout.der_alpha.Time, simout.der_alpha.Data*180/pi, 'Color', colors.matlab(2), 'DisplayName', 'Filtered Derivative'); hold on; grid on;
plot(dataset.time, dataset.alpha_dot*180/pi, 'Color', colors.matlab(1), 'DisplayName', 'Reconstructed');
plot(simout.KF_alpha_dot.Time, simout.KFct_alpha_dot.Data*180/pi, 'Color', colors.matlab(4), 'DisplayName', 'KF');
ylabel('$\dot{\alpha}\;[deg/s]$');
xlabel('$time\;[s]$')
legend;
xlim([start_time, end_time]);


%% 
figure;

sub(1) = subplot(1,2,1);
start_time = 79;
end_time = 84;

plot(simout.der_alpha.Time, simout.der_alpha.Data*180/pi, 'Color', colors.matlab(2), 'DisplayName', 'Filtered Derivative'); hold on; grid on;
plot(dataset.time, dataset.alpha_dot*180/pi, 'Color', colors.matlab(1), 'DisplayName', 'Reconstructed');
plot(simout.KF_alpha_dot.Time, simout.KFct_alpha_dot.Data*180/pi, 'Color', colors.matlab(4), 'DisplayName', 'KF');
ylabel('$\dot{\alpha}\;[deg/s]$');
xlabel('$time\;[s]$')
xlim([start_time, end_time]);

sub(2) = subplot(1,2,2);

start_time = 133;
end_time = 140;

plot(simout.der_alpha.Time, simout.der_alpha.Data*180/pi, 'Color', colors.matlab(2), 'DisplayName', 'Filtered Derivative'); hold on; grid on;
plot(dataset.time, dataset.alpha_dot*180/pi, 'Color', colors.matlab(1), 'DisplayName', 'Reconstructed');
plot(simout.KF_alpha_dot.Time, simout.KFct_alpha_dot.Data*180/pi, 'Color', colors.matlab(3), 'DisplayName', 'KF');
ylabel('$\dot{\alpha}\;[deg/s]$');
xlabel('$time\;[s]$')
legend;
xlim([start_time, end_time]);