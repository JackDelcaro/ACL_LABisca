

T_sim = 180;
dt = 2e-3;

%% Sine sweep
tau_d = 2e-3;
k_t = 0.042;
R = 8.4;
conv = tau_d / k_t * R;

t_vec = 0:dt:T_sweep;
w_max = 1*2*pi;
w_vec = linspace(0,w_max,length(t_vec));
in_vec = sin(w_vec.*t_vec);
