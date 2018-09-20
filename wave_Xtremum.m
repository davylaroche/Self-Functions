function racine = wave_Xtremum(vector) 
%%% This function return the zero value of the derivative of vector

derivee_t = diff(vector);
der1 = [derivee_t;derivee_t(end)]; der2 = [derivee_t(1);derivee_t]; 
derivee = mean([der1 der2], 2);

t = 1:length(derivee);

%%%%%%% building function
pp = spline(t, derivee);
myfun = @(t, y) ppval(pp, t);

%%%%%% Solving equation
for x = 1:length(derivee)
    t_root(x) = round(fsolve(myfun, x));
end

racine = unique(t_root(t_root>0));

end