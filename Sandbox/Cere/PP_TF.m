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
paths.jack_folder       = fullfile(string(paths.mainfolder_path), "Sandbox" + filesep + "Jack");
addpath(genpath(paths.file_path        ));
addpath(genpath(paths.data_folder      ));
addpath(genpath(paths.scripts_folder   ));
addpath(genpath(paths.simulation_folder));
addpath(genpath(paths.jack_folder));

%% SETTINGS

run('graphics_options.m');

%% LOAD SYSTEM

run('m0320_sys_model.m');
A = A_sys_V(0);
B = B_sys_V(0);
clearvars -except colors paths A B C;


%% YALMIP OPTIMIZATION

K = -[5.1799    1.7065  -11.0265    0.1152];

eig_ct = eig(A+B*K);
sys_cl = ss(A+B*K, -B*K(1), [1 0 0 0], 0);
cl_tf = tf(sys_cl);
bode(cl_tf);
