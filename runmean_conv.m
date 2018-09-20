function Y = runmean_conv(X, n)

coefs = ones(n,1)/n; 
Y = conv(X, coefs, 'same');

end