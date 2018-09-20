function nameFolds = FoldInDir(path, type, ext)
%this function returns all files or folders in the path without '.' & '..'

if nargin<2, type = 'folder';end
type = lower(type);

switch type
    case 'folder'
        d = dir(path);
        isub = [d(:).isdir]; %# returns logical vector
        nameFolds = {d(isub).name}';
        nameFolds(ismember(nameFolds,{'.','..'})) = [];
        
    case 'file'
        if exist('ext', 'var')
            d = dir(fullfile(path, ['*.', ext]));
        else
            d = dir(path);
        end
        isub = [d(:).isdir]; %# returns logical vector
        nameFolds = {d(isub==0).name}';
        nameFolds(ismember(nameFolds,{'.','..'})) = [];        
end

end

