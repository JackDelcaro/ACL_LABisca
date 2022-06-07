log_save();

function log_save()

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
%     filename = '20220520_1153_new_swing_up_down_int';
    filename = '20220520_1159_new_swing_up_down_int_smart90_V3';
%     filename = '20220520_1204_new_swing_up_down_int_smart90_V1p2';
    fprintf(1, "File Selected: %s\n", filename);
    Log_data = load(filename);
    
    figure;
    sgtitle("Experiment: " + string(strrep(strrep(filename, ".mat", ""), "_", "\_")));

    sub(1) = subplot(4,1,1);
    plot(Log_data.time, Log_data.voltage); hold on; grid on;
    ylabel('$Voltage\;[V]$');

    sub(2) = subplot(4,1,2);
    plot(Log_data.time, Log_data.theta_ref*180/pi, 'color', colors.matlab(2), 'DisplayName', 'reference'); hold on; grid on;
    plot(Log_data.time, Log_data.theta*180/pi, 'color', colors.matlab(1), 'DisplayName', 'data'); hold on; grid on;
    ylabel('$\theta\;[deg]$');
    legend;

    sub(3) = subplot(4,1,3);
    alpha = Log_data.alpha*180/pi;
    while any(alpha > 270 | alpha < -270)
        alpha(alpha > 270) = alpha(alpha > 270) - 360;
        alpha(alpha < -270) = alpha(alpha < -270) + 360;
    end
    plot(Log_data.time, Log_data.alpha_ref*180/pi, 'color', colors.matlab(2), 'DisplayName', 'reference'); hold on; grid on;
    plot(Log_data.time, alpha, 'color', colors.matlab(1), 'DisplayName', 'data');
    legend;
    ylabel('$\alpha\;[deg]$');
    xlabel('$time\;[s]$');
    
    linkaxes(sub, 'x');
    clearvars sub;
    
    stop_condition = false;
    while stop_condition == false
        
        inf_time_th = input('Start time: ');
        inf_time_th = max([0, inf_time_th]);
        sup_time_th = input('End time: ');
        sup_time_th = min([Log_data.time(end), sup_time_th]);
        
        boolean_mask = Log_data.time >= inf_time_th & Log_data.time <= sup_time_th;
        range = find(boolean_mask);
        
        tmp = char(filename);
        date_string = string(tmp(1:14));
        experiment_label = date_string + "bangbang" + "_st_" + ...
            num2str(floor(inf_time_th)) + "_end_" + num2str(floor(sup_time_th)) + "_ref_" + ...
            strrep(strrep(num2str(Log_data.theta_ref(range(1))*180/pi), '.', 'p'), '-', 'm');

        figure;
        sgtitle("Experiment: " + strrep(experiment_label, '_', '\_'));

        sub(1) = subplot(4,1,1);
        plot(Log_data.time(range), Log_data.voltage(range)); hold on; grid on;
        ylabel('$Voltage\;[V]$');

        sub(2) = subplot(4,1,2);
        plot(Log_data.time(range), Log_data.theta_ref(range)*180/pi, 'color', colors.matlab(2), 'DisplayName', 'reference'); hold on; grid on;
        plot(Log_data.time(range), Log_data.theta(range)*180/pi, 'color', colors.matlab(1), 'DisplayName', 'data'); hold on; grid on;
        ylabel('$\theta\;[deg]$');
        legend;

        sub(3) = subplot(4,1,3);
        alpha = Log_data.alpha(range)*180/pi;
        while alpha(1) > 180 || alpha(1) < -180
            if alpha(1) > 180
                alpha = alpha - 360;
            else
            	alpha = alpha + 360;
            end
        end
        plot(Log_data.time(range), Log_data.alpha_ref(range)*180/pi, 'color', colors.matlab(2), 'DisplayName', 'reference'); hold on; grid on;
        plot(Log_data.time(range), alpha, 'color', colors.matlab(1), 'DisplayName', 'data');
        legend;
        ylabel('$\alpha\;[deg]$');
        xlabel('$time\;[s]$');

        linkaxes(sub, 'x');
        xlim([inf_time_th, sup_time_th]);
        clearvars sub;

        fieldnames = string(fields(Log_data));
        for ii = 1:length(fieldnames)
            if fieldnames(ii) == "alpha"
                my_data.(fieldnames(ii)) = alpha*pi/180;
            elseif fieldnames(ii) == "time"
                tmp = Log_data.time;
                my_data.(fieldnames(ii)) = tmp(range) - tmp(range(1));
            else
                tmp = Log_data.(fieldnames(ii));
                my_data.(fieldnames(ii)) = tmp(range);
            end
        end
        savefile_label = experiment_label + ".mat";
        savefile_fullpath = fullfile(paths.parsed_data_folder, savefile_label);
        save(savefile_fullpath, '-struct', 'my_data');

        fprintf(1, "\n");

        stop_condition_string = input('Would you like to stop? [Y/N]: ', 's');
        if any(stop_condition_string == ["Y", "Yes", "y", "YES", "yes"])
            stop_condition = true;
        end
    end
end
