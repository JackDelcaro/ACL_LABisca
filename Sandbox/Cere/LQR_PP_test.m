
run('Sys_Linearization');

%% Pole placement 

% Poles_cl = [-200, -201];
% 
% K_pp = place(A_sys(3:4, 3:4), B_sys(3:4), Poles_cl);
% 
% A_cl = A_sys(3:4, 3:4) - B_sys(3:4) * K_pp;
% 
% eigenvalues_cl = eig(A_cl);

%% LQR control

Q = diag([1, 0.01, 100, 0.01]);
R = 10;
N = zeros(4,1);

[K, S, CLP] = lqr(sys, Q, R, N);