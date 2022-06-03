
clc;
clearvars;
close all;

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
paths.media_folder       = fullfile(string(paths.mainfolder_path), "Multimedia");
paths.report_images_folder = fullfile(string(paths.media_folder), "Report_Images");
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

reference_color = "#767676";
data_color = colors.blue(4);
simulation_color = colors.blue(1);

large_plot_handle = @(figure_handle, filename_index) large_plot(figure_handle, filename_index, filename, dynamic_dataset, static_dataset, reference_color, data_color, simulation_color);
zoomed_plot_handle = @(subplot_handles, title, dataset, start_time, end_time) zoomed_plot(subplot_handles, title, dataset, start_time, end_time, reference_color, data_color, simulation_color);

for filename_idx = 1:length(filename)
    fprintf('Filename: %s\n', filename(filename_idx));
    save_figures = input('Would you like to save the figures [Y/N]: ', 's');
    title_label = string(strrep(strrep(strrep(strrep(filename(filename_idx), ".mat", ""), "static", "complete"), "dynamic", "complete"), "_RESIM", ""));
    
    % FIGURE 1
    f(1) = figure;
    large_plot_handle(f(1), filename_idx);
    
    % FIGURE 2
    f(2) = figure;
    sgtitle("Experiment: " + strrep(title_label, "_", "\_") + "\_zoomed");
    for i = 1:9
        sub(i) = subplot(3,3,i); %#ok<SAGROW>
    end
    % zoomed_plot_handle(subplot_handles, title, dataset, start_time, end_time)
    zoomed_plot_handle([sub(1), sub(4), sub(7)], "Start Sinesweep", dynamic_dataset{filename_idx}, 5, 45);
    zoomed_plot_handle([sub(2), sub(5), sub(8)], "End Sinesweep", dynamic_dataset{filename_idx}, 298, 304);
    zoomed_plot_handle([sub(3), sub(6), sub(9)], "Single Step", static_dataset{filename_idx}, 44, 49);
    subplot(sub(3));
    legend('Position',[0.80906589365385,0.686662468927643,0.091662336339736,0.10204690470116]);
    clearvars sub;
    
    % FIGURE 3
    f(3) = figure;
    sgtitle("Experiment: " + strrep(title_label, "_", "\_") + "\_zoomed");
    for i = 1:3
        sub(i) = subplot(3,1,i);
    end
    % zoomed_plot_handle(subplot_handles, title, dataset, start_time, end_time)
    zoomed_plot_handle([sub(1), sub(2), sub(3)], "Start Sinesweep", dynamic_dataset{filename_idx}, 3, inf);
    subplot(sub(1));
    legend('Position',[0.843716678710699,0.835916200270927,0.091662336339736,0.10204690470116]);
    clearvars sub;
    
    % FIGURE 4
    f(4) = figure;
    sgtitle("Experiment: " + strrep(title_label, "_", "\_") + "\_zoomed");
    for i = 1:3
        sub(i) = subplot(3,1,i);
    end
    % zoomed_plot_handle(subplot_handles, title, dataset, start_time, end_time)
    zoomed_plot_handle([sub(1), sub(2), sub(3)], "Start Sinesweep", static_dataset{filename_idx}, 3, inf);
    subplot(sub(1));
    legend('Position',[0.843716678710699,0.835916200270927,0.091662336339736,0.10204690470116]);
    
    if any(save_figures == ["Y", "Yes", "y", "YES", "yes"])
        saveas(f(1), fullfile(paths.report_images_folder, title_label + ".png"));
        saveas(f(2), fullfile(paths.report_images_folder, title_label + "_zoomed.png"));
        saveas(f(3), fullfile(paths.report_images_folder, title_label + "_only_sinesweep.png"));
        saveas(f(4), fullfile(paths.report_images_folder, title_label + "_only_steps.png"));
    end
    
end

%% FUNCTIONS

function large_plot(figure_handle, filename_idx, filename, dynamic_dataset, static_dataset, reference_color, data_color, simulation_color)

    figure(figure_handle);
    title_label = string(strrep(strrep(strrep(strrep(filename(filename_idx), ".mat", ""), "static", "complete"), "dynamic", "complete"), "_RESIM", ""));
    sgtitle("Experiment: " + strrep(title_label, "_", "\_"));
    
    sub(1) = subplot(3,2,1); hold on;
    title('Sine Sweep');
    if any(fields(dynamic_dataset{filename_idx}) == "theta_ref")
        plot(dynamic_dataset{filename_idx}.time, dynamic_dataset{filename_idx}.theta_ref*180/pi, 'color', reference_color, 'DisplayName', 'Reference'); grid on;
    end
    plot(dynamic_dataset{filename_idx}.time, dynamic_dataset{filename_idx}.theta*180/pi, 'color', data_color, 'DisplayName', 'Real Data');
    plot(dynamic_dataset{filename_idx}.time, dynamic_dataset{filename_idx}.theta_sim*180/pi, '--', 'color', simulation_color, 'DisplayName', 'Simulation', 'LineWidth', 1.5);
    ylabel('$\theta\;[deg]$');
    set(gca,'Xticklabel',[]);

    sub(2) = subplot(3,2,3);
    if any(fields(dynamic_dataset{filename_idx}) == "alpha_ref")
        plot(dynamic_dataset{filename_idx}.time, dynamic_dataset{filename_idx}.alpha_ref*180/pi, 'color', reference_color, 'DisplayName', 'Reference'); hold on; grid on;
    end
    plot(dynamic_dataset{filename_idx}.time, dynamic_dataset{filename_idx}.alpha*180/pi, 'color', data_color, 'DisplayName', 'Real Data');
    plot(dynamic_dataset{filename_idx}.time, dynamic_dataset{filename_idx}.alpha_sim*180/pi, '--', 'color', simulation_color, 'DisplayName', 'Simulation', 'LineWidth', 1.5);
    ylabel('$\alpha\;[deg]$');
    set(gca,'Xticklabel',[]);
    
    sub(3) = subplot(3,2,5);
    plot(dynamic_dataset{filename_idx}.time, dynamic_dataset{filename_idx}.voltage, 'color', data_color, 'DisplayName', 'Voltage'); hold on; grid on;
    ylabel('$Voltage\;[V]$');
    xlabel('$time\;[s]$');
    linkaxes(sub, 'x');
    xlim([dynamic_dataset{filename_idx}.time(1), dynamic_dataset{filename_idx}.time(end)]);
    
    sub(4) = subplot(3,2,2); hold on;
    title('Steps');
    if any(fields(dynamic_dataset{filename_idx}) == "theta_ref")
        plot(static_dataset{filename_idx}.time, static_dataset{filename_idx}.theta_ref*180/pi, 'color', reference_color, 'DisplayName', 'Reference'); grid on;
    end
    plot(static_dataset{filename_idx}.time, static_dataset{filename_idx}.theta*180/pi, 'color', data_color, 'DisplayName', 'Real Data');
    plot(static_dataset{filename_idx}.time, static_dataset{filename_idx}.theta_sim*180/pi, '--', 'color', simulation_color, 'DisplayName', 'Simulation', 'LineWidth', 1.5);
    ylabel('$\theta\;[deg]$');
    legend('Position',[0.856442789599488,0.819417203330112,0.091662336339736,0.10204690470116]);
    set(gca,'Xticklabel',[]);

    sub(5) = subplot(3,2,4);
    if any(fields(static_dataset{filename_idx}) == "alpha_ref")
        plot(static_dataset{filename_idx}.time, static_dataset{filename_idx}.alpha_ref*180/pi, 'color', reference_color, 'DisplayName', 'Reference'); hold on; grid on;
    end
    plot(static_dataset{filename_idx}.time, static_dataset{filename_idx}.alpha*180/pi, 'color', data_color, 'DisplayName', 'Real Data');
    plot(static_dataset{filename_idx}.time, static_dataset{filename_idx}.alpha_sim*180/pi, '--', 'color', simulation_color, 'DisplayName', 'Simulation', 'LineWidth', 1.5);
    ylabel('$\alpha\;[deg]$');
    set(gca,'Xticklabel',[]);

    sub(6) = subplot(3,2,6);
    plot(static_dataset{filename_idx}.time, static_dataset{filename_idx}.voltage, 'color', data_color, 'DisplayName', 'Voltage'); hold on; grid on;
    ylabel('$Voltage\;[V]$');
    xlabel('$time\;[s]$');

    linkaxes(sub(4:6), 'x');
    xlim([static_dataset{filename_idx}.time(1), static_dataset{filename_idx}.time(end)]);
    drawnow;
    
    tmp = get(sub(1), 'Position');
    left_pos = tmp(1);
    top_pos = tmp(2);
    width = tmp(3);
    height = tmp(4);
    spacing = 0.025;
    set(sub(2), 'Position', [left_pos, top_pos-height-spacing, width, height]);
    set(sub(3), 'Position', [left_pos, top_pos-2*height-2*spacing, width, height]);
    tmp = get(sub(4), 'Position');
    left_pos = tmp(1);
    top_pos = tmp(2);
    width = tmp(3);
    height = tmp(4);
    set(sub(5), 'Position', [left_pos, top_pos-height-spacing, width, height]);
    set(sub(6), 'Position', [left_pos, top_pos-2*height-2*spacing, width, height]);
    
end

function zoomed_plot(subplot_handles, title_label, dataset, start_time, end_time, reference_color, data_color, simulation_color)
    
    range = dataset.time >= start_time & dataset.time <= end_time;
   
    subplot(subplot_handles(1)); hold on;
    title(title_label);
    
    if any(fields(dataset) == "theta_ref")
        plot(dataset.time(range), dataset.theta_ref(range)*180/pi, 'color', reference_color, 'DisplayName', 'Reference'); grid on;
    end
    plot(dataset.time(range), dataset.theta(range)*180/pi, 'color', data_color, 'DisplayName', 'Real Data');
    plot(dataset.time(range), dataset.theta_sim(range)*180/pi, '--', 'color', simulation_color, 'DisplayName', 'Simulation', 'LineWidth', 1.5);
    ylabel('$\theta\;[deg]$');
    set(gca,'Xticklabel',[]);

    subplot(subplot_handles(2));
    if any(fields(dataset) == "alpha_ref")
        plot(dataset.time(range), dataset.alpha_ref(range)*180/pi, 'color', reference_color, 'DisplayName', 'Reference'); hold on; grid on;
    end
    plot(dataset.time(range), dataset.alpha(range)*180/pi, 'color', data_color, 'DisplayName', 'Real Data');
    plot(dataset.time(range), dataset.alpha_sim(range)*180/pi, '--', 'color', simulation_color, 'DisplayName', 'Simulation', 'LineWidth', 1.5);
    ylabel('$\alpha\;[deg]$');
    set(gca,'Xticklabel',[]);

    subplot(subplot_handles(3));
    plot(dataset.time(range), dataset.voltage(range), 'color', data_color, 'DisplayName', 'Voltage'); hold on; grid on;
    ylabel('$Voltage\;[V]$');
    xlabel('$time\;[s]$');
    
    linkaxes(subplot_handles, 'x');
    xlim([start_time, end_time]);
    drawnow;
    
    tmp = get(subplot_handles(1), 'Position');
    left_pos = tmp(1);
    top_pos = tmp(2);
    width = tmp(3);
    height = tmp(4);
    spacing = 0.025;
    set(subplot_handles(2), 'Position', [left_pos, top_pos-height-spacing, width, height]);
    set(subplot_handles(3), 'Position', [left_pos, top_pos-2*height-2*spacing, width, height]);
    
end