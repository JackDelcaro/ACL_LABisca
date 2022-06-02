
clc;
clearvars;
% close all;

%% PATHS

paths.file_fullpath = matlab.desktop.editor.getActiveFilename;
[paths.file_path, ~, ~]  = fileparts(paths.file_fullpath);
paths.mainfolder_path    = strsplit(paths.file_path, 'ACL_LABisca');
paths.mainfolder_path    = fullfile(string(paths.mainfolder_path(1)), 'ACL_LABisca');
paths.data_folder        = fullfile(string(paths.mainfolder_path), "Data");
paths.parsed_data_folder = fullfile(string(paths.data_folder), "Parsed_Data");
paths.resim_parsed_data_folder = fullfile(string(paths.data_folder), "Resim_Parsed_Data");
paths.scripts_folder     = fullfile(string(paths.mainfolder_path), "Scripts");
paths.simulation_folder  = fullfile(string(paths.mainfolder_path), "Simulation");
addpath(genpath(paths.file_path        ));
addpath(genpath(paths.data_folder      ));
addpath(genpath(paths.scripts_folder   ));
addpath(genpath(paths.simulation_folder));

%% SETTINGS

run('graphics_options.m');

%% DATASET SELECTION

[filename, path] = uigetfile(paths.resim_parsed_data_folder, 'MultiSelect', 'on');
filename = string(filename)';

for filename_idx = 1:length(filename)
    if contains(filename(filename_idx), "complete")
        complete_dataset = load(filename(filename_idx));

        if contains(filename(filename_idx), "down")
            points_input = 154858;
        elseif contains(filename(filename_idx), "up")
            points_input = 129000;
        else
            error('Filename: -%s- does not contain up/down label', filename(filename_idx));
        end
        
        fieldnames = string(fields(complete_dataset));
        for i = 1:length(fieldnames)
            tmp = complete_dataset.(fieldnames(i));
            dynamic_dataset{filename_idx}.(fieldnames(i)) = tmp(1:points_input); %#ok<SAGROW>
            static_dataset{filename_idx}.(fieldnames(i)) = tmp(points_input+1:end); %#ok<SAGROW>
        end
        clearvars complete_dataset tmp;
        
    elseif contains(filename(filename_idx), "static")
        static_dataset{filename_idx} = load(filename(filename_idx));
        tmp = dir(paths.resim_parsed_data_folder);
        folder_filenames = string({tmp.name})';
        tmp = char(strrep(filename(filename_idx), "static", "dynamic"));
        dynamic_dataset_name = folder_filenames(contains(folder_filenames, tmp(15:end)));
        dynamic_dataset{filename_idx} = load(dynamic_dataset_name);
    elseif contains(filename(filename_idx), "dynamic")
        dynamic_dataset{filename_idx} = load(filename(filename_idx));
        tmp = dir(paths.resim_parsed_data_folder);
        folder_filenames = string({tmp.name})';
        tmp = char(strrep(filename(filename_idx), "dynamic", "static"));
        static_dataset_name = folder_filenames(contains(folder_filenames, tmp(15:end)));
        static_dataset{filename_idx} = load(static_dataset_name);
    else
        error('Filename: -%s- does not contain complete/static/dynamic label', filename(filename_idx));
    end
end


%% PLOTS

reference_color = colors.grey(2);
data_color = colors.orange_red(1);
simulation_color = colors.yellow(1);

for filename_idx = 1:length(filename)
    figure;
    sgtitle("Experiment: " + string(strrep(strrep(filename(filename_idx), ".mat", ""), "_", "\_")));

    sub(1) = subplot(3,2,1); hold on;
    title('Sine Sweep');
    if any(fields(dynamic_dataset{filename_idx}) == "theta_ref")
        plot(dynamic_dataset{filename_idx}.time, dynamic_dataset{filename_idx}.theta_ref*180/pi, 'color', reference_color, 'DisplayName', 'Reference'); grid on;
    end
    plot(dynamic_dataset{filename_idx}.time, dynamic_dataset{filename_idx}.theta*180/pi, 'color', data_color, 'DisplayName', 'Real Data');
    plot(dynamic_dataset{filename_idx}.time, dynamic_dataset{filename_idx}.theta_sim*180/pi, '--', 'color', simulation_color, 'DisplayName', 'Simulation', 'LineWidth', 1.5);
    ylabel('$\theta\;[deg]$');

    sub(2) = subplot(3,2,3);
    if any(fields(dynamic_dataset{filename_idx}) == "alpha_ref")
        plot(dynamic_dataset{filename_idx}.time, dynamic_dataset{filename_idx}.alpha_ref*180/pi, 'color', reference_color, 'DisplayName', 'Reference'); hold on; grid on;
    end
    plot(dynamic_dataset{filename_idx}.time, dynamic_dataset{filename_idx}.alpha*180/pi, 'color', data_color, 'DisplayName', 'Real Data');
    plot(dynamic_dataset{filename_idx}.time, dynamic_dataset{filename_idx}.alpha_sim*180/pi, '--', 'color', simulation_color, 'DisplayName', 'Simulation', 'LineWidth', 1.5);
    ylabel('$\alpha\;[deg]$');

    sub(3) = subplot(3,2,5);
    plot(dynamic_dataset{filename_idx}.time, dynamic_dataset{filename_idx}.voltage, 'color', data_color, 'DisplayName', 'Voltage'); hold on; grid on;
    ylabel('$Voltage\;[V]$');
    xlabel('$time\;[s]$');

    linkaxes(sub, 'x');
    clearvars sub;
    
    sub(1) = subplot(3,2,2); hold on;
    title('Steps');
    if any(fields(dynamic_dataset{filename_idx}) == "theta_ref")
        plot(static_dataset{filename_idx}.time, static_dataset{filename_idx}.theta_ref*180/pi, 'color', reference_color, 'DisplayName', 'Reference'); grid on;
    end
    plot(static_dataset{filename_idx}.time, static_dataset{filename_idx}.theta*180/pi, 'color', data_color, 'DisplayName', 'Real Data');
    plot(static_dataset{filename_idx}.time, static_dataset{filename_idx}.theta_sim*180/pi, '--', 'color', simulation_color, 'DisplayName', 'Simulation', 'LineWidth', 1.5);
    ylabel('$\theta\;[deg]$');
    legend('Position',[0.856442789599488,0.819417203330112,0.091662336339736,0.10204690470116]);

    sub(2) = subplot(3,2,4);
    if any(fields(static_dataset{filename_idx}) == "alpha_ref")
        plot(static_dataset{filename_idx}.time, static_dataset{filename_idx}.alpha_ref*180/pi, 'color', reference_color, 'DisplayName', 'Reference'); hold on; grid on;
    end
    plot(static_dataset{filename_idx}.time, static_dataset{filename_idx}.alpha*180/pi, 'color', data_color, 'DisplayName', 'Real Data');
    plot(static_dataset{filename_idx}.time, static_dataset{filename_idx}.alpha_sim*180/pi, '--', 'color', simulation_color, 'DisplayName', 'Simulation', 'LineWidth', 1.5);
    ylabel('$\alpha\;[deg]$');

    sub(3) = subplot(3,2,6);
    plot(static_dataset{filename_idx}.time, static_dataset{filename_idx}.voltage, 'color', data_color, 'DisplayName', 'Voltage'); hold on; grid on;
    ylabel('$Voltage\;[V]$');
    xlabel('$time\;[s]$');

    linkaxes(sub, 'x');
    clearvars sub;
end