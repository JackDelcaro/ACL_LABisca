clearvars;
close all;

%% PID poles and zeros

syms P N D I
syms mu
syms s
syms wc
syms cut_zero_ratio
syms pole_cut_ratio

P_contr = P;
I_contr = I / s;
D_contr = D * N * s / (s + N);

tot_contr = P_contr + I_contr + D_contr;

[num, den] = numden(tot_contr);

poles_eqn = den == 0;
zeros_eqn = num == 0;

poles = solve(poles_eqn, s);
zeros = solve(zeros_eqn, s);

%% Loop shaping

fast_pole_eqn = subs(den, s, -wc*pole_cut_ratio) == 0;
N = solve(fast_pole_eqn, N);

gain_eqn = I * mu == wc^3/cut_zero_ratio^2;
I = solve(gain_eqn, I);

zeros = subs(zeros);
slow_zeros_eqns = zeros == [-wc / cut_zero_ratio; -wc / cut_zero_ratio];
[P, D] = solve(slow_zeros_eqns, [P; D]);

disp(N);
disp(P);
disp(I);
disp(D);

%% Write transfer function part 1 - Display transfer function

wc = 20;
mu = 12.29;
cut_zero_ratio = 100;
pole_cut_ratio = 10;

N = subs(N);
I = subs(I);
P = subs(P);
D = subs(D);

num = subs(num);
den = subs(den);

disp(num);
disp(den);

%% Write transfer function part 2 - Write the TF given the displayed values

s = tf('s');

R = (4000 * s^2 + 1600*s + 160) / 12.29 / (s * (s + 200));  % Substitute the values
                                                            % you see on the
                                                            % display
                                                     
%% Check the results                                                     
                                                     
G = mu / s^2;

L = R * G;
                                                     
zero(L)
pole(L)