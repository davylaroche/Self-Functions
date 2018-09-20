function [ varargout ] = BTK_Extract( FILENAME, options )
% [MARKERS, ANGLES, MOMENTS, POWERS, FORCES, ANALOGS, FORCEPLATES, infos] = BTK_Extract( FILENAME, options );
% cette fonction extrait les données précisées dans le fichier option
% ('kin', 'dyn', 'pwr', 'analog', 'pff')
% varargout = [mkers, kin, dyn, pwr, forces, analog, PFF, GRW, et infos]
% GRW.P is the CoP in global reference frame

if nargin<2, options.kin = 1; options.dyn = 1; options.pwr = 1; options.analog = 1; options.pff = 1; end

%%% Lire le fichier C3D
H = btkReadAcquisition(FILENAME);

%%% Stocker les informations sur le fichier
slash = strfind(FILENAME, '\');
infos.filename = FILENAME(slash(end)+1:end);
infos.pathname = FILENAME(1:slash(end));
IDSUJ = btkFindMetaData(H, 'SUBJECTS', 'NAMES');
ID = IDSUJ.info.values;
MarkerS = btkFindMetaData(H, 'SUBJECTS', 'MARKER_SETS');
MarkerSet = MarkerS.info.values;

if options.kin == 1
    disp('####################### Extraction of trajectories #######################')
    % extract trajectories
    [MARKERS, MARKERSINFO] = btkGetMarkers(H);
    MARKERSINFO.LABELS = fieldnames(MARKERS);
    
    disp('####################### Extraction of angles #######################');
    % extract angles
    [ANGLES, ANGLESINFO] = btkGetAngles(H);
    ANGLESINFO.LABELS = fieldnames(ANGLES);
else
    MARKERS = NaN; MARKERSINFO=NaN;
    ANGLES=NaN; ANGLESINFO=NaN;
end
if options.dyn == 1
    disp('####################### Extraction of forces #######################');
    % extract moments
    [FORCES, FORCESINFO] = btkGetForces(H);
    MOMENTSINFO.LABELS = fieldnames(FORCES);
    
    disp('####################### Extraction of moments #######################');
    % extract moments
    [MOMENTS, MOMENTSINFO] = btkGetMoments(H);
    MOMENTSINFO.LABELS = fieldnames(MOMENTS);
else
    FORCES=NaN; FORCESINFO=NaN;
    MOMENTS=NaN; MOMENTSINFO=NaN;
end
if options.dyn == 1
    disp('####################### Extraction of powers #######################');
    % extract powers
    [POWERS, POWERSINFO] = btkGetPowers(H);
    POWERSINFO.LABELS = fieldnames(POWERS);
else
    POWERS=NaN; POWERSINFO=NaN;
end
if options.analog == 1  
    disp('####################### Extraction of analogs #######################');
    [ANALOGS, ANALOGSINFO] = btkGetAnalogs(H);
    ANALOGSINFO.LABELS = fieldnames(ANALOGS);
else
    ANALOGS=NaN; ANALOGSINFO=NaN;
end
if options.pff == 1  
    disp('####################### Extraction of analogs #######################');
    [FORCEPLATES, FORCEPLATESINFO] = btkGetForcePlatforms(H);
    GRW = btkGetGroundReactionWrenches(H); % GRW.P => CoP in VICON reference frame
                                           % GRW.F => Force in VICON reference frame
                                           % GRW.M => Force in VICON reference frame
else
    FORCEPLATES=NaN; FORCEPLATESINFO=NaN; GRW=NaN;
end

%%% Ecrire les fichier de sortie

%%%%%%% Fichier infos
infos.FirstFrame = btkGetFirstFrame(H);
infos.LastFrame = btkGetLastFrame(H);
infos.SubjectID = ID;
infos.MarkerSet = MarkerSet;
infos.kin.trajectories = MARKERSINFO;
infos.kin.angles = ANGLESINFO;
infos.dyn = MOMENTSINFO;
infos.pwr = POWERSINFO;
infos.frc = FORCESINFO;
infos.analog = ANALOGSINFO;
infos.pff = FORCEPLATESINFO;

%%%%%% Free memory
btkDeleteAcquisition(H);

%%%%%%% Fichier data
varargout = {MARKERS, ANGLES, MOMENTS, POWERS, FORCES, ANALOGS, FORCEPLATES, GRW, infos};


end

