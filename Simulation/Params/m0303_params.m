% Setup par
PARAMS.th_0_cable = -30.55*pi/180;
PARAMS.th_0 = 0;
PARAMS.th_dot_0 = 0;
PARAMS.al_0 = 56/55 * pi;
PARAMS.al_dot_0 = 0;
PARAMS.g = 9.81;

% Mechanical Parameters
PARAMS.mp = 2.4e-2;
PARAMS.Lp = 1.29e-1;     % exp0314 ~0.1225 forse una questione dell'esatta formula di inerzia ma sticazzi
PARAMS.mr = 9.5e-2;
PARAMS.Lr = 8.5e-2;
PARAMS.Jm = 4e-6;

PARAMS.Jh = 6e-7 + 4.7395e-06; %   (?)    exp0314 Jh+Jm=8e-6 ~ok
PARAMS.Cal = 1.4163e-05; % 5e-4;   exp0314 6.4940e-6
PARAMS.Cth = 2.2237e-4; %1.5e-3    exp0314 1.2135e-5 (solo motore)

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






