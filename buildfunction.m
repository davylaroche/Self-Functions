function [integral] = buildfunction(vector, frequ, a, b)

if nargin < 2, frequ = 1; a = 1; b=length(vector);end

%%%%%%%%%%%% making timeline
t = linspace(0, (length(vector)-1)/frequ, length(vector));

%%%%%%%%%%% building function
pp = spline(t, vector);
myfun = @(t, y) ppval(pp, t);

integral = quadl(myfun, t(a), t(b));

end