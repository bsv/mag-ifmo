function [ out ] = formsimin(vec, num_in)
%FORMSIMIN формирование значений входа этапа симуляции сети

    out = [];
    for i = num_in:num_in:numel(vec)
        out = [[out] {vec(i-num_in+1:i)}];
    end
end

