% Setup par
PARAMS.th_0_cable = -30.55*pi/180;
PARAMS.th_0 = 0;
PARAMS.th_dot_0 = 0;
PARAMS.al_0 = 160/161*pi;
PARAMS.al_dot_0 = 0;

% Mechanical Parameters
PARAMS.mp = 2.4e-2;
PARAMS.Lp = 1.29e-1;
PARAMS.mr = 9.5e-2;
PARAMS.Lr = 8.5e-2;
PARAMS.Jm = 4e-6;
PARAMS.Jh = 6e-7 + 4.7395e-06;
PARAMS.Cal = 1.4163e-05; % 5e-4;
PARAMS.Cth = 2.2237e-4; %1.5e-3
PARAMS.K = 5e-4/(20*pi/180);
PARAMS.Dth = 62*2e-5;
PARAMS.Sth = 12e-4;  %static friction - dynamic friction
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
                                 
% Linearized sys parameters

num = PARAMS.Jh + PARAMS.Jm + PARAMS.mp * PARAMS.Lr^2 + PARAMS.mr * PARAMS.Lr^2 / 3;
den = PARAMS.Lp * (PARAMS.Jh + PARAMS.Jm + PARAMS.mp * PARAMS.Lr^2 / 4 + PARAMS.mr * PARAMS.Lr^2 / 3);

PARAMS.A_pi = zeros(2);
PARAMS.B_pi = zeros(2,1);

PARAMS.A_pi(1,2) = 1;
PARAMS.A_pi(2,1) = 3 / 2 * 9.81 * num / den;

PARAMS.B_pi(2) = 3 / 2 * PARAMS.Lr / den;

% % Full state feedback
% 
% PARAMS.A = [ 0  1  0          0 
%              0  0  53.3226    0
%              0  0  0          1
%              0  0  166.7723   0 ];



