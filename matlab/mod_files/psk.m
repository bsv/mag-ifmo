clear all

N = 1000;
s = round(rand(1, N));

Fd = 1; % символьная скорость
Fc = 4; % несущая
FsFd = 40; % количество отсчетов на один символ
Fs = Fd * FsFd; % частота дискретизации

time = (1:N*FsFd)/Fs;

s_psk = cos(2*pi*Fc*time + pi/2*s(ceil(Fd*time)));

scale = 500

plot(s_psk(1:scale));

%% Демодуляция с помощью нейронной сети

npack = 20;
source = s_psk;
target = s;
nlearn = 500;

P = {};
for i = 1:npack:numel(s_psk)
    P = [P {source(i:i + npack - 1)'}];
end

T = {};
for i = 1:numel(s)
    T = {T {repmat(target(i), 1, round(FsFd/npack))}};
end


net = newff(P(1:nlearn), T(1:nlearn), 4, '', 'traingd');
net = train(net, P(1:nlearn), T(1:nlearn));

Y = sim(net, P);

Y = [Y{:}];

plot(Y(1:scale));



