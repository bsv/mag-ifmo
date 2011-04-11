clear all;
close all;

Fs1 = 3000000;
Fs2 = 4000000;
Fd = 13600000;

sig = csvread('data/sig1.txt');

[b, a] = butter(5, [2*Fs1/Fd, 2*Fs2/Fd]);
sig_filt = filtfilt(b, a, sig);

subplot(2,1,1);
plot(sig);

subplot(2,1,2);
plot(sig_filt);

%% Построение спектра сигнала

source = sig_filt;

FftL = numel(source);

FftS=abs(fft(source, FftL));
FftS=2*FftS./FftL;% нормирование спектра по амплитуде
FftS(1)=FftS(1)/2;% нормирование постоянной составляющей в спектре

F=0:Fd/FftL:Fd/2-1/FftL;% расчет оси частоты
plot(F,FftS(1:length(F)));