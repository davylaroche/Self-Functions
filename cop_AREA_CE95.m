function [area_CE95] = cop_AREA_CE95(COP)
%================================================= ========================
% FUNCTION: cop_AREA_CE95
% Author: Shinichi Amano
% All procedures are based on Prieto et al. (1996)
% This function calculate the 95% confidence ellipse of COP data (unit:mm^2).
%================================================= ========================

% Initial variables declaration
f=3; % F score for the large sample size (>120) is 3.00.
n=max(size(COP));

COPx=COP(:,1);
COPy=COP(:,2);

for jj=1:max(size(COPx))
temp(jj,1)=COPx(jj,1)*COPy(jj,1);
end
covar_xy=(1/n)*sum(temp);
clear temp;

%Calculate the area_CE95 (mm^2).
area_CE95=2*pi*f*sqrt((std(COPx))^2*(std(COPy))^2-covar_xy^2)/100;

clear jj f n COP COPx COPy covar_xy m_COPx m_COPy;
