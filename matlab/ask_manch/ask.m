init;

m = 0.65; % коэффициент модуляции

np = floor((max_time/msg_len)*fd);
%sam = modulate(sm, fc, fd, 'amdsb-tc', -m); % амплитудная модуляция
sam = (1 + m*sm).*cos(2*pi*fc*time); % амплитудная модуляция

subplot(2, 1, 1);
plot(time, sm);
grid on;
axis([min(time) max(time) -2 2]);

subplot(2, 1, 2);
plot(time, sam);
axis([min(time) max(time) -2 2]);
grid on;

%% Демодуляция стандартными средствами

snr = 2; % сигнал/шум
noise = awgn(sam, snr, 'measured');
dmod = demod(noise, fc, fd, 'amdsb-tc', -m);

figure 
subplot(2,1,1);
plot(time, dmod);

subplot(2,1,2);
plot(time, sm);
axis([min(time) max(time) -2 2]);

mc = manchtocode(dmod, np);
perc = cmpcode(code, mc)

%% Посчитаем величину ошибки при передачи последовательности байт   
    
snr = 5; % сигнал/шум
N = 64; % количество передаваемых байт
err = 1;

while(err == 1)
    
    perc = 0;

    for i = 1:N
        code = rndbitseq(8); % передаваемые данные
        sm = manch(time, code); % преобразуем данные в манчестерский код
        sam =  modulate(sm, fc, fd, 'amdsb-tc', -m); % модулируем несущую

        % Добавим шума

        noise = awgn(sam, snr, 'measured');
    
        % Интервальная выборка
        dmod = demod(noise, fc, fd, 'amdsb-tc', -m);
        
        mc = manchtocode(dmod, np);
        %cmpcode(code, mc)
        perc = perc + cmpcode(code, mc);
    end
    
    err = perc/N;
    N = N+1;
    N
end
N
err


%% Демодуляция с помощью нейронной сети

% пробуем получить соотношения для правл обучения
emin = fc/fd
e = 1/4%emin;
num_in = ceil(e*period/2*fd)

%

min_max = minmax(sam);

snr = 1; % сигнал/шум
noise = awgn(sam, snr, 'measured');

% Мин и макс значения для каждого входа сети
in_range = [];
for i = 1:num_in
    in_range = [in_range; min_max];
end

noise_inter_val = vec2group(noise, num_in);
inter_val = vec2group(sam, num_in);

net = newc(in_range, 2, 0.01, 0.001); % 2 нейрона
net.trainParam.epochs = 100;
net = init(net);
net = train(net, noise_inter_val);

figure;
subplot(5, 1, 1);
plot(time, sam);

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
mc = manchtocode(noise_res, np);
cmp = cmpcode(code, mc)

subplot(5, 1, 4);
plot(time(1:numel(noise_res)), noise_res);
axis([min(time) max(time) -0.1 1.2]);

subplot(5, 1, 5);
plot(time, sm);
axis([min(time) max(time) -2 2]);

%% Испытаем сеть на других данных
code2 = rndbitseq(8); % передаваемые данные
sm2 = manch(time, code2); % преобразуем данные в манчестерский код
sam2 =  modulate(sm2, fc, fd, 'amdsb-tc', -m); % модулируем несущую

    % Добавим шума
    snr2 = 0.1; % сигнал/шум
    noise2 = awgn(sam2, snr2, 'measured');
    
    % Интервальная выборка
    noise_inter_val2 = vec2group(noise2, num_in);
    
    % Построим график

    figure;

    subplot(3, 1, 1);
    plot(time, noise2)

    onet2 = sim(net, noise_inter_val2);
    noise_res2 = koh2vec(onet2, num_in, numel(time));
    subplot(3, 1, 2);
    plot(time(1:numel(noise_res2)), noise_res2);
    axis([min(time) max(time) -2 2]);

    subplot(3, 1, 3);
    plot(time, sm2);
    axis([min(time) max(time) -2 2]);
    
    % Сравниваем код, полученный из сигнала с выхода сети,
    % с исходным кодом сообщения
    code2
    np = floor((max_time/msg_len)*fd);
    mc = manchtocode(noise_res2, np)
    cmpcode(code2, mc)

%% Посчитаем величину ошибки при передачи последовательности байт   
    
snr = 5; % сигнал/шум
N = 64; % количество передаваемых байт
err = 1;

while(err == 1)
    
    perc = 0;

    for i = 1:N
        code = rndbitseq(8); % передаваемые данные
        sm = manch(time, code); % преобразуем данные в манчестерский код
        sam =  modulate(sm, fc, fd, 'amdsb-tc', -m); % модулируем несущую

        % Добавим шума

        noise = awgn(sam, snr, 'measured');
    
        % Интервальная выборка
        noise_inter_val = vec2group(noise, num_in);
        onet = sim(net, noise_inter_val);
        noise_res = koh2vec(onet, num_in, numel(time));
        
        mc = manchtocode(noise_res, np);
        %cmpcode(code, mc)
        perc = perc + cmpcode(code, mc);
    end
    
    err = perc/N;
    N = N+1;
    N
end
N-1
err
