function [ out ] = demsync(sam, time, period, fc)
%Демодуляция сигнала методом синхронного детектированияe
% period - период модулирующего сигнала

y = sam.*cos(fc*time);
[b, a] = butter(5, 2/period/fc); % сглаживание ФНЧ, расчет фильтра Баттерворта 5 порядка
out = filtfilt(b, a, y); % фильтрация

end

