
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
A = A_sys_V(pi);
B = B_sys_V(pi);
C_th_int = [1 0 0 0];
A = [A  zeros(4, 1); -C_th_int 0];
B = [B; 0];
C = [1 0 0 0 0;
     0 0 1 0 0];
clearvars -except colors paths A B C;
sys_ct = ss(A, B, C, []);
dt = 2e-3;

%% SYSTEM DISCRETIZATION

sys_dt = c2d(sys_ct, dt);
[F, G, H, ~, ~] = ssdata(sys_dt);

%% YALMIP OPTIMIZATION

enable_red_cntrl_effort = true;
Tsettling = 2;
rho = exp(-5*dt/Tsettling);
rho2 = 1;
alpha = -(1 - rho2);

n = size(F, 1);
m = size(G, 2);

yalmip clear;

P = sdpvar(n);
L = sdpvar(m,n);

kl = sdpvar(1);
kp = sdpvar(1);

LMIconstr = [[rho^2*P-F*P*F'-F*L'*G'-G*L*F' G*L;
                L'*G'                        P] >= 1e-3*eye(n*2)];
LMIconstr = LMIconstr + ...
            [[(rho2^2 - alpha^2)*P-F*P*F'-F*L'*G'-G*L*F'-alpha*(P*F'+L'*G'+G*L+F*P) G*L;
                L'*G'                        P] >= 1e-3*eye(n*2)];

if enable_red_cntrl_effort == 1
    LMIconstr = LMIconstr + [ [kl*eye(n), L'; L, eye(m)] >= 1e-5*eye(n+m)];
    LMIconstr = LMIconstr + [ [kp*eye(n), eye(n); eye(n), P] >= 1e-5*eye(2*n)];
end

LMIconstr = LMIconstr + [kl >= 1e-3];
LMIconstr = LMIconstr + [kp >= 1e-3];

options=sdpsettings('solver','sedumi', 'verbose', 1);
J = optimize(LMIconstr,0.01*kl + 10*kp,options);
feas = J.problem;
feas

L = double(L);
P = double(P);

K = L/P;
ei = eig(F+G*K);
figure;
initial( ss(F, zeros(size(G)), C, [], dt), [5*pi/180 0 5*pi/180 0 0]');
figure;
initial( ss(F+G*K, zeros(size(G)), C, [], dt), [5*pi/180 0 5*pi/180 0 0]');