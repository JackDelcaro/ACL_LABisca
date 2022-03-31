
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

run('m0320_sys_model.m');
dt=2e-3;

%% LQ
Tsettling = 1.5;
rho = exp(-5*dt/Tsettling);

A = A_sys_V(0);
B = B_sys_V(0);
C_th_int = [1 0 0 0];
A = [A  zeros(4, 1); -C_th_int 0];
B = [B; 0];
C = [1 0 0 0 0;
     0 0 1 0 0];
sys_0_V = ss(A, B, C, 0);
sys_0_V_dt = c2d(sys_0_V, dt);
[F, G, H, ~, ~] = ssdata(sys_0_V_dt);
Q = diag([1 0.01 1000 0.01 0.1]);
R = 10;
N = zeros(5,1);

[K, S, CLP] = dlqr(1/rho*F, 1/rho*G, Q, R, N);
K
real(eig(A_sys_V(0)))
abs(eig(F))
log(eig(F))/dt
abs(eig(F-G*K))
log(eig(F-G*K))/dt

