function MissedValues
%%% Cette fonction remplace les données manquantes avec la technique du biais maximum

%% File to load
file2load = 'E:\DATA\Ergocycle\Stats 50 patients\Data 11-02-2014 meaned replacement.xlsx';
[~, ~, raw] = xlsread(file2load, 'replacedValues1');

%% Parameters
headersize = 3;
groupecol = 2;
sujcol = 1;
tpscol = 3;
replacement_methods = 'Mean Values'; % 3 choices : 'Mean Values' / 'Biais Max' / 'LOCF'

%%%%% Déterminer le nombre de groupe et de tps
groupes = unique(raw(2:end, groupecol));
tps = unique(raw(2:end, tpscol));

%%%%% Si biais maximum donner groupe à maximiser et à minimiser ainsi que
%%%% define max or min biais for parameters
groupemax = 'CONC'; groupemin = 'EXC';
param = {'FC max' 'Pic VO2 après retraitement' 'SV1 après retraitement' 'QR après retraitement' 'TAS' 'TAD' 'Puissance max (w)' 'Tps 1/2 récup (s)'...
    'S0 Distance TM6' 'S0 VO2 TM6' 'S0 FC REPOS TM6' 'S0 FC FINAL TM6' 'S0 FC MOY' 'S0 D/6/FC' 'SO TUG' 'Force max Quadri ' 'Force max triceps'};
keyparam = {'max', 'max', 'max', 'max', 'min', 'min', 'max', 'min', 'max', 'max', 'min', 'min', 'min', 'max', 'min', 'max', 'max'};
container = containers.Map(param, keyparam);

%%%  Déterminer le type de remplacement
if ~strcmp(replacement_methods, 'LOCF')
    
    for c1 = 1:length(groupes)
        for c2 = 1:length(tps)
            grp.(groupes{c1}).(tps{c2}) = ismember(raw(2:end, groupecol), groupes{c1}) & ismember(raw(2:end, tpscol), tps{c2});
            if strcmp(groupes{c1}, groupemax)
                grp.(groupes{c1}).biais = 'Maxi';
            elseif strcmp(groupes{c1}, groupemin)
                grp.(groupes{c1}).biais = 'Mini';
            else
                grp.(groupes{c1}).biais = 'None';
            end
        end
    end

    %% parcourir le fichier à la recherche de valeurs manquantes
    for x = headersize+1:size(raw, 2)
        clear valtemp
        valtemp = cell2mat(raw(2:end, x));

        for xx = 1:size(raw, 1)-1
            clear temp

            if isnan(valtemp(xx))
                switch replacement_methods    
                    case 'Biais Max'

                        if (strcmp(container(raw{1, x}), 'max') && strcmp(grp.(raw{xx+1, groupecol}).biais, 'max')) || (strcmp(container(raw{1, x}), 'min') && strcmp(grp.(raw{xx+1, groupecol}).biais, 'min'))
                            temp = nanmax(valtemp(grp.(raw{xx+1, groupecol}).(raw{xx+1, tpscol})==1));
                        elseif (strcmp(container(raw{1, x}), 'min') && strcmp(grp.(raw{xx+1, groupecol}).biais, 'max')) || (strcmp(container(raw{1, x}), 'max') && strcmp(grp.(raw{xx+1, groupecol}).biais, 'min')) 
                            temp = nanmin(valtemp(grp.(raw{xx+1, groupecol}).(raw{xx+1, tpscol})==1));
                        elseif (strcmp(container(raw{1, x}), 'max') || strcmp(container(raw{1, x}), 'max')) && strcmp(grp.(raw{xx+1, groupecol}).biais, 'none')
                            temp = nanmean(valtemp(grp.(raw{xx+1, groupecol}).(raw{xx+1, tpscol})==1));
                        end

                    case 'Mean Values'

                        temp = nanmean(valtemp(grp.(raw{xx+1, groupecol}).(raw{xx+1, tpscol})==1));

                end

                raw(xx+1, x) = num2cell(temp);
            end
        end
    end
    xlswrite(file2load, raw, 'replacedValues');
else
    %%%%% Déterminer le nombre de sujets
    subjects = unique(raw(2:end, sujcol));
    dataraw = raw(2:end, headersize+1:end);
    
    lineS0 = ismember(raw(:, tpscol), 'S00');
    groupeC = containers.Map(raw(lineS0==1, sujcol), raw(lineS0==1, groupecol));
    
    for c1 = 1:length(subjects)
        for c3 = 1:length(tps)
            grp.(subjects{c1}).(tps{c3}) = ismember(raw(2:end, sujcol), subjects{c1}) & ismember(raw(2:end, tpscol), tps{c3});
            data.(subjects{c1}).(tps{c3}) = dataraw(grp.(subjects{c1}).(tps{c3})==1, :);
        end
    end
    
    for c1 = 1:length(subjects)
        for c3 = 1:length(tps)
            for c4 = 1:size(data.(subjects{c1}).(tps{c3}), 2)
                if isnan(cell2mat(data.(subjects{c1}).(tps{c3})(1, c4)))
                    completed = 0;
                    if c3 ~= 1
                        for c5 = 1:c3-1
                           if ~isnan(cell2mat(data.(subjects{c1}).(tps{c3-c5})(1, c4))) && completed == 0
                               data.(subjects{c1}).(tps{c3})(1, c4) = data.(subjects{c1}).(tps{c3-c5})(1, c4);
                               completed = 1;
                           elseif isnan(cell2mat(data.(subjects{c1}).(tps{c3-c5})(1, c4))) && completed == 0
                               data.(subjects{c1}).(tps{c3})(1, c4) = {NaN};
                           end
                        end
                    else
                        data.(subjects{c1}).(tps{c3})(1, c4) = {NaN};
                    end
                end
            end
        end
    end
    
    exportraw = raw(1, :);
    for c1 = 1:length(subjects)
        for c3 = 1:length(tps)
            exportraw(end+1, sujcol) = subjects(c1);
            exportraw(end, groupecol) = {groupeC(subjects{c1})};
            exportraw(end, tpscol) = tps(c3);
            exportraw(end, headersize+1:end) = data.(subjects{c1}).(tps{c3})(1, :);
        end
    end
    
   xlswrite(file2load, exportraw, 'replacedValues');   
end


% xlswrite(file2load, [keys(container);values(container)], 'keys')
       
end


