function [ simres ] = koh2vec(onet, num_in)
%Преобразует результаты симуляции сети Кохонена
%в вектор 0 и 1
%   Для сети с 2 выходами

    simres = [];
    for i = 1:numel(onet)
        if (onet{i}(1) - onet{i}(2)) > 0
            simres = [simres ones(1, num_in)];
        else
            simres = [simres zeros(1, num_in)];
        end
    end

end

