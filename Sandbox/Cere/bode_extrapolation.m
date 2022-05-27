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
paths.scripts_folder     = fullfile(string(paths.mainfolder_path), "Scripts");
paths.simulation_folder  = fullfile(string(paths.mainfolder_path), "Simulation");
addpath(genpath(paths.file_path        ));
addpath(genpath(paths.data_folder      ));
addpath(genpath(paths.scripts_folder   ));
addpath(genpath(paths.simulation_folder));

%% SETTINGS
run('graphics_options.m');

%% DATASET SELECTION
[filename, path] = uigetfile(paths.parsed_data_folder);
filename = string(filename)';
Log_data = load(filename);

%% FFT
input = Log_data.theta_ref(1:154858);
output = Log_data.theta(1:154858);
t = Log_data.time(1:154858);

freq_min = 0.4; % rad/s
freq_max = 9;

[magn_in, phase_in, freq_in] = my_fft(input, t);
[magn_out, phase_out, freq_out] = my_fft(output, t);
magn_tf = magn_out ./ magn_in;

freq_in = freq_in *2*pi;
freq_out = freq_out *2*pi;

phase_in = phase_in * 180 / pi;
phase_out = phase_out * 180 / pi;

%dB conversion
magn_tf = 20*log10(magn_tf);
phase_tf = phase_out - phase_in;
phase_tf(phase_tf > 180) = phase_tf(phase_tf > 180) - 360;
phase_tf(phase_tf < -180) = phase_tf(phase_tf < -180) + 360;

%% Plot
figure
hold on
plot(t, input);
plot(t, output);
title('Theta ref vs Theta')
hold off
legend('$\theta_{ref}$', '$\theta$', 'Interpreter', 'latex');
xlabel('Time [s]');

%Input
figure
plot(freq_in, magn_in);
title('FFT $\theta_{ref}$', 'Interpreter', 'latex')
ylabel('Amplitude');
xlabel('Frequency [rad/s]');
grid on
xlim([freq_min, freq_max]);

% subplot(2, 1, 2)
% plot(freq_in, phase_in);
% xlabel('Frequency [Hz]');
% ylabel('Phase [degrees]');
% grid on
% xlim([freq_min, freq_max]);

%Output
figure
plot(freq_out, magn_out);
title('FFT $\theta$', 'Interpreter', 'latex')
ylabel('Amplitude');
xlabel('Frequency [rad/s]');
grid on
xlim([freq_min, freq_max]);

% 
% subplot(2, 1, 2)
% plot(freq_out, phase_out);
% xlabel('Frequency [Hz]');
% ylabel('Phase [degrees]');
% grid on
% xlim([freq_min, freq_max]);

% TF
% figure
% subplot(2, 1, 1)
% semilogx(freq_out*2*pi, magn_tf);
% title('Bode TF');
% grid on;
% xlim([freq_min, freq_max]);
% ylabel('Magnitude [dB]');
% subplot(2, 1, 2)
% semilogx(freq_out*2*pi, phase_tf);
% grid on;
% xlim([freq_min, freq_max]);
% xlabel('Frequency [rad/s]');
% ylabel('Phase [degrees]');
% 
% figure
% bode(G)
% grid on;
% title('Bode REAL TF');

% TF magn
figure
sgtitle("Experiment: " + string(strrep(strrep(filename, ".mat", ""), "_", "\_")));
semilogx(freq_out, magn_tf, 'LineWidth', 1.2);
legend('TF $G_{\theta_{ref} - \theta}$', 'Interpreter', 'latex');
xlim([freq_min, freq_max]);
ylabel('Magnitude [dB]');
xlabel('Frequency [rad/s]');
grid on;