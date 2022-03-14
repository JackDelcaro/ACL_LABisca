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

%% INITIALIZATION

model_name = 's0310_main';
load_system([model_name '.slx']);

params_script_name = 'm0303_params';
run([params_script_name '.m']);

simulator_name = 's0312_simulator';
motor_simulator_name = 's0303_motor_simulator';
controller_name = 's0307_theta_controller_PID';
set_param([model_name '/Simulator Subsystem'], 'ReferencedSubsystem', simulator_name);
set_param([model_name '/Motor Simulator Subsystem'], 'ReferencedSubsystem', motor_simulator_name);
set_param([model_name '/Controller Subsystem'], 'ReferencedSubsystem', controller_name);

using_dynamically_generated_model = true;

if using_dynamically_generated_model

    dyn_model_name = 'm0312_dyn_model';
    cable_model_name = 'm0313_cable_model';
    friction_model_name = 'm0313_friction_model';
    run('m0312_gen_dyn_model.m');

end



save_system(simulator_name);
save_system(motor_simulator_name);
save_system(controller_name);
save_system(model_name);

close_system(model_name);


T_sim = 20;
dt = 1e-4;
dt_control = 2e-2;

sim(model_name);