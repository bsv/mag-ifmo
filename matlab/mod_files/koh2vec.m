function [ simres ] = koh2vec(onet, num_in, time_ctr)
%Преобразует результаты симуляции сети Кохонена
%в вектор 0 и 1
%   Для сети с 2 выходами

    simres = [];
    for i = 1:numel(onet)
        for j = 1:numel(onet{i})
            if(onet{i}(j) == 1)
                simres = [simres repmat(j-1, 1, num_in)];
            end
        end
    end

    simres = [simres zeros(1, time_ctr - numel(simres))];
end

