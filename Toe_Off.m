function [END_ST] = Toe_Off(VECTOR, N_CYCLE, CYCLE, type, frequ)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TOE OFF DETERMINATION
if nargin<3, type = 'position'; frequ = 100;end
if nargin<4, frequ = 100;end

if N_CYCLE > 0
    switch type
        case 'position'
            for a = 1:N_CYCLE
                [~, END_ST(a, 1)] = nanmin(VECTOR(CYCLE(a, 1):CYCLE(a+1, 1), 1));
            end
        case 'velocity'
            for a = 1:N_CYCLE
                vector = derivative(VECTOR(CYCLE(a, 1):CYCLE(a+1, 1)), frequ, 1);
                len = round(linspace(1, CYCLE(a+1, 1)-CYCLE(a, 1), 5));
                seuil = abs(nanmean(vector(len(2):len(3))))+2.38*std((vector(len(2):len(3))));
                END_ST(a, 1) = len(3)+find(vector(len(3):end)>seuil, 1, 'first')-1;          
            end
    end
else
    END_ST = NaN;
end


end

