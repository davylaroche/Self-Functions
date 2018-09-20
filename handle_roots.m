function poly_roots = handle_roots(vector, n, opt, Xval, solver)
%%% this function retunrn roots for timeserie vector (m*1)
%%% this function use fsolve or fzero function
%%% n increase number of points to vector (default = 1)
%%% opt defines if the function seek for 'all' roots or just the 'nearest' root of
%%% the value Xval
%%% Xval must be integer, and position define the postion of the vector t

if nargin < 2, n = 1; solver = 'fzero'; opt = 'all'; end
if nargin < 3, solver = 'fzero'; opt = 'all'; end
if nargin < 5, solver = 'fzero'; end

options = optimset('Display','off');

t = linspace(1, length(vector), length(vector));
tt = linspace(1, length(vector), length(vector)*n);

input = spline(t, vector, tt);

pp = spline(tt, vector);
myfun = @(tt, y) ppval(pp, tt);

if strcmp(opt, 'all'), counter = length(input); beg = 1; else Xval = Xval*n; counter = Xval; beg = Xval;end

switch solver
    case 'fsolve'
        for x0 = beg:counter
            x(x0) = round(fsolve(myfun, x0, options));
        end
        
    case 'fzero'
        for x0= beg:counter
            x(x0) = round(fzero(myfun, x0, options));
        end
end

if strcmp(opt, 'all')
    poly_roots = unique(x);
else
    poly_roots = x(counter);
end

poly_roots = poly_roots(poly_roots>0 & poly_roots<length(vector));

end