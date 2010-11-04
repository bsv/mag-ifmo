clear all % очищаем все переменные
close all % закрываем все графики

% Моделируемые частота несущей и скорости передачи
carrier = 125000;
baud = 4000;
%

% Расчет модельных величин
msg_len = 8; % передаем байт
max_time = 1000;
fc = (msg_len/max_time)*(carrier/baud) % несущая чатота
fd = 4*fc; % частота дискретизации
time = 0:1/fd:max_time; % шкала времени
period = max_time/msg_len; % период модулирующего сигнала

code = rndbitseq(msg_len); % передаваемые данные
sm = manch(time, code); % преобразуем данные в манчестерский код
