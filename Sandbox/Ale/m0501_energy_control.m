
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
run('m0405_sys_model.m');
run('m0405_params.m');


% 
% th_ddot=simplify(subs(th_ddot, al, al + sym(pi)), 100);
% al_ddot=simplify(subs(al_ddot, al, al + sym(pi)), 100);


%%  BECERISMO


E = 1/2*B(2,2)*al_dot^2 + 1/2*B(2,1)*th_dot^2 + mp*g*l2*(cos(al)-1);
E_dot = B(2,2)*al_dot*al_ddot + B(2,1)*th_dot*th_ddot - mp*g*l2*sin(al);
E_zero = -2*mp*g*l2;



Ly = (E - E_zero)^2/2;
Ly_dot = simplify((E - E_zero)*E_dot, 100)



eq = Ly_dot == 0;
T_eq = simplify(solve(eq, tau), 100); %this is never gonna work
T_eq
