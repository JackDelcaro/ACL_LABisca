
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

sys_0_V = ss(A_sys_V(0), B_sys_V(0), C, 0);
sys_0_V_dt = c2d(sys_0_V, dt);
[F, G, H, ~, ~] = ssdata(sys_0_V_dt);
Q = diag([1 0.01 1 0.01]);
R = 1;
N = zeros(4,1);

[K, S, CLP] = dlqr(1.01*F, 1.01*G, Q, R, N);
K
real(eig(A_sys_V(0)))
abs(eig(F))
log(abs(eig(F)))/dt
abs(eig(F-G*K))
log(abs(eig(F-G*K)))/dt

