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
nlearn = 0.5*N*kd;

P = groupnet(source, 1);
T = groupnet(target, 1);

net = newfftd(P(1:nlearn), T(1:nlearn), [0:npack-1], 4);
net = train(net, P(1:nlearn), T(1:nlearn));

%load ask_1000_50 ask_w
%net.IW = ask_w{1};
%net.LW = ask_w{2};
%net.b = ask_w{3};

Y = sim(net, P(desync*kd + 1:end));
Y = ([Y{:}]);

%% 2) Обучаем сеть выделять сигнал
source = Y;
target = sig; 

P2 = groupnet(source, 1);
T2 = groupnet(target, 1);

net2 = newff(P2(1:nlearn), T2(1:nlearn), 4);
net2 = train(net2, P2(1:nlearn), T2(1:nlearn));

%net2.IW = ask_w{4};
%net2.LW = ask_w{5};
%net2.b = ask_w{6};

simres = sim(net2, P2(desync*kd + 1:end));
simres = round([simres{:}]);

%% Выход персептонной сети подаем на вход сети Кохонена

num_in = 4%0.25 * kd; % 0.25 от количиства отсчетов на символ
coh_in = groupnet(Y, num_in);
%coh_in = Y;
netc = newc(coh_in(1:nlearn), 2); 
%netc.inputWeights{1}.delays = [0:npack-1];
%for i = 1:5
%    [netc, out, e] = adapt(netc, coh_in(1:nlearn));
%    i
%end
netc = train(netc, coh_in(1:nlearn));
iw = netc.IW;

% Создаем новую сеть
%coh_in = Y;
%netc = newc([0 2], 2, 0.01, 0.001); % 2 нейрона
%netc.inputWeights{1}.delays = [0:num_in-1];
%netc.IW = iw;

%netc.IW = ask_w{4};
%netc.LW = ask_w{5};
%netc.b = ask_w{6};

onet = sim(netc, coh_in(desync*kd + 1:end));
simres = koh2vec(onet, num_in, numel(Y(desync*kd + 1:end)));
%simres = vec2ind(onet) - 1;
%

%err = symerr(target, simres)

target_desync = target(desync*kd + 1:end);
simres = simres(desync*kd + 1:end);
Y = Y(desync*kd + 1:end);

%% Построение графиков
figure
scale = 5000;

%simres(find(simres>1)) = 1;
%simres(find(simres < 0)) = 0;

%[b, a] = butter(5, 10*rate/Fs);
%simres = round(filtfilt(b, a, simres));

subplot(4, 1, 1)
plot(noise(1:scale));
title('FILT output');
axis([0 scale-1 min(noise)-0.2 max(noise) + 0.2]);

subplot(4, 1, 2)
plot(Y(1:scale));
title('TDNN output');
axis([0 scale-1 min(Y)-0.2 max(Y) + 0.2]);

subplot(4, 1, 3)
plot(simres(1:scale));
axis([0 scale-1 min(simres)-0.2 max(simres) + 0.2]);
title('END output');

subplot(4, 1, 4)
plot(target(1:scale));
axis([0 scale-1 min(target)-0.2 max(target) + 0.2]);
title('TARGET output');

%% Проверяем работу сети на N новых символах
st = round(rand(1, N));
sigt = repmat(st, kd, 1);
sigt = sigt(:)';

snr = 20;
source = awgn(mainsig, snr, 'measured');

Pt = groupnet(source, 1);
Yt = sim(net, Pt(desync*kd + 1:end));
Yt = ([Yt{:}]);

source = Yt;

Pt2 = groupnet(source, 1);
simrest = sim(net2, Pt2(desync*kd + 1:end));
simrest = round([simrest{:}]);

bit_seq = []
for i = kd/2:kd:numel(simrest)
    bit_seq = [bit_seq simrest(i)];
end

%bit_seq = decnrz(simres, kd);

numel(bit_seq)
err = symerr(st, bit_seq)/N

%% SAVE net parameters

net_iw = net.IW;
net_lw = net.LW;
net_b = net.b;
net2_iw = net2.IW;
net2_lw = net2.LW;
net2_b = net2.b;

ask_w = {net_iw, net_lw, net_b, net2_iw, net2_lw net2_b};
save ask_1000_50 ask_w
