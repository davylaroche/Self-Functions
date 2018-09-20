function [CYCLE, N_CYCLE, END_ST, CUT]= Peaks_Select(VECTOR, process, arg, threshold, duration)

% This function permit to selection Peak for cutting Cycle
%%% Vector must be 1*m vector of point 
%%% Process could be - 'automatic' : automatic cutting, errors are notified if cycle are > 15% differences and need 'recut' pass.
%                    - 'semi-automatic' : automatic recut with asking windows if cycle are > 15% difference, not need news pass, cyles are saved
%                    - 'manual' : open windows to ask for good or not cycle at each time
%%% arg must be a 1*m array of double indicating approximative position of peaks

% this function uses : ind = findpeaks(y) finds the indices (ind) which are
%   local maxima in the sequence y.  For local minima, use
%   FINDPEAKS (-Y).
%   [ind,peaks] = findpeaks(y) returns the value of the peaks at 
%   these locations, i.e. peaks=y(ind);
%   FINDPEAKS (Y, THRESHOLD) performs the same opration, but will
%   only return peaks larger than THRESHOLD.
%   FINDPEAKS (Y, THRESHOLD, DURATION) will only find peaks separated by
%   at least DURATION points.

criterion = 0.85; % value under which cycle are condidered invalid
value_min = -30; % value under which peaks are not considered
IC = 15; % Intervalle de confiance autour du point trouvé pour définir le max du cycle
figure_pos = [50 200 1200 800];
if nargin<2, process = 'manual'; arg = [];end
if nargin<3, arg = [];end   
if (nargin < 4 || isempty (threshold)), threshold = value_min; end
if (nargin < 5), duration = 0; end
if (nargin < 6), vector_legend = 'Axis';end
m = length(VECTOR);

Xmin = find(~isnan(VECTOR), 1, 'first');
Xmax = find(~isnan(VECTOR), 1, 'last');

%%%%%%%%%%%%%%%%%%%%%%%%% Détecter les pics
[ind,peaks] = findpeaks(VECTOR, threshold, duration);

if ~isempty(arg)
    ind2 = ind; 
    clear peaks ind
    ind = arg(arg>=Xmin & arg<=Xmax);
    peaks = VECTOR(ind, 1);
    for x = 1:length(arg)-1
        if peaks(x, 1)-IC >= Xmin && peaks(x,1)+IC<=Xmax
            Y(x,1)=nanmax(VECTOR(peaks(x,1)-IC:peaks(x,1)+IC,1));
        else
            if peaks(x, 1)-IC >= Xmin
                Y(x,1)=nanmax(VECTOR(peaks(x,1)-IC:Xmax,1));
            elseif peaks(x, 1)+IC <=Xmax
                Y(x,1)=nanmax(VECTOR(Xmin:peaks(x,1)+IC,1));
            else
                Y(x,1)=nanmax(VECTOR(Xmin:Xmax,1));
            end
        end
    end
    clear peaks ind
    ind = Y; peaks = VECTOR(Y);
    clear Y
    %%%%%%%%%%%% Vérifications des valeurs contenues dans arg
    if length(ind)>length(ind2)
        if sum(ismember(ind, ind2))~=0, errinpic = 0; else errinpic = 1;end
    else
        if ismember(ind2, ind)~=0, errinpic = 0; else errinpic = 1;end
    end
else
    errinpic = 0;
end

%%%% Compute % error in cycle determination % computing %
%%%% difference in peaks
if length(ind) > 2 && errinpic == 0;
    piclength = diff(ind); 
    for x = 1:length(piclength)
        matverif(x, :) = piclength./piclength(x);
    end
    if sum(sum(matverif < criterion))~=0 || ~isempty(peaks(peaks<value_min)), errinpic = 1;else errinpic = 0;end
else
    errinpic = 1;
end

VERIF = 0;   
while VERIF == 0

    switch process
    
        case 'automatic'
            if errinpic ~= 1 
                N_CYCLE = length(ind)-1;
                X = sort(ind);
                CUT = 1;
            else
                N_CYCLE = NaN;
                X = NaN;
                CUT = 0;  
            end
            VERIF = 1; 

        case 'semi-automatic'

            if errinpic == 1 
                %%%%%%%%% build the figure to represent peaks found
                h = figure(1);
                set(h, 'pos', figure_pos,'MenuBar', 'None'); hold on;
                plot(VECTOR,'r');
                Ymin=nanmin(VECTOR)-10; 
                Ymax=nanmax(VECTOR)+10;
                legend(vector_legend);
                title('CYCLE DETERMINATION');
                axis([Xmin Xmax Ymin Ymax]);            

                if isempty(ind)
                    button = questdlg('No peak found, Continue [Yes] or modify [No]','VERIF', 'Yes','No','Ccl','No');
                else
                    plot(ind, peaks, 'bo');
                    button = questdlg(['  FOUND ', num2str(length(ind)-1), ' CYCLE(S) PRESS [YES] TO CONTINUE or [NO] whenever an error occured'],...
                        'VERIF', 'Yes','No','No');
                end

                if ~strcmp(button, 'Yes')     
                    clf(h);
                    plot(VECTOR,'r');
                    Ymin=nanmin(VECTOR)-10; 
                    Ymax=nanmax(VECTOR)+10;
                    legend(vector_legend);
                    title('CYCLE DETERMINATION');
                    axis([Xmin Xmax Ymin Ymax]);            
                    set(h, 'pos', figure_pos,'MenuBar', 'None'); hold on;

                    [X,~] = ginput;
                    X = round(X);
                    X = sort(X);
                    close(h)
                else
                    close(h)
                    if isempty(ind)
                        N_CYCLE = 0;
                        X = NaN;
                        CUT = 1;
                        VERIF = 1; 
                    else
                        N_CYCLE = length(ind)-1;
                        X = sort(ind);
                        CUT = 1;
                        VERIF = 1; 
                    end
                end
            else
                N_CYCLE = length(ind)-1;
                X = sort(ind);
                CUT = 1;
                VERIF = 1; 
            end

        case 'manual'
            h = figure(1);
            set(h, 'pos', figure_pos,'MenuBar', 'None'); hold on;  
            plot(VECTOR,'r');
            Ymin=nanmin(VECTOR)-10; 
            Ymax=nanmax(VECTOR)+10;
            legend(vector_legend);
            title('CYCLE DETERMINATION');
            axis([Xmin Xmax Ymin Ymax]);            
            
            if isempty(ind)
                button = questdlg('No peak found, Continue [Yes] or modify [No]','VERIF', 'Yes','No','Ccl','No');
            else
                plot(ind, peaks, 'bo');
                button = questdlg(['  FOUND ', num2str(length(ind)-1), ' CYCLE(S) PRESS [YES] TO CONTINUE or [NO] whenever an error occured'],...
                    'VERIF', 'Yes','No','No');
            end

            if ~strcmp(button, 'Yes')    
                if ~isempty(ind)
                    clf h;
                    plot(VECTOR,'r');
                    Ymin=nanmin(VECTOR)-10; 
                    Ymax=nanmax(VECTOR)+10;
                    legend(vector_legend);
                    title('CYCLE DETERMINATION');
                    axis([Xmin Xmax Ymin Ymax]);            
                    set(h, 'pos', figure_pos,'MenuBar', 'None'); hold on;

                    [X,~] = ginput;
                    X = round(X);
                    X = sort(X);
                else
                    if exist('X', 'var') == 0, X = 0;end
                end        
                close(h)
            else
                close(h)
                if isempty(ind)
                    N_CYCLE = 0;
                    X = NaN;
                    CUT = 1;
                    VERIF = 1; 
                else
                    N_CYCLE = length(ind)-1;
                    X = sort(ind);
                    CUT = 1;
                    VERIF = 1; 
                end
            end
    end
    
    if VERIF == 0
        N_CYCLE = length(X)-1;
        if N_CYCLE ~= 0
            for x=1:N_CYCLE+1
                if X(x, 1)-IC >= Xmin && X(x,1)+IC<=Xmax
                    [~, Y(x,1)] = nanmax(VECTOR(X(x,1)-IC:X(x,1)+IC,1));
                    Y(x,1) = Y(x,1) + X(x, 1)-IC;
                else
                    if X(x, 1)-IC >= Xmin
                        [~, Y(x,1)] = nanmax(VECTOR(X(x,1)-IC:Xmax,1));
                        Y(x,1) = Y(x,1) + X(x, 1)-IC;
                    elseif X(x, 1)+IC <=Xmax
                        [~, Y(x,1)] = nanmax(VECTOR(Xmin:X(x,1)+IC,1));
                        Y(x,1) = Y(x,1) + Xmin;
                    else
                        [~, Y(x,1)] = nanmax(VECTOR(Xmin:Xmax,1));
                        Y(x,1) = Y(x,1) + Xmin;
                    end
                end
            end
            clear X ind peaks
            X = Y;
            ind = X; peaks = VECTOR(X);
        else
            close(h)
            N_CYCLE = 0;
            X = 0;
            VERIF = 1; 
            CUT = 1;
        end
    end
end

n = size(X,2);
if n>1
    CYCLE = X';
else
    CYCLE = X;
end

[END_ST] = Toe_Off(VECTOR, N_CYCLE, CYCLE);

end

function [ind,peaks] = findpeaks(y, threshold, duration)
% FINDPEAKS  Find peaks in real vector.
%   ind = findpeaks(y) finds the indices (ind) which are
%   local maxima in the sequence y.  For local minima, use
%   FINDPEAKS (-Y).
%
%   [ind,peaks] = findpeaks(y) returns the value of the peaks at 
%   these locations, i.e. peaks=y(ind);
%
%   FINDPEAKS (Y, THRESHOLD) performs the same opration, but will
%   only return peaks larger than THRESHOLD.
%
%   FINDPEAKS (Y, THRESHOLD, DURATION) will only find peaks separated by
%   at least DURATION points.
%
%   Originally posted to comp.soft-sys.matlab 12.16.1996 by 
%   Tom Krauss (krauss@mathworks.com)
%
%   Modified 6.27.2001 by Ian Kremenic (ian@nismat.org) to also
%   use optional threshold.
% 
% Last modified: 9.28.2001

if (nargin < 2 || isempty (threshold))
    threshold = min (y);
end

if (nargin < 3)
    duration = 0;
end

y = y(:)';

dy = diff(y);

ind = find( ([dy 0]<0) & ([0 dy]>=0) & (y>=threshold));

% don't want endpoints; must make sure that ind is not empty!
if (~isempty (ind) && ind (1) == 1)
    ind (1) = [];
end
%if (y(end-1)<y(end) & (y(end)>threshold))
%    ind = [ind length(y)];
%end

% make sure all points are at least DURATION apart
if (duration ~= 0)
    index = 1;
    while (index < length (ind))
        tooClose = find (ind (index+1:end) < ind (index) + duration);
        ind (tooClose+index) = [];
        index = index + 1;
    end
end

if nargout > 1
    peaks = y(ind);
end

%+=== Tom Krauss ========================= krauss@mathworks.com ===+
%|    The MathWorks, Inc.                    info@mathworks.com    |
%|    24 Prime Park Way                http://www.mathworks.com    |
%|    Natick, MA 01760-1500                   ftp.mathworks.com    |
%+=== Tel: 508-647-7346 ==== Fax: 508-647-7002 ====================+

end

function [END_ST] = Toe_Off(VECTOR, N_CYCLE, CYCLE, type, frequ)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TOE OFF DETERMINATION
if nargin<4, type = 'position'; frequ = 100;end
if nargin<5, frequ = 100;end

if N_CYCLE > 0
    switch type
        case 'position'
            for a = 1:N_CYCLE
                [~, END_ST(a, 1)] = nanmin(VECTOR(CYCLE(a):CYCLE(a+1), 1));
            end
        case 'velocity'
            for a = 1:N_CYCLE
                vector = derivative(VECTOR(CYCLE(a):CYCLE(a+1)), frequ, 1);
                len = round(linspace(1, CYCLE(a+1)-CYCLE(a), 5));
                seuil = abs(nanmean(vector(len(2):len(3))))+2.38*std((vector(len(2):len(3))));
                END_ST(a, 1) = len(3)+find(vector(len(3):end)>seuil, 1, 'first')-1;          
            end
    end
else
    END_ST = NaN;
end


end