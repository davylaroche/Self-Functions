function [Tracks, Forces, EMG, fileinfo] = GetPECS(type, server_close)

%%
if nargin<2 % in case of close = 0, then PECS server was not released
    server_close = 1;
end

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
frequency = get(hTrial, 'VideoRate');
labels = {};

%%%%%%%%%% Getting file Informations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
E_Node = invoke(hTrial, 'EclipseNode');
filename = get(E_Node, 'Title');
path = get(hTrial, 'DataPath');
Subject_node = invoke(hTrial, 'Subject', 0);
subject_name = get(Subject_node, 'Name');

fileinfo.path = path;
fileinfo.name = filename;
fileinfo.subject = subject_name;
fileinfo.video_rate = frequency;

h = waitbar(0, 'Reading data from PECS server.....');

if ~isempty(findstr(type, 'kin'))
    
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

    release( marqueur );
else
    Tracks = NaN;
end

if ~isempty(findstr(type, 'pff'))
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
        
        fin = double(size(tracks, 1)*(samplerate/frequency));
        
        First = get(interm, 'FirstSampleNum');
        Last = get(interm, 'LastSampleNum');
        
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
    release( interm )
else
   Forces = NaN; 
end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%% Récupérer les Données analogiques
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numeric = ['0' '1' '2' '3' '4' '5' '6' '7' '8' '9'];    
if ~isempty(findstr(type, 'emg'))    
    % Liste des cannaux
    nb_cannaux = invoke(hTrial, 'AnalogChannelCount');

%    A = {'Left SOL','Left GAM','Left TA','Left RF','Left BFL','Left GLME','Left ES','Left TRP','Right SOL','Right GAM','Right TA','Right RF','Right BFL','Right GLME','Right ES','Right TRP'};
   
    % trouver les numéros des canaux
    tt = 1;
   
    %%%%%%% Determining the length of data
    for nb=0:nb_cannaux-1
        interm = invoke(hTrial, 'AnalogChannel', nb);
        fin_v(nb+1) = invoke(interm, 'LastSampleNum' );
    end
    
    fin = double(nanmax(fin_v));
    
    for nb=0:nb_cannaux-1
        waitbar(0.50+(double(nb)/double(nb_cannaux-1))*0.5, h);
        clear label
        %interm = strcat('index',eval('machin'))
        interm = invoke(hTrial, 'AnalogChannel', nb);
        % nom_index = get(interm, 'Label')
        label = get(interm, 'Label');
        unit = get(interm, 'Units');
        Analog_rate = get(interm, 'SampleRate');

        if ~isempty(strfind(lower(unit), 'v')) && isempty(strfind(label, 'FSW')) && isempty(findstr(numeric, label(1)))
            
            emg_labels(tt) = {repinv_char(label)};

            First = invoke(interm, 'FirstSampleNum' );
            Last = invoke(interm, 'LastSampleNum' );
                        
            if First>0
                emg_can(First:Last) = get(interm, 'GetSamples', First, Last);
            else
                emg_can(First+1:Last+1) = get(interm, 'GetSamples', First, Last);
                fin = fin-1;
            end
            if First > 1, emg_can(1:First-1) = NaN;end
            if Last < fin, emg_can(Last+1:fin) = NaN;end

            EMG.(char(emg_labels(tt))).raw = emg_can; 
            EMG.(char(emg_labels(tt))).channel = nb; 
            tt = tt + 1;
        end
    end   

    fileinfo.AnalogRate = Analog_rate;

else
    EMG = NaN;
end

if server_close ~= 1 % case of launching other program before closing servers
    %%%%%%%%%%% Filtrer les données
    %%%%%% Construction du filtre
%     [b, a] = butter(5, [20/(Analog_rate/2) 400/(Analog_rate/2)]);
    [b, a] = butter(5, 50/(Analog_rate/2));
    
    %%%%%%% Filtre et rectification
    muscles = fieldnames(EMG);
    for xx = 1:length(muscles)
        clear temp out_vect vector
        temp = double(EMG.(char(muscles(xx))).raw);
        if length(temp(isnan(temp)==0))>20
            vector = abs(filtfilt(b, a, temp(isnan(temp)==0)));
            out_vect(isnan(temp)==1) = NaN;
            out_vect(isnan(temp)==0) = vector;
        else
            out_vect(1:length(temp)) = NaN;
        end
        EMG_out.(char(muscles(xx))).raw = out_vect;
        EMG_out.(char(muscles(xx))).channel = EMG.(char(muscles(xx))).channel;
    end
    
     %%%%%%%%%%% Ecrire les données dans le fichier C3D
    muscles = fieldnames(EMG_out);
    for nb=1:length(muscles)
        clear ecrit new_canal
        chan = EMG_out.(char(muscles(nb))).channel;
        
        interm = invoke(hTrial, 'AnalogChannel', chan);      
        First = invoke(interm, 'FirstSampleNum' );
        Last = invoke(interm, 'LastSampleNum' );
        
        new_canal = EMG_out.(char(muscles(nb))).raw;
        if exist([path, '\référence_EMG.mat'], 'file')
            load([path, '\référence_EMG.mat']);
            new_canal = new_canal./nanmean(EMG_ref.(char(muscles(nb))).raw);
        end
        invoke(interm, 'SetSamples', First, Last, new_canal(First+1:Last+1));
    
     end   
end


%%%%%%%%%%%%%%%%% release all servers
release( E_Node );
release( hTrial );
release( hServer );

close(h);
end