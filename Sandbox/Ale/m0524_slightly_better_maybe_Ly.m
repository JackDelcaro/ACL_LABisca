
clc;
clearvars;

%% PATHS

paths.file_full2ath = matlab.desktop.editor.getActiveFilename;
[paths.file_path, ~, ~] = fileparts(paths.file_full2ath);
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

D = [Jm+Jh+mr*Lr^2/12+mr*l1^2+mp*(Lr^2+l2^2*sin(al)^2) mp*l2*Lr*cos(al);
    mp*l2*Lr*cos(al) mp*(Lp^2/12+l2^2)];
H = [mp*l2^2*sin(2*al)*th_dot*al_dot-mp*Lr*l2*sin(al)*al_dot^2;
    -1/2*mp*l2^2*sin(2*al)*th_dot^2];
G = [0; -mp*g*l2*sin(al)];
B = [1;0];

E = simplify(1/2*Q_dot'*D*Q_dot + mp*g*l2*(cos(al)-1), 100);

syms k_E k_ome k_th k_delta real

E_0 = 0.01;

Lambda = simplify(k_E*(E-E_0) + k_ome*(B'/D)*B, 100);

tau = (k_ome*(B'/D)*(H+G)-k_th*th-k_delta*th_dot)/Lambda;

V_in = R/ki*tau+kv*th_dot;

cond = mp*g*l2/D(2,2);


run('m0405_params.m');


fun = vpa(subs((1-cos(al))* det(D), [l1;l2;mp;Lp;mr;Lr;Jm;Jh;Cth;Cal;Dth;K;Sth;g],...
    [PARAMS.l1;PARAMS.l2;PARAMS.mp;PARAMS.Lp;PARAMS.mr;PARAMS.Lr;PARAMS.Jm;PARAMS.Jh;PARAMS.Cth;PARAMS.Cal;PARAMS.Dth;PARAMS.K;PARAMS.Sth;PARAMS.g]),5);


% 5e-8 max fun

ratio_min=vpa(subs(cond, [l1;l2;mp;Lp;mr;Lr;Jm;Jh;Cth;Cal;Dth;K;Sth;g],...
    [PARAMS.l1;PARAMS.l2;PARAMS.mp;PARAMS.Lp;PARAMS.mr;PARAMS.Lr;PARAMS.Jm;PARAMS.Jh;PARAMS.Cth;PARAMS.Cal;PARAMS.Dth;PARAMS.K;PARAMS.Sth;PARAMS.g]),5)* 5e-8;

k_E_val = double(1);
k_ome_val = double(2 * ratio_min * k_E_val);
k_delta_val = double(k_ome_val);
k_th_val = double(10 * k_ome_val);

% V_in = vpa(subs(V_in, [l1;l2;mp;Lp;mr;Lr;Jm;Jh;Cth;Cal;Dth;K;Sth;g;R;ki;kv],...
%     [PARAMS.l1;PARAMS.l2;PARAMS.mp;PARAMS.Lp;PARAMS.mr;PARAMS.Lr;PARAMS.Jm;...
%     PARAMS.Jh;PARAMS.Cth;PARAMS.Cal;PARAMS.Dth;PARAMS.K;PARAMS.Sth;PARAMS.g;...
%     PARAMS.Rm;PARAMS.ki;PARAMS.kv]),5)







