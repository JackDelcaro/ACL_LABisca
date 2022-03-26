
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
clearvars -except colors paths A B C;


%% YALMIP OPTIMIZATION

enable_red_cntrl_effort = true;
Tsettling = 1.5;
csi_min = 0.65;
alpha = 5/Tsettling;

n = size(A, 1);
m = size(B, 2);

yalmip clear;

Y = sdpvar(n);
L = sdpvar(m ,n);
    
kl = sdpvar(1);
ky = sdpvar(1);
cos_theta = csi_min;
sin_theta = sin(acos(csi_min));
LMIconstr = [[sin_theta*( A*Y+Y*A'+B*L+L'*B'), cos_theta*(A*Y-Y*A'+B*L-L'*B');
              cos_theta*(-A*Y+Y*A'-B*L+L'*B'), sin_theta*(A*Y+Y*A'+B*L+L'*B')] <= -1e-6*eye(2*n)];
LMIconstr = LMIconstr + [Y*A'+A*Y+B*L+L'*B'+2*alpha*Y <= -1e-6*eye(n)] + [Y>=1e-6*eye(n)];
if enable_red_cntrl_effort == 1
    LMIconstr = LMIconstr + [ [kl*eye(n), L'; L, eye(m)] >= 1e-6*eye(n+m)];
    LMIconstr = LMIconstr + [ [ky*eye(n), eye(n); eye(n), Y] >= 1e-6*eye(2*n)];
end
LMIconstr = LMIconstr + [kl >= 1e-6];
LMIconstr = LMIconstr + [ky >= 1e-6];
options = sdpsettings('solver','sedumi','verbose',1);
J = optimize(LMIconstr, 0.01*kl + 10*ky, options);
feas = J.problem;
L = double(L);
Y = double(Y);

K = L/Y;
eig_ct = eig(A+B*K);

% PLOTS
figure;
initial( ss(A, zeros(size(B)), C, []), [5*pi/180 0 5*pi/180 0]');
figure;
initial( ss(A+B*K, zeros(size(B)), C, []), [5*pi/180 0 5*pi/180 0]');


% PLOTS
dt = 2e-3;
sys_ct = ss(A, B, C, []);
sys_dt = c2d(sys_ct, dt);
[F, G, ~, ~, ~] = ssdata(sys_dt);
figure;
initial( ss(F, zeros(size(G)), C, [], dt), [5*pi/180 0 5*pi/180 0]');
figure;
initial( ss(F+G*K, zeros(size(G)), C, [], dt), [5*pi/180 0 5*pi/180 0]');
