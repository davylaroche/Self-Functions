function [xAT, yAT, ATtime, t] = FncAT(tps, pal, Ve, VO2, VCO2)
% This function aim to find the anaerobic treshold based on the paper on
% Kvca, P., & Vilikus, Z. (2001). Assessment of Anaerobic Threshold as a Software Application Vilmed 2.0 in MS EXCEL. Sports Medicine, Training and Rehabilitation, 10(3), 151–164. doi:10.1080/10578310210397
% This function needs the optimisation toolbox
% inputs:
%%% tps: time vector
%%% pal: step of the tests (only the first and last are used then must be present)
%%% Ve: ventilation waveforms in L
%%% VO2: O2 uptake in mL
%%% VCO2: CO2 uptake in mL

% outputs:
%%% xAT: VO2 anaerobic treshold in L
%%% yAT: Ve or VCO2 correspondant value
%%% ATtime: time AT occurs
%%% t: line of the VO2 vector at AT occurs

%%%% Here choose the parameter you want Ve or VCO2
Y = VCO2*1000; 
%Y = Ve;
X = VO2*1000; % or Ve

%%%% Create parameters we need for exp determination
%%% meaning by minute
steptime=60; % time in second for the step calculation
nbstep = fix(((pal(end, 1)-pal(1, 1))/steptime))+1;

%%%% Create step function of steptime
stepT = pal(1, 2);
nStep = [tps(stepT) stepT];

while tps(stepT)<=tps(pal(end, 2))
    stepT = find(tps(:, 1)>tps(stepT)+(steptime-1), 1, 'first');
    nStep(end+1, :) = [tps(stepT) stepT];
end

for c1 = 1:size(nStep, 1)-1
    Xi(c1) = nanmean(X(nStep(c1, 2):nStep(c1+1, 2)));
    Yi(c1) = nanmean(Y(nStep(c1, 2):nStep(c1+1, 2)));
end

%%%%%%%%% Debug
% Xi = [870 1470 1279 1949 2140 2297 2662 2932 3854];
% Yi = [14.4 21.3 22.1 35.7 39.4 45.2 54.8 66.7 97.9];
% n = 9;

lnYi = log(Yi);
squxi = Xi.^2;
xilnyi = Xi.*lnYi;

sXi = nansum(Xi);
sYi = nansum(Yi);
slnYi = nansum(lnYi);
ssquxi = nansum(squxi);
sxilnyi = nansum(xilnyi);

%%%% Extract the log linear parameters
n = length(Xi);

Xf = Xi(1);
Xl = nanmax(Xi);

lnA = (slnYi*ssquxi-sXi*sxilnyi)/(n*ssquxi-sXi^2);
A = exp(lnA);
B = ((n*sxilnyi)-(sXi*slnYi))/(n*ssquxi-sXi^2);

Xp = ((1/B-Xl)/(exp(B*(Xf-Xl))-1))-((1/B-Xf)/(1-exp(B*(Xl-Xf))));
Yp = A*exp(B*Xf)+A*B*exp(B*Xf)*(Xp-Xf);

%%%% Solve the equation to determine adress of AT
% xfun = @(x) A^2*Xp*exp(2*B*x)*(x-Xp)+B*x^3*Yp*(A*exp(B*x)-Yp);
xfun =@(x) sqrt((Xp/x-1)^2 + (Yp/(A*exp(B*x))-1)^2);
xAT = fminbnd(xfun, 0, nanmax(Xi));
yAT = xfun(xAT);

%%%%% Find at what time AT occurs
t = find(X>xAT, 1, 'first');
ATtime = tps(t);

end

