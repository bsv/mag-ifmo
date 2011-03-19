function [ out ] = groupnet(vec, num)
%INNETFORM Формирует входной или выходной набор данных для нейронной сети

    out = [];
    for i = num:num:numel(vec)
        out = [out, {vec(i-num+1:i)'}];
    end

end

