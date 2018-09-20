function [newdata_out, t2int_out] = fillgaps(data_in, frequency, minlen, method, cutoff)

% FILLGAPS   Fill in gaps and make sure points are consecutive.
%
%   NEWDATA = FILLGAPS (DATA, MINLEN) looks at the points contained
%   in the (presumed) vector DATA, and fills in any gaps which
%   are shorter than MINLEN points (in other words, makes sets
%   of consecutive points).  

counter = size(data_in, 2);
newdata_out = zeros(size(data_in, 1), counter);
t2int_out = zeros(size(data_in, 1), counter);

for x = 1:counter
    clear data newdata t2int gaps gapsIndex gapLen startPoint endpoint gapIndex dataIndex theGap
    data = data_in(:, x); 
    
    if (nargin < 3)
        minlen = frequency;		% how many missing points might be a glitch
    end
    if (nargin < 5)
        cutoff = 10;
    end
    if (nargin < 4)
        method = 'linear';
    end

    newdata = [];
    vect = find(isnan(data)==0);


    % find non-consecutive portions of data (which are less than minlen)
    gaps = diff(vect);
    gapsIndex = find (gaps > 1 & gaps <= minlen);
    gapLen = (gaps(gapsIndex)-1);	% how long is each glitch
    startPoint = min(vect);
    endpoint = max(vect);
    gapsIndex = [0;gapsIndex];
    gapLen = [0;gapLen];
    %%%%%% Correction des gaps 
    gapIndex(1) = gapsIndex(1)+startPoint;
    for i = 2:length(gapsIndex)
        gapIndex(i) = gapsIndex(i)+startPoint+sum(gapLen(1:i-1));
    end
    gapIndex(end+1) = endpoint+1;

    %%%%%%% Filtrage des données 
    %%%% Définition du filtre
    if cutoff/(frequency/2)<1
        half_frequ = frequency/2;
        [b, a] = butter(4, cutoff/half_frequ);
        filtered(1:length(data))=NaN;
        for theGap = 1:length(gapIndex)-1
           dataIndex = gapIndex(theGap)+gapLen(theGap):gapIndex(theGap+1)-1;
           if length(dataIndex)>12
              filtered(dataIndex) = filtfilt(b, a, data(dataIndex));
           else
              filtered(dataIndex) = data(dataIndex);
           end
        end
    else
        filtered(1:length(data))=NaN;
        for theGap = 1:length(gapIndex)-1
           dataIndex = gapIndex(theGap)+gapLen(theGap):gapIndex(theGap+1)-1;
           if round(1/frequency)<2, valrunmean = 2;else valrunmean = round(1/frequency);end
           filtered(dataIndex) = runmean(data(dataIndex), valrunmean);
        end
    end

    %%%%%%%%%%%% Interpolation des données
    t2int = startPoint:endpoint;
       % fill in
    newdata = [data(1:startPoint-1);interp1(vect,filtered(vect),t2int, method)';data(endpoint+1:length(data))];
    % newdata = filtered;
    
    newdata_out(:, x) = newdata;
    t2int_out(:, x) = t2int;
end
end






