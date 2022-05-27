clearvars
clc

%% Bode test
freq_min = 0.4; % Hertz
freq_max = 1000;

s = tf('s');
G = 1 / (s/(2*pi*5) + 1);

t = linspace(0, 400, 1000000);
u = chirp(t, freq_min, t(end), freq_max);

y = (lsim(G, u, t))';

input = u;
output = y;

%% FFT
[magn_in, phase_in, freq_in] = my_fft(input, t);
[magn_out, phase_out, freq_out] = my_fft(output, t);
magn_tf = magn_out ./ magn_in;

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
hold off
legend('Input', 'Output');
xlabel('Time [s]');

%Input
figure
subplot(2, 1, 1)
plot(freq_in, magn_in);
title('Input')
ylabel('Amplitude');
grid on
xlim([freq_min, freq_max]);

subplot(2, 1, 2)
plot(freq_in, phase_in);
xlabel('Frequency [Hz]');
ylabel('Phase [degrees]');
grid on
xlim([freq_min, freq_max]);

%Output
figure
subplot(2, 1, 1)
plot(freq_out, magn_out);
title('Output')
ylabel('Amplitude');
grid on
xlim([freq_min, freq_max]);

subplot(2, 1, 2)
plot(freq_out, phase_out);
xlabel('Frequency [Hz]');
ylabel('Phase [degrees]');
grid on
xlim([freq_min, freq_max]);

% TF
figure
subplot(2, 1, 1)
semilogx(freq_out*2*pi, magn_tf);
title('Bode TF');
grid on;
xlim([freq_min, freq_max]);
ylabel('Magnitude [dB]');
subplot(2, 1, 2)
semilogx(freq_out*2*pi, phase_tf);
grid on;
xlim([freq_min, freq_max]);
xlabel('Frequency [rad/s]');
ylabel('Phase [degrees]');

figure
bode(G)
grid on;
title('Bode REAL TF');

% TF magn
figure
semilogx(freq_out*2*pi, magn_tf, 'LineWidth', 1.2);
title('Bode TF');
xlim([freq_min, freq_max]);
ylabel('Magnitude [dB]');
xlabel('Frequency [rad/s]');
grid on;