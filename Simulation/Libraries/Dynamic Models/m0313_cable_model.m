syms tau_cable real;
syms K th_0_cable real;

cable_model_PARAMS.K = K;
cable_model_PARAMS.th_0_cable = th_0_cable;

tau_cable = K * (th_0_cable - th);