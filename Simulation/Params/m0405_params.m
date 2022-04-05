PARAMS.angle_quantization = 0.00307;

% Setup par
PARAMS.th_0_cable = 0;
PARAMS.th_0 = 10/180*pi;
PARAMS.th_dot_0 = 0;
PARAMS.al_0 = 170/180*pi;
PARAMS.al_dot_0 = 0;
PARAMS.g = 9.81;

% Mechanical Parameters
PARAMS.Lp_offset = 0.85e-2;
PARAMS.mp = 2.4e-2;
PARAMS.Lp = 1.29e-1 - PARAMS.Lp_offset;
PARAMS.mr = 9.5e-2;
PARAMS.Lr = 8.5e-2;
PARAMS.Jm = 4e-6;
PARAMS.l2 = (PARAMS.Lp/2 - PARAMS.Lp_offset);
PARAMS.l1 = 0.5117*PARAMS.Lr/2;

PARAMS.Jh = 8.009e-6 - PARAMS.Jm; % official inertia 6e-7
PARAMS.Cal = 2*6.494e-6;
PARAMS.Cth = 0.94*3.660e-4;

PARAMS.K = 2.215e-3;
PARAMS.Sth = 7.9e-4;  % static friction
PARAMS.Dth = 0.85*PARAMS.Sth; % dynamic friction
PARAMS.Sth_vel_threshold = 1e-8;
PARAMS.tau_nom = 22e-3;

% Electrical Parameters
PARAMS.Lm = 1.16e-3;
PARAMS.Rm = 8.4;
PARAMS.ki = 0.042;
PARAMS.kv = 0.042;
PARAMS.Dm = 0;
PARAMS.n = 1;
PARAMS.V_sat = 10;

% Loop Parameters

PARAMS.mu_V_theta_dot = PARAMS.ki /((PARAMS.mp + PARAMS.mr/3) * PARAMS.Lr^2 + ...
                                     PARAMS.Jm + PARAMS.Jh) / PARAMS.Rm;
                                 
% Linearized sys parameters (without friction and only alpha state feedback control law)

num = PARAMS.Jh + PARAMS.Jm + PARAMS.mp * PARAMS.Lr^2 + PARAMS.mr * PARAMS.Lr^2 / 3;
den = PARAMS.Lp * (PARAMS.Jh + PARAMS.Jm + PARAMS.mp * PARAMS.Lr^2 / 4 + PARAMS.mr * PARAMS.Lr^2 / 3);

PARAMS.A_pi = zeros(2);
PARAMS.B_pi = zeros(2,1);

PARAMS.A_pi(1,2) = 1;
PARAMS.A_pi(2,1) = 3 / 2 * 9.81 * num / den;

PARAMS.B_pi(2) = 3 / 2 * PARAMS.Lr / den;

% Linearized sys parameters (with friction and full state feedback control law)

% PARAMS.A_pi = zeros(4);
% PARAMS.B_pi = zeros(4,1);
% 
% PARAMS.A_pi(1, 2) = 1;
% PARAMS.A_pi(2, 2) = - PARAMS.Cth / (PARAMS.Jh + PARAMS.Jm + PARAMS.Lr^2 * PARAMS.mp / 4 + PARAMS.Lr^2 * PARAMS.mr / 3);
% PARAMS.A_pi(2, 3) = (9 * PARAMS.Lr * PARAMS.g * PARAMS.mp) / (12 * PARAMS.Jh + 12 * PARAMS.Jm + 3 * PARAMS.Lr^2 * PARAMS.mp + 4 * PARAMS.Lr^2 * PARAMS.mr);
% PARAMS.A_pi(2, 4) = -(18 * PARAMS.Cal * PARAMS.Lr) / (12 * den);
% 
% PARAMS.A_pi(3, 4) = 1;
% PARAMS.A_pi(4, 2) = -(18 * PARAMS.Cth * PARAMS.Lr) / (12 * den);
% PARAMS.A_pi(4, 3) = 3 / 2 * PARAMS.g * num / den;
% PARAMS.A_pi(4, 4) = -3 * PARAMS.Cal * num / (den * PARAMS.Lp * PARAMS.mp);
% 
% PARAMS.B_pi(2, 1) = PARAMS.Lp / den;
% PARAMS.B_pi(4, 1) = 3 / 2 * PARAMS.Lr / den;

PARAMS.A_pi_int = zeros(3);
PARAMS.B_pi_int = zeros(3,1);

PARAMS.A_pi_int(1:2, 1:2) = PARAMS.A_pi;
PARAMS.A_pi_int(3, 1:2) = [-1 0];

PARAMS.B_pi_int(1:2, 1) = PARAMS.B_pi;

% Tsettling = 2; csi = 0.0001; red_contr; LMIs DT new paper m0325_K_al_th
PARAMS.K_pp_al_th_pi_2 = [4.1265    1.8863  -44.4296   -3.3301];
% Tsettling = 1.5; csi = 0.65; red_contr; LMIs CT (filter up to 15 hz is
% fine)
PARAMS.K_pp_al_th_pi_3 = [4.1265    1.8863  -44.4296   -3.3301];
% PAOLOOOOOO CHE PARAMETRI SONO?
PARAMS.K_pp_al_th_pi_int_1 = [11.1394 2.6857 -39.5275 -3.1135 -18.4929];
% PAOLOOOOOO METTI QUI IL FILTRO NUMERO 2 TESTATO IN LAB
% PARAMS.K_pp_al_th_pi_int_2;
% Tsettling = 1.5; csi = 0.65; red_contr; LMIs CT
PARAMS.K_pp_al_th_pi_int_3 = [15.2679    4.0205  -71.4237   -5.4872  -24.2209];
% Tsettling = 2; csi = 0.65; red_contr; LMIs CT
PARAMS.K_pp_al_th_pi_int_4 = [8.9949    2.8354  -57.2486   -4.3455  -11.6041];
% Tsettling = 4; csi = 0.0001; red_contr; LMIs DT
PARAMS.K_pp_al_th_pi_int_5 = [16.6630    5.7182  -98.9577   -7.7006  -15.2651]; % does not work, inputs are too high
% Tsettling = 15; csi = 0.0001; red_contr; LMIs DT
PARAMS.K_pp_al_th_pi_int_6 = [3.9670    2.3061  -61.6491   -4.5726   -1.6836];


%LQ
%Q = diag([1 0.01 1 0.01]) R = 1; [K, S, CLP] = dlqr(1.01*F, 1.01*G, Q, R, N);
PARAMS.K_LQ_down1 = -[11.0652    2.9103  -16.3115    0.7839];

%Q = diag([1 0.01 1 0.01]) R = 1; [K, S, CLP] = dlqr(1.01*F, 1.01*G, Q, R, N);
PARAMS.K_LQ_up1 = -[-13.3597   -4.1353   74.1672    6.1174];

% LQ int
% Tsettling = 2; Q = diag([0.1 0.01 1 0.01 0.1]); R = 1;
PARAMS.K_LQ_int_down1 = -[6.6748    1.4382   -5.1058    0.1867  -11.9854];
% Tsettling = 1.5; Q = diag([1 0.01 1 0.01 0.1]); R = 1;
PARAMS.K_LQ_int_down2 = -[14.7467    2.4421   -7.4821    0.6436  -32.6271];
% Tsettling = 1.5; Q = diag([1 0.01 1 0.01 0.1]); R = 10;
PARAMS.K_LQ_int_down3 = -[12.8100    2.2404   -7.2298    0.5428  -26.8886];
% Tsettling = 1.5; Q = diag([1 0.01 1000 0.01 0.1]); R = 10;
PARAMS.K_LQ_int_down4 = -[20.3440    3.5740  -14.4428    1.2646  -41.0934];


% Tsettling = 2; Q = diag([0.1 0.01 1 0.01 0.1]); R = 1;
PARAMS.K_LQ_int_up1 = -[-9.8980   -2.7541   55.3324    4.4881   14.0087];


PARAMS.K_pp_state = PARAMS.K_LQ_int_up1(1:4);
PARAMS.K_pp_th_int = PARAMS.K_LQ_int_up1(5);






