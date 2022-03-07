clear vars


syms l1 l2 real;
syms al th real;
syms al_dot th_dot real;
syms al_ddot th_ddot real;
syms mp mr Lp Lr Jm Jh real;
syms Cth Cal real;
syms tau T Attr real;
syms th_dh th_dh_dot th_dh_ddot c g G C real;

L1 = Lr;
L2 = Lp;


Q = [th_dh al]';
Q_dot = [th_dh_dot al_dot]';
Q_ddot = [th_dh_ddot al_ddot]';
s1 = simplify(sin(Q(1)));
c1 = simplify(cos(Q(1)));
s2 = sin(Q(2));
c2 = cos(Q(2));

O = [0 0 0]';
z0 = [0 0 1]';
z1 = [-c1 s1 0]';
Pl1 = [-l1*s1 l1*c1 0]';
P1 = [-L1*s1 L1*c1 0]';
Pl2 = [-L1*s1-l2*c1*s2 L1*c1-l2*s1*s2 -l2*c2]';

J0_l1 = [z0 O];
J0_l2 = [z0 z1];
Jp_l1 = [cross(z0, Pl1) O];
Jp_l2 = [cross(z0, Pl2) cross(z1, Pl2-P1)];
Jp_l2 = simplify(Jp_l2, 10);

I1 = mr*L1^2/12 + Jm + Jh;
I2 = mp*L2^2/12;

B = simplify(mr*(Jp_l1')*Jp_l1 + I1*(J0_l1')*J0_l1 +mp*(Jp_l2')*Jp_l2 + I2*(J0_l2')*J0_l2, 100);


% c(i,j,k) = (diff(B(i,j),Q(k)) + diff(B(i,k),Q(j)) - diff(B(j,k),Q(i)))/2;

%c symbles, 2d matrix:
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

G = [0 -mp*(g0'*Jp_l2(:,2))]';

Attr = [Cth Cal]'.*Q_dot;

T = simplify(B*Q_ddot + C*Q_dot + G + Attr, 1000);

%tau=T(1)









