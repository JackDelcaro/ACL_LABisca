dt_control = 2e-3;

PARAMS.angle_quantization = 0.00307;

% Setup par
PARAMS.th_0_cable = 0;
PARAMS.th_0 = 0/180*pi;
PARAMS.th_dot_0 = 0;
PARAMS.al_0 = 0*175/180*pi;
PARAMS.al_dot_0 = 0;
PARAMS.g = 9.81;

% Mechanical Parameters
PARAMS.Lp_offset = 0.85e-2;
PARAMS.mp = 2.4e-2;
PARAMS.Lp = 1.29e-1 - PARAMS.Lp_offset;
PARAMS.mr = 9.5e-2;
PARAMS.Lr = 8.5e-2;
PARAMS.Jm = 4e-6;
PARAMS.l2 = (PARAMS.Lp/2 - PARAMS.Lp_offset);
PARAMS.l1 = 0.5117*PARAMS.Lr/2;
PARAMS.Jh = (8.009e-6 - PARAMS.Jm); % official inertia 6e-7
PARAMS.Cal = 2*6.494e-6;
PARAMS.Cth = 0.94*3.660e-4;

% PARAMS.Lp_offset = 0.85e-2;
% PARAMS.mp = 2.4e-2*1.14;
% PARAMS.Lp = 1.29e-1 - PARAMS.Lp_offset;
% PARAMS.mr = 9.5e-2*.82;
% PARAMS.Lr = 8.5e-2;
% PARAMS.Jm = 4e-6;
% PARAMS.l2 = (PARAMS.Lp/2 - PARAMS.Lp_offset)*0.87;
% PARAMS.l1 = 0.5117*PARAMS.Lr/2*1.38;
% PARAMS.Jh = (8.009e-6 - PARAMS.Jm); % official inertia 6e-7
% PARAMS.Cal = 2*6.494e-6*0.58;
% PARAMS.Cth = 0.94*3.660e-4*0.52;


% PARAMS.K = 2.215e-3*0.7;
% PARAMS.Sth = 8.2209e-04;  % static friction
% PARAMS.Dth = 0.85*PARAMS.Sth; % dynamic friction
PARAMS.K = 2.215e-3;
PARAMS.Sth = 7.9e-4;  % static friction
PARAMS.Dth = 0.85*PARAMS.Sth; % dynamic friction
PARAMS.Sth_vel_threshold = 1e-8;
PARAMS.tau_nom = 22e-3;

% Electrical Parameters
PARAMS.Lm = 1.16e-3;
PARAMS.Rm = 8.4;
PARAMS.ki = 0.042;
PARAMS.kv = 0.042;
PARAMS.Dm = 0;
PARAMS.n = 1;
PARAMS.V_sat = 10;

% Loop Parameters

PARAMS.mu_V_theta_dot = PARAMS.ki /((PARAMS.mp + PARAMS.mr/3) * PARAMS.Lr^2 + ...
                                     + PARAMS.Jm + PARAMS.Jh) / PARAMS.Rm;
PARAMS.mu_V_theta_dot_new = PARAMS.ki /((PARAMS.mp + PARAMS.mr/12) * PARAMS.Lr^2 + ...
                                     + PARAMS.mr*PARAMS.l1^2 + PARAMS.Jm + PARAMS.Jh) / PARAMS.Rm;
                                 
PARAMS.A_pi_CT = [0       1       0        0;
                  -7.9065 -2.056  53.5758  -0.027;
                  0       0       0        1;
                  -9.1936 -2.3907 196.4972 -0.0989];          
PARAMS.B_pi_CT = [0; 17.8475; 0; 20.753];
PARAMS.A_0_CT = [0       1       0         0;
                 -7.9065 -2.056  53.5758   0.027;
                 0       0       0         1;
                 9.1936  2.3907  -196.4972 -0.0989]; 
PARAMS.B_0_CT = [0; 17.8475; 0; -20.753];
PARAMS.C = eye(4);
PARAMS.D = zeros(4, 1);

sys_pi_CT = ss(PARAMS.A_pi_CT, PARAMS.B_pi_CT, PARAMS.C, PARAMS.D);
sys_0_CT = ss(PARAMS.A_0_CT, PARAMS.B_0_CT, PARAMS.C, PARAMS.D);
sys_pi_DT = c2d(sys_pi_CT, dt_control);
sys_0_DT = c2d(sys_0_CT, dt_control);

PARAMS.A_pi_DT = sys_pi_DT.A;          
PARAMS.B_pi_DT = sys_pi_DT.B;
PARAMS.A_0_DT = sys_0_DT.A; 
PARAMS.B_0_DT = sys_0_DT.B;

PARAMS.A_DT = PARAMS.A_pi_DT;
PARAMS.B_DT = PARAMS.B_pi_DT;

% Tsettling = 2; csi = 0.0001; red_contr; LMIs DT new paper m0325_K_al_th
PARAMS.K_pp_al_th_pi_2 = [4.1265    1.8863  -44.4296   -3.3301];
% Tsettling = 1.5; csi = 0.65; red_contr; LMIs CT (filter up to 15 hz is
% fine)
PARAMS.K_pp_al_th_pi_3 = [4.1265    1.8863  -44.4296   -3.3301];
% Tsettling = 5/7; csi = 0.65; red_contr; LMIs CT
PARAMS.K_pp_al_th_pi_4 = [20.048    5.5215  -88.2768   -7.3710];
% Tsettling = 2; csi = 0.65; red_contr; LMIs CT
PARAMS.K_pp_al_th_pi_5 = [2.4575    1.3584  -39.3144   -3.0921];
% Tsettling = 5/7; csi = 0.65; red_contr; LMIs CT
PARAMS.K_pp_al_th_0_0 = [-19.432    -4.8652  34.1206   -1.5614];
% Tsettling = 1.5; csi = 0.65; red_contr; LMIs CT
PARAMS.K_pp_al_th_0_2 = [-2.9639 -1.0897 12.9853 0.6530];
% Tsettling = 1.5; csi = 0.65; red_contr; LMIs CT
PARAMS.K_pp_al_th_0_int_1 = [-9.3798 -2.2442  20.0627 0.0519 15.6933];
% Tsettling = 1.5; csi = 0.65; red_contr; LMIs CT; Same as 0_int_1 int gain
% halved
PARAMS.K_pp_al_th_0_int_2 = [-9.3798 -2.2442  20.0627 0.0519 7];
% Tsettling = 5/7; csi = 0.65; red_contr; LMIs CT; State gain same as 0_1
% int gain same as 0_int_2
PARAMS.K_pp_al_th_0_int_3 = [-19.432    -4.8652  34.1206   -1.5614 7];
% PAOLOOOOOO CHE PARAMETRI SONO?
PARAMS.K_pp_al_th_pi_int_1 = [11.1394 2.6857 -39.5275 -3.1135 -18.4929];
% PAOLOOOOOO METTI QUI IL FILTRO NUMERO 2 TESTATO IN LAB
% PARAMS.K_pp_al_th_pi_int_2;
% Tsettling = 1.5; csi = 0.65; red_contr; LMIs CT
PARAMS.K_pp_al_th_pi_int_3 = [15.2679    4.0205  -71.4237   -5.4872  -24.2209];
% Tsettling = 2; csi = 0.65; red_contr; LMIs CT
PARAMS.K_pp_al_th_pi_int_4 = [8.9949    2.8354  -57.2486   -4.3455  -11.6041];
% Tsettling = 4; csi = 0.0001; red_contr; LMIs DT
PARAMS.K_pp_al_th_pi_int_5 = [16.6630    5.7182  -98.9577   -7.7006  -15.2651]; % does not work, inputs are too high
% Tsettling = 15; csi = 0.0001; red_contr; LMIs DT
PARAMS.K_pp_al_th_pi_int_6 = [3.9670    2.3061  -61.6491   -4.5726   -1.6836];
% same as K_pp_al_th_pi_int_3 and int tuned separately
PARAMS.K_pp_al_th_pi_int_7 = [15.2679    4.0205  -71.4237   -5.4872  -7];
% Tsettling = 3; csi = 0.65; red_contr; LMIs CT
PARAMS.K_pp_al_th_pi_int_8 = [4.5802 1.8764 -46.2492 -3.6911 -4.3971];
% Tsettling = 2; csi = 0.65; red_contr; LMIs CT and int tuned separately
PARAMS.K_pp_al_th_pi_int_9 = [9.2218 2.9433 -60.5912 -4.9199 -7];


%LQ
%Q = diag([1 0.01 1 0.01]) R = 1; [K, S, CLP] = dlqr(1.01*F, 1.01*G, Q, R, N);
PARAMS.K_LQ_down1 = -[11.0652    2.9103  -16.3115    0.7839];
%Q = diag([1 0.01 1 0.01]) R = 10; T_settling = 5/7;
PARAMS.K_LQ_down2 = -[28.8076    6.2177  -27.3012    2.8533];
%Q = diag([1 0.01 1 0.01]) R = 10; T_settling = 1.5; higher R or lower
%Q_vel don't change result;
PARAMS.K_LQ_down3 = -[3.7083    1.3043   -7.7097    0.0341];
%Q = diag([1 1 1 1]) R = 10; T_settling = 1.5;
PARAMS.K_LQ_down4 = -[5.1799    1.7065  -11.0265    0.1152];

%Q = diag([1 0.01 1 0.01]) R = 1; [K, S, CLP] = dlqr(1.01*F, 1.01*G, Q, R, N);
PARAMS.K_LQ_up1 = -[3.7083    1.3043   -7.7097    0.0341];
%Tsettling=1.5 Q = diag([1 0.01 1 0.01]) R = 10; [K, S, CLP] = dlqr(1.01*F, 1.01*G, Q, R, N);
PARAMS.K_LQ_up2 = -[-5.4742    -2.1787   50.0101    4.0182];
%Tsettling=2 Q = diag([1 0.01 1 0.01]) R = 10;
PARAMS.K_LQ_up3 = -[-3.2114   -1.4433   40.0155    3.1511];

% LQ int
% Tsettling = 2; Q = diag([0.1 0.01 1 0.01 0.1]); R = 1;
PARAMS.K_LQ_int_down1 = -[6.6748    1.4382   -5.1058    0.1867  -11.9854];
% Tsettling = 1.5; Q = diag([1 0.01 1 0.01 0.1]); R = 1;
PARAMS.K_LQ_int_down2 = -[14.7467    2.4421   -7.4821    0.6436  -32.6271];
% Tsettling = 1.5; Q = diag([1 0.01 1 0.01 0.1]); R = 10;
PARAMS.K_LQ_int_down3 = -[12.8100    2.2404   -7.2298    0.5428  -26.8886];
% Tsettling = 1.5; Q = diag([1 0.01 1000 0.01 0.1]); R = 10;
PARAMS.K_LQ_int_down4 = -[20.3440    3.5740  -14.4428    1.2646  -41.0934];
% Tsettling = 1.5; Q = diag([1 0.01 1 0.01 0.001]); R = 10;
PARAMS.K_LQ_int_down5 = -[13.1717    2.2966   -7.4566    0.5662  -27.6754];
% Tsettling = 5/7; Q = diag([1 0.01 1 0.01 0.001]); R = 10;
PARAMS.K_LQ_int_down6 = -[117.4679   10.6780   12.8370    6.0146 -409.5086];
% same as K_LQ_down2 and int tuned separately
PARAMS.K_LQ_int_down7 = [PARAMS.K_LQ_down2 13];
% same as K_LQ_int_down5 and int tuned separately
PARAMS.K_LQ_int_down8 = -[13.1717    2.2966   -7.4566    0.5662  -13];

% Tsettling = 2; Q = diag([0.1 0.01 1 0.01 0.1]); R = 1;
PARAMS.K_LQ_int_up1 = -[-9.8980   -2.7541   55.3324    4.4881   14.0087];
% Tsettling = 1.5; Q = diag([1 0.01 1 0.01 0.0001]); R = 10;
PARAMS.K_LQ_int_up2 = -[-19.2311 -4.5206 76.9661 6.3535 33.5411];
% same as K_LQ_int_up2 and int tuned separately
PARAMS.K_LQ_int_up3 = -[-19.2311 -4.5206 76.9661 6.3535 7];
% Tsettling = 3; Q = diag([1 0.01 1 0.01 0.0001]); R = 10;
PARAMS.K_LQ_int_up4 = -[-4.4341 -1.5359 40.0969 3.1656 4.7109];
% Tsettling = 2; Q = diag([1 0.01 1 0.01 0.0001]); R = 10;
PARAMS.K_LQ_int_up5 = -[-9.8519 -2.7667 55.8715 4.5301 7];

PARAMS.K_pp_state = PARAMS.K_LQ_int_up3(1:4);
PARAMS.K_pp_th_int = PARAMS.K_LQ_int_up3(5);


% KF
PARAMS.Q_pi1 = [50 0   0  0;
                0  0.9 0  0;
                0  0   50 0;
                0  0   0  0.9];
            
PARAMS.R_pi1 = [2e-2 0;
                0    2e-2];
            
PARAMS.L1_KF = [0.0023 0.0001 0.0042 0.0006;
                0.0137 0.0020 0.0592 0.0080;
                0.0042 0.0006 0.0181 0.0025;
                0.0555 0.0080 0.2460 0.0335];
            
PARAMS.Q_KF = PARAMS.Q_pi1;
PARAMS.R_KF = PARAMS.R_pi1;

%% OVERWRITE PARAMETERS

PARAMS.polyfit.order = 2;
PARAMS.polyfit.window = 120;
PARAMS.polyfit.forgetting_factor = (10^-3)^(1/PARAMS.polyfit.window);
PARAMS.polyfit.center_idx = floor(PARAMS.polyfit.window/2);
PARAMS.polyfit.time = (0:dt_control:(PARAMS.polyfit.window-1)*dt_control)';
PARAMS.polyfit.time = PARAMS.polyfit.time - PARAMS.polyfit.time(PARAMS.polyfit.center_idx);
PARAMS.polyfit.powers = PARAMS.polyfit.order:-1:0;
for j = 1:(PARAMS.polyfit.order+1)
    Reg(:, j) = (PARAMS.polyfit.time.^(PARAMS.polyfit.order - j + 1)) .* (PARAMS.polyfit.forgetting_factor.^((length(PARAMS.polyfit.time)-1):-1:0)');
end
PARAMS.polyfit.pinvR = pinv(Reg);
clearvars Reg;

%% LYAPUNOV
% Dovrebbe fare 3 oscillazioni e salire tenendo theta quasi a 0 (fig 98 2)
% - se lo tira su ma oscilla un po' troppo lontano da pi, aumentare k_th,
% se troppo veloce dimiuirlo (fattore 2.5x)
% - se alpha fa troppe oscillazioni diminuire k_delta, se ne fa troppo
% poche aumentarlo (fattore 5x) (SE FUNZIONA la struct 1 prova
% direttamente con questo)
%(se non funge bene eventualmente aumenta o diminuisci del 10 K_ome)
% bastano 2 gradi di offset per tirarlo su, ma ci vorrÃ  piÃ¹ tempo, tipo 15
% sec, con 80 gradi di offset lo fa in una botta sola
lyapunov_struct(1).k_th = 0.0042435;
lyapunov_struct(1).k_delta = 9.7927e-05;
lyapunov_struct(1).k_ome = 1.0446e-05;

lyapunov_struct(4).k_th = 0.0042435/5;
lyapunov_struct(4).k_delta = 9.7927e-05/2;
lyapunov_struct(4).k_ome = 1.1751e-05;

% Questo Lyapunov controlla poco theta ma lo tira su abbastanza veloce (fig 54 2). Per
% risultati ancora piï¿½ veloci abbassare k_delta (fino a 1/25 del valore
% nominale), attento che tende a spararlo su veloce
% serve min 25 gradi di offset su theta per farlo partire, se non becca al
% secondo swing non lo porterÃ  mai su
lyapunov_struct(2).k_th = 8.4870e-04;
lyapunov_struct(2).k_delta = 1.9586e-05;
lyapunov_struct(2).k_ome = 1.1751e-05;


lyapunov_struct(5).k_th = 8.4870e-04;
lyapunov_struct(5).k_delta = 1.9586e-05*0.75;
lyapunov_struct(5).k_ome = 1.1751e-05;

% Lyapunov tranquillo in circa 7 oscillazioni con theta abbastanza fermo
% (fig 76 1)
% modificare k_ome non cambia molto, abbassandolo fa meno oscillazioni per
% salire
% K_th può scendere fino a 25 volte ma è un filo più lento
% aumentare delta fino a 2.5 crea una risposta ancora più lenta in alpha
% (tipo picchi esponenziali)
% cambiare la reference non cambia molto i risultati (quasi nulla)
lyapunov_struct(3).k_th = 1.6974e-04;
lyapunov_struct(3).k_delta = 2.2034e-04*2;
lyapunov_struct(3).k_ome = 1.0446e-05*0.75;

lypanuov_index = 2;
PARAMS.k_th = lyapunov_struct(lypanuov_index).k_th;
PARAMS.k_delta = lyapunov_struct(lypanuov_index).k_delta;
PARAMS.k_ome = lyapunov_struct(lypanuov_index).k_ome;


%% DERIVATIVE FILTER

s = tf('s');
freq_der_filter = 15;
der_filt = s/(s/(2*pi*freq_der_filter)+1);
[num_der_filter, den_der_filter] = tfdata(c2d(der_filt, dt_control), 'v');

%% FILTER

freq_filter = 15;
filt = 1/(s/(2*pi*freq_filter)+1);
[num_filter, den_filter] = tfdata(c2d(filt, dt_control), 'v');

%% REF FILTER

freq_ref_filter = 3;
ref_filt = 1/(s/(2*pi*freq_ref_filter)+1);
[num_ref_filter, den_ref_filter] = tfdata(c2d(ref_filt, dt_control), 'v');