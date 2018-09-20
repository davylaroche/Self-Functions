function output = stepmean(input, type, step)
%%% this function compute mean every step points
%%% value step could be points number then associate to type: 'points'
%%% or could be % associate to type : 'percentage'

if ~isnumeric(input), input = str2double(input); end

[m, n] = size(input);

for c1 = 1:n
    
    switch type
        case 'points'
            steps = step;
            nstep = fix(m/step);
        case 'percentage'
            steps = round(step*m/100);
            nstep = fix(100/step);
    end
    
    stepcount = round(linspace(1, m, nstep+1));
    for c2 = 1:length(stepcount)-1
        output(c2, c1) = nanmean(input(stepcount(c2):stepcount(c2+1), c1));
    end
    
end
end
