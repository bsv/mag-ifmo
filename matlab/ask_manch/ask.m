clear all % очищаем все переменные
close all % закрываем все графики

fd = 250; % частота дискретизации
fc = 20; % несущая чатота
time = 0:1/fd:20; % шкала времени
code = [1 0 0 1 1]; % передаваемые данные
m = 0.65; % коэффициент модуляции
ac = 1; % амплитуда несущего сигнала

sm = manch(time, code); % преобразуем данные в манчестерский код
sam = ac*(1 + m*sm).*cos(fc*time); % модулируем несущую

subplot(2, 1, 1);
plot(time, sm);
grid on;
axis([min(time) max(time) -2 2]);

subplot(2, 1, 2);
plot(time, sam);
axis([min(time) max(time) -2 2]);
grid on;
%% Демодуляция сигнала методом синхронного детектирования

figure;
subplot(4, 1, 1);
plot(time, sam);

period = (time(numel(time))-time(1))/numel(code); % период модулирующего сигнала
z = demsync(sam, time, period, fc);
subplot(4, 1, 2);
plot(time,z);

%% Генерция шума 

snr = 1; % сигнал/шум
noise = awgn(sam, snr, 'measured');
subplot(4, 1, 3);
plot(time, noise);

z = demsync(noise, time, period, fc);
subplot(4, 1, 4);
plot(time, z);
axis([min(time) max(time) 0 1]);

%% Демодуляция с помощью нейронной сети

num_in = 25;
interval = 5;
min_max = minmax(sam);

snr = 0.5; % сигнал/шум
noise = awgn(sam, snr);

in_range = [];
for i = 1:num_in
    in_range = [in_range; min_max];
end

in_val = vec2group(sam, num_in);
noise_val = vec2group(noise, num_in);

% Интервальная выборка
inter_val = intsample(sam, interval, num_in);
noise_inter_val = intsample(noise, interval, num_in);

net = newc(in_range, 2, 0.01, 0.001); % 2 нейрона
net.trainParam.epochs = 50;
net = init(net);
net = train(net, noise_inter_val);
%load net;

figure;
subplot(5, 1, 1);
plot(time, sam);

onet = sim(net, inter_val);
simres = koh2vec(onet, num_in);

% растягиваем значения simres на всю временную ось
simres = stretch(simres, num_in, interval);

subplot(5, 1, 2);
plot(time(1:numel(simres)), simres);
axis([min(time) max(time) -2 2]);

subplot(5, 1, 3);
plot(time, noise)

onet = sim(net, noise_inter_val);
noise_res = koh2vec(onet, num_in);

% растягиваем значения simres на всю временную ось
noise_res = stretch(noise_res, num_in, interval);

subplot(5, 1, 4);
plot(time(1:numel(noise_res)), noise_res);
axis([min(time) max(time) -2 2]);

subplot(5, 1, 5);
plot(time, sm);
axis([min(time) max(time) -2 2]);

%% Испытаем сеть на других данных
code2 = [1 0 0 1 1]; % передаваемые данные
sm2 = manch(time, code2); % преобразуем данные в манчестерский код
sam2 = ac*(1 + m*sm2).*cos(fc*time); % модулируем несущую

    % Добавим шума
    snr2 = 1; % сигнал/шум
    noise2 = awgn(sam2, snr2);

    % Построим график
    noise_val2 = vec2group(noise2, num_in);
    in_val2 = vec2group(sam2, num_in);

    % немного сдвигаем выборку
    %interval = 15;
    % Интервальная выборка
    inter_val2 = intsample(sam2, interval, num_in);
    noise_inter_val2 = intsample(noise2, interval, num_in);

    figure;
    subplot(5, 1, 1);
    plot(time, sam2);

    onet2 = sim(net, inter_val2);
    simres2 = koh2vec(onet2, num_in);
    simres2 = stretch(simres2, num_in, interval);
    subplot(5, 1, 2);
    plot(time(1:numel(simres2)), simres2);
    axis([min(time) max(time) -2 2]);

    subplot(5, 1, 3);
    plot(time, noise2)

    onet2 = sim(net, noise_inter_val2);
    noise_res2 = koh2vec(onet2, num_in);
    noise_res2 = stretch(noise_res2, num_in, interval);
    subplot(5, 1, 4);
    plot(time(1:numel(noise_res2)), noise_res2);
    axis([min(time) max(time) -2 2]);

    subplot(5, 1, 5);
    plot(time, sm2);
    axis([min(time) max(time) -2 2]);











