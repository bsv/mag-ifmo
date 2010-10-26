function [ out ] = intsample(in, interval, num_in)
%Разбивает входную последовательность на группы ячеек
% Значения в групы выбираются через interval из исходного вектора
    
    out = [];
    range_val = num_in*interval;
    
    for i = range_val+1:range_val:numel(in)
        cell = [];
        for j = num_in:-1:1
            % !!! Берем значения по модулю
            cell = [cell abs(in(i - j*interval))];
        end
        out = [out {cell'}];
    end


end

