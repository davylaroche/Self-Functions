function [truefalse, lignenbr ] = cellfind( mat , arg )
% This function seek to find line lignenbr in mat matching arg.
% mat must be cell matrix
% arg should be a string of characters

m = size(mat, 1);
lignenbr = []; truefalse = [];
for x = 1:m
    if strcmp(mat{x}, arg)
        lignenbr = [lignenbr;x];
        truefalse  = [truefalse;1];
    else
        truefalse  = [truefalse;0];
    end
end

end

