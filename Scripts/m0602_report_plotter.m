
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
paths.report_final_images_folder = fullfile(string(paths.media_folder), "Report_final_images");
addpath(genpath(paths.file_path        ));
addpath(genpath(paths.data_folder      ));
addpath(genpath(paths.scripts_folder   ));
addpath(genpath(paths.simulation_folder));

%% SETTINGS

run('graphics_options.m');

%% DATASET SELECTION

mask_labels = ["time", "theta", "theta_ref", "theta_sim", "alpha", "alpha_ref", "alpha_sim", "voltage", "alpha_dot_sim", "theta_dot_sim", "voltage_sim", "controller_switch", "controller_switch_sim"];
mask_labels_bode = ["freq_max", "freq_min", "freq_out_real", "freq_out_resim", "freq_vector", "magn_bode_ref",  "magn_tf_real", "magn_tf_resim", "phase_bode_ref", "phase_tf_real", "phase_tf_resim"];
            
[filename, path] = uigetfile(paths.resim_parsed_data_folder, 'MultiSelect', 'on');
filename = string(filename)';

for filename_idx = 1:length(filename)
    if contains(filename(filename_idx), "complete")
        complete_dataset = load(filename(filename_idx));

        if contains(filename(filename_idx), "down") || contains(filename(filename_idx), "PID") || contains(filename(filename_idx), "PD")
            points_input = 154858;
        elseif contains(filename(filename_idx), "up")
            points_input = 129000;
        else
            error('Filename: -%s- does not contain up/down label', filename(filename_idx));
        end
        
        fieldnames = string(fields(complete_dataset));
        label_indexes = arrayfun(@(x) find(fieldnames == x, 1, 'first'), mask_labels, 'UniformOutput', false);
        label_indexes = cell2mat(label_indexes(cellfun(@(x) ~isempty(x), label_indexes)));
        label_indexes = sort(label_indexes);
        fieldnames = fieldnames(label_indexes);
        for i = 1:length(fieldnames)
            tmp = complete_dataset.(fieldnames(i));
            dynamic_dataset{filename_idx}.(fieldnames(i)) = tmp(1:points_input); %#ok<SAGROW>
            static_dataset{filename_idx}.(fieldnames(i)) = tmp(points_input+1:end); %#ok<SAGROW>
        end
        
        fieldnames = string(fields(complete_dataset));
        label_indexes = arrayfun(@(x) find(fieldnames == x, 1, 'first'), mask_labels_bode, 'UniformOutput', false);
        label_indexes = cell2mat(label_indexes(cellfun(@(x) ~isempty(x), label_indexes)));
        label_indexes = sort(label_indexes);
        fieldnames = fieldnames(label_indexes);
        for i = 1:length(fieldnames)
            bode_dataset{filename_idx}.(fieldnames(i)) = complete_dataset.(fieldnames(i)); %#ok<SAGROW>
        end
        clearvars complete_dataset tmp;
        
    elseif contains(filename(filename_idx), "static")
        
        static_dataset{filename_idx} = load(filename(filename_idx));
        tmp = dir(paths.resim_parsed_data_folder);
        folder_filenames = string({tmp.name})';
        tmp = char(strrep(filename(filename_idx), "static", "dynamic"));
        dynamic_dataset_name = folder_filenames(contains(folder_filenames, tmp(15:end)));
        tmp = load(dynamic_dataset_name);
        
        fieldnames = string(fields(tmp));
        label_indexes = arrayfun(@(x) find(fieldnames == x, 1, 'first'), mask_labels, 'UniformOutput', false);
        label_indexes = cell2mat(label_indexes(cellfun(@(x) ~isempty(x), label_indexes)));
        label_indexes = sort(label_indexes);
        fieldnames = fieldnames(label_indexes);
        for i = 1:length(fieldnames)
            dynamic_dataset{filename_idx}.(fieldnames(i)) = tmp.(fieldnames(i));
        end
        
        fieldnames = string(fields(tmp));
        label_indexes = arrayfun(@(x) find(fieldnames == x, 1, 'first'), mask_labels_bode, 'UniformOutput', false);
        label_indexes = cell2mat(label_indexes(cellfun(@(x) ~isempty(x), label_indexes)));
        label_indexes = sort(label_indexes);
        fieldnames = fieldnames(label_indexes);
        for i = 1:length(fieldnames)
            bode_dataset{filename_idx}.(fieldnames(i)) = tmp.(fieldnames(i));
        end
        
    elseif contains(filename(filename_idx), "dynamic")
        tmp = load(filename(filename_idx));
        
        fieldnames = string(fields(tmp));
        label_indexes = arrayfun(@(x) find(fieldnames == x, 1, 'first'), mask_labels, 'UniformOutput', false);
        label_indexes = cell2mat(label_indexes(cellfun(@(x) ~isempty(x), label_indexes)));
        label_indexes = sort(label_indexes);
        fieldnames = fieldnames(label_indexes);
        for i = 1:length(fieldnames)
            dynamic_dataset{filename_idx}.(fieldnames(i)) = tmp.(fieldnames(i));
        end
        
        fieldnames = string(fields(tmp));
        label_indexes = arrayfun(@(x) find(fieldnames == x, 1, 'first'), mask_labels_bode, 'UniformOutput', false);
        label_indexes = cell2mat(label_indexes(cellfun(@(x) ~isempty(x), label_indexes)));
        label_indexes = sort(label_indexes);
        fieldnames = fieldnames(label_indexes);
        for i = 1:length(fieldnames)
            bode_dataset{filename_idx}.(fieldnames(i)) = tmp.(fieldnames(i));
        end
        
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
large_plot_handle2 = @(figure_handle, filename_index) large_plot2(figure_handle, filename_index, filename, dynamic_dataset, static_dataset, reference_color, data_color, simulation_color);
zoomed_plot_handle = @(subplot_handles, title, dataset, start_time, end_time) zoomed_plot(subplot_handles, title, dataset, start_time, end_time, reference_color, data_color, simulation_color);
bode_plot_handle = @(subplot_handles, dataset, top_pos, bot_pos, left_pos, right_pos) bode_plot(subplot_handles, dataset, top_pos, bot_pos, left_pos, right_pos, reference_color, data_color, simulation_color);

for filename_idx = 1:length(filename)
    fprintf('Filename: %s\n', filename(filename_idx));
    save_figures = input('Would you like to save the figures [Y/N]: ', 's');
    title_label = string(strrep(strrep(strrep(strrep(filename(filename_idx), ".mat", ""), "static", "complete"), "dynamic", "complete"), "_RESIM", ""));
    
    % Central sweep cut time
    tmp = dynamic_dataset{filename_idx}.time > dynamic_dataset{filename_idx}.time(floor(end/2)) - 3;
    sweep_cut_start = dynamic_dataset{filename_idx}.time(find(dynamic_dataset{filename_idx}.theta_ref>0 & [0; dynamic_dataset{filename_idx}.theta_ref(1:end-1)]<0 & tmp, 1, 'first')) - 0.25;
    sweep_cut_end = dynamic_dataset{filename_idx}.time(find(dynamic_dataset{filename_idx}.theta_ref>0 & [0; dynamic_dataset{filename_idx}.theta_ref(1:end-1)]<0 & tmp, 3, 'first')) + 0.25;
    sweep_cut_end = sweep_cut_end(end);
    
    % Last step cut time
    max_step = max(static_dataset{filename_idx}.theta_ref);
    start_step = static_dataset{filename_idx}.time(find(static_dataset{filename_idx}.theta_ref == max_step, 1, 'first')) - 1;
    end_step = static_dataset{filename_idx}.time(find(static_dataset{filename_idx}.theta_ref == max_step, 1, 'last')) + 1;
    
    % FIGURE 1
    f(1) = figure;
    large_plot_handle(f(1), filename_idx);
    
    % FIGURE 2
    f(2) = figure;
    large_plot_handle2(f(2), filename_idx);
    
    % FIGURE 3
    f(3) = figure;
    clearvars sub;
    for i = 1:3
        sub(i) = subplot(3,1,i); %#ok<SAGROW>
    end
    zoomed_plot_handle([sub(1), sub(2), sub(3)], "Sinesweep", dynamic_dataset{filename_idx}, dynamic_dataset{filename_idx}.time(1), dynamic_dataset{filename_idx}.time(end));
    subplot(sub(1));
    legend('Position',[0.844799515743725,0.876427927349818,0.091662336339736,0.10204690470116]);
    
    % FIGURE 4
    f(4) = figure;
    clearvars sub;
    for i = 1:3
        sub(i) = subplot(3,1,i);
    end
    zoomed_plot_handle([sub(1), sub(2), sub(3)], "Steps", static_dataset{filename_idx}, static_dataset{filename_idx}.time(1), static_dataset{filename_idx}.time(end));
    subplot(sub(1));
    legend('Position',[0.843716678710699,0.835916200270927,0.091662336339736,0.10204690470116]);
    
    % FIGURE 5
    f(5) = figure;
    clearvars sub;
    for i = 1:6
        sub(i) = subplot(3,2,i);
    end
    zoomed_plot_handle([sub(1), sub(3), sub(5)], "Central sweep", dynamic_dataset{filename_idx},  sweep_cut_start, sweep_cut_end);
    zoomed_plot_handle([sub(2), sub(4), sub(6)], "Step", static_dataset{filename_idx}, start_step, end_step);
    subplot(sub(2));
    legend('Position',[0.867893881970764,0.884209999696931,0.111913545769407,0.102996823330787]);
    
    % FIGURE 6
    f(6) = figure;
    clearvars sub;
    sub(1) = subplot(3,4,1);
    sub(2) = subplot(3,4,5);
    sub(3) = subplot(3,4,9);
    sub(4) = subplot(3,4,2);
    sub(5) = subplot(3,4,6);
    sub(6) = subplot(3,4,10);
    zoomed_plot_handle([sub(1), sub(2), sub(3)], "Central sweep", dynamic_dataset{filename_idx},  sweep_cut_start, sweep_cut_end);
    zoomed_plot_handle([sub(4), sub(5), sub(6)], "Step", static_dataset{filename_idx}, start_step, end_step);
    subplot(sub(4));
    legend('Position',[0.450121041112044,0.882058420880224,0.098877334632407,0.101950107904424]); % half page
    tmp = get(sub(1), 'Position');
    top_pos = tmp(2) + tmp(4);
    tmp = get(sub(3), 'Position');
    bot_pos = tmp(2);
    s = subplot(3,4,3);
    tmp = get(s, 'Position');
    left_pos = tmp(1);
    delete(s);
    s = subplot(3,4,4);
    tmp = get(s, 'Position');
    right_pos = tmp(1) + tmp(3);
    delete(s);
    clearvars sub;
    sub(1) = subplot(2,2,2);
    sub(2) = subplot(2,2,4);
    clearvars sub;
    sub(1) = subplot(2,2,2);
    sub(2) = subplot(2,2,4);
    bode_plot_handle(sub, bode_dataset{filename_idx}, top_pos, bot_pos, left_pos, right_pos);
    subplot(sub(1));
    legend('Position', [0.829757018763094,0.876986499705379,0.128734228304222,0.102046904701159]);
    
    
    % FIGURE 7
    f(7) = figure;
    clearvars sub;
    sub(1) = subplot(3,3,1);
    sub(2) = subplot(3,3,4);
    sub(3) = subplot(3,3,7);
    zoomed_plot_handle(sub, "Step", static_dataset{filename_idx}, start_step, end_step);
    subplot(sub(1));
    legend('Position', [0.290943997257144,0.879926224718177,0.098877334632407,0.101950107904424]);
    tmp = get(sub(1), 'Position');
    top_pos = tmp(2) + tmp(4);
    tmp = get(sub(3), 'Position');
    bot_pos = tmp(2);
    s = subplot(3,3,2);
    tmp = get(s, 'Position');
    left_pos = tmp(1);
    delete(s);
    s = subplot(3,3,3);
    tmp = get(s, 'Position');
    right_pos = tmp(1) + tmp(3);
    delete(s);
    clearvars sub;
    sub(1) = subplot(2,2,2);
    sub(2) = subplot(2,2,4);
    bode_plot_handle(sub, bode_dataset{filename_idx}, top_pos, bot_pos, left_pos, right_pos);
    subplot(sub(1));
    legend('Position', [0.829757018763094,0.876986499705379,0.128734228304222,0.102046904701159]);
    
    if any(save_figures == ["Y", "Yes", "y", "YES", "yes"])
        saveas(f(1), fullfile(paths.report_final_images_folder, title_label + ".png"));
        saveas(f(2), fullfile(paths.report_final_images_folder, title_label + "_full_experiment.png"));
        saveas(f(3), fullfile(paths.report_final_images_folder, title_label + "_only_sinesweep.png"));
        saveas(f(4), fullfile(paths.report_final_images_folder, title_label + "_only_steps.png"));
        saveas(f(5), fullfile(paths.report_final_images_folder, title_label + "_csweep_step.png"));
        saveas(f(6), fullfile(paths.report_final_images_folder, title_label + "_bode_csweep_step.png"));
        saveas(f(7), fullfile(paths.report_final_images_folder, title_label + "_bode_step.png"));
    end
    
end

%% FUNCTIONS

function large_plot(figure_handle, filename_idx, filename, dynamic_dataset, static_dataset, reference_color, data_color, simulation_color)

    figure(figure_handle);
    title_label = string(strrep(strrep(strrep(strrep(filename(filename_idx), ".mat", ""), "static", "complete"), "dynamic", "complete"), "_RESIM", ""));
%     sgtitle("Experiment: " + strrep(title_label, "_", "\_"));
    
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
        alpha_ref = dynamic_dataset{filename_idx}.alpha_ref;
        while abs(alpha_ref(1) - dynamic_dataset{filename_idx}.alpha(1)) > pi
            if alpha_ref(1) - dynamic_dataset{filename_idx}.alpha(1) > pi
                alpha_ref = alpha_ref - 2*pi;
            else
                alpha_ref = alpha_ref + 2*pi;
            end
        end
        plot(dynamic_dataset{filename_idx}.time, alpha_ref*180/pi, 'color', reference_color, 'DisplayName', 'Reference'); hold on; grid on;
    end
    plot(dynamic_dataset{filename_idx}.time, dynamic_dataset{filename_idx}.alpha*180/pi, 'color', data_color, 'DisplayName', 'Real Data');
    plot(dynamic_dataset{filename_idx}.time, dynamic_dataset{filename_idx}.alpha_sim*180/pi, '--', 'color', simulation_color, 'DisplayName', 'Simulation', 'LineWidth', 1.5);
    ylabel('$\alpha\;[deg]$');
    set(gca,'Xticklabel',[]);
    
    sub(3) = subplot(3,2,5);
    plot(dynamic_dataset{filename_idx}.time, dynamic_dataset{filename_idx}.voltage, 'color', data_color, 'DisplayName', 'Voltage'); hold on; grid on;
    ylabel('$Voltage\;[V]$');
    ylim([-10 10]);
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
    legend('Position',[0.859691300698568,0.86206112657105,0.091662336339736,0.10204690470116]);
    set(gca,'Xticklabel',[]);

    sub(5) = subplot(3,2,4);
    if any(fields(static_dataset{filename_idx}) == "alpha_ref")
        alpha_ref = static_dataset{filename_idx}.alpha_ref;
        while abs(alpha_ref(1) - static_dataset{filename_idx}.alpha(1)) > pi
            if alpha_ref(1) - static_dataset{filename_idx}.alpha(1) > pi
                alpha_ref = alpha_ref - 2*pi;
            else
                alpha_ref = alpha_ref + 2*pi;
            end
        end
        plot(static_dataset{filename_idx}.time, alpha_ref*180/pi, 'color', reference_color, 'DisplayName', 'Reference'); hold on; grid on;
    end
    plot(static_dataset{filename_idx}.time, static_dataset{filename_idx}.alpha*180/pi, 'color', data_color, 'DisplayName', 'Real Data');
    plot(static_dataset{filename_idx}.time, static_dataset{filename_idx}.alpha_sim*180/pi, '--', 'color', simulation_color, 'DisplayName', 'Simulation', 'LineWidth', 1.5);
    ylabel('$\alpha\;[deg]$');
    set(gca,'Xticklabel',[]);

    sub(6) = subplot(3,2,6);
    plot(static_dataset{filename_idx}.time, static_dataset{filename_idx}.voltage, 'color', data_color, 'DisplayName', 'Voltage'); hold on; grid on;
    ylabel('$Voltage\;[V]$');
%     ylim([-10 10]);
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

function large_plot2(figure_handle, filename_idx, filename, dynamic_dataset, static_dataset, reference_color, data_color, simulation_color)

    figure(figure_handle);
%     title_label = string(strrep(strrep(strrep(strrep(filename(filename_idx), ".mat", ""), "static", "complete"), "dynamic", "complete"), "_RESIM", ""));
%     sgtitle("Experiment: " + strrep(title_label, "_", "\_"));
    
    sub(1) = subplot(3,1,1); hold on;
    title('Experiment');
    if any(fields(dynamic_dataset{filename_idx}) == "theta_ref")
        plot(dynamic_dataset{filename_idx}.time, dynamic_dataset{filename_idx}.theta_ref*180/pi, 'color', reference_color, 'DisplayName', 'Reference'); grid on;
    end
    plot(dynamic_dataset{filename_idx}.time, dynamic_dataset{filename_idx}.theta*180/pi, 'color', data_color, 'DisplayName', 'Real Data');
    plot(dynamic_dataset{filename_idx}.time, dynamic_dataset{filename_idx}.theta_sim*180/pi, '--', 'color', simulation_color, 'DisplayName', 'Simulation', 'LineWidth', 1.5);
    
    static_time_offset = static_dataset{filename_idx}.time(1) - dynamic_dataset{filename_idx}.time(end) - 0.002;
    
    if any(fields(static_dataset{filename_idx}) == "theta_ref")
        plot(static_dataset{filename_idx}.time - static_time_offset, static_dataset{filename_idx}.theta_ref*180/pi, 'color', reference_color, 'HandleVisibility', 'off'); grid on;
    end
    plot(static_dataset{filename_idx}.time - static_time_offset, static_dataset{filename_idx}.theta*180/pi, 'color', data_color, 'HandleVisibility', 'off');
    plot(static_dataset{filename_idx}.time - static_time_offset, static_dataset{filename_idx}.theta_sim*180/pi, '--', 'color', simulation_color, 'HandleVisibility', 'off', 'LineWidth', 1.5);
    
    ylabel('$\theta\;[deg]$');
    set(gca,'Xticklabel',[]);
    legend('Position',[0.859691300698568,0.86206112657105,0.091662336339736,0.10204690470116]);
    
    sub(2) = subplot(3,1,2); hold on;
    if any(fields(dynamic_dataset{filename_idx}) == "alpha_ref")
        alpha_ref = dynamic_dataset{filename_idx}.alpha_ref;
        while abs(alpha_ref(1) - dynamic_dataset{filename_idx}.alpha(1)) > pi
            if alpha_ref(1) - dynamic_dataset{filename_idx}.alpha(1) > pi
                alpha_ref = alpha_ref - 2*pi;
            else
                alpha_ref = alpha_ref + 2*pi;
            end
        end
        plot(dynamic_dataset{filename_idx}.time, alpha_ref*180/pi, 'color', reference_color, 'DisplayName', 'Reference');
    end
    plot(dynamic_dataset{filename_idx}.time, dynamic_dataset{filename_idx}.alpha*180/pi, 'color', data_color, 'DisplayName', 'Real Data');
    plot(dynamic_dataset{filename_idx}.time, dynamic_dataset{filename_idx}.alpha_sim*180/pi, '--', 'color', simulation_color, 'DisplayName', 'Simulation', 'LineWidth', 1.5);
    
    if any(fields(static_dataset{filename_idx}) == "alpha_ref")
        alpha_ref = static_dataset{filename_idx}.alpha_ref;
        while abs(alpha_ref(1) - static_dataset{filename_idx}.alpha(1)) > pi
            if alpha_ref(1) - static_dataset{filename_idx}.alpha(1) > pi
                alpha_ref = alpha_ref - 2*pi;
            else
                alpha_ref = alpha_ref + 2*pi;
            end
        end
        plot(static_dataset{filename_idx}.time - static_time_offset, alpha_ref*180/pi, 'color', reference_color, 'HandleVisibility', 'off');
    end
    plot(static_dataset{filename_idx}.time - static_time_offset, static_dataset{filename_idx}.alpha*180/pi, 'color', data_color, 'HandleVisibility', 'off');
    plot(static_dataset{filename_idx}.time - static_time_offset, static_dataset{filename_idx}.alpha_sim*180/pi, '--', 'color', simulation_color, 'HandleVisibility', 'off', 'LineWidth', 1.5);
    
    ylabel('$\alpha\;[deg]$');
    set(gca,'Xticklabel',[]);
    
    sub(3) = subplot(3,1,3);
    plot(dynamic_dataset{filename_idx}.time, dynamic_dataset{filename_idx}.voltage, 'color', data_color, 'DisplayName', 'Voltage'); hold on; grid on;
    plot(static_dataset{filename_idx}.time - static_time_offset, static_dataset{filename_idx}.voltage, 'color', data_color, 'HandleVisibility', 'off');
    ylabel('$Voltage\;[V]$');
    ylim([-10 10]);
    xlabel('$time\;[s]$');
    linkaxes(sub, 'x');
    xlim([dynamic_dataset{filename_idx}.time(1), dynamic_dataset{filename_idx}.time(end) + static_dataset{filename_idx}.time(end) - static_dataset{filename_idx}.time(1)]);
    
    tmp = get(sub(1), 'Position');
    left_pos = tmp(1);
    top_pos = tmp(2);
    width = tmp(3);
    height = tmp(4);
    spacing = 0.025;
    set(sub(2), 'Position', [left_pos, top_pos-height-spacing, width, height]);
    set(sub(3), 'Position', [left_pos, top_pos-2*height-2*spacing, width, height]);
    
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
        alpha_ref = dataset.alpha_ref;
        while abs(alpha_ref(1) - dataset.alpha(1)) > pi
            if alpha_ref(1) - dataset.alpha(1) > pi
                alpha_ref = alpha_ref - 2*pi;
            else
                alpha_ref = alpha_ref + 2*pi;
            end
        end
        plot(dataset.time(range), alpha_ref(range)*180/pi, 'color', reference_color, 'DisplayName', 'Reference'); hold on; grid on;
    end
    plot(dataset.time(range), dataset.alpha(range)*180/pi, 'color', data_color, 'DisplayName', 'Real Data');
    plot(dataset.time(range), dataset.alpha_sim(range)*180/pi, '--', 'color', simulation_color, 'DisplayName', 'Simulation', 'LineWidth', 1.5);
    ylabel('$\alpha\;[deg]$');
    set(gca,'Xticklabel',[]);

    subplot(subplot_handles(3));
    plot(dataset.time(range), dataset.voltage(range), 'color', data_color, 'DisplayName', 'Voltage'); hold on; grid on;
    ylabel('$Voltage\;[V]$');
    ylim([-10 10]);
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

function bode_plot(subplot_handles, dataset, top_pos, bot_pos, left_pos, right_pos, reference_color, data_color, simulation_color)

    subplot(subplot_handles(1));
    plot(dataset.freq_vector, dataset.magn_bode_ref, 'LineWidth', 1.5, 'Color', reference_color, 'DisplayName', '$G_{\theta_{ref}-\theta}$ reference'); hold on; grid on;
    semilogx(dataset.freq_out_real, dataset.magn_tf_real, 'LineWidth', 2.0, 'Color', data_color, 'DisplayName', '$G_{\theta_{ref}-\theta}$ real');
    semilogx(dataset.freq_out_resim, dataset.magn_tf_resim, 'LineWidth', 1.5, 'Color', simulation_color, 'DisplayName', '$G_{\theta_{ref}-\theta}$ simulated');
    
    
    ylabel('$Magnitude\;[dB]$');
    set(gca,'Xticklabel',[]);

    subplot(subplot_handles(2));
    plot(dataset.freq_vector, dataset.phase_bode_ref, 'LineWidth', 1.5, 'Color', reference_color, 'HandleVisibility', 'off'); hold on; grid on;
    semilogx(dataset.freq_out_real, dataset.phase_tf_real, 'LineWidth', 2.0, 'Color', data_color, 'HandleVisibility', 'off');
    semilogx(dataset.freq_out_resim, dataset.phase_tf_resim, 'LineWidth', 1.5, 'Color', simulation_color, 'HandleVisibility', 'off');
    
    linkaxes(subplot_handles, 'x');
    xlim([dataset.freq_min, dataset.freq_max]);
    xlabel('$Frequency\;[rad/s]$');
    ylabel('$Phase\;[deg]$');
    
    subplot(subplot_handles(1));
    ylims = ylim;
    ylim([min(ylims(1), -9), max(ylims(2), 3.5)]);
    spacing = 0.025;
    height = (top_pos - bot_pos - spacing)/2;
    set(subplot_handles(1), 'Position', [left_pos, top_pos-height, right_pos-left_pos, height]);
    set(subplot_handles(2), 'Position', [left_pos, bot_pos, right_pos-left_pos, height]);
    linkaxes(subplot_handles, 'x');
    
end