function [ out_res ] = stretch(simres, num_in, interval, time_ctr)
%STRETCH Summary of this function goes here
%   Detailed explanation goes here

out_res = [];
for i = 1:num_in:numel(simres)
    for j = 1:interval
        out_res = [out_res simres(i:i + num_in-1)];
    end
end

out_res = [out_res zeros(1, time_ctr - numel(out_res))];

end

