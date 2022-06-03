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
data_color = colors.blue(4);
simulation_color = colors.blue(1);

%% REAL DATASET SELECTION
[filename_real, path] = uigetfile(paths.parsed_data_folder);
filename_real = string(filename_real)';
Log_data_real = load(filename_real);

%% Reshape data
is_only_dynamic = input('(1: only dynamic exp, 0: complete test): \n');
is_down = input('(1: pendulum down, 0: pendulum up): \n');

if is_only_dynamic == 1 
    points_input = length(Log_data_real.time);
else
    if is_down == 1
        points_input = 154858;
    else
        points_input = 129000;
    end
end

%% FFT
input_real = Log_data_real.theta_ref(1:points_input);
output_real = Log_data_real.theta(1:points_input);
t_real = Log_data_real.time(1:points_input);

[magn_in_real, phase_in_real, freq_in_real] = my_fft(input_real, t_real);
[magn_out_real, phase_out_real, freq_out_real] = my_fft(output_real, t_real);
magn_tf_real = magn_out_real ./ magn_in_real;

phase_in_real = phase_in_real * 180 / pi;
phase_out_real = phase_out_real * 180 / pi;

%dB conversion
magn_tf_real = 20*log10(magn_tf_real);
phase_tf_real = phase_out_real - phase_in_real;
phase_tf_real(phase_tf_real > 180) = phase_tf_real(phase_tf_real > 180) - 360;
phase_tf_real(phase_tf_real < -180) = phase_tf_real(phase_tf_real < -180) + 360;

%% RESIM DATASET SELECTION
[filename_resim, path] = uigetfile(paths.resim_parsed_data_folder);
filename_resim = string(filename_resim)';
Log_data_resim = load(filename_resim);

% %% Reshape data
% is_only_dynamic = input('(1: only dynamic exp, 0: complete test): \n');
% is_down = input('(1: pendulum down, 0: pendulum up): \n');
% 
% if is_only_dynamic == 1 
%     points_input = length(Log_data_resim.time);
% else
%     if is_down == 1
%         points_input = 154858;
%     else
%         points_input = 129000;
%     end
% end

%% FFT
input_resim = Log_data_resim.theta_ref(1:points_input);
output_resim = Log_data_resim.theta(1:points_input);
t_resim = Log_data_resim.time(1:points_input);

[magn_in_resim, phase_in_resim, freq_in_resim] = my_fft(input_resim, t_resim);
[magn_out_resim, phase_out_resim, freq_out_resim] = my_fft(output_resim, t_resim);
magn_tf_resim = magn_out_resim ./ magn_in_resim;

phase_in_resim = phase_in_resim * 180 / pi;
phase_out_resim = phase_out_resim * 180 / pi;

%dB conversion
magn_tf_resim = 20*log10(magn_tf_resim);
phase_tf_resim = phase_out_resim - phase_in_resim;
phase_tf_resim(phase_tf_resim > 180) = phase_tf_resim(phase_tf_resim > 180) - 360;
phase_tf_resim(phase_tf_resim < -180) = phase_tf_resim(phase_tf_resim < -180) + 360;

%% Plot
freq_in_real = freq_in_real *2*pi;
freq_out_real = freq_out_real *2*pi;
freq_in_resim = freq_in_resim *2*pi;
freq_out_resim = freq_out_resim *2*pi;

freq_min = 0.4;
if is_down == 1
    freq_max = 9;
else
    freq_max = 6;
end

%REAL
figure
hold on
plot(t_real, input_real);
plot(t_real, output_real);
title('Theta ref vs Theta (REAL)')
hold off
legend('$\theta_{ref}$', '$\theta$', 'Interpreter', 'latex');
xlabel('Time [s]');

figure
plot(freq_in_real, magn_in_real);
title('FFT $\theta_{ref}$ (REAL)', 'Interpreter', 'latex')
ylabel('Amplitude');
xlabel('Frequency [rad/s]');
grid on
xlim([freq_min, freq_max]);

figure
plot(freq_out_real, magn_out_real);
title('FFT $\theta$ (REAL)', 'Interpreter', 'latex')
ylabel('Amplitude');
xlabel('Frequency [rad/s]');
grid on
xlim([freq_min, freq_max]);

%RESIM
figure
hold on
plot(t_resim, input_resim);
plot(t_resim, output_resim);
title('Theta ref vs Theta (RESIM)')
hold off
legend('$\theta_{ref}$', '$\theta$', 'Interpreter', 'latex');
xlabel('Time [s]');

figure
plot(freq_in_resim, magn_in_resim);
title('FFT $\theta_{ref}$ (RESIM)', 'Interpreter', 'latex')
ylabel('Amplitude');
xlabel('Frequency [rad/s]');
grid on
xlim([freq_min, freq_max]);

figure
plot(freq_out_resim, magn_out_resim);
title('FFT $\theta$ (RESIM)', 'Interpreter', 'latex')
ylabel('Amplitude');
xlabel('Frequency [rad/s]');
grid on
xlim([freq_min, freq_max]);

% BODE
f(1) = figure;
subplot(2,1,1)
hold on
sgtitle("Experiment: " + string(strrep(strrep(filename_real, ".mat", ""), "_", "\_")));
semilogx(freq_out_real, magn_tf_real, 'LineWidth', 2.0, 'Color', data_color);
semilogx(freq_out_resim, magn_tf_resim, 'LineWidth', 1.5, 'Color', simulation_color);
legend('TF real', 'TF simulated', 'Interpreter', 'latex');
hold off
ylabel('Magnitude [dB]');
xlim([freq_min, freq_max]);
grid on;

subplot(2,1,2)
hold on
semilogx(freq_out_real, phase_tf_real, 'LineWidth', 2.0, 'Color', data_color);
semilogx(freq_out_resim, phase_tf_resim, 'LineWidth', 1.5, 'Color', simulation_color);
hold off
xlim([freq_min, freq_max]);
xlabel('Frequency [rad/s]');
ylabel('Phase [degrees]');

title_label = "Bode_" + string(strrep(filename_real, ".mat", ""));
saveas(f(1), fullfile(paths.report_images_folder, title_label + ".png"));

