function [ output_arg ] = aligne( data, input_arg )
% This function check function of input_args, 'lin' or 'col'
% if data is really in 'col' or 'line', then modifify to match
% input data must be m x 1 or 1 x n vector
% input_arg must 'col' to set data in colum or 'lin' to set data in line
% output_arg is the data set by input_arg

if isvector(data) || isempty(data)
    [m, n] = size(data);
    switch input_arg
        case 'col'
            if n == 1
                output_arg = data';
            else
                output_arg = data;
            end
        case 'lin'
            if m == 1
                output_arg = data';
            else
                output_arg = data;
            end
    end
else
    error 'input data is not a vector, consider m*1 or n*1 data'
end


end

