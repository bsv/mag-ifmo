clear all % очищаем все переменные
close all % закрываем все графики

fd = 250; % частота дискретизации
fc = 20; % несущая чатота
time = 0:1/fd:20; % шкала времени
code = [0 1 1 0 1]; % передаваемые данные
m = 0.65; % коэффициент модуляции
ac = 1; % амплитуда несущего сигнала

sm = manch(time, code); % преобразуем данные в манчестерский код
sam = ac*(1 + m*sm).*cos(fc*time); % модулируем несущую

subplot(3, 1, 1);
plot(time, sm);
grid on;
axis([min(time) max(time) -2 2]);

subplot(3, 1, 2);
plot(time, sam);
axis([min(time) max(time) -2 2]);
grid on;
%% Демодуляция сигнала методом синхронного детектирования

period = (time(numel(time))-time(1))/numel(code); % период модулирующего сигнала
z = demsync(sam, time, period, fc);
subplot(3, 1, 3);
plot(time,z);

%% Генерция шума 

figure;
snr = 1; % сигнал/шум
noise = awgn(sam, snr);
subplot(2, 1, 1);
plot(time, noise);

z = demsync(noise, time, period, fc);
subplot(2, 1, 2);
plot(time, z);

%% Выделение амплитуды с помощью сети Элмана

%N = 600; % количество обучающих выборок
%smseq = con2seq(sm(1:N)); % преобразуем из последовательности в марицу
%samseq = con2seq(sam(1:N));

%net = newelm(samseq, smseq, 1);
%net = train(net, samseq, smseq);

%a = sim(net, con2seq(sam));

%subplot(2, 1, 1);
%plot(time, cat(2, a{:}), '--');

%subplot(2, 1, 2);
%plot(time, sam);

%% Демодуляция с помощью нейронной сети

num_in = 100;
min_max = minmax(sam);
in_range = [];
in_val = [];

for i = 1:num_in
    in_range = [in_range; min_max];
end

in_val = vec2group(sam, num_in);
noise_val = vec2group(noise, num_in);

net = newc(in_range, 2, 0.1, 0.01); % 2 нейрона
net.trainParam.epochs = 500;
net = init(net);
[net, i1, i2, e] = train(net, in_val);

figure;
plot(1:numel(in_val), e);

figure;
subplot(5, 1, 1);
plot(time, sam);

onet = sim(net, in_val);
simres = koh2vec(onet, num_in);
subplot(5, 1, 2);
plot(time(1:numel(simres)), simres);
axis([min(time) max(time) -2 2]);

subplot(5, 1, 3);
plot(time, noise)

onet = sim(net, noise_val);
noise_res = koh2vec(onet, num_in);
subplot(5, 1, 4);
plot(time(1:numel(noise_res)), noise_res);
axis([min(time) max(time) -2 2]);

subplot(5, 1, 5);
plot(time, sm);
axis([min(time) max(time) -2 2]);

%% Испытаем сеть на других данных
code2 = [0 0 0 0 0 1 1]; % передаваемые данные
sm2 = manch(time, code2); % преобразуем данные в манчестерский код
sam2 = ac*(1 + m*sm2).*cos(fc*time); % модулируем несущую

% Добавим шума
snr2 = 0.1; % сигнал/шум
noise2 = awgn(sam2, snr2);

% Построим график
noise_val2 = vec2group(noise2, num_in);
in_val2 = vec2group(sam2, num_in);

figure;
subplot(5, 1, 1);
plot(time, sam2);

onet2 = sim(net, in_val2);
simres2 = koh2vec(onet2, num_in);
subplot(5, 1, 2);
plot(time(1:numel(simres2)), simres2);
axis([min(time) max(time) -2 2]);

subplot(5, 1, 3);
plot(time, noise2)

onet2 = sim(net, noise_val2);
noise_res2 = koh2vec(onet2, num_in);
subplot(5, 1, 4);
plot(time(1:numel(noise_res2)), noise_res2);
axis([min(time) max(time) -2 2]);

subplot(5, 1, 5);
plot(time, sm2);
axis([min(time) max(time) -2 2]);











