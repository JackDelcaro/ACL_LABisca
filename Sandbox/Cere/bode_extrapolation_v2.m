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
reference_color = "#767676";
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

freq_min = 0.4;
if is_down == 1
    freq_max = 9;
else
    freq_max = 6;
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
phase_tf_real = phase_tf_real * pi / 180;
phase_tf_real = unwrap(phase_tf_real) * 180 / pi;

%% RESIM DATASET SELECTION
[filename_resim, path] = uigetfile(paths.resim_parsed_data_folder);
filename_resim = string(filename_resim)';
Log_data_resim = load(filename_resim);

%% FFT
input_resim = Log_data_resim.theta_ref(1:points_input);
output_resim = Log_data_resim.theta_sim(1:points_input);
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

%% Bode reference
freq_vector = linspace(freq_min, freq_max, 77429);
% tf_ref = tf([6 20], [0.005, 1, 6, 20]); % PD
tf_ref = tf([7 7*1.5*2 7*1.5*1.5], [0 0 7 7*1.5*2 7*1.5*1.5]+[1/70 1 0 0 0]); %PID
% tf_ref = tf([346.8 23.42 4.654e04], [1 56.58 1265 1.195e04 4.76e04]); % PP_down_0 HP
% tf_ref = tf([52.9 3.571 7099], [1 35.16 528.2 2890 8160]); % PP_down_2 LP
% tf_ref = tf([167.4 136.2 2.247e04 1.677e04], [1 43.29 791 5788 2.354e04 1.677e04]); % PP_int_down_2
% tf_ref = tf([92.45 6.242 1.241e04], [1 30.22 527.9 4370 1.347e04]); % LQ_down_4
% tf_ref = tf([235.1 247.9 3.156e04 3.114e04], [1 31.39 597.1 6025 3.262e04 3.114e04]); % LQ_int_down_8
% tf_ref =tf([-465.198916376074,-278.032747242441,60711.3913660366,27848.4626009559], [1,70.2646888201975,1768.15875767053,15277.9761639210,58948.9815185760,27848.4626009575]); % PP_int_up_7
% tf_ref =tf([-585.953987170463,-294.840159415106,76478.3952203376,27848.4626009558], [1,84.8892739777155,1836.33455573711,17250.7424869966,74715.9853728766,27848.4626009572]); % LQ_int_up_3
% tf_ref =tf([-164.6 -222.2 2.207e04 2.833e04], [1 51.73 900.9 6552 2.101e04 2.833e04]); % PP_int_up_9
% tf_ref =tf([-79.14 -89.42 1.061e04 1.128e04], [1 40.44 562.7 3314 9554 1.128e04]); % LQ_int_up_4 LP
[magn_bode_ref_unshaped, phase_bode_ref_unshaped, ~] = bode(tf_ref, freq_vector);

%dB conversion
magn_bode_ref(:) = magn_bode_ref_unshaped(1, 1, :);
magn_bode_ref = magn_bode_ref';
magn_bode_ref = 20*log10(magn_bode_ref);

phase_bode_ref(:) = phase_bode_ref_unshaped(1,1,:);
phase_bode_ref = phase_bode_ref';
phase_bode_ref(phase_bode_ref > 180) = phase_bode_ref(phase_bode_ref > 180) - 360;
phase_bode_ref(phase_bode_ref < -180) = phase_bode_ref(phase_bode_ref < -180) + 360;

%% Frequencies
freq_in_real = freq_in_real *2*pi;
freq_out_real = freq_out_real *2*pi;
freq_in_resim = freq_in_resim *2*pi;
freq_out_resim = freq_out_resim *2*pi;

%% Plot

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

% Comparison
figure
hold on
plot(t_real, output_real);
plot(t_real, output_resim);
title('Theta (REAL) vs Theta (RESIM)')
hold off
legend('$\theta_{real}$', '$\theta_{resim}$', 'Interpreter', 'latex');
xlabel('Time [s]');

% BODE
f(1) = figure;
clearvars sub;
sub(1) = subplot(2,1,1);
hold on
sgtitle("Experiment: " + string(strrep(strrep(filename_real, ".mat", ""), "_", "\_")));
semilogx(freq_out_real, magn_tf_real, 'LineWidth', 2.0, 'Color', data_color);
semilogx(freq_out_resim, magn_tf_resim, 'LineWidth', 1.5, 'Color', simulation_color);
plot(freq_vector, magn_bode_ref, 'LineWidth', 1.5, 'Color', reference_color);
legend('$G_{\theta_{ref}-\theta}$ real', '$G_{\theta_{ref}-\theta}$ simulated', '$G_{\theta_{ref}-\theta}$ reference', 'Interpreter', 'latex');
hold off
ylabel('Magnitude [dB]');
xlim([freq_min, freq_max]);
set(gca,'Xticklabel',[]);
grid on;

sub(2) = subplot(2,1,2);
hold on
semilogx(freq_out_real, phase_tf_real, 'LineWidth', 2.0, 'Color', data_color);
semilogx(freq_out_resim, phase_tf_resim, 'LineWidth', 1.5, 'Color', simulation_color);
plot(freq_vector, phase_bode_ref, 'LineWidth', 1.5, 'Color', reference_color);
hold off
xlim([freq_min, freq_max]);
xlabel('Frequency [rad/s]');
ylabel('Phase [deg]');

tmp = get(sub(1), 'Position');
left_pos = tmp(1);
top_pos = tmp(2);
width = tmp(3);
height = tmp(4);
spacing = 0.025;
set(sub(2), 'Position', [left_pos, top_pos-height-spacing, width, height]);
linkaxes(sub, 'x');


title_label = "Bode_" + string(strrep(filename_real, ".mat", ""));
% saveas(f(1), fullfile(paths.report_images_folder, title_label + ".png"));

save(fullfile(path, filename_resim), '-append', 'freq_out_real', 'magn_tf_real', ...
    'freq_out_resim', 'magn_tf_resim', 'freq_vector', 'magn_bode_ref', 'freq_out_real', 'phase_tf_real', ...
    'freq_out_resim', 'phase_tf_resim', 'freq_vector', 'phase_bode_ref', 'freq_min', 'freq_max');

