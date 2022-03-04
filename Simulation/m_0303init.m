
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

run('m_0303params.m');

T_sim = 20;
dt = 1e-4;

t_vec = 0:dt:T_sim;
w_max = 3*2*pi;
w_vec = linspace(0,w_max,length(t_vec));
in_vec = sin(w_vec.*t_vec);

simul.input = [t_vec', in_vec'];

%% SIMULATION

out = sim("s_0303main.slx");

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

big_Y = zeros(2*length(out.tau), 6);

big_Y(1:2:end, 1) = theta_ddot;
big_Y(1:2:end, 2) = 1/4*(sin(out.alpha).^2).*theta_ddot+sin(2*out.alpha).*out.theta_dot.*out.alpha_dot/4;
big_Y(1:2:end, 3) = cos(out.alpha).*alpha_ddot/2;
big_Y(1:2:end, 4) = out.theta_dot;
big_Y(1:2:end, 5) = 0;
big_Y(1:2:end, 6) = 0;
big_Y(2:2:end, 1) = 0;
big_Y(2:2:end, 2) = -alpha_ddot/3+sin(2*out.alpha)/2.*out.theta_dot.^2;
big_Y(2:2:end, 3) = -cos(out.alpha).*theta_ddot/2;
big_Y(2:2:end, 4) = 0;
big_Y(2:2:end, 5) = -sin(out.alpha)/2;
big_Y(2:2:end, 6) = -out.alpha_dot;

pi = pinv(big_Y)*big_tau;

g = 9.81;
dyn_params = [Jm+Jh+(mp+mr/3)*Lr^2; mp*Lp^2; mp*Lp*Lr; Cth; mp*g*Lp; Cal];
figure;
subplot(1,2,1); hold on;
scatter(big_Y*dyn_params, big_tau); grid on;
title('Theoretical Parameters');
subplot(1,2,2); hold on;
scatter(big_Y*pi, big_tau); grid on;
title('Fitted Model');


%% RESULTS

%% SAVE RESULTS
