
n=0;
d=0;
frac=1.1;
z=tf('z', 0.002);
N=20;
for i=1:N
    n=n+(1/frac)^(i-1)*z^(-i+1);
    d=d+(1/frac)^(i-1);
end

tran=n/d;
a=cell2mat(tran.Numerator);
b=cell2mat(tran.Denominator);
Anum=a(1:N);
Bden=b(1:N);