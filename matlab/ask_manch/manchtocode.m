function [ code ] = manchtocode(data, np)
% Преобразует манчестерский код в битовую последовательность
% np - количество отсчетов времени за период

    code = [];
    step = round(np*0.25);
    
    for i=1:np:numel(data)-np
        if(data(i+step) < data(i+round(2.5*step)))
            code = [code 1];
        else
            code = [code 0];
        end
    end
end

