function [Tracks, Forces, EMG, fileinfo] = getC3D(c3dFileDynamic, type)
%global itf

%%%%%%%% Getting file informations
a = strfind(c3dFileDynamic, '\');
fileinfo.name = c3dFileDynamic(a(end)+1:end);
fileinfo.path = c3dFileDynamic(1:a(end));
fileinfo.type = type;

% keyDyn = getEvents(c3dFileDynamic, 2, [1 2]);

if ~isempty(strfind(type, 'kin'))

    [Tracks, frequ, Markerset, subject] = getMarkers(c3dFileDynamic);
    fileinfo.video_rate = frequ;
    fileinfo.Markerset = Markerset;
    fileinfo.subject = subject;
    
else
    Tracks = NaN;
end

if ~isempty(strfind(type, 'pff'))
    [Forces, C3DKey] = getKinetics(c3dFileDynamic);
    fileinfo.Force_plate = C3DKey;
else
   Forces = NaN; 
end

if ~isempty(strfind(type, 'emg'))
    [EMG, C3Dkey] = getEMG(c3dFileDynamic);
    fileinfo.EMG = C3Dkey;
else
     EMG = NaN; 
end  

%if multiple == 0, close(itf);end

end

% Get kinematic marker positions 
% --------------------------------------------------------------------
% Usage: markers = getMarkers(c3dFile)
% --------------------------------------------------------------------
% 
% Inputs:   c3dFile: the C3D filename with path
 % 
% Outputs:  Tracks:  Struct sorted by labels with XYZ position

function [Tracks, MOTIONfreq, markerSet, name] = getMarkers(c3dFile)
%global itf
% Load c3d files
% --------------
itf = c3dserver();
openc3d(itf, 0, c3dFile);

% Extract Subject Information
% ---------------------------
aIndex = itf.GetParameterIndex('SUBJECTS', 'NAMES');
name = itf.GetParameterValue(aIndex, 0);

aIndex = itf.GetParameterIndex('SUBJECTS', 'MARKER_SETS');
markerSet = itf.GetParameterValue(aIndex, 0);

framesTotal = nframes(itf);
C_index = itf.GetParameterIndex('TRIAL', 'CAMERA_RATE');
MOTIONfreq = double(itf.GetParameterValue(C_index, 0));

startF = itf.GetVideoFrame(0);
endF = itf.GetVideoFrame(1);

% Extract marker position data from c3d files and
% transform it into the appropiate coordinate system 
% ---------------------------------------------------
var = [];
frames = (startF:endF)';
nIndex = itf.GetParameterIndex('POINT', 'LABELS');
nItems = itf.GetParameterLength(nIndex);

for j = 1:nItems 
    clear target_name XYZPOS RESIDS residindex signal_index
    target_name = itf.GetParameterValue(nIndex, j-1);
    signal_index = j-1;

    XYZPOS(:,1) = itf.GetPointDataEx(signal_index,0,startF,endF,'1');
    XYZPOS(:,2) = itf.GetPointDataEx(signal_index,1,startF,endF,'1');
    XYZPOS(:,3) = itf.GetPointDataEx(signal_index,2,startF,endF,'1');
    RESIDS(:,1) = itf.GetPointResidualEx(signal_index,startF,endF);

    XYZPOS = cell2mat(XYZPOS);
    RESIDS = cell2mat(RESIDS);
    residindex = find(RESIDS == -1);
    XYZPOS(residindex, :) = NaN;    
    
    if startF > 1, temp(1:startF-1, 1:3) = NaN; XYZPOS = [temp;XYZPOS]; end
    
    Tracks.([target_name, '_X']) = double(XYZPOS(:, 1));
    Tracks.([target_name, '_Y']) = double(XYZPOS(:, 2));
    Tracks.([target_name, '_Z']) = double(XYZPOS(:, 3));
end
closec3d(itf);
end

% Extract and process kinetic data (GRF, CoP) from a C3D file.
% ----------------------------------------------------------------------
% Usage: [Forces, CoP, C3Dkey] = getKinetics(C3Dfile)
% ----------------------------------------------------------------------

function [Forces, C3Dkey] = getKinetics(c3dFile, C3Dkey)
%global itf
% -------------------------------------------
% Load important parameters from the c3d file
% -------------------------------------------
x = 1; y = 2; z = 3;
itf = c3dserver();
openc3d(itf, 0, c3dFile);

C3Dkey.FP_CALIB(:, 1) = [200 903 0];
C3Dkey.FP_CALIB(:, 2) = [200 300 0];

C3Dkey.dirVec.FPMODEL  = [2 1 -3];
C3Dkey.dirVec.VICMODEL = [2 -1 3];
C3Dkey.dirVec.FPVICON(:, 2) = [-1 2 -3];
C3Dkey.dirVec.FPVICON(:, 1) = [1 -2 -3];

% Extract Trial Information
% -------------------------
aRIndex = itf.GetParameterIndex('ANALOG', 'RATE');
C3Dkey.Sample_rate = double(itf.GetParameterValue(aRIndex, 0));

FUIndex = itf.GetParameterIndex('FORCE_PLATFORM', 'USED');
C3Dkey.numPlatesUsed = double(itf.GetParameterValue(FUIndex, 0));

for j = 1:C3Dkey.numPlatesUsed
    clear field
    field = ['PFF', num2str(j)];
    Forces.(field) = [];
end
%PFF = 1;

C3Dkey.analog2video = double(itf.GetAnalogVideoRatio);
C3Dkey.numFrames.uncroppedV = nframes(itf);
C3Dkey.numFrames.uncroppedA = C3Dkey.numFrames.uncroppedV * C3Dkey.analog2video - C3Dkey.analog2video + 1;

PMIndex = itf.GetParameterIndex('POINT', 'MOMENT_UNITS');
try
    C3Dkey.Moment_Units = itf.GetParameterValue(PMIndex, 0);
catch
    C3Dkey.Moment_Units = 'Nmm';
end

PFIndex = itf.GetParameterIndex('POINT', 'FORCE_UNITS');
try 
    C3Dkey.Force_Units = itf.GetParameterValue(PFIndex, 0);
catch
    C3Dkey.Force_Units = 'N';
end

nIndex = itf.GetParameterIndex('ANALOG', 'LABELS');
nItems = itf.GetParameterLength(nIndex);

uIndex = itf.GetParameterIndex('ANALOG', 'UNITS');


startF = itf.GetVideoFrame(0);%*C3Dkey.analog2video;
endF = itf.GetVideoFrame(1);%*C3Dkey.analog2video;

C3Dkey.numFrames.croppedV = nframes(itf);
C3Dkey.numFrames.croppedA = nframes(itf) * C3Dkey.analog2video;

for i = 1:nItems
    clear target_name units
    value = 0;
    target_name = itf.GetParameterValue(nIndex, i-1);
    units = itf.GetParameterValue(uIndex, i-1);
    if strcmp(units, C3Dkey.Moment_Units) || strcmp(units, C3Dkey.Force_Units)
        if isnan(str2double(target_name(end)))
            if i>1
                for jj = 1:size(target_field, 1)
                    if strcmp(char(target_field(jj, 1)), target_name)
                        value = jj;
                    end
                end
                if value == 0
                    target_field(i, 1) = {target_name};
                    target_field(i, 2) = {1};   
                else
                    target_field(i, 1) = {target_name};
                    target_field(i, 2) = {cell2mat(target_field(value, 2))+1};
                end
            else
                target_field(i, 1) = {target_name};
                target_field(i, 2) = {1};
            end
        else
            target_field(i, 1) = {target_name};
            target_field(i, 2) = {str2double(target_name(end))};
        end
    end
end

for i = 1:nItems
    target_name = itf.GetParameterValue(nIndex, i-1);
    units = itf.GetParameterValue(uIndex, i-1);
    if strcmp(units, C3Dkey.Moment_Units) || strcmp(units, C3Dkey.Force_Units)
        pff = cell2mat(target_field(i, 2));
        field = ['PFF', num2str(cell2mat(target_field(i, 2)))];
        if strfind(lower(target_name), 'fx')
            Forces.(field).Value(:, 1) = cell2mat(itf.GetAnalogDataEx(i-1,startF, endF,'1',0,0,'0'));
            Forces.(field).labels(1) = {'Fx'};
            F_all(x, :, pff) = double(Forces.(field).Value(:, 1));
            
        elseif strfind(lower(target_name), 'fy')
            Forces.(field).Value(:, 2) = cell2mat(itf.GetAnalogDataEx(i-1,startF, endF,'1',0,0,'0'));
            Forces.(field).labels(2) = {'Fy'};
            F_all(y, :, pff) = double(Forces.(field).Value(:, 2));
            
        elseif strfind(lower(target_name), 'fz')
            Forces.(field).Value(:, 3) = cell2mat(itf.GetAnalogDataEx(i-1,startF, endF,'1',0,0,'0'));
            Forces.(field).labels(3) = {'Fz'};
            F_all(z, :, pff) = double(Forces.(field).Value(:, 3));

        elseif strfind(lower(target_name), 'mx')
            Forces.(field).Value(:, 4) = cell2mat(itf.GetAnalogDataEx(i-1,startF, endF,'1',0,0,'0'));
            Forces.(field).labels(4) = {'Mx'};
            Mo_all(x, :, pff) = double(Forces.(field).Value(:, 4));

        elseif strfind(lower(target_name), 'my')
            Forces.(field).Value(:, 5) = cell2mat(itf.GetAnalogDataEx(i-1,startF, endF,'1',0,0,'0'));
            Forces.(field).labels(5) = {'My'};
            Mo_all(y, :, pff) = double(Forces.(field).Value(:, 5));

        elseif strfind(lower(target_name), 'mz')
            Forces.(field).Value(:, 6) = cell2mat(itf.GetAnalogDataEx(i-1,startF, endF,'1',0,0,'0'));
            Forces.(field).labels(6) = {'Mz'};
            Mo_all(z, :, pff) = double(Forces.(field).Value(:, 6));

        end     
    end
end

% --------------------------------------------------
% Calculate CoP & GRMx data from extracted variables
% --------------------------------------------------
% Finds the global CoP (VICON COORDS) for each plate in each direction
% Finds the GRM about CoP for each plate in each direction
% 
% referenced from: http://www.kwon3d.com/theory/grf/cop.html
% --------------------------------------------------------------------
FP = calPlateLOrigin2GCenter(itf, C3Dkey);

for i = 1:C3Dkey.numPlatesUsed   % Force Plate Loop (i)
    clear field vec
    field = ['PFF', num2str(i)];
    
    % Determine local force plate origin values
    % This comes from the individual callibration of each force plate
    % ---------------------------------------------------------------
    a = FP.localOriginsGLOB(x,i);
    b = FP.localOriginsGLOB(y,i);
    c = FP.localOriginsGLOB(z,i);
    
    
    % Determine vector from FP origin to CoP in FORCE PLATE coordinates
    % vecA::  FP_ORIGIN -> CoP (FP COORDS)
    % -----------------------------------------------------------------
   
    vecA(x,:) = (((-Mo_all(y,:,i) - (c * F_all(x,:,i))) ./ F_all(z,:,i)) + a);
    vecA(y,:) = (( Mo_all(x,:,i) - (c * F_all(y,:,i))) ./ F_all(z,:,i)) + b;
    vecA(z,:) = ones(1, C3Dkey.numFrames.croppedA) * FP.localOriginsFP(i,z);
    
    % Convert now to VICON coordinate system
    % FPorig2CoP:: FP_ORIGIN -> CoP (VICON COORDS)
    % --------------------------------------------
   
    FPorig2CoP = coordChange(vecA, C3Dkey.dirVec.FPVICON(:, i));
    
    % A small check to see if the force plate origin is correct.
    % FPorig2CoP = zeros(3, C3Dkey.numFrames.croppedA);
    
    
    % Calculate CoP from VICON ORIGIN (all in VICON coordinates)
    % X_all:: VICON_ORIGIN -> FP_ORIGIN (VICON COORDS) 
    %          + FP_ORIGIN -> CoP       (VICON COORDS)
    % ----------------------------------------------------------
    for j = 1:3               % Coordinate Loop  (j)
        X_all(j,:,i) = (ones(1, C3Dkey.numFrames.croppedA) ...
            * FP.viconOrig2FPorigGLOB(j,i) + FPorig2CoP(j,:));
    end
    
    % Calculate Moments about CoP (FP COORDS)
    % ---------------------------------------
    
    % Tx: Should be 0 by definition
    % Tx = Mxo -c.Fy - (Ycop - b)Fz
    Mx_all(x,:,i) = Mo_all(x,:,i) ...
        - ( (c * F_all(y,:,i)) ) ...
        - ( (vecA(y,:) - b) .* F_all(z,:,i) );
    
    % Ty: Should be 0 by definition
    % Ty = Myo +c.Fx + (Xcop - a)Fz
    Mx_all(y,:,i) = Mo_all(y,:,i) ...
        + ( (c * F_all(x,:,i)) ) ...
        + ( (vecA(x,:) - a) .* F_all(z,:,i) );
    
    % Tz: Free moment is nonzero
    % Tz = Mzo + (Ycop - b)Fx - (Xcop - a)Fy
    Mx_all(z,:,i) = Mo_all(z,:,i) ...
        + ( (vecA(y,:) - b) .* F_all(x,:,i) ) ...
        - ( (vecA(x,:) - a) .* F_all(y,:,i) );  
   
    Forces.(field).CoP = [squeeze(X_all(:, :, i));squeeze(Mx_all(:, :, i))]'; 
end

closec3d(itf);

end


% Extract raw EMG data EMG(t) from a C3D file

% --------------------------------------------------------------------
% Usage: [EMG, EMGVecGlob] = getEMG(C3Dfile)
% --------------------------------------------------------------------
% 
% Inputs:   C3Dkey: the C3D key structure from getEvents
%           emgSetName: the label of EMG names contained in the EMG set
%               (this must be defined in loadlabels.m as glab.[emgSetName])
% 
% Outputs:  EMGVecGlob.MUSCNAME.time = time vector (starting from 0 in analog freq)
%           EMG = raw EMG data vector (V)
%           EMGVecGlob.MUSCNAME.name = string of muscle label
% 
% ---------------------------------------------------------------------
function FP = calPlateLOrigin2GCenter(itf, C3Dkey)

FP.order = [1 2];
   
x = 1; y = 2; z = 3;
Corner_index = itf.GetParameterIndex('FORCE_PLATFORM', 'CORNERS');
Origin_index = itf.GetParameterIndex('FORCE_PLATFORM', 'ORIGIN');
Type_index = itf.GetParameterIndex('FORCE_PLATFORM', 'TYPE');

for i = 1:length(FP.order)      % Force Plate Loop (i)
    
    FP.type = double(itf.GetParameterValue(Type_index, FP.order(i)-1));
        
    for j = 1:4                 % Corner Loop for extracting corners
        for k = 1:3             % Direction Loop for extracting corners
            FP.corners(j,k,i) = double(itf.GetParameterValue(Corner_index, ...
                12*(FP.order(i)-1)+3*(j-1)+k-1));
        end
    end
    
    for k = 1:3                 % Direction loop to extract local origins
        FP.localOriginsFP(i,k) = double(itf.GetParameterValue(Origin_index, ...
            3*(FP.order(i)-1)+k-1));
    end
    
    % Get force plate surface centers (global vicon coordinates)
    % corners must be labelled sequentially
    % (bug fixed TD June 2009)
    FP.viconOrig2FPcenterSurfaceGLOB(i,x) = (FP.corners(3,x,i) - ...
        FP.corners(1,x,i))/2 + FP.corners(1,x,i);
    FP.viconOrig2FPcenterSurfaceGLOB(i,y) = (FP.corners(3,y,i) - ...
        FP.corners(1,y,i))/2 + FP.corners(1,y,i);
    FP.viconOrig2FPcenterSurfaceGLOB(i,z) = mean(FP.corners(:,z,i));
    
    FP.localOriginsGLOB(:, i) = coordChange(FP.localOriginsFP(i, :)', C3Dkey.dirVec.FPVICON(:, i))';
    FP.viconOrig2FPorigGLOB(:, i) = FP.viconOrig2FPcenterSurfaceGLOB(i, :)' - FP.localOriginsGLOB(:, i);
end

% Convert the vector from FP true origin --> FP top surface center
% from FP coordinate system to VICON global coordinate system


% Vector addition from VICON ORIGIN --> CENTER OF PLATE SURFACE
% and CENTER OF PLATE SURFACE --> PLATE TRUE ORIGIN
% (all represented in global VICON coordinate system)


% Convert the force plate corner data into the model coordinate system
% (it may be usful later on)
cornersNew = [];
for i = 1:C3Dkey.numPlatesUsed
    cornersNew(:,:,i) = coordChange(FP.corners(:,:,i)', C3Dkey.dirVec.VICMODEL)';
end
FP.corners_model = cornersNew;

end

function [EMG, C3Dkey] = getEMG(c3dFile)

% Set up some initial parameters and do some initial checks
% ---------------------------------------------------------
mag = 1000;             % (from mV to uV)
Units = 'V';

% Extract EMG data
% ----------------
itf = c3dserver();
openc3d(itf, 0, c3dFile);
out.names = [];

% Extract Trial Information
% -------------------------
aIndex = itf.GetParameterIndex('ANALOG', 'RATE');
C3Dkey.Sample_rate = double(itf.GetParameterValue(aIndex, 0));

C3Dkey.analog2video = double(itf.GetAnalogVideoRatio);

nIndex = itf.GetParameterIndex('ANALOG', 'LABELS');
nItems = itf.GetParameterLength(nIndex);

uIndex = itf.GetParameterIndex('ANALOG', 'UNITS');
C3Dkey.EMG_Units = Units;

startF = itf.GetVideoFrame(0);
endF = itf.GetVideoFrame(1);

numeric = ['1' '2' '3' '4' '5' '6' '7' '8' '9' '0'];
for i = 1:nItems
    clear target_name target
    target = itf.GetParameterValue(nIndex, i-1);
    
    %%%%%% replace invalid characters
    [target_name] = repinv_char(target);
    
    units = itf.GetParameterValue(uIndex, i-1);
    
    if strcmp(units, C3Dkey.EMG_Units) && isempty(findstr(numeric, target_name(1)))
        EMG.(target_name).raw = double(cell2mat(itf.GetAnalogDataEx(i-1,startF, endF,'1',0,0,'0')));
        EMG.(target_name).time = startF:endF; 
    end

end

closec3d(itf);

end