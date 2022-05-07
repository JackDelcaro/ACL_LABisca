clearvars;
close all;

run('m0320_sys_model.m');

dt_control = 2e-3;
load('data_KF.mat');
data = out;

theta_vec = data.theta;
theta_vec.Data = -theta_vec.Data;
alpha_vec = data.alpha;
alpha_vec.Data = alpha_vec.Data - pi;
voltage_vec = data.voltage;
voltage_vec.Data = -voltage_vec.Data;
theta_dot_vec = data.theta_dot;
theta_dot_vec.Data = -theta_dot_vec.Data;
alpha_dot_vec = data.alpha_dot;

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

%%

base = 10;

N_ypos = 10;
N_xpos = 10;
N_xvel = 10;

R_pos = base.^(-fix(N_ypos/2):fix(N_ypos/2)-(1-mod(N_ypos, 2)));
Q_th = base.^(-fix(N_xpos/2):fix(N_xpos/2)-(1-mod(N_xpos, 2)));
Q_th_dot = base.^(-fix(N_xvel/2):fix(N_xvel/2)-(1-mod(N_xvel, 2)));
Q_al = Q_th;
Q_al_dot = Q_th_dot;

Q = zeros(5, 5, N_xpos, N_xvel);

for i=1:N_xpos
    for j=1:N_xvel
        Q(:, :, i, j) = [0 0       0           0       0;
                         0 Q_th(i) 0           0       0;
                         0 0       Q_th_dot(j) 0       0;
                         0 0       0           Q_al(i) 0;
                         0 0       0           0       Q_al_dot(j)];
    end
end

R = zeros(2, 2, N_ypos);

for i=1:N_ypos
    R(:, :, i) = [R_pos(i), 0;
                  0         R_pos(i)];
end

U = [voltage_vec.Data theta_vec.Data alpha_vec.data];
t_vec = voltage_vec.Time;

mse_mat_th_dot = zeros(N_xpos, N_xvel, N_ypos);
mse_mat_al_dot = zeros(N_xpos, N_xvel, N_ypos);
% mse_mat_th_dot_DT = zeros(N_xpos, N_xvel, N_ypos);
% mse_mat_al_dot_DT = zeros(N_xpos, N_xvel, N_ypos);

mse_min_th = inf;
idx_min_th = zeros(3, 1);

mse_min_al = inf;
idx_min_al = zeros(3, 1);

for i=1:N_xpos
    for j=1:N_xvel
        for k=1:N_ypos
            
            [~, L_CT]= kalman(sys_KF_CT, Q(:, :, i, j), R(:, :, k));
%             [~, L_DT] = kalmd(sys_KF_CT, Q(:, :, i, j), R(:, :, k), dt_control);
            
%             A_KF_DT_tf = A_pi_DT - L_DT * C;
%             B_KF_DT_tf = [B_pi_DT L_DT];
%             C_KF_DT_tf = eye(4);
%             sys_KF_DT_tf = ss(A_KF_DT_tf, B_KF_DT_tf, C_KF_DT_tf, 0, dt_control);
            
            A_KF_CT_tf = A_pi_CT - L_CT * C;
            B_KF_CT_tf = [B_pi_CT L_CT];
            C_KF_CT_tf = eye(4);
            sys_KF_CT_tf = ss(A_KF_CT_tf, B_KF_CT_tf, C_KF_CT_tf, 0);
            
            x_est = lsim(sys_KF_CT_tf, U, t_vec);
%             x_est_DT = lsim(sys_KF_DT_tf, U, t_vec);
            
            mse_mat_th_dot(i, j, k) = sum((x_est(:, 2) - theta_dot_vec.Data).^2);
            mse_mat_al_dot(i, j, k) = sum((x_est(:, 4) - alpha_dot_vec.Data).^2);
%             mse_mat_th_dot_DT(i, j, k) = sum((x_est_DT(:, 2) - theta_dot_vec.Data).^2);
%             mse_mat_al_dot_DT(i, j, k) = sum((x_est_DT(:, 4) - alpha_dot_vec.Data).^2);

            if mse_mat_th_dot(i, j, k) < mse_min_th
                mse_min_th = mse_mat_th_dot(i, j, k);
                idx_min_th = [i; j; k];
            end
            
            if mse_mat_al_dot(i, j, k) < mse_min_al
                mse_min_al = mse_mat_al_dot(i, j, k);
                idx_min_al = [i; j; k];
            end
            
            disp([num2str(i), ' ', num2str(j), ' ', num2str(k)]);
            
        end
    end
end

%%

idx_vec = 1:N_ypos*N_xpos*N_xvel;
x_axis_vec = zeros(length(idx_vec), 1);
y_axis_vec = zeros(length(idx_vec), 1);
z_axis_vec = zeros(length(idx_vec), 1);
mse_vec_th_dot = zeros(length(idx_vec), 1);
mse_vec_al_dot = zeros(length(idx_vec), 1);

for i=1:length(idx_vec)
    
    l = mod(i-1, N_ypos) + 1;
    k = mod(fix((i-1) / N_ypos), N_xvel) + 1;
    j = fix((i-1) / N_ypos / N_xvel) + 1;
    
    x_axis_vec(i) = j;
    y_axis_vec(i) = k;
    z_axis_vec(i) = l;
    
    mse_vec_th_dot(i) = mse_mat_th_dot(j, k, l);
    mse_vec_al_dot(i) = mse_mat_al_dot(j, k, l);
    
end

mse_vec_th_dot_norm = mse_min_th ./ mse_vec_th_dot;
mse_vec_al_dot_norm = mse_min_al ./ mse_vec_al_dot;

figure
scatter3(x_axis_vec, y_axis_vec, z_axis_vec, ones(length(idx_vec), 1) * 15, mse_vec_th_dot_norm, 'filled');
figure
scatter3(x_axis_vec, y_axis_vec, z_axis_vec, ones(length(idx_vec), 1) * 15, mse_vec_al_dot_norm, 'filled');

%%

[~, L_CT]= kalman(sys_KF_CT, Q(:, :, idx_min_th(1), idx_min_th(2)), R(:, :, idx_min_th(3)));

A_KF_CT_tf = A_pi_CT - L_CT * C;
B_KF_CT_tf = [B_pi_CT L_CT];
C_KF_CT_tf = eye(4);
sys_KF_CT_tf = ss(A_KF_CT_tf, B_KF_CT_tf, C_KF_CT_tf, 0);

x_est = lsim(sys_KF_CT_tf, U, t_vec);

figure
plot(t_vec, theta_dot_vec.Data);
hold on;
plot(t_vec, x_est(:, 2));

[~, L_CT]= kalman(sys_KF_CT, Q(:, :, idx_min_al(1), idx_min_al(2)), R(:, :, idx_min_al(3)));

A_KF_CT_tf = A_pi_CT - L_CT * C;
B_KF_CT_tf = [B_pi_CT L_CT];
C_KF_CT_tf = eye(4);
sys_KF_CT_tf = ss(A_KF_CT_tf, B_KF_CT_tf, C_KF_CT_tf, 0);

x_est = lsim(sys_KF_CT_tf, U, t_vec);

figure
plot(t_vec, alpha_dot_vec.Data);
hold on;
plot(t_vec, x_est(:, 4));
