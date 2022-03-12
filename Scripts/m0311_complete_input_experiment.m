
dt = 2e-3;
standby_duration = 3; % [s]
% Steps Parameters
steps_amplitude = [0.1 0.2 0.5 0.8 1];
steps_duration = 4; % [s]
% Ramps Parameters
ramps_amplitude = [0.1 0.2 0.5 0.8 1];
ramps_duration = [2 2 2 5 5]; % [s]
ramps_backoff_duration = 1;
% Sine Sweep Parameters
sweep_params = [0.05 10 30]; % [ initial_frequency [Hz], final_frequency [Hz], duration [s] ]
% sine sweep can be 'linear' or 'exponential'
% Sinusoids Parameters
sinusoid_freq = [0.1 0.4 1 5 8]; % frequencies in [Hz]

[time,experiment] = create_input_experiment(dt, standby_duration,...
                    'steps', steps_amplitude, steps_duration, ...
                    'ramps', ramps_amplitude, ramps_duration, ramps_backoff_duration, ...
                    'sweep', sweep_params, 'exponential', ...
                    'sinusoids', sinusoid_freq);
                
plot(time,experiment); grid on;