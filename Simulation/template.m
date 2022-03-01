
clc;
clearvars;
close all;

%% PATHS

paths.file_fullpath = matlab.desktop.editor.getActiveFilename;
[paths.file_path, ~, ~] = fileparts(paths.file_fullpath);
addpath(genpath(paths.file_path));
paths.data_folder = fullfile(string(paths.file_path), "..", "Data");
addpath(genpath(paths.data_folder));
paths.scripts_folder = fullfile(string(paths.file_path), "..", "Scripts");
addpath(genpath(paths.scripts_folder));

%% SETTINGS

run('graphics_options.m');

%% INITIALIZATION

%% SIMULATION

%% RESULTS

%% SAVE RESULTS
