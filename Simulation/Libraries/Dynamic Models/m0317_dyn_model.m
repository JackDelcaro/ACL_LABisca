%% syms for days

syms l1 l2 real;
syms mp mr Lp Lr Jm Jh real;
syms Cth Cal real;
syms g real;  

model_PARAMS.mp = mp;
model_PARAMS.mr = mr;
model_PARAMS.Lp = Lp;
model_PARAMS.Lr = Lr;
model_PARAMS.Jm = Jm;
model_PARAMS.Jh = Jh;
model_PARAMS.Cth = Cth;
model_PARAMS.Cal = Cal;
model_PARAMS.g = g;

%% var definition
%L1 = Lr;
%L2 = Lp;
l1 = Lr/2;   %comment these for generic values
l2 = Lp/2;   %

s1 = simplify(sin(q(1)));
c1 = simplify(cos(q(1)));
s2 = sin(q(2));
c2 = cos(q(2));

%% axes and points

O = [0 0 0]';
z0 = [0 0 1]';
z1 = [-s1 c1 0]';
Pl1 = [-l1*s1 l1*c1 0]';
P1 = [-Lr*s1 Lr*c1 0]';
Pl2 = [-Lr*s1-l2*c1*s2 Lr*c1-l2*s1*s2 -l2*c2]';

%% Ai

R01 = [c1 0 -s1;
       s1 0 c1;
       0 -1 0];
R12 = [c2 0 -s2;
       s2 0 c2;
       0 -1 0];
   
R02 = R01*R12;




%% Jacobians

J0_l1 = [z0 O];
J0_l2 = [z0 z1];
Jp_l1 = [cross(z0, Pl1) O];
Jp_l2 = [cross(z0, Pl2) cross(z1, Pl2-P1)];
Jp_l2 = simplify(Jp_l2, 10);

Ir = mr*Lr^2/12;  %add Jh Jm
Ip = mp*Lp^2/12;

Ir_big = diag([Ir,Ir+Jh+Jm,0]);
Ip_big = diag([Ip,Ip,0]);

%% matrixes

%B = simplify(m1*(Jp_l1')*Jp_l1 + I1*(J0_l1')*J0_l1 + m2*(Jp_l2')*Jp_l2 + I2*(J0_l2')*J0_l2, 100);
B = simplify(mr*(Jp_l1')*Jp_l1 + (J0_l1')*R01*Ir_big*R01'*J0_l1 + mp*(Jp_l2')*Jp_l2 + (J0_l2')*R02*Ip_big*R02'*J0_l2, 100);

%c(i,j,k) = (diff(B(i,j),Q(k)) + diff(B(i,k),Q(j)) - diff(B(j,k),Q(i)))/2;
%c symbols, 2d matrix:(for some reason it didn't work with 3d matrixes)
%|1  2|
%|3  4|
%

for i=1:2
    for j=1:2 
        for k=1:2
            C(j,k, i) = simplify((diff(B(i,j),q(k)) + diff(B(i,k),q(j)) - diff(B(j,k),q(i)))/2, 10);
        end
    end
end

g0=[0 0 -g]';

G = [0 -mp*(g0'*Jp_l2(:,2))]';

%% other forces

R = [Cth 0; 0 Cal];










