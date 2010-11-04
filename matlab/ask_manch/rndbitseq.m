function [byte] = rndbitseq(len)
% Фукция генерирует случайную последовательность
% битов длиной len
% len - длина битовой последовательности

    byte = [];
    for i = 1:len
        byte = [byte round(rand())];
    end
end