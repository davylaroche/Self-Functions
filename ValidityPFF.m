function [ PFF ] = ValidityPFF(path, file)

% Lecture du fichier .enf du C3D (filename)
% extrait l'information de platform gauche/droite/invalid
% retourne la valeur PFF indiquant le coté/validité de la plateforme 1/2

fichierenf = dir(fullfile(path, strrep(lower(file), '.c3d', '*.enf')));
fid = fopen(fullfile(path, fichierenf.name), 'r');
str = fgetl(fid);
while strncmp(str,'FP1=',4) == 0
    str = fgetl(fid);
end
ValFP1 = strsplit(str,'='); ValFP1 = strsplit(ValFP1{2});
while strncmp(str,'FP2=',4) == 0
    str = fgetl(fid);
end
ValFP2 = strsplit(str,'='); ValFP2 = strsplit(ValFP2{2});
fclose(fid);
PFF.FP1 = ValFP1;
PFF.FP2 = ValFP2;


end

