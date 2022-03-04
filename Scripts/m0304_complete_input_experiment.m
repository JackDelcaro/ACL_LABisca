%% Complete Experiment

dt = 2e-3;
T_sweep = 60;

t2_vec = (0:dt:T_sweep)';
w_max = 2*pi;
w_vec = linspace(0,w_max,length(t2_vec))';
in2_vec = sin(w_vec.*t2_vec);

step_vec = [zeros(2000,1); ones(2000,1); zeros(2000,1); -ones(2000,1)];
in1_vec = [step_vec*0.05; step_vec*0.2; step_vec*0.6; step_vec*0.8; step_vec; zeros(2000,1)];
t1_vec = (0:dt:(dt*(length(in1_vec)-1)))';

t2_vec = t2_vec + t1_vec(end) + dt;

omega = [0.05; 0.2; 0.5; 0.8; 1.2; 1.5; 1.9; 2.3; 2.6; 3; 3.5; 4; 6; 10; 20]*2*pi;
sin_vec = [];
for i = 1:length(omega)
    tested_ome = omega(i);
    time_sin = (0:dt:(2*pi/tested_ome))';
    sin_vec = [sin_vec; zeros(2000,1); sin(tested_ome * time_sin)];
end
sin_vec = [sin_vec; zeros(2000,1)];
time_sin_vec = (0:dt:(dt*(length(sin_vec)-1)))' + dt + t2_vec(end);

t_tot = [t1_vec; t2_vec; time_sin_vec];
in_tot = [in1_vec; in2_vec; sin_vec];

plot(t_tot, in_tot);

simul.input = [t_tot, in_tot];
T_sim = t_tot(end);

