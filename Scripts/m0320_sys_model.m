
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

%% syms for days

syms l1 l2 real;
syms al th th_0 real;
syms al_dot th_dot real;
syms al_ddot th_ddot real;
syms mp mr Lp Lr Jm Jh real;
syms Cth Cal Dth Sth real;
syms tau T Attr real;
syms c g G C K real;
syms V real;
syms R ki kv real;

%% var definition
l1 = Lr/2;   %comment these for generic values
l2 = Lp/2;   %

Q = [th al]';
Q_dot = [th_dot al_dot]';
Q_ddot = [th_ddot al_ddot]';
s1 = simplify(sin(Q(1)));
c1 = simplify(cos(Q(1)));
s2 = sin(Q(2));
c2 = cos(Q(2));

%% axes and points

O = [0 0 0]';
z0 = [0 0 1]';
z1 = [-s1 c1 0]';
Pl1 = [-l1*s1 l1*c1 0]';
P1 = [-Lr*s1 Lr*c1 0]';
Pl2 = [-Lr*s1-l2*c1*s2 Lr*c1-l2*s1*s2 -l2*c2]';

%% Ai

R01 = [c1 0 -s1;
       s1 0 c1;
       0 -1 0];
R12 = [c2 0 -s2;
       s2 0 c2;
       0 -1 0];
   
R02 = R01*R12;




%% Jacobians

J0_l1 = [z0 O];
J0_l2 = [z0 z1];
Jp_l1 = [cross(z0, Pl1) O];
Jp_l2 = [cross(z0, Pl2) cross(z1, Pl2-P1)];
Jp_l2 = simplify(Jp_l2, 10);

I1 = mr*Lr^2/12;  %add Jh Jm
I2 = mp*Lp^2/12;

I1_big = diag([I1,I1+Jh+Jm,0]);
I2_big = diag([I2,I2,0]);

%% matrixes

%B = simplify(mr*(Jp_l1')*Jp_l1 + I1*(J0_l1')*J0_l1 + mp*(Jp_l2')*Jp_l2 + I2*(J0_l2')*J0_l2, 100);
B = simplify(mr*(Jp_l1')*Jp_l1 + (J0_l1')*R01*I1_big*R01'*J0_l1 + mp*(Jp_l2')*Jp_l2 + (J0_l2')*R02*I2_big*R02'*J0_l2, 100);

%c(i,j,k) = (diff(B(i,j),Q(k)) + diff(B(i,k),Q(j)) - diff(B(j,k),Q(i)))/2;
%c symbols, 2d matrix:(for some reason it didn't work with 3d matrixes)
%|1  2|
%|3  4|
%
c(1,1) = (diff(B(1,1),Q(1)) + diff(B(1,1),Q(1)) - diff(B(1,1),Q(1)))/2;
c(1,2) = (diff(B(1,1),Q(2)) + diff(B(1,2),Q(1)) - diff(B(1,2),Q(1)))/2;
c(2,1) = (diff(B(1,2),Q(1)) + diff(B(1,1),Q(2)) - diff(B(2,1),Q(1)))/2;
c(2,2) = (diff(B(1,2),Q(2)) + diff(B(1,2),Q(2)) - diff(B(2,2),Q(1)))/2;
c(3,1) = (diff(B(2,1),Q(1)) + diff(B(2,1),Q(1)) - diff(B(1,1),Q(2)))/2;
c(3,2) = (diff(B(2,1),Q(2)) + diff(B(2,2),Q(1)) - diff(B(1,2),Q(2)))/2;
c(4,1) = (diff(B(2,2),Q(1)) + diff(B(2,1),Q(2)) - diff(B(2,1),Q(2)))/2;
c(4,2) = (diff(B(2,2),Q(2)) + diff(B(2,2),Q(2)) - diff(B(2,2),Q(2)))/2;

C = [c(1,:)*Q_dot c(2,:)*Q_dot;
     c(3,:)*Q_dot c(4,:)*Q_dot];
 
C = simplify(C, 100);

g0=[0 0 -g]';

G = [0 -mp*(g0'*Jp_l2(:,2))]';

%% other forces

Attr_v = [Cth Cal]'.*Q_dot;

molla = [K*(th-th_0) 0]'; %th_0 rest angle of the spring

%% ta-da

T = simplify(B*Q_ddot + C*Q_dot + G + Attr_v + molla, 100);

b = simplify([tau;0] - (T - B*Q_ddot), 100);

tmp = simplify(B\b, 100);
tmp = subs(tmp, th_0, 0);

th_ddot = tmp(1);
al_ddot = tmp(2);

% These non linear equations have 2 equilibria, one in th = tau/K, al = 0,
% the other in th = tau/K, al = pi
eq_pos_1 = [tau/K, 0, 0, 0];
eq_pos_2 = [tau/K, 0, pi, 0];
assert(simplify(subs(th_ddot, [th, th_dot, al, al_dot], eq_pos_1), 100) == 0 && ...
       simplify(subs(al_ddot, [th, th_dot, al, al_dot], eq_pos_1), 100) == 0 );
assert(simplify(subs(th_ddot, [th, th_dot, al, al_dot], eq_pos_2), 100) == 0 && ...
       simplify(subs(al_ddot, [th, th_dot, al, al_dot], eq_pos_2), 100) == 0 );

%% SYSTEM MATRICES

A_s = sym('a%d%d', [4,4]);
B_s = sym('b%d%d', [4,1]);

% States:
%   - theta
%   - theta_dot
%   - alpha
%   - alpha_dot

A_s(1,:) = [0 1 0 0];
A_s(2,:) = gradient(th_ddot, [th, th_dot, al, al_dot]);
A_s(3,:) = [0 0 0 1];
A_s(4,:) = gradient(al_ddot, [th, th_dot, al, al_dot]);

A_s = simplify(A_s, 100);

B_s(1) = 0;
B_s(2) = diff(th_ddot, tau);
B_s(3) = 0;
B_s(4) = diff(al_ddot, tau);

B_s = simplify(B_s, 100);

eq_state_pos = simplify( - A_s\B_s * tau, 100);

%% EQUILIBRIUM POSITION

A_al_tau = @(alpha) simplify(subs(A_s, [th, th_dot, al, al_dot], [tau/K, 0, alpha, 0]), 100);
B_al_tau = @(alpha) simplify(subs(B_s, [th, th_dot, al, al_dot], [tau/K, 0, alpha, 0]), 100);
% Note that A_al does not contain tau if al = 0 or al = pi

A_0_tau = A_al_tau(0);
A_pi_tau = A_al_tau(pi);

B_0_tau = B_al_tau(0);
B_pi_tau = B_al_tau(pi);

C = [1 0 0 0;
     0 0 1 0];

%% SYSTEM EQUATIONS

run('m0318_params.m');
g_value = 9.81;

Params = [mp, mr, Lp, Lr, Jm, Jh, g, Cth, Cal, K, R, ki, kv];
Params_value = [PARAMS.mp, PARAMS.mr, PARAMS.Lp, PARAMS.Lr, PARAMS.Jm,...
    PARAMS.Jh, g_value, PARAMS.Cth, PARAMS.Cal, PARAMS.K, PARAMS.Rm, PARAMS.ki, PARAMS.kv];

A_sys_tau = @(alpha) double(subs(A_al_tau(alpha), Params, Params_value));
B_sys_tau = @(alpha) double(subs(B_al_tau(alpha), Params, Params_value));

C_alpha = [0 0 1 0];

sys_pi_tau = ss(A_sys_tau(pi), B_sys_tau(pi), C, 0);

G_mimo = tf(sys_pi_tau);

G_tau_theta = G_mimo(1);
G_tau_alpha = G_mimo(2);

eigvals_pi_tau = eig(A_sys_tau(pi));

%% SYSTEM WITH MOTOR

% Let us introduce the voltage V
th_ddot = subs(th_ddot, tau, ki/R * (V - kv*th_dot));
al_ddot = subs(al_ddot, tau, ki/R * (V - kv*th_dot));

eq_pos_1 = [ki*V/K/R, 0, 0, 0];
eq_pos_2 = [ki*V/K/R, 0, pi, 0];
assert(simplify(subs(th_ddot, [th, th_dot, al, al_dot], eq_pos_1), 100) == 0 && ...
       simplify(subs(al_ddot, [th, th_dot, al, al_dot], eq_pos_1), 100) == 0 );
assert(simplify(subs(th_ddot, [th, th_dot, al, al_dot], eq_pos_2), 100) == 0 && ...
       simplify(subs(al_ddot, [th, th_dot, al, al_dot], eq_pos_2), 100) == 0 );

%% SYSTEM MATRICES

A_s = sym('a%d%d', [4,4]);
B_s = sym('b%d%d', [4,1]);

% States:
%   - theta
%   - theta_dot
%   - alpha
%   - alpha_dot

A_s(1,:) = [0 1 0 0];
A_s(2,:) = gradient(th_ddot, [th, th_dot, al, al_dot]);
A_s(3,:) = [0 0 0 1];
A_s(4,:) = gradient(al_ddot, [th, th_dot, al, al_dot]);

A_s = simplify(A_s, 100);

B_s(1) = 0;
B_s(2) = diff(th_ddot, V);
B_s(3) = 0;
B_s(4) = diff(al_ddot, V);

B_s = simplify(B_s, 100);

eq_state_pos = simplify( - A_s\B_s * tau, 100);

%% EQUILIBRIUM POSITION

A_al_V = @(alpha) simplify(subs(A_s, [th, th_dot, al, al_dot], [ki*V/K/R, 0, alpha, 0]), 100);
B_al_V = @(alpha) simplify(subs(B_s, [th, th_dot, al, al_dot], [ki*V/K/R, 0, alpha, 0]), 100);
% Note that A_al_V does not contain tau if al = 0 or al = pi

A_0_V = A_al_V(0);
A_pi_V = A_al_V(pi);

B_0_V = B_al_V(0);
B_pi_V = B_al_V(pi);

%% SYSTEM EQUATIONS

run('m0318_params.m');
g_value = 9.81;

A_sys_V = @(alpha) double(subs(A_al_V(alpha), Params, Params_value));
B_sys_V = @(alpha) double(subs(B_al_V(alpha), Params, Params_value));

sys_pi_V = ss(A_sys_V(pi), B_sys_V(pi), C, 0);

G_mimo = tf(sys_pi_V);

G_V_theta = G_mimo(1);
G_V_alpha = G_mimo(2);

eigvals_pi_V = eig(A_sys_V(pi));

%%
% 
% for i = 1:size(A_s, 1)
%     for j = 1:size(A_s, 2)
%         tmp3(i, j) = simplify(gradient(A_s(i,j), V), 100);
%         tmp4(i, j) = simplify(gradient(A_s(i,j), th), 100);
%     end
% end
% 
% tmp5 = simplify(tmp3 + tmp4/K/R*ki, 100);
% % pretty(tmp5);