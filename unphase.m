function dephased = unphase(X, type)
%%%% This function shift to pi the signal vector X

if nargin < 2, type = 'real';end

if strcmpi(type, 'real');
    M = nanmean(X);
    Xc = X-M;
    dephased = -Xc+M;
elseif strcmpi(type, 'opposite')
    dephased = -X;
elseif strcmpi(type, 'none')
    dephased = X;
end

end