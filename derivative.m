function output = derivative(vector, frequency, n, option)
%%% This function compute the nth derivative of the signal vector (m*1
%%% vector) 
%%% Frequency is the sampling rate of the input vector 
%%% n is the degree to derivative the input vector
%%% option is a struct with option for derivative of the signal :
%%% 'smooth' is 'on' or 'off' and allow to smooth input signal to have
%%% better derivative and to make option in smooth funtion

if nargin<4, option.smooth = 'off'; option.produit = 10;end

if strcmp(option.smooth, 'on')
    if isfield(option, 'span'), span = option.span; end
    if isfield(option, 'method'), method = option.method; end
    
    if exist('span', 'var') && exist('method', 'var')
        input = smooth(vector, span, method);
    elseif exist('span', 'var') && ~exist('method', 'var')
        input = smooth(vector, span);
    elseif ~exist('span', 'var') && exist('method', 'var')
        input = smooth(vector, method);
    else
        input = smooth(vector');
    end
    
else
    input = vector;
end
   
[nf,nm]=size(input);
if ~isfield(option, 'produit'), option.produit = 10;end
multiplicateur = option.produit; %%% Multiplication of the input signal
dt = 1/frequency; % period of sampling rate
t = linspace(0, (nf-1)*dt, nf); % normal time rate
tt=linspace(0, (nf-1)*dt, nf*multiplicateur); % More points to smooth, n times sampling rate

for x = 1:nm
    clear smoothsignal tmp ttt pp myfun 
    
    smoothsignal=spline(t,input(:, x),tt);
    tmp = diff(smoothsignal, n)*(frequency^n);

    ttt = linspace(0, (nf-1)*dt, (nf*multiplicateur)-n);

    pp = spline(ttt, tmp);
    myfun = @(ttt, y) ppval(pp, ttt);

    % n_t = linspace(1, length(tmp), t);
    output(:, x) = myfun(t);
end

end