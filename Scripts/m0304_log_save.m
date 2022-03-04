
clc;
clearvars;
close all;

%% PATHS

paths.file_fullpath = matlab.desktop.editor.getActiveFilename;
[paths.file_path, ~, ~] = fileparts(paths.file_fullpath);

paths.mainfolder_path       = strsplit(paths.file_path, 'ACL_LABisca');
paths.mainfolder_path       = fullfile(string(paths.mainfolder_path(1)), 'ACL_LABisca');
paths.data_folder           = fullfile(string(paths.mainfolder_path), "Data");
paths.parsed_data_folder    = fullfile(string(paths.data_folder), "Parsed_Data");
paths.scripts_folder        = fullfile(string(paths.mainfolder_path), "Scripts");
addpath(genpath(paths.file_path     ));
addpath(genpath(paths.data_folder   ));
addpath(genpath(paths.scripts_folder));

%% Variable log

experiment_label = 'TEEEEST';
load_experiment_name = 'data_04-Mar-2022_12-52-36';

load([load_experiment_name, '.mat']);
eval("log_var = " + string(strrep(load_experiment_name, '-', '_')) + ";");

Log_data.voltage = log_var(1, :);
Log_data.theta = log_var(2, :) *0.176 /180 * pi;
Log_data.alpha = log_var(3, :) *0.176 /180 * pi;

savefile_label = [datestr(now, 'yyyymmdd_HHMM_'), experiment_label, '.mat'];
savefile_fullpath = fullfile(paths.parsed_data_folder, savefile_label);

save(savefile_fullpath, '-struct', 'Log_data');

