
clc;
clearvars;
close all;

%% PATHS

paths.file_fullpath = matlab.desktop.editor.getActiveFilename;
[paths.file_path, ~, ~] = fileparts(paths.file_fullpath);
addpath(genpath(paths.file_path));
paths.mainfolder_path = strsplit(paths.file_path, 'ACL_LABisca');
paths.mainfolder_path = fullfile(string(paths.mainfolder_path(1)), 'ACL_LABisca');
paths.data_folder = fullfile(string(paths.mainfolder_path), "Data");
addpath(genpath(paths.data_folder));
paths.scripts_folder = fullfile(string(paths.mainfolder_path), "Scripts");
addpath(genpath(paths.scripts_folder));

%% SETTINGS

run('graphics_options.m');

%% INITIALIZATION

run('m0303_params.m');

dt = 2e-4;
T_sweep = 60;

zero_length = ceil(2/dt);

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

in_voltage = [t_tot, 0.4*in_tot];
T_sim = t_tot(end);


%% SIMULATION

out = sim("s0310_main.slx");

big_tau = zeros(2*length(out.tau), 1);
big_tau(1:2:end) = out.tau; 

s = tf('s');
omega_cut = 10*2*pi;
filter = s/(1+s/omega_cut);
[num,den] = tfdata(c2d(filter, dt), 'v');

% theta_ddot = filtfilt(num, den, out.theta_dot);
% alpha_ddot = filtfilt(num, den, out.alpha_dot);
theta_ddot = gradient(out.theta_dot)/dt;
alpha_ddot = gradient(out.alpha_dot)/dt;


% big_Y = zeros(2*length(out.tau), 6);
% 
% big_Y(1:2:end, 1) = theta_ddot;
% big_Y(1:2:end, 2) = 1/4*(sin(out.alpha).^2).*theta_ddot+sin(2*out.alpha).*out.theta_dot.*out.alpha_dot/4;
% big_Y(1:2:end, 3) = cos(out.alpha).*alpha_ddot/2;
% big_Y(1:2:end, 4) = out.theta_dot;
% big_Y(1:2:end, 5) = 0;
% big_Y(1:2:end, 6) = 0;
% big_Y(2:2:end, 1) = 0;
% big_Y(2:2:end, 2) = -alpha_ddot/3+sin(2*out.alpha)/2.*out.theta_dot.^2;
% big_Y(2:2:end, 3) = -cos(out.alpha).*theta_ddot/2;
% big_Y(2:2:end, 4) = 0;
% big_Y(2:2:end, 5) = -sin(out.alpha)/2;
% big_Y(2:2:end, 6) = -out.alpha_dot;
% 
% pi_vec = pinv(big_Y)*big_tau;
% 
% g = 9.81;
% dyn_params = [Jm+Jh+(mp+mr/3)*Lr^2; mp*Lp^2; mp*Lp*Lr; Cth; mp*g*Lp; Cal];
% figure;
% subplot(1,2,1); hold on;
% scatter(big_Y*dyn_params, big_tau); grid on;
% title('Theoretical Parameters');
% subplot(1,2,2); hold on;
% scatter(big_Y*pi_vec, big_tau); grid on;
% title('Fitted Model');


%% RESULTS

figure
subplot(2,1,1);
plot(0:dt:T_sim, out.theta*180/pi); grid on;
subplot(2,1,2);
plot(0:dt:T_sim, out.alpha*180/pi); grid on;

%% SAVE RESULTS
