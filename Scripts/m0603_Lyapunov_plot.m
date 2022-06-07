
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

[filename, path] = uigetfile(fullfile(paths.resim_parsed_data_folder, "*Lyapunov_pt*"), 'MultiSelect', 'on');
filename = string(filename)';

%% PLOTS

reference_color = "#767676";
data_color = colors.blue(4);
simulation_color = colors.blue(1);

plot_handle = @(subplot_handles, title, dataset, start_time, end_time) zoomed_plot(subplot_handles, title, dataset, start_time, end_time, reference_color, data_color, simulation_color, colors);
save_figures = input('Would you like to save the figures [Y/N]: ', 's');

for filename_idx = 1:length(filename)
    fprintf('Filename: %s\n', filename(filename_idx));
    log_vars = load(filename(filename_idx));
    title_label = string(strrep(strrep(strrep(strrep(filename(filename_idx), ".mat", ""), "static", "complete"), "dynamic", "complete"), "_RESIM", ""));  
    
    % FIGURE 3
    f(1) = figure;
%     sgtitle("Experiment: " + strrep(title_label, "_", "\_"));
    for i = 1:3
        sub(i) = subplot(3,1,i); %#ok<SAGROW>
    end
    % zoomed_plot_handle(subplot_handles, title, dataset, start_time, end_time)
    plot_handle([sub(1), sub(2), sub(3)], "Lyapunov Swing up", log_vars, 0, inf);
    subplot(sub(1));
    legend('Position',[0.785097288526719,0.830062075365859,0.210693231403036,0.166024755611708]);
    clearvars sub;
    
    if any(save_figures == ["Y", "Yes", "y", "YES", "yes"])
        saveas(f(1), fullfile(paths.report_images_folder, title_label + ".png"));
    end
    
end

%% FUNCTIONS

function zoomed_plot(subplot_handles, title_label, dataset, start_time, end_time, reference_color, data_color, simulation_color, colors)
    
    range = find(dataset.time >= start_time & dataset.time <= end_time);
   
    subplot(subplot_handles(1)); hold on;
    title(title_label);
    
    plot(dataset.time(range), dataset.theta(range)*180/pi, 'color', data_color, 'DisplayName', 'Real Data');
    plot(dataset.time(range), dataset.theta_sim(range)*180/pi, '--', 'color', simulation_color, 'DisplayName', 'Simulation', 'LineWidth', 1.5);
    ylabel('$\theta\;[deg]$');
    set(gca,'Xticklabel',[]);

    subplot(subplot_handles(2));
    plot(dataset.time(range), ones(size(dataset.time(range)))*180, 'color', reference_color, 'DisplayName', 'Reference'); hold on; grid on;
    plot(dataset.time(range), -ones(size(dataset.time(range)))*180, 'color', reference_color, 'HandleVisibility', 'off');
    plot(dataset.time(range), dataset.alpha(range)*180/pi, 'color', data_color, 'DisplayName', 'Real Data');
    plot(dataset.time(range), dataset.alpha_sim(range)*180/pi, '--', 'color', simulation_color, 'DisplayName', 'Simulation', 'LineWidth', 1.5);
    ylabel('$\alpha\;[deg]$');
    set(gca,'Xticklabel',[]);

    subplot(subplot_handles(3));
    plot(dataset.time(range), dataset.voltage(range), 'color', data_color, 'DisplayName', 'Voltage'); hold on; grid on;
    plot(dataset.time(range), dataset.voltage_sim(range), '--', 'color', simulation_color, 'DisplayName', 'Voltage'); hold on; grid on;
    ylabel('$Voltage\;[V]$');
    xlabel('$time\;[s]$');
    
    switch_to_lyap_time = dataset.time(find(dataset.controller_switch(range) == 1, 1, 'first'));
    switch_to_up_time = dataset.time(find(dataset.controller_switch(range) == 1, 1, 'last') + 1);
    if ~isempty(find(dataset.controller_switch_sim(range) == 2, 1, 'first'))
        switch_to_up_sim_time = dataset.time(find(dataset.controller_switch_sim(range) == 1, 1, 'last') + 1);
    else
        switch_to_up_sim_time = Inf;
    end
    
    for i = 1:3
        subplot(subplot_handles(i));
        y_lims = ylim;
        plot([switch_to_lyap_time, switch_to_lyap_time], y_lims, '--', 'color', 'r', 'DisplayName', 'Controller Switch', 'LineWidth', 1.5);
        plot([switch_to_up_time, switch_to_up_time], y_lims, '--', 'color', 'r', 'HandleVisibility', 'off', 'LineWidth', 1.5);
        plot([switch_to_up_sim_time, switch_to_up_sim_time], y_lims, '--', 'color', colors.yellow(2), 'DisplayName', 'Simulated Switch', 'LineWidth', 1.5);
        ylim(y_lims);
    end
    
    linkaxes(subplot_handles, 'x');
    xlim([dataset.time(range(1)), dataset.time(range(end))]);
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