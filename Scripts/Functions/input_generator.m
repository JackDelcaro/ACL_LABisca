function [time, complete_experiment] = input_generator(dt, zero_time, varargin)

is_cell_step = @(x) cellfun(@(y)(isstring(y)||ischar(y)) && contains(y, {'step', 'steps', 'Step', 'Steps'}),x,'UniformOutput',1);
is_cell_sine = @(x) cellfun(@(y)(isstring(y)||ischar(y)) && contains(y, {'sinusoid', 'sinusoids', 'Sinusoid', 'Sinusoids'}),x,'UniformOutput',1);
is_cell_sweep = @(x) cellfun(@(y)(isstring(y)||ischar(y)) && contains(y, {'sweep', 'Sweep'}),x,'UniformOutput',1);
is_cell_ramp = @(x) cellfun(@(y)(isstring(y)||ischar(y)) && contains(y, {'ramp', 'Ramp', 'ramps', 'Ramps'}),x,'UniformOutput',1);

complete_experiment = [];

while ~isempty(varargin)

    if is_cell_step(varargin(1))
        
        steps_amplitude = varargin{2};
        steps_duration = varargin{3};
        
        num_steps = length(steps_amplitude);
        step_length = ceil(steps_duration/dt);
        tot_steps_duration = num_steps*4*step_length;
        steps_vector = zeros(tot_steps_duration,1);
        for i = 1:num_steps
            steps_vector(((4*i-4)*step_length+1):((4*i-3)*step_length )) = steps_amplitude(i)*ones(step_length,1);
            steps_vector(((4*i-2)*step_length+1):((4*i-1)*step_length )) = -steps_amplitude(i)*ones(step_length,1);
        end
        experiment = [zeros(ceil(zero_time/dt),1); steps_vector];
        
        varargin(1:3) = [];
        
    elseif is_cell_sine(varargin(1))
        
        sinusoids_frequencies = varargin{2};
        
        sinusoids_omegas = sinusoids_frequencies*2*pi;
        sines_vector = [];
        for i = 1:length(sinusoids_omegas)
            tested_ome = sinusoids_omegas(i);
            time_sin = (0:dt:(2*pi/tested_ome)-dt)';
            sines_vector = [sines_vector; zeros(ceil(zero_time/dt),1); sin(tested_ome * time_sin)]; %#ok<AGROW>
        end
        experiment = sines_vector;
        
        varargin(1:2) = [];
        
    elseif is_cell_sweep(varargin(1))
        
        tmp = varargin{2};
        sweep_omega_start = tmp(1)*2*pi;
        sweep_omega_end = tmp(2)*2*pi;
        sweep_duration = tmp(3);
        sweep_type = varargin{3};
        
        sweep_t_vec = (0:dt:sweep_duration-dt)';
        if sweep_type == "linear"
            sweep_vector = sin(sweep_omega_start*sweep_t_vec + (sweep_omega_end - sweep_omega_start)/2/sweep_duration*sweep_t_vec.^2);
        else
            sweep_omega_start = max(sweep_omega_start, 0.00001);
            sweep_vector = sin(sweep_omega_start*sweep_duration/log(sweep_omega_end/sweep_omega_start)*(arrayfun(@(x)(sweep_omega_end/sweep_omega_start)^(x/sweep_duration), sweep_t_vec) - 1));
        end
        experiment = [zeros(ceil(zero_time/dt),1); sweep_vector];
        
        varargin(1:3) = [];
        
    elseif is_cell_ramp(varargin(1))
        
        ramps_amplitude = varargin{2};
        ramps_duration = varargin{3};
        ramps_backoff_duration = varargin{4};
        
        num_ramps = length(ramps_amplitude);
        ramp_length = ceil(ramps_duration/dt);
        backoff_length = ceil(ramps_backoff_duration/dt);
        ramp_tot_length = ramp_length*4+4*backoff_length;
        tot_ramps_duration = sum(ramp_tot_length);
        ramps_vector = zeros(tot_ramps_duration,1);
        start_ramp1_idx = 1;
        for i = 1:num_ramps
            end_ramp1_idx = start_ramp1_idx + ramp_length(i) - 1;
            ramps_vector(start_ramp1_idx:end_ramp1_idx) = ramps_amplitude(i)*linspace(0,1,ramp_length(i))'.*ones(ramp_length(i),1);
            start_ramp2_idx = end_ramp1_idx + backoff_length - 1;
            ramps_vector(end_ramp1_idx:start_ramp2_idx) = ramps_amplitude(i)*ones(backoff_length,1);
            end_ramp2_idx = start_ramp2_idx + ramp_length(i) - 1;
            ramps_vector(start_ramp2_idx:end_ramp2_idx) = ramps_amplitude(i)*(1 - linspace(0,1,ramp_length(i))'.*ones(ramp_length(i),1));
            start_ramp3_idx = end_ramp2_idx + backoff_length - 1;
            ramps_vector(end_ramp2_idx:start_ramp3_idx) = zeros(backoff_length,1);
            end_ramp3_idx = start_ramp3_idx + ramp_length(i) - 1;
            ramps_vector(start_ramp3_idx:end_ramp3_idx) = - ramps_amplitude(i)*linspace(0,1,ramp_length(i))'.*ones(ramp_length(i),1);
            start_ramp4_idx = end_ramp3_idx + backoff_length - 1;
            ramps_vector(end_ramp3_idx:start_ramp4_idx) = -ramps_amplitude(i)*ones(backoff_length,1);
            end_ramp4_idx = start_ramp4_idx + ramp_length(i) - 1;
            ramps_vector(start_ramp4_idx:end_ramp4_idx) = - ramps_amplitude(i)*(1 - linspace(0,1,ramp_length(i))'.*ones(ramp_length(i),1));
            end_idx = end_ramp4_idx + backoff_length - 1;
            ramps_vector(end_ramp4_idx:end_idx) = zeros(backoff_length,1);
            start_ramp1_idx = end_idx + 1;
        end
        experiment = [zeros(ceil(zero_time/dt),1); ramps_vector];
        
        varargin(1:4) = [];
    else
        experiment = [];
        varargin(1) = [];
        warning('WARNING: invalid input!');
    end
    
    complete_experiment = [complete_experiment; experiment]; %#ok<AGROW>
end

complete_experiment = [complete_experiment;
              zeros(ceil(zero_time/dt),1)];
time = 0:dt:(length(complete_experiment)-1)*dt;

end
