function [phase, harmonic, power] = fcn_fft(V, Fs, n, graph)

%%%% This function returns the first n harmonics and the first n phase with the associated power spectrum of
%%%% the vector V in descending order of power spectrum
%%%% Fs is the sampling frequency
%%%% n is set to 1 as default
%%%% graph is set to 'off' as default

if nargin < 3, n = 1; graph = 'off';end
if nargin < 4, graph = 'off';end

L = length(V);
NFFT = 2^nextpow2(L);
Y = fft(V,NFFT)/L;

f = Fs/2*linspace(0,1,NFFT/2+1);

[~, H] = sort(abs(Y(1:NFFT/2+1)));

if f(H(end)) == 0
    [power(1:n), id] = sort(abs(Y(H(end-n:end-1))), 1, 'descend');
    harmonic(1:n) = sort(f(H(end-n:end-1)));
    harmonic(1:n) = harmonic(id);
    phase(1:n)= angle(Y(H(end-n:end-1)));
    phase(1:n) = phase(id);
else
    [power(1:n), id] = sort(abs(Y(H(end-n+1:end))), 1, 'descend');
    harmonic(1:n) = sort(f(H(end-n+1:end)));
    harmonic(1:n) = harmonic(id);
    phase(1:n)= angle(Y(H(end-n+1:end)));
    phase(1:n) = phase(id);
end

if strcmp(graph, 'on')
    subplot (1, 2, 1)
    plot(f,2*abs(Y(1:NFFT/2+1))) 
    title('Single-Sided Amplitude Spectrum of y(t)')
    xlabel('Frequency (Hz)');
    ylabel('|Y(f)|');
    
    subplot (1, 2, 2)
    plot(f,2*angle(Y(1:NFFT/2+1))) 
    title('Single-Sided Amplitude phase of y(t)')
    xlabel('Phase (Radian)');
    ylabel('|Y(f)|');    
end
end