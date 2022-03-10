clearvars

%% syms for days

syms l1 l2 real;
syms al th th_0 real;
syms al_dot th_dot real;
syms al_ddot th_ddot real;
syms m2 m1 Lp Lr L1 L2 Jm Jh real;
syms Cth Cal real;
syms tau T Attr real;
syms c g G C K real;  

%% var definition
%L1 = Lr;
%L2 = Lp;
l1 = L1/2;   %comment these for generic values
l2 = L2/2;   %

Q = [th al]';
Q_dot = [th_dot al_dot]';
Q_ddot = [th_ddot al_ddot]';
s1 = simplify(sin(Q(1)));
c1 = simplify(cos(Q(1)));
s2 = sin(Q(2));
c2 = cos(Q(2));

%% axes and points

O = [0 0 0]';
z0 = [0 0 1]';
z1 = [-s1 c1 0]';
Pl1 = [-l1*s1 l1*c1 0]';
P1 = [-L1*s1 L1*c1 0]';
Pl2 = [-L1*s1-l2*c1*s2 L1*c1-l2*s1*s2 -l2*c2]';

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

I1 = m1*L1^2/12;  %add Jh Jm
I2 = m2*L2^2/12;

I1_big = diag([I1,I1,0]);
I2_big = diag([I2,I2,0]);

%% matrixes

%B = simplify(m1*(Jp_l1')*Jp_l1 + I1*(J0_l1')*J0_l1 + m2*(Jp_l2')*Jp_l2 + I2*(J0_l2')*J0_l2, 100);
B = simplify(m1*(Jp_l1')*Jp_l1 + (J0_l1')*R01*I1_big*R01'*J0_l1 + m2*(Jp_l2')*Jp_l2 + (J0_l2')*R02*I2_big*R02'*J0_l2, 100);

%c(i,j,k) = (diff(B(i,j),Q(k)) + diff(B(i,k),Q(j)) - diff(B(j,k),Q(i)))/2;
%c symbols, 2d matrix:(for some reason it didn't work with 3d matrixes)
%|1  2|
%|3  4|
%
c(1,1) = (diff(B(1,1),Q(1)) + diff(B(1,1),Q(1)) - diff(B(1,1),Q(1)))/2;
c(1,2) = (diff(B(1,1),Q(2)) + diff(B(1,2),Q(1)) - diff(B(1,2),Q(1)))/2;
c(2,1) = (diff(B(1,2),Q(1)) + diff(B(1,1),Q(2)) - diff(B(2,1),Q(1)))/2;
c(2,2) = (diff(B(1,2),Q(2)) + diff(B(1,2),Q(2)) - diff(B(2,2),Q(1)))/2;
c(3,1) = (diff(B(2,1),Q(1)) + diff(B(2,1),Q(1)) - diff(B(1,1),Q(2)))/2;
c(3,2) = (diff(B(2,1),Q(2)) + diff(B(2,2),Q(1)) - diff(B(1,2),Q(2)))/2;
c(4,1) = (diff(B(2,2),Q(1)) + diff(B(2,1),Q(2)) - diff(B(2,1),Q(2)))/2;
c(4,2) = (diff(B(2,2),Q(2)) + diff(B(2,2),Q(2)) - diff(B(2,2),Q(2)))/2;

C = [c(1,:)*Q_dot c(2,:)*Q_dot;
     c(3,:)*Q_dot c(4,:)*Q_dot];
 
C = simplify(C, 100);

g0=[0 0 -g]';

G = [0 -m2*(g0'*Jp_l2(:,2))]';

%% other forces

Attr = [Cth Cal]'.*Q_dot;

molla = [-K*(th-th_0) 0]'; %th_0 rest angle of the spring

%% ta-da

T = simplify(B*Q_ddot + C*Q_dot + G + Attr + molla, 100);









