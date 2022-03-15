
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
paths.sim_folder            = fullfile(string(paths.mainfolder_path), "Simulation");
paths.sim_utils_folder      = fullfile(string(paths.sim_folder), "Utils");
addpath(genpath(paths.file_path       ));
addpath(genpath(paths.data_folder     ));
addpath(genpath(paths.scripts_folder  ));
addpath(genpath(paths.sim_utils_folder));

run('graphics_options.m');

%% Variable log

cd(paths.raw_data_folder);
[filename, path] = uigetfile('MultiSelect', 'on');
cd(paths.mainfolder_path);
filename = string(filename)';

for i = 1:length(filename)
    
    fprintf(1, "File Selected: %s\n", filename(i));
    
    experiment_label = input('Insert the new name for the parsed data: ', 's');
    if isempty(experiment_label)
        experiment_label = 'test';
    end
    experiment_label = strrep(experiment_label, ' ', '_');
    
    time_selection = input('Would you like to select a time interval [Y/N]: ', 's');
    if any(time_selection == ["Y", "Yes", "y", "YES", "yes"])
        enable_time_selection = true;
    else
        enable_time_selection = false;
        inf_time_th = 0;
        sup_time_th = inf;
    end

    load(fullfile(path, filename(i)));
    
    eval("log_var = " + string(strrep(strrep(filename(i), '.mat', ''), '-', '_')) + ";");
    
    Log_data.time    = log_var(1, :)';
    Log_data.theta   = log_var(2, :)' *0.176 /180 * pi;
    Log_data.alpha   = log_var(3, :)' *0.176 /180 * pi;
    Log_data.voltage = log_var(4, :)';
    if size(log_var, 1) >= 5
        Log_data.theta_ref = log_var(5, :)';
    end
    if size(log_var, 1) >= 6
        Log_data.alpha_ref = log_var(6, :)';
    end
    
    if enable_time_selection
        figure;
        sgtitle("Experiment: " + string(strrep(strrep(filename(i), ".mat", ""), "_", "\_")));

        sub(1) = subplot(3,1,1);
        plot(Log_data.time, Log_data.voltage); hold on; grid on;
        ylabel('$Voltage\;[V]$');

        sub(2) = subplot(3,1,2);
        plot(Log_data.time, Log_data.theta*180/pi); hold on; grid on;
        ylabel('$\theta\;[deg]$');

        sub(3) = subplot(3,1,3);
        plot(Log_data.time, Log_data.alpha*180/pi); hold on; grid on;
        ylabel('$\alpha\;[deg]$');
        xlabel('$time\;[s]$');

        linkaxes(sub, 'x');
        
        inf_time_th = input('Start time: ');
        inf_time_th = max([0, inf_time_th]);
        sup_time_th = input('End time: ');
        sup_time_th = min([Log_data.time(end), sup_time_th]);
    end
    
    % Time interval selection
    Log_data.voltage = Log_data.voltage(Log_data.time >= inf_time_th & Log_data.time <= sup_time_th);
    Log_data.theta   = Log_data.theta(Log_data.time >= inf_time_th & Log_data.time <= sup_time_th);
    Log_data.alpha   = Log_data.alpha(Log_data.time >= inf_time_th & Log_data.time <= sup_time_th);
    if size(log_var, 1) >= 5
        Log_data.theta_ref   = Log_data.theta_ref(Log_data.time >= inf_time_th & Log_data.time <= sup_time_th);
    end
    if size(log_var, 1) >= 6
        Log_data.alpha_ref   = Log_data.alpha_ref(Log_data.time >= inf_time_th & Log_data.time <= sup_time_th);
    end
    Log_data.time    = Log_data.time(Log_data.time >= inf_time_th & Log_data.time <= sup_time_th);
    Log_data.time    = Log_data.time - Log_data.time(1);
    
    savefile_date = get_savefile_date(filename(i));
    savefile_label = savefile_date + string(experiment_label) + ".mat";
    savefile_fullpath = fullfile(paths.parsed_data_folder, savefile_label);

    save(savefile_fullpath, '-struct', 'Log_data');
    
    fprintf(1, "\n");
end

