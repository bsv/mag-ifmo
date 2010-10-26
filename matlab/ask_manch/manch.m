function [ out ] = manch(time, code)
%function [ out ] = manch(time, code)
%
%Generate manchester pulse sharing
%   time
%   code - message in binary code
%   out  - pulse sharing value

    out = [];
    half_period = floor(numel(time)/(numel(code)*2)); 
    
    if half_period < 1
        disp('The time interval cant not include this code');
    else

        sample0 = [ones(1, half_period) -1*ones(1, half_period)];
        sample1 = [-1*ones(1, half_period) ones(1, half_period)];

        for i = 1:numel(code)
            if code(i) == 1
                out = [out sample1];
            else
                out = [out sample0];
            end
        end
        
        out = [out zeros(1, numel(time) - numel(out))];
    end

end

