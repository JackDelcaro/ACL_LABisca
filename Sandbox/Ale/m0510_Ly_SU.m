
clc;
clearvars;

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
run('m0405_sys_model.m');



th_ddot=simplify(th_ddot, 100);
al_ddot=simplify(al_ddot, 100);


%%  BECERISMO

K_th = 0.3;
K_th_dot = 1;
K_al = 0.5;
K_al_dot = 1.5;

% Ly = K_th/2*th^2 + k_th_dot/2*th_dot^2 + K_al/2*(al-pi)^2 + K_al_dot/2*al_dot^2

Ly_dot = K_th*th*th_dot + K_th_dot*th_dot*th_ddot + K_al*(al-sym(pi))*al_dot + K_al_dot*al_dot*al_ddot;

eq = Ly_dot == (-th^2-(al-sym(pi))^2-th_dot^2-al_dot^2)*1.5;
V_eq = simplify(solve(eq, V), 100); %this is never gonna work
x="V = "+string(V_eq)+";"

% eval("BUH ="+x)








