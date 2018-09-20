function [DATA] = mfileload(Filename)

Donnee = load(Filename,'-mat');
field = char(fieldnames(Donnee));
DATA = Donnee.(field);
end