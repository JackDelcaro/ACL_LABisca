%% HYPOTHESIS
% -c.o.m. in the middle of each rod
% -negligible distances in the junction between arm and pendulum
% -both the pendulum and the arm can be considered slender rods

clearvars;
close all;

%% Variables definition

syms al th
syms al_dot th_dot
syms al_ddot th_ddot
syms mp mr Lp Lr Jm Jh
syms Cth Cal
syms tau

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

syms g

V = mp * g * h_p;

J_r = mr * Lr^2 / 12;
J_p = mp * Lp^2 / 12;

T_rr = 1/2 * J_r * th_dot^2;
T_rt = 1/2 * mr * v_cr_sq;
T_pr = 1/2 * J_p * al_dot^2;
T_pt = 1/2 * mp * v_cp_sq;

T = T_rr + T_rt + T_pr + T_pt;

L = T - V;

%% Lagrange equation terms

dL_dthdot = simplify(diff(L, th_dot), 'Steps', 20);
dL_daldot = simplify(diff(L, al_dot), 'Steps', 20);
dL_dth = simplify(diff(L, th), 'Steps', 20);
dL_dal = simplify(diff(L, al), 'Steps', 20);

dt_dLthdot = simplify(diff(dL_dthdot, th_dot) * th_ddot + ...
                      diff(dL_dthdot, al_dot) * al_ddot + ...
                      diff(dL_dthdot, th) * th_dot + ...
                      diff(dL_dthdot, al) * al_dot, 'Steps', 20);
                  
dt_dLaldot = simplify(diff(dL_daldot, th_dot) * th_ddot + ...
                      diff(dL_daldot, al_dot) * al_ddot + ...
                      diff(dL_daldot, th) * th_dot + ...
                      diff(dL_daldot, al) * al_dot, 'Steps', 20);
                  
lhs_th = simplify(dt_dLthdot - dL_dth + Cth * th_dot + (Jm + Jh) * th_ddot, ...
                  'Steps', 20);
lhs_al = simplify(dt_dLaldot - dL_dal + Cal * al_dot, 'Steps', 20);

A(1, :) = gradient(lhs_th, [th_ddot, al_ddot]);
A(2, :) = gradient(lhs_al, [th_ddot, al_ddot]);

b(1, :) = tau - (lhs_th - A(1, :) * [th_ddot; al_ddot]);
b(2, :) = - (lhs_al - A(2, :) * [th_ddot; al_ddot]);

b = simplify(b, 100);

X = simplify(A\b, 100);

%% Dynamic parameters identification

% Reformulate the dynamic equations as linear equations wrt a set of
% dynamic parameters 

dyn_params = [Jm+Jh+(mp+mr/3)*Lr^2; mp*Lp^2; mp*Lp*Lr; Cth; mp*g*Lp; Cal];

Y = [th_ddot, 1/4*(1-cos(al)^2)*th_ddot + sin(2*al)*th_dot*al_dot/4, -cos(al)*al_ddot/2+al_dot^2*sin(al)/2, th_dot, 0, 0;
     0, al_ddot/3-sin(2*al)/8*th_dot^2, -cos(al)/2*th_ddot, 0, sin(al)/2, al_dot];
