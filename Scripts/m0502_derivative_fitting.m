
clc;
clearvars;
clear polynomial_fit;
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
paths.sim_log_folder        = fullfile(string(paths.sim_folder), "Log");
paths.sim_data_folder       = fullfile(string(paths.sim_folder), "Data");
addpath(genpath(paths.file_path     ));
addpath(genpath(paths.data_folder   ));
addpath(genpath(paths.scripts_folder));
addpath(genpath(paths.sim_folder    ));

%% SETTINGS

run('graphics_options.m');

%% SIMULATION PARAMETERS

% dataset_name = '20220321_1748_ol_full_pendulum_swing_90';
dataset_name = '20220314_1650_sinesweep_0p75V_exp07';
% dataset_name = '20220314_1640_varin_exp07_cut_ramps';
% dataset_name = '20220314_1640_varin_exp07_cut_squarewaves_ramps';
dataset = load(dataset_name);
run('m0405_fmincon_sim_init');

dt_dataset = mean(diff(dataset.time));

tmp = sgolayfilt(dataset.theta, 1, 51);
dataset.theta_filtered = sgolayfilt(tmp, 1, 25);

tmp = sgolayfilt(dataset.alpha, 1, 51);
dataset.alpha_filtered = sgolayfilt(tmp, 1, 25);

dataset.theta_dot = gradient(dataset.theta_filtered, dataset.time);
dataset.alpha_dot = gradient(dataset.alpha_filtered, dataset.time);

%% FITTING FUNCTION

figure;
plot(dataset.time, dataset.alpha); hold on; grid on;

window_size = 51;
order = 1;
powers = order:-1:0;
alpha_reconstr = nan(size(dataset.time));
for i = 1:length(dataset.time)-window_size
    time_short = dataset.time(i:i+window_size);
    alpha_short = dataset.alpha(i:i+window_size);
    coeffs = polynomial_fit(time_short,alpha_short,order,0.95);
    
    center_idx = floor(length(time_short)/2);
    time_tmp = time_short - time_short(center_idx);
    alpha_reconstr_short = (repmat(time_tmp, 1, length(coeffs)).^repmat(powers, length(alpha_short), 1))*coeffs;
    alpha_reconstr_short = alpha_reconstr_short + alpha_short(center_idx);
    
%     plot(time_short, alpha_reconstr_short);
%     drawnow;
    alpha_reconstr(i+window_size) = alpha_reconstr_short(end);
end

clear polynomial_fit;
window_size = 25;
order = 1;
alpha_reconstr2 = nan(size(dataset.time));
for i = 1:length(dataset.time)-window_size
    time_short = dataset.time(i:i+window_size);
    alpha_short = alpha_reconstr(i:i+window_size);
    coeffs = polynomial_fit(time_short,alpha_short,order,1);
    
    center_idx = floor(length(time_short)/2);
    time_tmp = time_short - time_short(center_idx);
    alpha_reconstr_short = (repmat(time_tmp, 1, length(coeffs)).^repmat(powers, length(alpha_short), 1))*coeffs;
    alpha_reconstr_short = alpha_reconstr_short + alpha_short(center_idx);
    
%     plot(time_short, alpha_reconstr_short);
%     drawnow;
    alpha_reconstr2(i+window_size) = alpha_reconstr_short(end);
end


plot(dataset.time, alpha_reconstr);
plot(dataset.time, alpha_reconstr2);

figure;
plot(dataset.time, dataset.alpha_dot); hold on; grid on;
plot(dataset.time, gradient(alpha_reconstr, dataset.time));
plot(dataset.time, gradient(alpha_reconstr2, dataset.time));


