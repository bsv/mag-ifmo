Fs = 100;
t = 0:1/Fs:3;

beta = pi;
Fc = 10;
F = 1;
s = cos(2*pi*Fc*t + beta*sin(2*pi*F*t));
y = hilbert(s);
phi = unwrap(angle(y));
z_pm = phi - 2*pi*Fc*t;
z_fm = diff(phi)*Fs - 2*pi*Fc;
plot(t, z_pm, t(1:end-1), z_fm, '--');
%%

