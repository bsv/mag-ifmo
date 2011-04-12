clear all

N = 500;
%s = round(rand(1, N));
s = repmat([0; 1], N/2, 1);
s = s(:)';

Fc = 1000; % несущая
Fs = 4 * Fc; % частота дискретизации

rate = 50;
kd = round(Fc/rate); % количество отсчетов за символ
sig = repmat(s, kd, 1);
sig = sig(:)';

%time = (1:N*FsFd)/Fs;
m = 0.65; % коэффициент модуляции

%ssk = cos(2*pi*Fc*time + pi/2*s(ceil(Fd*time))); % фазовая модуляция
spsk = modulate(sig, Fc, Fs, 'pm', m) + 1; % фазовая модуляция
sfsk = modulate(sig, Fc, Fs, 'fm', m) + 1; % частотная модуляция
sask = modulate(sig, Fc, Fs, 'amdsb-tc', m) + 1; % амплитудная модуляция

scale = 1000;

subplot(4, 1, 1);
plot(sask(1:scale));
title('Amplitude');

subplot(4, 1, 2);
plot(spsk(1:scale));
title('Phase');

subplot(4, 1, 3);
plot(sfsk(1:scale));
title('Freq');

subplot(4, 1, 4)
plot(sig(1:scale));
axis([0, scale-1, -0.2, 1.2]);
title('Source')

%% Демодуляция с помощью нейронной сети

% q_ask16
%qsk_init
%source = s_qask16;
%target = repmat(aa, FsFd, 1);
%target = target(:)';
%

desync = 0; % коэффициент рассинхронизации в пределах одного битового 
              % интервала
              
% 1) Обучаем сеть давить помехи
npack = 2*kd;
snr = 10;

mainsig = sask;
noise =  awgn(mainsig, snr, 'measured'); 
source = noise;
target = sig;
nlearn = 0.1*N*kd;

P = groupnet(source, 1);
T = groupnet(target, 1);

net = newfftd(P(1:nlearn), T(1:nlearn), [0:3], 4);
net = train(net, P(1:nlearn), T(1:nlearn));

Y = sim(net, P(desync*kd + 1:end));
Y = ([Y{:}]);

%% Выход персептонной сети подаем на вход сети Кохонена

num_in = 4;
coh_in = groupnet(Y, num_in);
%coh_in = Y;
netc = newc(coh_in(1:nlearn), 2); 
%netc.inputWeights{1}.delays = [0:npack-1];
%for i = 1:5
%    [netc, out, e] = adapt(netc, coh_in(1:nlearn));
%    i
%end
netc = train(netc, coh_in(1:nlearn));

onet = sim(netc, coh_in(desync*kd + 1:end));
simres = koh2vec(onet, num_in, numel(Y(desync*kd + 1:end)));
%simres = vec2ind(onet) - 1;


%% Оцениваем результат работы сети Кохонена

s = round(rand(1, N));
sig = repmat(s, kd, 1);
sig = sig(:)';

m = 0.65; % коэффициент модуляции

spsk = modulate(sig, Fc, Fs, 'pm', m) + 1; % фазовая модуляция
sfsk = modulate(sig, Fc, Fs, 'fm', m) + 1; % частотная модуляция
sask = modulate(sig, Fc, Fs, 'amdsb-tc', m) + 1; % амплитудная модуляция

mainsig = sask;

scale = 1000;
desync = 0;

snr = 30;
noise =  awgn(mainsig, snr, 'measured');
P = groupnet(noise, 1);
Y = sim(net, P(desync*kd + 1:end));
Y = ([Y{:}]);

coh_in = groupnet(Y, num_in);
onet = sim(netc, coh_in(desync*kd + 1:end));
simres = koh2vec(onet, num_in, numel(Y(desync*kd + 1:end)));

[b, a] = butter(5, 5*rate/Fs);
simres = round(filtfilt(b, a, simres));

simres = [simres zeros(1, desync*kd)];

bit_seq = [];
for i = kd/2 + kd*(1 - desync):kd:numel(simres)
    bit_seq = [bit_seq simres(i)];
end

numel(bit_seq)
err = symerr(s(2:end), bit_seq)/N

subplot(3,1,1);
plot(Y(1:scale));
axis([0 scale-1 min(Y)-0.2 max(Y) + 0.2]);

subplot(3,1,2)
plot(simres(1:scale))
axis([0 scale-1 min(simres)-0.2 max(simres) + 0.2]);

subplot(3,1,3)
plot(sig(1:scale))
axis([0 scale-1 min(sig)-0.2 max(sig) + 0.2]);


%% SAVE net parameters

net_iw = net.IW;
net_lw = net.LW;
net_b = net.b;
net2_iw = net2.IW;
net2_lw = net2.LW;
net2_b = net2.b;

ask_w = {net_iw, net_lw, net_b, net2_iw, net2_lw net2_b};
save ask_1000_50 ask_w
