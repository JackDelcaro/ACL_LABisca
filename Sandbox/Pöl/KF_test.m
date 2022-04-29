clearvars;
close all;

dt_control = 2e-3;

run('m0320_sys_model.m');
A_pi_CT = A_sys_V(pi);
B_pi_CT = B_sys_V(pi);
A_0_CT = A_sys_V(0);
B_0_CT = B_sys_V(0);
          
C = [1 0 0 0;
     0 0 1 0];
D = [0; 0];

sys_pi_CT = ss(A_pi_CT, B_pi_CT, C, D);
sys_0_CT = ss(A_0_CT, B_0_CT, C, D);
sys_pi_DT = c2d(sys_pi_CT, dt_control);
sys_0_DT = c2d(sys_0_CT, dt_control);

A_pi_DT = sys_pi_DT.A;          
B_pi_DT = sys_pi_DT.B;
A_0_DT = sys_0_DT.A; 
B_0_DT = sys_0_DT.B;

A_KF_CT = A_pi_CT;
B_KF_CT = [B_pi_CT eye(4)];
A_KF_DT = A_pi_DT;
B_KF_DT = [B_pi_DT eye(4)];

D_KF = [D zeros(2, 4)];

sys_KF_CT = ss(A_KF_CT, B_KF_CT, C, D_KF);
sys_KF_DT = ss(A_KF_DT, B_KF_DT, C, D_KF, dt_control);

R_pos = 1e3;
R_vel = 1e3;
Q_th = 10;
Q_th_dot = 10;
Q_al = 10;
Q_al_dot = 10;

% KF
Q_pi1 = [0 0    0        0    0;
         0 Q_th 0        0    0;
         0 0    Q_th_dot 0    0;
         0 0    0        Q_al 0;
         0 0    0        0    Q_al_dot];
            
R_pi1 = [R_pos 0;
         0     R_pos];
            
Q_KF = Q_pi1;
R_KF = R_pi1;

[~, L_CT]= kalman(sys_KF_CT, Q_KF, R_KF);
[~, L_DT] = kalman(sys_KF_DT, Q_KF, R_KF);
[~, L_DT2] = kalmd(sys_KF_CT, Q_KF, R_KF, dt_control);

% A_KF_DT_tf = A_pi_DT - L_DT2 * C;
% B_KF_DT_tf = L_DT2(:, 4);
% C_KF_DT_tf = [0 0 0 1];
% sys_KF_DT_tf = ss(A_KF_DT_tf, B_KF_DT_tf, C_KF_DT_tf, 0, dt_control);
% KF_DT_tf = tf(sys_KF_DT_tf);
% 
% A_KF_CT_tf = A_pi_CT - L_CT * C;
% B_KF_CT_tf = L_CT(:, 2);
% C_KF_CT_tf = [0 0 0 1];
% sys_KF_CT_tf = ss(A_KF_CT_tf, B_KF_CT_tf, C_KF_CT_tf, 0);
% KF_CT_tf = tf(sys_KF_CT_tf);

A_KF_CT_tot_tf = A_pi_CT - L_CT * C;
B_KF_CT_tot_tf = [B_pi_CT, L_CT];
C_KF_CT_tot_tf = [0 1 0 0;
                  0 0 0 1];
sys_KF_CT_tot_tf = ss(A_KF_CT_tot_tf, B_KF_CT_tot_tf, C_KF_CT_tot_tf, 0);
KF_CT_tot_tf = tf(sys_KF_CT_tot_tf);

bode(KF_CT_tot_tf);