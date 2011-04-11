clear all % очищаем все переменные
close all % закрываем все графики

N = 1000;
aa = randint(1, N, 4);
bb = randint(1, N, 4);
a1 = 2*aa-3;
b1 = 2*bb-3;
Fd = 2400; % символьная скорость
Fc = 1800; % несущая частота
FsFd = 4; % число отсчетов на один символ
Fs = Fd * FsFd; % частота дискретизации

% дублируем каждый отсчет
a1 = repmat(a1, FsFd, 1);
a1 = a1(:)';
b1 = repmat(b1, FsFd, 1);
b1 = b1(:)';

% формируем аналоговый сигнал
t = (0:N*FsFd-1)/Fs;
%t = t';
s_qask16 = a1 .* cos(2*pi*Fc*t) + b1 .* sin(2*pi*Fc*t);
figure
plot(t(1:100), s_qask16(1:100))

%%  Демодуляция сигнала

% добавляем шуму
%snr = 2; % сигнал/шум
%noise = awgn(s_qask16, snr, 'measured');
%figure
%plot(t(1:100), noise(1:100))

% Демодуляция с использованием комплексных чисел

y = s_qask16 .* exp(j*2*pi*Fc*t) * 2;

[b, a] = butter(2, Fd*2/Fs);
fy = filtfilt(b, a, y);

z = fy(3:FsFd:end);

figure
plot(z, '.')
axis square

a2 = round((real(z)+3)/2);
a2(find(a2<0)) = 0;
a2(find(a2>3)) = 3;
b2 = round((imag(z)+3)/2);
b2(find(b2<0)) = 0;
b2(find(b2>3)) = 3;
ea2 = symerr(aa, a2)
eb2 = symerr(bb, b2)

% Пример выделения одной компоненты (вычисления с помощью тригонометрии)
ycos = s_qask16 .* cos(2*pi*Fc*t)*2;
testcos = s_qask16 .* cos(t);

fycos = filtfilt(b, a, ycos);
fycos2 = fycos(3:FsFd:end);
a3 = round((fycos2+3)/2);
a3(find(a3<0)) = 0;
a3(find(a3>3)) = 3;
ea3 = symerr(aa, a3)

%% Демодуляция с помощью нейронной сети


% Аппроксимация операции умножения на опорное колебание
num_in = 1;
num_delay = 1;
num_out = 1;
num_neuron = 10;
num_layers = 2;
num_sample = 1000;

sample = s_qask16;
target = 2*pi*t;

x = groupnet(sample, num_in);
test = groupnet(target, num_out);

% Классическая сеть
net = newff(x(1:num_sample), test(1:num_sample), [num_neuron], {}, 'traingda');
net.divideFcn = '';
net.trainParam.epochs = 1000;
%net.inputWeights{1}.delays = (0:num_delay);

net = init(net);
net = train(net, x(1:num_sample), test(1:num_sample));
%

out_net = sim(net, x);

out_net = [out_net{1,:}];

eout = symerr(target, out_net)

