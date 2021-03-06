% MEANFREQUENCY This computes the mean frequency of a power spectrum.
%
% mf = meanfrequency(f,p)
%
% Author Adrian Chan
%
% This computes the mean fequency of a power spectrum.
%
% Reference: �berg T, Sandsj� L, Kadefors R, "EMG mean power frequency: 
% Obtaining a reference value", Clinical Biomechanics, vol. 9, pp. 253-257,
% 1994.
%
% Inputs
%    f: frequencies (Hz)
%    p: power spectral density values
%
% Outputs
%    mf: mean frequency
%
% Modifications
% 09/09/21 AC First created.
function mf = meanfrequency(x, fs)

nfft = 2^nextpow2(length(x));
Y = fft(x,nfft)/length(x);
p = 2*abs(Y(1:nfft/2+1));
f = (fs/2*linspace(0,1,nfft/2+1))';

mf = sum(f.*p)/sum(p);
