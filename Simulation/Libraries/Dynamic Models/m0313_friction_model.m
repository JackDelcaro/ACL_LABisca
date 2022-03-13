syms tau_res real;
syms tau_friction real;
syms Sth_vel_threshold Sth Dth real;

friction_model_PARAMS.Sth_vel_threshold = Sth_vel_threshold;
friction_model_PARAMS.Sth = Sth;
friction_model_PARAMS.Dth = Dth;

tau_max_static_friction = piecewise((th_dot > -Sth_vel_threshold) & (th_dot < Sth_vel_threshold), Sth, 0);
tau_static_friction = min(tau_res, tau_max_static_friction);
tau_dynamic_friction = piecewise((th_dot > -Sth_vel_threshold) & (th_dot < Sth_vel_threshold), 0, Dth) * sign(th_dot);
tau_friction = tau_static_friction + tau_dynamic_friction;