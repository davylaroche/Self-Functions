function [Tracks, Forces, EMG, fileinfo] = getmultipleC3D(filename, path, typeofdata)
%%%% This function load multiple C3D file and merge in one 
Tracks = struct();
Forces = struct();
EMG = struct();
fileinfo = struct();

for x = 1:length(filename)
    clear file t_Tracks t_Forces t_EMG t_fileinfo
            
    if isstruct(filename)
        file = [path, filename(x).name];
        
    elseif iscell(filename)
        file = [path, char(filename(x))];

    else
        error 'Input must be multiple'
    end
    
    clear field field_info
    
    [t_Tracks, ~, ~, ~, ~, t_EMG, t_Forces, t_fileinfo] = BTK_Extract( FILENAME, options );
%     [t_Tracks, t_Forces, t_EMG, t_fileinfo] = getC3D(file, typeofdata);
    
    field_info = fieldnames(t_fileinfo);
    for xx = 1:length(field_info)
        if isfield(fileinfo, char(field_info(xx)))
            fileinfo.(char(field_info(xx)))(end+1:end+size(t_fileinfo.(char(field_info(xx))), 1)) = {t_fileinfo.(char(field_info(xx)))};
        else
            fileinfo.(char(field_info(xx))) = {t_fileinfo.(char(field_info(xx)))};
        end
    end 
    
    clear field 
    if findstr('kin', typeofdata)
        field = fieldnames(t_Tracks);
        for xx = 1:length(field)
            if isfield(Tracks, char(field(xx)))
                Tracks.(char(field(xx)))(end+1:end+size(t_Tracks.(char(field(xx))), 1)) = t_Tracks.(char(field(xx)));
            else
                Tracks.(char(field(xx))) = t_Tracks.(char(field(xx)));
            end
        end           
    end
    
    clear field 
    if findstr('pff', typeofdata)
        fieldinside = [{'Value'}, {'labels'}, {'CoP'}];
        field = fieldnames(t_Forces);
        for xx = 1:length(field)
            if isfield(Forces, char(field(xx)))
                if isfield(Forces.(char(field(xx))), char(fieldinside(1)))
                    Forces.(char(field(xx))).(char(fieldinside(1)))(end+1:end+size(t_Forces.(char(field(xx))).(char(fieldinside(1))), 1), :) = t_Forces.(char(field(xx))).(char(fieldinside(1)));
                else
                    Forces.(char(field(xx))).(char(fieldinside(1)))= t_Forces.(char(field(xx))).(char(fieldinside(1)));
                end
                if isfield(Forces.(char(field(xx))), char(fieldinside(2)))
                    Forces.(char(field(xx))).(char(fieldinside(2)))(end+1:end+size(t_Forces.(char(field(xx))).(char(fieldinside(2))), 1), :) = t_Forces.(char(field(xx))).(char(fieldinside(2)));
                else
                    Forces.(char(field(xx))).(char(fieldinside(2)))= t_Forces.(char(field(xx))).(char(fieldinside(2)));
                end
                if isfield(Forces.(char(field(xx))), char(fieldinside(3)))
                    Forces.(char(field(xx))).(char(fieldinside(3)))(end+1:end+size(t_Forces.(char(field(xx))).(char(fieldinside(3))), 1), :) = t_Forces.(char(field(xx))).(char(fieldinside(3)));
                else
                    Forces.(char(field(xx))).(char(fieldinside(3)))= t_Forces.(char(field(xx))).(char(fieldinside(3)));
                end
            else
                Forces.(char(field(xx))) = t_Forces.(char(field(xx)));
            end
        end
    end
    
    clear field 
    if findstr('emg', typeofdata)
        field = fieldnames(t_EMG);
        for xx = 1:length(field)
            if isfield(EMG, char(field(xx)))
                EMG.(char(field(xx)))(end+1:end+size(t_EMG.(char(field(xx))), 1)) = t_EMG.(char(field(xx)));
            else
                EMG.(char(field(xx))) = t_EMG.(char(field(xx)));
            end
        end
    end

    
end
end