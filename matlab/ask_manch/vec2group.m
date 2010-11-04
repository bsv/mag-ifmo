function [ out ] = vec2group(vec, num_in )
%Разбивает вектор на группы, чтобы можно было их подать на вход сети
    
    out = [];
    for i = num_in:num_in:numel(vec)
        out = [[out] {abs(vec(i-num_in+1:i))'}];
    end
end

