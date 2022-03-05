
clc;
clearvars;
close all;

%% PATHS

paths.file_fullpath = matlab.desktop.editor.getActiveFilename;
[paths.file_path, ~, ~] = fileparts(paths.file_fullpath);

paths.mainfolder_path       = strsplit(paths.file_path, 'ACL_LABisca');
paths.mainfolder_path       = fullfile(string(paths.mainfolder_path(1)), 'ACL_LABisca');
paths.data_folder           = fullfile(string(paths.mainfolder_path), "Data");
paths.raw_data_folder       = fullfile(string(paths.data_folder), "Raw_Data");
paths.parsed_data_folder    = fullfile(string(paths.data_folder), "Parsed_Data");
paths.scripts_folder        = fullfile(string(paths.mainfolder_path), "Scripts");
addpath(genpath(paths.file_path     ));
addpath(genpath(paths.data_folder   ));
addpath(genpath(paths.scripts_folder));

%% Variable log

cd(paths.raw_data_folder);
[filename, path] = uigetfile('MultiSelect', 'on');
cd(paths.file_path);
filename = string(filename)';

for i = 1:length(filename)
    
    fprintf(1, "File Selected: %s\n", filename(i));
    
    experiment_label = input('Insert the new name for the parsed data: ', 's');
    if isempty(experiment_label)
        experiment_label = 'test';
    end
    experiment_label = strrep(experiment_label, ' ', '_');

    load(fullfile(path, filename(i)));
    
    eval("log_var = " + string(strrep(strrep(filename(i), '.mat', ''), '-', '_')) + ";");

    Log_data.voltage = log_var(1, :);
    Log_data.theta = log_var(2, :) *0.176 /180 * pi;
    Log_data.alpha = log_var(3, :) *0.176 /180 * pi;
    
    savefile_date = get_savefile_date(filename(i));
    savefile_label = savefile_date + string(experiment_label) + ".mat";
    savefile_fullpath = fullfile(paths.parsed_data_folder, savefile_label);

    save(savefile_fullpath, '-struct', 'Log_data');
    
    fprintf(1, "\n");
end

