init;

m = 0.65; % коэффициент модуляции

sfm = modulate(sm, fc, fd, 'fm', m); % фазовая модуляция

subplot(2, 1, 1);
plot(time, sm);
grid on;
axis([min(time) max(time) -2 2]);

subplot(2, 1, 2);
plot(time, sfm);
axis([min(time) max(time) -2 2]);
grid on;

%% Демодуляция с помощью нейронной сети

% пробуем получить соотношения для правил обучения
num_in = 100%ceil(period*fc/2)
%

min_max = minmax(sfm);

snr = 0.5; % сигнал/шум
noise = awgn(sfm, snr, 'measured');

% Мин и макс значения для каждого входа сети
in_range = [];
for i = 1:num_in
    in_range = [in_range; min_max];
end

noise_inter_val = vec2group(noise, num_in);
inter_val = vec2group(sfm, num_in);


net = newc(in_range, 2, 0.01, 0.001); % 2 нейрона
net.trainParam.epochs = 50;
net = init(net);
net = train(net, noise_inter_val);

figure;
subplot(5, 1, 1);
plot(time, sfm);

onet = sim(net, inter_val);
simres = koh2vec(onet, num_in, numel(time));

subplot(5, 1, 2);
plot(time(1:numel(simres)), simres);
axis([min(time) max(time) -0.1 1.2]);

subplot(5, 1, 3);
plot(time, noise)

onet = sim(net, noise_inter_val);
noise_res = koh2vec(onet, num_in, numel(time));

code;
np = floor((max_time/msg_len)*fd);
mc = manchtocode(noise_res, np);
cmp = cmpcode(code, mc)

subplot(5, 1, 4);
plot(time(1:numel(noise_res)), noise_res);
axis([min(time) max(time) -0.1 1.2]);

subplot(5, 1, 5);
plot(time, sm);
axis([min(time) max(time) -2 2]);