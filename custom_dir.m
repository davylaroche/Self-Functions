function  listdir = custom_dir(path, arg)
%%% this function give list of content from the path : "path"
%%% it give path without . or .. with argument 'path'
%%% it give files with argument 'file'

switch arg
    case 'file'
        listdir = dir(path);       
    case 'path'
        temp = dir(path);
        indx=[];
        for c1=1:length(temp);
            if temp(c1).isdir==1 && (~strcmpi(temp(c1).name, '..') && ~strcmpi(temp(c1).name, '.'))
                indx(end+1) = c1;
            end
        end
        listdir = temp(indx);
end


end