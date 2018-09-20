function [ lignenbr ] = cellfindstr( mat , arg , option)
% This function seek to find line lignenbr in mat who piece of arg is present.
% mat must be cell matrix, search is case senstive
% arg should be a string of characters
if nargin < 3, option = 'normal';end
m = size(mat, 1);
lignenbr = [];
for x = 1:m
    if strcmp(option, 'opposite')
        if isempty(strfind(mat{x}, arg))
            lignenbr = [lignenbr;x];
        end
    else
        if ~isempty(strfind(mat{x}, arg))
            lignenbr = [lignenbr;x];
        end
    end
end

end

