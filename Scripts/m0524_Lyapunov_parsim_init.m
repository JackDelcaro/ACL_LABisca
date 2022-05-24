
try
    paths.file_fullpath = matlab.desktop.editor.getActiveFilename;
catch
    paths.file_fullpath = pwd;
end
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

%% INITIALIZATION

dt = 2e-4;
dt_control = 2e-3;
run('m0405_params.m');

PARAMS.k_th = 1.3057e-04*1.3;
PARAMS.k_delta = 1.3057e-05*1.5;
PARAMS.k_ome = 1.3057e-05;

T_sim = 30;

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
