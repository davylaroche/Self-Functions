function [ lignenbr ] = cellfindi( mat , arg )
% This function seek to find line lignenbr in mat matching arg without whatever case.
% mat must be cell matrix
% arg should be a string of characters

m = size(mat, 1);
lignenbr = [];
for x = 1:m
    if strcmpi(mat{x}, arg)
        lignenbr = [lignenbr;x];
    end
end

end