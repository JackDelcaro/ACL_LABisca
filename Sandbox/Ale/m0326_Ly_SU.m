
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
run('m0320_sys_model.m');



th_ddot=simplify(subs(th_ddot, al, al + sym(pi)), 100);
al_ddot=simplify(subs(al_ddot, al, al + sym(pi)), 100);


%%  BECERISMO

Ly_dot = th*th_dot + al*al_dot + th_dot*th_ddot + al_dot*al_ddot;

eq = Ly_dot == 0;
V_eq = simplify(solve(eq, V), 100); %this is never gonna work
V_eq












