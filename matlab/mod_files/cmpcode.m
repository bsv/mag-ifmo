function [ perc ] = cmpcode(code, code_test)
% Сравнивает две битовые последовательности
% perc - процент похожести code_test на code 

    n = min(numel(code), numel(code_test));
    neq = 0; % количество различающихся бит
    for i = 1:n
        if(code(i) ~= code_test(i))
            neq = neq + 1;
        end
    end
    
    perc = 1-neq/n;

end

