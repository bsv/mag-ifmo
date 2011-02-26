init; 

m = 0.65;
sam = (1 + m*sm).*cos(2*pi*fc*time); % амплитудная модуляция

noise3 = 0;
noise_old = 0;
eps = 1;

snr = 0.1;
eps_mas = [];

for i=1:100
    noise3 = noise3 + awgn(sam, snr, 'measured');
    
    eps_cur = abs(sum(abs(noise_old)) - sum(abs(noise3/i)));
    
    if eps_cur < 100   
        eps_mas = [eps_mas eps_cur];
    end
    
    if  eps_cur < eps
        break;
    end
    noise_old = noise3/i;
end

i
subplot(2, 1, 1)
plot(time, noise3/i)

subplot(2, 1, 2)
plot(1:numel(eps_mas), eps_mas)
