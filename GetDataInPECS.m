function [frequency, Tracks, Forces, EMG, fileinfo] = GetDataInPECS(type)

%% Lire dans le serveur
hServer = actxserver( 'PECS.Document' );
invoke( hServer, 'Refresh' );
hTrial = get(hServer, 'Trial' );

%% Prendre les données
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% Récupérer les trajectoires des marqueurs et Récupérer les
%%%%%%%%%%%%% angles du plugIn Gait
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nb_traj = get(hTrial, 'TrajectoryCount');
tracks = [];
frequency.Video = get(hTrial, 'VideoRate');
labels = {};

%%%%%%%%%% Getting file Informations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
E_Node = invoke(hTrial, 'EclipseNode');
filename = get(E_Node, 'Title');
path = get(hTrial, 'DataPath');
exercice = 'marche';

if findstr(lower(path), 'marche'); exercice = 'marche';end
if findstr(lower(path), 'tug'); exercice = 'TUG';end
if findstr(lower(path), 'posture'); exercice = 'posture';end

fileinfo.path = path;
fileinfo.name = filename;
fileinfo.type = exercice;

if exist('loadlabels.m', 'file'); loadlabels;end

h = waitbar(0, 'Reading data from PECS server.....');
if ~isempty(strfind(type, 'kin'))
    
    for nb=0:nb_traj-1
        waitbar((double(nb)/double((nb_traj-1)))*0.25, h);

        clear A marqueur temp  
        int = get(hTrial, 'Trajectory', nb);
        A = get(int, 'Label');
        labels = [labels, A];
        marqueur = invoke(hTrial, 'FindTrajectory', A);
        First = get(marqueur, 'FirstValidFieldNum' );
        Last = get(marqueur, 'LastValidFieldNum' );
        temp = get(marqueur, 'GetPoints', First, Last);
        tracks(First:Last, end+1:end+3) = temp';
        if First > 1, tracks(1:First-1, end-2:end) = NaN;end
        if Last < size(tracks, 1), tracks(Last+1:end, end-2:end) = NaN;end
    end

    for i = 1:size(tracks, 2)
        tracks(tracks(:, i)==0, i) = NaN;
    end

    %%%%%%%%%%%%%%%%%%%% Créer le container
    for x = 1:length(labels)
        label(3*x-2) = {[char(labels(x)), '_X']};
        label(3*x-1) = {[char(labels(x)), '_Y']};
        label(3*x) = {[char(labels(x)), '_Z']};

        Tracks.(char(label(3*x-2))) = tracks(:, 3*x-2);
        Tracks.(char(label(3*x-1))) = tracks(:, 3*x-1);
        Tracks.(char(label(3*x))) = tracks(:, 3*x);
    end
else
    Tracks = []; 
end
if ~isempty(strfind(type, 'pff'))
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%% Récupérer les Forces
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    nb_pff = get(hTrial, 'ForcePlateCount');
    
    for nb = 0:nb_pff-1
        waitbar(0.25+(double(nb)/double((nb_pff-1)))*0.25, h);
        clear forces samplerate interm field First Last
        field = ['PFF', num2str(nb+1)];
        interm = invoke(hTrial, 'ForcePlate', nb);
        samplerate = get(interm, 'SampleRate');
        analog2Video_I = invoke(interm, 'AnalogToVideoRatio');
        analog2Video = get(analog2Video_I, 'Numerator')/get(analog2Video_I, 'Denominator');
        First = get(interm, 'FirstSampleNum');
        Last = get(interm, 'LastSampleNum');
        fin = round(Last/analog2Video);
        
        if First>0
            forces(First:Last, :) = get(interm, 'GetForces', First, Last)';
        else
            forces(First+1:Last+1, :) = get(interm, 'GetForces', First, Last)';
            fin = fin-1;
        end
        
        if First > 1, forces(1:First-1, :) = NaN;end
        if Last < fin, forces(Last+1:fin, :) = NaN;end
        if First>0
            CoP(First:Last, :) = get(interm, 'GetCenterOfPressures', First, Last)';
        else
            CoP(First+1:Last+1, :) = get(interm, 'GetCenterOfPressures', First, Last)';
        end
        if First > 1, CoP(1:First-1, :) = NaN;end
        if Last < fin, CoP(Last+1:fin, :) = NaN;end
        
        Forces.(field).Rate = samplerate;
        Forces.(field).Values = forces;
        Forces.(field).CoP = CoP;
        
    end
    frequency.Analog = samplerate;
    frequency.Analog2VideoRatio = analog2Video;
else
   Force = []; 
end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%% Récupérer les Données analogiques
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Liste des cannaux
if ~isempty(strfind(type, 'emg'))
    nb_cannaux = invoke(hTrial, 'AnalogChannelCount');
    if nb_cannaux>0
        if exist('glab', 'var')
            wanted = glab.EMG;
            EMGlabels = 1; % labels are known
        else
            EMGlabels = 0; % labels are unknown
        end
        % trouver les numéros des canaux

        %%%%%%%%%%%%%% Créer une structure avec l'ensemble des canaux
        for gg=0:nb_cannaux-1
            clear emg_can label unit
            fin = double(size(tracks, 1)*(Analog_rate/frequency));
            waitbar(0.75+(double(gg)/double(tt))*0.25, h);        
            canal = invoke(hTrial, 'AnalogChannel', gg);
            unit = get(canal, 'Units');
            label = get(interm, 'Label');
            Analog_rate = get(interm_emg, 'SampleRate');
            if ~isempty(strfind(lower(unit), 'v')) 
                First = invoke( canal, 'FirstSampleNum' );
                Last = invoke( canal, 'LastSampleNum' );
                
                % Calcul des coordonnées du canal
                if First>0
                    emg_can(First:Last) = get(canal, 'GetSamples', First, Last);
                else
                    emg_can(First+1:Last+1) = get(canal, 'GetSamples', First, Last);
                    fin = fin-1;
                end
                if First > 1, emg_can(1:First-1) = NaN;end
                if Last < fin, emg_can(Last+1:fin) = NaN;end
                switch EMGlabels
                    case 1
                        for tt = 1:length(EMGlabels)
                            if strcmp(labels, EMGlabels{tt})
                                EMG.(char(label)) = emg_can; %% Export only analogs channels contained in glab.EMG
                            end
                        end
                    case 0
                        EMG.(char(label)) = emg_can; %% Export of all analogs channels with 'v' in units
                end
            end
        end
        fileinfo.AnalogRate = Analog_rate;
    else
        EMG = []; 
    end
else
    EMG = [];
end
%%%%%%%%%%%%%%%%% release all servers
release( E_Node );
if ~isempty(strfind(type, 'kin')), release( marqueur ); release( int ); else Tracks = NaN; end
if ~isempty(strfind(type, 'pff')), release( interm ); else Forces = NaN; end
if ~isempty(strfind(type, 'emg')), release( interm_emg ); release(canal);else EMG = NaN; end
release( hTrial );
release( hServer );
close(h);
end