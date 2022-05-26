
clc;
clearvars;
close all;

%% PATHS

paths.file_fullpath = matlab.desktop.editor.getActiveFilename;
[paths.file_path, ~, ~] = fileparts(paths.file_fullpath);
paths.mainfolder_path   = strsplit(paths.file_path, 'ACL_LABisca');
paths.mainfolder_path   = fullfile(string(paths.mainfolder_path(1)), 'ACL_LABisca');
paths.data_folder       = fullfile(string(paths.mainfolder_path), "Data");
paths.scripts_folder    = fullfile(string(paths.mainfolder_path), "Scripts");
paths.simulation_folder = fullfile(string(paths.mainfolder_path), "Simulation");
addpath(genpath(paths.file_path        ));
addpath(genpath(paths.data_folder      ));
addpath(genpath(paths.scripts_folder   ));
addpath(genpath(paths.simulation_folder));

%% SETTINGS

run('graphics_options.m');
run('m0524_Lyapunov_parsim_init.m');

%% PARPOOL SETUP
number_of_workers = 8;
p = gcp('nocreate'); % If no pool is active, do not create new one.
if isempty(p)
    previous_poolsize = 0;
else
    previous_poolsize = p.NumWorkers;
end
if previous_poolsize ~= number_of_workers
    myCluster = parcluster('local');
    delete(myCluster.Jobs);
    delete(p);
    p = parpool(number_of_workers);
end


%% PARLOOP

% k_th_vect = [1/125 1/25 1/5 1 5 25 125]*1.3057e-04*1.3;
% k_delta_vect = [1/125 1/25 1/5 1 5 25 125]*1.3057e-05*1.5;
% k_ome_vect = [0.8 1 1.5]*1.3057e-05;

k_th_vect = [1/5 1/2.5 1 2.5 5]*8.4870e-04;
k_delta_vect = [1/125 1/25 1/5 1 5 25 125]*1.3057e-05*1.5;
k_ome_vect = [0.7 0.8 0.9]*1.3057e-05;

iteration_number = length(k_th_vect)*length(k_delta_vect)*length(k_ome_vect);
% Initialize the array of simulations
in_sim(iteration_number) = Simulink.SimulationInput;
for idx_th = 1:length(k_th_vect)
    for idx_delta = 1:length(k_delta_vect)
        for idx_ome = 1:length(k_ome_vect)
            % Need to populate the model name since we get any empty array by default
%             fprintf("idx_ome: %d, idx_delta: %d, idx_th: %d, tot: %d\n", idx_ome, idx_delta, idx_th, idx_ome+(idx_delta-1)*length(k_ome_vect)+(idx_th-1)*length(k_delta_vect)*length(k_ome_vect));
            linear_index = idx_ome+(idx_delta-1)*length(k_ome_vect)+(idx_th-1)*length(k_delta_vect)*length(k_ome_vect);
            
            curr_params(linear_index).k_th = k_th_vect(idx_th); %#ok<SAGROW>
            curr_params(linear_index).k_delta = k_delta_vect(idx_delta); %#ok<SAGROW>
            curr_params(linear_index).k_ome = k_ome_vect(idx_ome); %#ok<SAGROW>
            
            in_sim(linear_index).ModelName = 's0509_Ly_bang';

            in_sim(linear_index) = in_sim(linear_index).setVariable('PARAMS.k_th', k_th_vect(idx_th));
            in_sim(linear_index) = in_sim(linear_index).setVariable('PARAMS.k_delta', k_delta_vect(idx_delta));
            in_sim(linear_index) = in_sim(linear_index).setVariable('PARAMS.k_ome', k_ome_vect(idx_ome));
        end
    end
end

tic;
parsim_out = parsim(in_sim, 'ShowProgress', 'on', ...
    'SetupFcn', @() lyapunov_setup_fcn(fullfile(paths.scripts_folder, "m0524_Lyapunov_parsim_init.m")));
elapsed_time = toc;

save('Lyapunov_parsim_2.mat','in_sim','parsim_out','elapsed_time','k_th_vect','k_delta_vect','k_ome_vect','curr_params');

%% RESTART

clc;
clearvars;
close all;

%% PATHS

paths.file_fullpath = matlab.desktop.editor.getActiveFilename;
[paths.file_path, ~, ~] = fileparts(paths.file_fullpath);
paths.mainfolder_path   = strsplit(paths.file_path, 'ACL_LABisca');
paths.mainfolder_path   = fullfile(string(paths.mainfolder_path(1)), 'ACL_LABisca');
paths.data_folder       = fullfile(string(paths.mainfolder_path), "Data");
paths.scripts_folder    = fullfile(string(paths.mainfolder_path), "Scripts");
paths.simulation_folder = fullfile(string(paths.mainfolder_path), "Simulation");
addpath(genpath(paths.file_path        ));
addpath(genpath(paths.data_folder      ));
addpath(genpath(paths.scripts_folder   ));
addpath(genpath(paths.simulation_folder));

%% SETTINGS

run('graphics_options.m');
run('m0524_Lyapunov_parsim_init.m');

%% PARPOOL SETUP
number_of_workers = 8;
p = gcp('nocreate'); % If no pool is active, do not create new one.
if isempty(p)
    previous_poolsize = 0;
else
    previous_poolsize = p.NumWorkers;
end
if previous_poolsize ~= number_of_workers
    myCluster = parcluster('local');
    delete(myCluster.Jobs);
    delete(p);
    p = parpool(number_of_workers);
end

%% PARLOOP

k_th_vect = [1/125 1/25 1/5 1 5 25 125]*1.3057e-04*1.3;
k_delta_vect = [1/5 1/2.5 1 2.5 5]*9.7927e-05;
k_ome_vect = [0.7 0.8 0.9]*1.3057e-05;

iteration_number = length(k_th_vect)*length(k_delta_vect)*length(k_ome_vect);
% Initialize the array of simulations
in_sim(iteration_number) = Simulink.SimulationInput;
for idx_th = 1:length(k_th_vect)
    for idx_delta = 1:length(k_delta_vect)
        for idx_ome = 1:length(k_ome_vect)
            % Need to populate the model name since we get any empty array by default
%             fprintf("idx_ome: %d, idx_delta: %d, idx_th: %d, tot: %d\n", idx_ome, idx_delta, idx_th, idx_ome+(idx_delta-1)*length(k_ome_vect)+(idx_th-1)*length(k_delta_vect)*length(k_ome_vect));
            linear_index = idx_ome+(idx_delta-1)*length(k_ome_vect)+(idx_th-1)*length(k_delta_vect)*length(k_ome_vect);
            
            curr_params(linear_index).k_th = k_th_vect(idx_th); %#ok<SAGROW>
            curr_params(linear_index).k_delta = k_delta_vect(idx_delta); %#ok<SAGROW>
            curr_params(linear_index).k_ome = k_ome_vect(idx_ome); %#ok<SAGROW>
            
            in_sim(linear_index).ModelName = 's0509_Ly_bang';

            in_sim(linear_index) = in_sim(linear_index).setVariable('PARAMS.k_th', k_th_vect(idx_th));
            in_sim(linear_index) = in_sim(linear_index).setVariable('PARAMS.k_delta', k_delta_vect(idx_delta));
            in_sim(linear_index) = in_sim(linear_index).setVariable('PARAMS.k_ome', k_ome_vect(idx_ome));
        end
    end
end

tic;
parsim_out = parsim(in_sim, 'ShowProgress', 'on', ...
    'SetupFcn', @() lyapunov_setup_fcn(fullfile(paths.scripts_folder, "m0524_Lyapunov_parsim_init.m")));
elapsed_time = toc;

save('Lyapunov_parsim_3.mat','in_sim','parsim_out','elapsed_time','k_th_vect','k_delta_vect','k_ome_vect','curr_params');


%% FUNCTIONS
function lyapunov_setup_fcn(filename)

    evalin('base', "run('" + filename + "');");

end
