
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
C_th_int = [1 0 0 0];
A = [A  zeros(4, 1); -C_th_int 0];
B = [B; 0];
C = [1 0 0 0 0;
     0 0 1 0 0];
clearvars -except colors paths A B C;
sys_ct = ss(A, B, C, []);
dt = 2e-3;

%% SYSTEM DISCRETIZATION

sys_dt = c2d(sys_ct, dt);
[F, G, ~, ~, ~] = ssdata(sys_dt);

%% YALMIP OPTIMIZATION

enable_red_cntrl_effort = true;
Tsettling = 4;
csi = 0.0001;

% Algorithm
rho = exp(-5*dt/Tsettling);
phi = acos(csi);

n = size(F, 1);
m = size(G, 2);

yalmip clear;

P = sdpvar(n);
H = sdpvar(n);
S = sdpvar(m,n);

% R11 = -rho^2;
% R12 = 0;
% R22 = 1;
% 
% M11 = sdpvar(size(R11, 1)*n);
% M12 = sdpvar(size(R11, 1)*n);
% M22 = sdpvar(size(R11, 1)*n);
% for i = 1:size(R11, 1)
%     for j = 1:size(R11, 2)
%         M11((i-1)*n+1:i*n, (j-1)*n+1:j*n) = R11(i, j)*P + R12(i ,j)*(F*H+G*S) + R12(j ,i)*(F*H+G*S)';
%         M12((i-1)*n+1:i*n, (j-1)*n+1:j*n) = R12(j ,i)*(P-H') + R22(i, j)*(F*H+G*S);
%         M22((i-1)*n+1:i*n, (j-1)*n+1:j*n) = R22(i, j)*(P-H-H');
%     end
% end
% Mtot = [M11 M12; M12' M22];

x0 = -exp(-pi/tan(phi));
xse = (1 + x0)/2;
t = linspace(0, pi/tan(phi), 1000)';
x_spiral = (exp(-t).*cos(tan(phi)*t))';
y_spiral = (exp(-t).*sin(tan(phi)*t))';
xe = 0.7;
idx = find(x_spiral - xe < 0, 1);
xe = x_spiral(idx);
ye = y_spiral(idx);
ak = (1 - x0)/2;
bk = ye*ak/sqrt (ak^2 - (xe - xse)^2);

% x_ell = xse + ak*cos(0:0.01:2*pi)';
% y_ell = bk*sin(0:0.01:2*pi)';

R11e = [-1 -xse/ak; -xse/ak -1];
R12e = [0 (1/ak-1/bk)/2; (1/ak+1/bk)/2 0];
R22e = zeros(2, 2);

gamma = atan2(ye, 1-xe);
xv = rho;
R11v = [-xv*sin(gamma)*2 0; 0 -xv*sin(gamma)*2];
R12v = [sin(gamma) cos(gamma); -cos(gamma) sin(gamma)];
R22v = zeros(2, 2);

R11 = [R11e zeros(2,2); zeros(2,2) R11v];
R12 = [R12e zeros(2,2); zeros(2,2) R12v];
R22 = [R22e zeros(2,2); zeros(2,2) R22v];

M11 = sdpvar(size(R11, 1)*n);
M12 = sdpvar(size(R11, 1)*n);
M22 = sdpvar(size(R11, 1)*n);
for i = 1:size(R11, 1)
    for j = 1:size(R11, 2)
        M11((i-1)*n+1:i*n, (j-1)*n+1:j*n) = R11(i, j)*P + R12(i ,j)*(F*H+G*S) + R12(j ,i)*(F*H+G*S)';
        M12((i-1)*n+1:i*n, (j-1)*n+1:j*n) = R12(j ,i)*(P-H') + R22(i, j)*(F*H+G*S);
        M22((i-1)*n+1:i*n, (j-1)*n+1:j*n) = R22(i, j)*(P-H-H');
    end
end
Mtot = [M11 M12; M12' M22];

LMIconstr = [Mtot <= -1e-4*eye(2*size(R11, 1)*n)];

ks = sdpvar(1);
kh = sdpvar(1);

if enable_red_cntrl_effort == 1
    LMIconstr = LMIconstr + [ [ks*eye(n), S'; S, eye(m)] >= 1e-8*eye(n+m)];
    LMIconstr = LMIconstr + [ [kh*eye(n), eye(n); eye(n), H] >= 1e-8*eye(2*n)];
end

LMIconstr = LMIconstr + [ks >= 1e-6];
LMIconstr = LMIconstr + [kh >= 1e-6];

options = sdpsettings('solver','sedumi', 'verbose', 1);
J = optimize(LMIconstr, 0.01*ks + 10*kh, options);
feas = J.problem;
feas

P = double(P);
H = double(H);
S = double(S);

K = S/H
eig_DT = eig(F+G*K);

% PLOTS
figure;
initial( ss(F, zeros(size(G)), C, [], dt), [5*pi/180 0 5*pi/180 0 0]');
figure;
initial( ss(F+G*K, zeros(size(G)), C, [], dt), [5*pi/180 0 5*pi/180 0 0]');

%%
x_unit_circle = cos(0:0.01:2*pi)';
y_unit_circle = sin(0:0.01:2*pi)';
% x_lim1 = rho*cos(0:0.01:2*pi)';
% y_lim1 = rho*sin(0:0.01:2*pi)';
% x_lim2 = - alpha +rho2*cos(0:0.01:2*pi)';
% y_lim2 = rho2*sin(0:0.01:2*pi)';

figure;
title('DT poles');
plot(x_unit_circle, y_unit_circle, '--k', 'DisplayName', 'Unit Circle'); hold on; grid on;
% patch(x_lim1, y_lim1, [0.9290 0.6940 0.1250], 'FaceAlpha', 0.3, 'LineStyle', 'none', 'HandleVisibility', 'off'); hold on;
% patch(x_lim2, y_lim2, [0.9290 0.6940 0.1250], 'FaceAlpha', 0.3, 'LineStyle', 'none', 'HandleVisibility', 'off'); hold on;
scatter(real(eig_DT), imag(eig_DT), 'filled', 'MarkerEdgeColor', colors(1), 'MarkerFaceColor', colors(1),...
    'DisplayName', 'CL Poles');
axis equal;
legend;

%%
figure;
title('CT poles');
% x_lim1_ct = real(log(x_lim1 + 1i*y_lim1))/dt;
% y_lim1_ct = imag(log(x_lim1 + 1i*y_lim1))/dt;
% x_lim2_ct = real(log(x_lim2 + 1i*y_lim2))/dt;
% y_lim2_ct = imag(log(x_lim2 + 1i*y_lim2))/dt;
eig_ct = log(eig_DT)/dt;
plot([0 0], [min(imag(eig_ct))-2 max(imag(eig_ct))+2], '--k', 'DisplayName', 'Imag Axis'); hold on; grid on;
% plot(x_lim1_ct, y_lim1_ct, '--', 'Color', [0.9290 0.6940 0.1250], 'DisplayName', 'Constraint 1'); hold on; grid on;
% plot(x_lim2_ct, y_lim2_ct, '--r', 'DisplayName', 'Constraint 2'); hold on; grid on;
scatter(real(eig_ct), imag(eig_ct), 'filled', 'MarkerEdgeColor', colors(1), 'MarkerFaceColor', colors(1),...
    'DisplayName', 'CL Poles');
axis equal;
ylim([min(imag(eig_ct))-2 , max(imag(eig_ct))+2]);
legend

%%
% patch(x_lim1_ct, y_lim1_ct, [0.9290 0.6940 0.1250], 'FaceAlpha', 0.3, 'LineStyle', 'none', 'HandleVisibility', 'off'); hold on;
% patch(x_lim2_ct, y_lim2_ct, [0.9290 0.6940 0.1250], 'FaceAlpha', 0.3, 'LineStyle', 'none', 'HandleVisibility', 'off'); hold on;
% scatter(real(eig_DT), imag(eig_DT), 'filled', 'MarkerEdgeColor', colors(1), 'MarkerFaceColor', colors(1),...
%     'DisplayName', 'CL Poles');
% axis equal;
% legend;

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

%%
% d = tan(acos(0.3));
% R = (-pi/d/dt:0.01:0)';
% I1 = -d*R;
% I2 = d*R;
% R_tot = [R; flip(R)];
% I_tot = [I1; flip(I2)];
% plot(real(exp((R_tot+1i*I_tot)*dt)), imag(exp((R_tot+1i*I_tot)*dt)), 'DisplayName', '0.3');
% 
% d = tan(acos(0.6));
% R = (-pi/d/dt:0.01:0)';
% I1 = -d*R;
% I2 = d*R;
% R_tot = [R; flip(R)];
% I_tot = [I1; flip(I2)];
% plot(real(exp((R_tot+1i*I_tot)*dt)), imag(exp((R_tot+1i*I_tot)*dt)), 'DisplayName', '0.6');
% 
% d = tan(acos(0.8));
% R = (-pi/d/dt:0.01:0)';
% I1 = -d*R;
% I2 = d*R;
% R_tot = [R; flip(R)];
% I_tot = [I1; flip(I2)];
% plot(real(exp((R_tot+1i*I_tot)*dt)), imag(exp((R_tot+1i*I_tot)*dt)), 'DisplayName', '0.8');
% 
% d = tan(acos(0.99));
% R = (-pi/d/dt:0.01:0)';
% I1 = -d*R;
% I2 = d*R;
% R_tot = [R; flip(R)];
% I_tot = [I1; flip(I2)];
% plot(real(exp((R_tot+1i*I_tot)*dt)), imag(exp((R_tot+1i*I_tot)*dt)), 'DisplayName', '0.99');
% legend;