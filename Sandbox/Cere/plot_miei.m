%% ADD PATHS
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
reference_color = "#767676";
data_color = colors.blue(4);
simulation_color = colors.blue(1);

[filename, path] = uigetfile(paths.resim_parsed_data_folder, 'MultiSelect', 'on');
load(filename);

%% Abuse
f(1) = figure;
title_label = string(strrep(strrep(strrep(strrep(filename, ".mat", ""), "static", "complete"), "dynamic", "complete"), "_RESIM", ""));
sgtitle("Experiment: " + strrep(title_label, "_", "\_"));
subplot(3, 2, 1); hold on;
plot(time, theta_ref*180/pi, 'color', reference_color, 'DisplayName', 'Reference'); grid on;
plot(time, theta*180/pi, 'color', data_color, 'DisplayName', 'Real Data');
% plot(time, theta_sim*180/pi, '--', 'color', simulation_color, 'DisplayName', 'Simulation', 'LineWidth', 1.5);
ylabel('$\theta\;[deg]$');
set(gca,'Xticklabel',[]);

subplot(3, 2, 3);
plot(time,  -alpha_ref*180/pi, 'color', reference_color, 'DisplayName', 'Reference'); hold on; grid on;
plot(time, alpha*180/pi, 'color', data_color, 'DisplayName', 'Real Data');
% plot(time, alpha_sim*180/pi, '--', 'color', simulation_color, 'DisplayName', 'Simulation', 'LineWidth', 1.5);
ylabel('$\alpha\;[deg]$');
set(gca,'Xticklabel',[]);

subplot(3, 2, 5);
plot(time,voltage, 'color', data_color, 'DisplayName', 'Voltage'); hold on; grid on;
ylabel('$Voltage\;[V]$');
ylim([-10 10]);
xlabel('$time\;[s]$');
xlim([time(1),time(end)]);

subplot(3, 2, 2); hold on;
plot(time, theta_ref*180/pi, 'color', reference_color, 'DisplayName', 'Reference'); grid on;
plot(time, theta*180/pi, 'color', data_color, 'DisplayName', 'Real Data');
% plot(time, theta_sim*180/pi, '--', 'color', simulation_color, 'DisplayName', 'Simulation', 'LineWidth', 1.5);
ylabel('$\theta\;[deg]$');
set(gca,'Xticklabel',[]);
xlim([6.2,8.3]);
legend('Position',[0.818593359828276,0.74285494352031,0.082638973659939,0.066599995749337]);

subplot(3, 2, 4);
plot(time,  -alpha_ref*180/pi, 'color', reference_color, 'DisplayName', 'Reference'); hold on; grid on;
plot(time, alpha*180/pi, 'color', data_color, 'DisplayName', 'Real Data');
% plot(time, alpha_sim*180/pi, '--', 'color', simulation_color, 'DisplayName', 'Simulation', 'LineWidth', 1.5);
ylabel('$\alpha\;[deg]$');
set(gca,'Xticklabel',[]);
xlim([6.2,8.3]);

subplot(3, 2, 6);
plot(time,voltage, 'color', data_color, 'DisplayName', 'Voltage'); hold on; grid on;
ylabel('$Voltage\;[V]$');
ylim([-10 10]);
xlabel('$time\;[s]$');
xlim([6.2,8.3]);

saveas(f(1), fullfile(paths.report_images_folder, title_label + ".png"));