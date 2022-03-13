%% HYPOTHESIS
% -c.o.m. in the middle of each rod
% -negligible distances in the junction between arm and pendulum
% -both the pendulum and the arm can be considered slender rods

%% Variables definition

syms mp mr Lp Lr Jm Jh real
syms Cth Cal real
syms g

model_PARAMS.mp = mp;
model_PARAMS.mr = mr;
model_PARAMS.Lp = Lp;
model_PARAMS.Lr = Lr;
model_PARAMS.Jm = Jm;
model_PARAMS.Jh = Jh;
model_PARAMS.Cth = Cth;
model_PARAMS.Cal = Cal;
model_PARAMS.g = g;

%% Kinematics

x_cr = Lr/2 * cos(th);
y_cr = Lr/2 * sin(th);

x_cp = Lr * cos(th) - Lp/2 * sin(al) * sin(th);
y_cp = Lr * sin(th) + Lp/2 * sin(al) * cos(th);
z_cp = -Lp/2 * cos(al);

h_p = z_cp + Lp/2;

vx_cr = diff(x_cr, th) * th_dot;
vy_cr = diff(y_cr, th) * th_dot;

v_cr_sq = simplify(vx_cr^2 + vy_cr^2);

vx_cp = diff(x_cp, th) * th_dot + diff(x_cp, al) * al_dot;
vy_cp = diff(y_cp, th) * th_dot + diff(y_cp, al) * al_dot;
vz_cp = diff(z_cp, th) * th_dot + diff(z_cp, al) * al_dot;

v_cp_sq = simplify(vx_cp^2 + vy_cp^2 + vz_cp^2, 'Steps', 10);

%% Energies

V = mp * g * h_p;

J_r = mr * Lr^2 / 12;
J_p = mp * Lp^2 / 12;

T_rr = 1/2 * J_r * th_dot^2;
T_rt = 1/2 * mr * v_cr_sq;
T_pr = 1/2 * J_p * al_dot^2;
T_pt = 1/2 * mp * v_cp_sq;

T = T_rr + T_rt + T_pr + T_pt;

L = T - V;

D = 1/2 * (Cth * th_dot^2 + Cal * al_dot^2);