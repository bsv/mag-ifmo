clear all

N = 1000;
s = round(rand(1, N));

Fd = 1; % символьная скорость
Fc = 4; % несущая
FsFd = 40; % количество отсчетов на один символ
Fs = Fd * FsFd; % частота дискретизации

time = (1:N*FsFd)/Fs;

s_psk = cos(2*pi*Fc*time + pi/2*s(ceil(Fd*time)));

scale = 500;

plot(s_psk(1:scale));

%% Демодуляция с помощью нейронной сети

npack = 20;
source = s_psk;
target = repmat(s, round(FsFd/npack), 1);
target = target(:)';
nlearn = 500;

P = groupnet(source, npack);
T = groupnet(target, 1);

net = newff(P(1:nlearn), T(1:nlearn), 4, '', 'traingd');

%for i = 1:100
%    [net, y, e] = adapt(net, P, T);
%    i
%    sumerr = sum([e{:}])
%end

net = train(net, P(1:nlearn), T(1:nlearn));

Y = sim(net, P);

out = round([Y{:}]);

err = symerr(target, out)

subplot(2, 1, 1)
plot(target(1:scale));

subplot(2, 1, 2)
plot(out(1:scale));



