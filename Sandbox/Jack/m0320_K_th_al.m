
clc;
clearvars;
close all;

%% PATHS

paths.file_fullpath = matlab.desktop.editor.getActiveFilename;
[paths.file_path, ~, ~] = fileparts(paths.file_fullpath);
paths.mainfolder_path   = strsplit(paths.file_path, 'ACL_LABisca');
paths.mainfolder_path   = fullfile(string(paths.mainfolder_path(1)), 'ACL_LABisca');
paths.data_folder       = fullfile(string(paths.mainfolder_path), "Data");
paths.scripts_folder    = fullfile(string(paths.mainfolder_path), "Scripts");
paths.simulation_folder = fullfile(string(paths.mainfolder_path), "Simulation");
paths.jack_folder       = fullfile(string(paths.mainfolder_path), "Sandbox" + filesep + "Jack");
addpath(genpath(paths.file_path        ));
addpath(genpath(paths.data_folder      ));
addpath(genpath(paths.scripts_folder   ));
addpath(genpath(paths.simulation_folder));
addpath(genpath(paths.jack_folder));

%% SETTINGS

run('graphics_options.m');

%% LOAD SYSTEM

run('m0320_sys_model.m');
A = A_sys_V(pi);
B = B_sys_V(pi);
clearvars -except colors paths A B C;
sys_ct = ss(A, B, C, []);
dt = 2e-3;

%% SYSTEM DISCRETIZATION

sys_dt = c2d(sys_ct, dt);
[F, G, H, ~, ~] = ssdata(sys_dt);

%% YALMIP OPTIMIZATION

enable_red_cntrl_effort = true;
Tsettling = 20;
rho = exp(-5*dt/Tsettling);
csi = 0.3;
phi = acos(csi);
alpha = - exp(-phi/tan(phi))*cos(-phi);
rho2 = exp(-phi/tan(phi))*sin(phi);

n = size(F, 1);
m = size(G, 2);

yalmip clear;

P = sdpvar(n);
L = sdpvar(m,n);

kl = sdpvar(1);
kp = sdpvar(1);

LMIconstr = [[rho^2*P-F*P*F'-F*L'*G'-G*L*F' G*L;
                L'*G'                        P] >= 1e-8*eye(n*2)];
LMIconstr = LMIconstr + ...
            [[(rho2^2 - alpha^2)*P-F*P*F'-F*L'*G'-G*L*F'-alpha*(P*F'+L'*G'+G*L+F*P) G*L;
                L'*G'                        P] >= 1e-8*eye(n*2)];

if enable_red_cntrl_effort == 1
    LMIconstr = LMIconstr + [ [kl*eye(n), L'; L, eye(m)] >= 1e-8*eye(n+m)];
    LMIconstr = LMIconstr + [ [kp*eye(n), eye(n); eye(n), P] >= 1e-8*eye(2*n)];
end

LMIconstr = LMIconstr + [kl >= 1e-8];
LMIconstr = LMIconstr + [kp >= 1e-8];

options=sdpsettings('solver','sedumi', 'verbose', 1);
J = optimize(LMIconstr,0.01*kl + 10*kp,options);
feas = J.problem;
feas

L = double(L);
P = double(P);

K = L/P
eig_DT = eig(F+G*K);

%% PLOTS
figure;
initial( ss(F, zeros(size(G)), C, [], dt), [5*pi/180 0 5*pi/180 0]');
figure;
initial( ss(F+G*K, zeros(size(G)), C, [], dt), [5*pi/180 0 5*pi/180 0]');

x_unit_circle = cos(0:0.01:2*pi)';
y_unit_circle = sin(0:0.01:2*pi)';
x_lim1 = rho*cos(0:0.01:2*pi)';
y_lim1 = rho*sin(0:0.01:2*pi)';
x_lim2 = - alpha +rho2*cos(0:0.01:2*pi)';
y_lim2 = rho2*sin(0:0.01:2*pi)';

figure;
title('DT poles');
plot(x_unit_circle, y_unit_circle, '--k', 'DisplayName', 'Unit Circle'); hold on; grid on;
patch(x_lim1, y_lim1, [0.9290 0.6940 0.1250], 'FaceAlpha', 0.3, 'LineStyle', 'none', 'HandleVisibility', 'off'); hold on;
patch(x_lim2, y_lim2, [0.9290 0.6940 0.1250], 'FaceAlpha', 0.3, 'LineStyle', 'none', 'HandleVisibility', 'off'); hold on;
scatter(real(eig_DT), imag(eig_DT), 'filled', 'MarkerEdgeColor', colors(1), 'MarkerFaceColor', colors(1),...
    'DisplayName', 'CL Poles');
axis equal;
legend;

%%
figure;
title('CT poles');
x_lim1_ct = real(log(x_lim1 + 1i*y_lim1))/dt;
y_lim1_ct = imag(log(x_lim1 + 1i*y_lim1))/dt;
x_lim2_ct = real(log(x_lim2 + 1i*y_lim2))/dt;
y_lim2_ct = imag(log(x_lim2 + 1i*y_lim2))/dt;
eig_ct = log(eig_DT)/dt;
plot([0 0], [min(imag(eig_ct))-2 max(imag(eig_ct))+2], '--k', 'DisplayName', 'Imag Axis'); hold on; grid on;
plot(x_lim1_ct, y_lim1_ct, '--', 'Color', [0.9290 0.6940 0.1250], 'DisplayName', 'Constraint 1'); hold on; grid on;
plot(x_lim2_ct, y_lim2_ct, '--r', 'DisplayName', 'Constraint 2'); hold on; grid on;
scatter(real(eig_ct), imag(eig_ct), 'filled', 'MarkerEdgeColor', colors(1), 'MarkerFaceColor', colors(1),...
    'DisplayName', 'CL Poles');
axis equal;
ylim([min(imag(eig_ct))-2 , max(imag(eig_ct))+2]);
legend

%% 
figure;
d = tan(acos(csi));
R = (-pi/d/dt:0.01:0)';
I1 = -d*R;
I2 = d*R;
R_tot = [R; flip(R)];
I_tot = [I1; flip(I2)];
plot(real(exp((R_tot+1i*I_tot)*dt)), imag(exp((R_tot+1i*I_tot)*dt)), 'DisplayName', num2str(csi)); hold on; grid on;
axis equal;

phi = acos(csi);
x_r = exp(-phi/tan(phi))*cos(-phi);
r = exp(-phi/tan(phi))*sin(phi);
x_cir_v = x_r + r*cos(0:0.01:2*pi)';
y_cir_v = r*sin(0:0.01:2*pi)';
plot(x_cir_v, y_cir_v, '--k');
