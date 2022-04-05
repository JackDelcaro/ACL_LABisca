
%% PATHS

paths.file_fullpath = matlab.desktop.editor.getActiveFilename;
[paths.file_path, ~, ~] = fileparts(paths.file_fullpath);

paths.mainfolder_path       = strsplit(paths.file_path, 'ACL_LABisca');
paths.mainfolder_path       = fullfile(string(paths.mainfolder_path(1)), 'ACL_LABisca');
paths.data_folder           = fullfile(string(paths.mainfolder_path), "Data");
paths.raw_data_folder       = fullfile(string(paths.data_folder), "Raw_Data");
paths.parsed_data_folder    = fullfile(string(paths.data_folder), "Parsed_Data");
paths.scripts_folder        = fullfile(string(paths.mainfolder_path), "Scripts");
paths.sim_folder            = fullfile(string(paths.mainfolder_path), "Simulation");
paths.sim_log_folder        = fullfile(string(paths.sim_folder), "Log");
paths.sim_data_folder       = fullfile(string(paths.sim_folder), "Data");
addpath(genpath(paths.file_path     ));
addpath(genpath(paths.data_folder   ));
addpath(genpath(paths.scripts_folder));
addpath(genpath(paths.sim_folder    ));

%% SIMULATION PARAMETERS

dt = 2e-4;
run('m0405_params.m');
dt_control = 2e-3;
PARAMS.al_0 = dataset.alpha(1);
PARAMS.th_0 = dataset.theta(1);

%% DERIVATIVES OF REAL DATA

dt_dataset = mean(diff(dataset.time));
omega_cut = 100*2*pi;
s = tf('s');
filter = 1/(1+s/omega_cut);
[num,den] = tfdata(c2d(filter, dt_dataset), 'v');

dataset.theta_filtered = filtfilt(num, den, dataset.theta);
dataset.alpha_filtered = filtfilt(num, den, dataset.alpha);

dataset.theta_dot = gradient(dataset.theta_filtered, dataset.time);
dataset.alpha_dot = gradient(dataset.alpha_filtered, dataset.time);


simin.voltage = [dataset.time, dataset.voltage];
simin.theta = [dataset.time, dataset.theta];
simin.theta_dot = [dataset.time, dataset.theta_dot];

T_sim = simin.voltage(end, 1);

%% DERIVATIVE FILTER

s = tf('s');
freq_der_filter = 15;
der_filt = s/(s/(2*pi*freq_der_filter)+1);
[num_der_filter, den_der_filter] = tfdata(c2d(der_filt, dt_control), 'v');

%% FILTER

freq_filter = 15;
filt = 1/(s/(2*pi*freq_filter)+1);
[num_filter, den_filter] = tfdata(c2d(filt, dt_control), 'v');

%% REF FILTER

freq_ref_filter = 3;
ref_filt = 1/(s/(2*pi*freq_ref_filter)+1);
[num_ref_filter, den_ref_filter] = tfdata(c2d(ref_filt, dt_control), 'v');
