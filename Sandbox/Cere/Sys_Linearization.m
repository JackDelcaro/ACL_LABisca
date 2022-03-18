%% HYPOTHESIS
% -c.o.m. in the middle of each rod
% -negligible distances in the junction between arm and pendulum
% -both the pendulum and the arm can be considered slender rods

% clearvars;
close all;

%% Variables definition

syms al th
syms al_dot th_dot
syms mp mr Lp Lr Jm Jh
syms Cth Cal
syms tau g

A = sym('A', [4,4]);
B = sym('B', [4,1]);

g_value = 9.81;

%% Linearization

a_11 = mp * (Lp^2/4 - Lp^2*cos(al)^2/4 + Lr^2) + mr*Lr^2/3 + Jm + Jh;
a_12 = mp*Lp*Lr*cos(al)/2;
a_21 = mp*Lp*Lr*cos(al)/2;
a_22 = mp*Lp^2/3;

det_A = (a_11*a_22 - a_12*a_21);

b_1 = tau - Cth*th_dot - (mp*Lp^2*sin(2*al)/4)*al_dot*th_dot + ...
    (mp*Lp*Lr*sin(al)/2)*al_dot^2;
b_2 = -Cal*al_dot - mp*g*Lp*sin(al)/2 + (mp*Lp^2*sin(2*al)/8)*th_dot^2;

th_ddot = (b_1.*a_22 - b_2.*a_12) / det_A;
al_ddot = (-b_1.*a_21 + b_2.*a_11) / det_A;

A(1,:) = [ 0 1 0 0];
A(3,:) = [ 0 0 0 1];

A(2,:) = gradient(th_ddot, [th, th_dot, al, al_dot]);
A(4,:) = gradient(al_ddot, [th, th_dot, al, al_dot]);

B(1) = 0;
B(3) = 0;
B(2) = diff(th_ddot, tau);
B(4) = diff(al_ddot, tau);


%% Eq. positions

A_0 = simplify(subs(A, [al, al_dot, th_dot], [0,0,0]), 10);
A_pi = simplify(subs(A, [al, al_dot, th_dot], [pi,0, 0]), 10);

B_0 = simplify(subs(B, al, 0), 10);
B_pi = simplify(subs(B, al, pi), 10);

C = [1 0 1 0];


%% Sys equations

run('m0303_params.m');

Params = [mp, mr, Lp, Lr, Jm, Jh, g, Cth, Cal];
Params_value = [PARAMS.mp, PARAMS.mr, PARAMS.Lp, PARAMS.Lr, PARAMS.Jm, PARAMS.Jh, g_value, PARAMS.Cth, PARAMS.Cal];

A_sys = double(subs(A_pi, Params, Params_value));
B_sys = double(subs(B_pi, Params, Params_value));

C_alpha = [0 0 1 0];

sys = ss(A_sys, B_sys, C_alpha, 0);

G_tau_alpha = tf(sys);

eigenvalues = eig(A_sys);

