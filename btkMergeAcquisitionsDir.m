function btkMergeAcquisitionsDir(listofiles, outputname)
% this function merge files in the listfiles var that must be cell array
% and define [pathname, filename]
% this function use BTK toolbox >= ver0.2.

for x = 1:length(listofiles)
    VAR(x) = btkReadAcquisition(listofiles{x});
end

if length(VAR) == 2
    ACQ = btkMergeAcquisitions(VAR(1), VAR(2));
elseif length(VAR) == 3
    ACQ = btkMergeAcquisitions(VAR(1), VAR(2), VAR(3));
elseif length(VAR) == 4
    ACQ = btkMergeAcquisitions(VAR(1), VAR(2), VAR(3), VAR(4));    
elseif length(VAR) == 5
    ACQ = btkMergeAcquisitions(VAR(1), VAR(2), VAR(3), VAR(4), VAR(5));
elseif length(VAR) == 6
    ACQ = btkMergeAcquisitions(VAR(1), VAR(2), VAR(3), VAR(4), VAR(5), VAR(6));
elseif length(VAR) == 7
    ACQ = btkMergeAcquisitions(VAR(1), VAR(2), VAR(3), VAR(4), VAR(5), VAR(6), VAR(7));
elseif length(VAR) == 8
    ACQ = btkMergeAcquisitions(VAR(1), VAR(2), VAR(3), VAR(4), VAR(5), VAR(6), VAR(7), VAR(8));
elseif length(VAR) == 9
    ACQ = btkMergeAcquisitions(VAR(1), VAR(2), VAR(3), VAR(4), VAR(5), VAR(6), VAR(7), VAR(8), VAR(9)); 
elseif length(VAR) == 10
    ACQ = btkMergeAcquisitions(VAR(1), VAR(2), VAR(3), VAR(4), VAR(5), VAR(6), VAR(7), VAR(8), VAR(9), VAR(10));
end

%%%%% mettre tous les champs du même nom à la suite
ACQ2 = btkmerge(ACQ, outputname);
btkWriteAcquisition(ACQ2, outputname);

btkDeleteAcquisition(ACQ);
btkDeleteAcquisition(ACQ2);

end

function [ACQ2, MAT] = btkmerge(ACQ, outputname)

ACQ2 = btkCloneAcquisition(ACQ);
%%%%%%% Markers %%%%%%% Angles %%%%%%% Moments %%%%%%% Forces %%%%%%% Powers
[POINTS, POINTSINFOS] = btkGetPoints(ACQ2);
[POINTSm, p_Frames, Pnotused] = btkappend(POINTS, 'matrix');
NUM = nanmax(p_Frames(:, 2));

%%%%%%% Analogs
[ANALOGS, ANALOGSINFOS] = btkGetAnalogs(ACQ2);
[ANALOGSm, ~, Anotused] = btkappend(ANALOGS, 'vector');

%%%%%%%% ForcePlateforme
% [FORCEPLATES, FORCEPLATESINFO] = btkGetForcePlatforms(ACQ2);
% GRW = btkGetGroundReactionWrenches(ACQ2);
% FRW = btkGetGroundReactionWrenches(ACQ2);
% 
% [FORCEPLATESm, ~, FPnotused] = btkappend(FORCEPLATES, 'pff');
% [GRWm, ~, ~] = btkappend(GRW, 'pff');
% [FRWm, ~, ~] = btkappend(FRW, 'pff');

%%%%%%%%%%%%% inscrire les données de l'acquisition
btkSetFirstFrame(ACQ2, 1)
btkSetFrameNumber(ACQ2, NUM)

%%% inscrire les données
%%%%%%%%%%% les nouveaux points
if ~isempty(POINTSm)
    fieldsp = fieldnames(POINTSm);
    btkClearPoints(ACQ2)
    for x = 1:length(fieldsp)
        try
    %         btkSetPoint(ACQ2, fieldsp{x}, POINTSm.(fieldsp{x}));
            unit = POINTSINFOS.units.(fieldsp{x});
            if strcmp(unit, 'mm'), type = 'marker';end
            if strcmp(unit, 'deg'), type = 'angle';end
            if strcmp(unit, 'N'), type = 'force';end
            if strcmp(unit, 'Nmm'), type = 'moment';end
            if strcmp(unit, 'W'), type = 'power';end
            if strcmp(unit, 'V'), type = 'scalar';end
            if isempty(unit), type = 'scalar';end
            btkAppendPoint(ACQ2, type, fieldsp{x}, POINTSm.(fieldsp{x}));
        catch
            disp(['error in file: ', outputname, ' Mkers: ', fieldsp{x}, ' does not exist']);
        end
    end
end

if ~isempty(ANALOGSm)
    fieldap = fieldnames(ANALOGSm);
    btkClearAnalogs(ACQ2)
    for x = 1:length(fieldap)
        try
        unit = ANALOGSINFOS.units.(fieldap{x});
        if strcmp(unit, 'mm'), type = 'marker';end
        if strcmp(unit, 'deg'), type = 'angle';end
        if strcmp(unit, 'N'), type = 'force';end
        if strcmp(unit, 'Nmm'), type = 'moment';end
        if strcmp(unit, 'W'), type = 'power';end
        if strcmp(unit, 'V'), type = 'scalar';end
        if isempty(unit), type = 'scalar';end

        btkAppendAnalog(ACQ2, fieldap{x}, ANALOGSm.(fieldap{x}));
        btkSetAnalogUnit(ACQ2, fieldap{x}, unit);

        catch
            disp(['error in file: ', outputname, ' Analogs: ', fieldap{x}, ' does not exist']);
        end

    end
end

end

function [output, frames, notused] = btkappend(input, datatype, option)

if nargin<3, option = 'nopff';end
notused = {};
switch option
    case 'pff'
        fields = fieldnames(input);
        %%%%%%%%%% Trouver les plateformes avec les mêmes corners
        
    case 'nopff'
        fields = fieldnames(input);
        a = cellfindstr(fields, '_2', 'opposite');
        for x = 1:length(a)
            clear temp 
            if isvarname(fields{a(x)})
                if strcmp(fields{a(x)}, 'CentreOfMass')
                    smlar = cellfindstr(fields, fields{a(x)});
                    fl = cellfindstr(fields(smlar), 'Floor', 'opposite');
                    smlar = smlar(fl);
                else
                    smlar = cellfindstr(fields, fields{a(x)});
                end
                temp = input.(fields{a(x)})(input.(fields{a(x)})(:, 1)~=0, :);
                for xx = 1:length(smlar)
                   clear nonzeroval
                   if smlar(xx) ~= a(x)
                       %%%%%%% Remove zero values
                       nonzeroval = input.(fields{smlar(xx)})(input.(fields{smlar(xx)})(:, 1)~=0, :);
                       temp(end+1:end+size(nonzeroval, 1), :) = nonzeroval;
                       notused(end+1, 1:2) = {smlar(xx), fields{smlar(xx)}};
                   end
                end
                temp(temp(:, 1)==0, :) = NaN;

                output.(fields{a(x)}) = temp;
                FF(x) = 1;
                LF(x) = size(temp, 1);
            else
                output = NaN;notused=NaN;
            end
        end
        
        for x = 1:length(a)
            if isfield(output, fields{a(x)})
                if size(output.(fields{a(x)}), 1)<nanmax(LF)
                    switch datatype
                        case 'matrix'
                            output.(fields{a(x)})(end+1:nanmax(LF), 1:3) = NaN;
                        case 'vector'
                            output.(fields{a(x)})(end+1:nanmax(LF), 1) = NaN;
                    end
                end
            else
                switch datatype
                    case 'matrix'
                        output.(fields{a(x)})(1:nanmax(LF), 1:3) = NaN;
                    case 'vector'
                        output.(fields{a(x)})(1:nanmax(LF), 1) = NaN;
                end
            end
        end
        
        if exist('FF', 'var') && exist('LF', 'var')
            frames = [FF' LF'];
        else
            frames = NaN;
        end
        if ~exist('output', 'var')
            output = [];
            notused = [];
        end
end



end