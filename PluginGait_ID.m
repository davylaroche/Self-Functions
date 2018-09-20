function wanted_name = PluginGait_ID(joint, axes, model, position)

%%%%%%%%% this function send name of tracks in plugingait data
%%%%%%% joint must be : head, trunk, shoulder, elbow, wrist, hand
%%%%%%%%%               pelvis, hip, knee, ankle, foot, arm, forearm,
%%%%%%%%%               thigh, shank, toe, CoM, CoMF, PFF

%%%%%%% axes could be one of X, Y, Z 

%%%%%%% model must be : markers, PG, angle, moment, power, force

%%%%%%% position must be left, right and/or anterior, posterior, origine,
%%%%%%% lateral, proximal, up and down
if nargin < 4, position = ' ';end
wanted_name={};

if strfind(axes, 'X'), axe = '_X';end
if strfind(axes, 'Y'), axe = '_Y';end  
if strfind(axes, 'Z'), axe = '_Z';end    

if strfind(position, 'left'), side = 'L';end
if strfind(position, 'right'), side = 'R';end

if strfind(position, 'origine'), plan = 'O';end
if strfind(position, 'lateral'), plan = 'L';end
if strfind(position, 'proximal'), plan = 'P';end
if strfind(position, 'anterior'), plan = 'A';end

if strcmp(joint, 'pelvis') & strfind(position, 'anterior'); plan = 'A';end
if strcmp(joint, 'pelvis') & strfind(position, 'posterior'); plan = 'P';end

if strcmp(joint, 'head') & strfind(position, 'anterior'); plan = 'F';end
if strcmp(joint, 'head') & strfind(position, 'posterior'); plan = 'B';end

if strcmp(joint, 'wrist') & strfind(position, 'anterior'); plan = 'A';end
if strcmp(joint, 'wrist') & strfind(position, 'posterior'); plan = 'B';end

% *************************************************************************
if strcmp(model, 'markers') %%%%%%%%% markers name
% *************************************************************************   
    if strcmp(joint, 'head'); wanted_name = {[side, plan, 'HD', axe]};end
   
    if strcmp(joint, 'trunk'); 
        if finstr(position, 'up') && finstr(position, 'anterior')
            wanted_name = {['CLAV', axe]};
        elseif finstr(position, 'down') && finstr(position, 'anterior')
            wanted_name = {['STRN', axe]};
        elseif finstr(position, 'down') && finstr(position, 'posterior')
            wanted_name = {['T10', axe]};
        elseif finstr(position, 'up') && finstr(position, 'posterior')
            wanted_name = {['C7', axe]};
        elseif finstr(position, 'down') && finstr(position, 'posterior') && finstr(position, 'right')
            wanted_name = {['RBAK', axe]};
        end
    end
    
    if strcmp(joint, 'shoulder'); wanted_name = {[side, 'SHO', axe]};end
    if strcmp(joint, 'elbow'); wanted_name = {[side, 'ELB', axe]};end
    if strcmp(joint, 'wrist'); wanted_name = {[side, 'WR', plan, axe]};end    
    if strcmp(joint, 'hand'); wanted_name = {[side, 'FIN', axe]};end
    if strcmp(joint, 'pelvis'); wanted_name = {[side, plan, 'SI', axe]};end
    
    if strcmp(joint, 'thigh'); wanted_name = {[side, 'THI', axe]};end
    if strcmp(joint, 'shank'); wanted_name = {[side, 'TIB', axe]};end
    if strcmp(joint, 'knee'); wanted_name = {[side, 'KNE', axe]};end
    if strcmp(joint, 'ankle'); wanted_name = {[side, 'ANK', axe]};end
    if strcmp(joint, 'calc'); wanted_name = {[side, 'HEE', axe]};end
    if strcmp(joint, 'foot'); wanted_name = {[side, 'TOE', axe]};end
    
% *************************************************************************
elseif  strcmp(model, 'PG') %%%%%%%%% plugin gait
% *************************************************************************       
    if strcmp(joint, 'head'); wanted_name = {['HED', plan, axe]};end
    if strcmp(joint, 'trunk'); wanted_name = {['TRX', plan, axe]};end
    if strcmp(joint, 'pelvis'); wanted_name = {['PEL', plan, axe]};end
   
    if strcmp(joint, 'shoulder'); wanted_name = {[side, 'CL', plan, axe]};end
    
    if strcmp(joint, 'arm'); wanted_name = {[side, 'HU', plan, axe]};end
    if strcmp(joint, 'forearm'); wanted_name = {[side, 'RA', plan, axe]};end
    if strcmp(joint, 'hand'); wanted_name = {[side, 'HN', plan, axe]};end
    
    if strcmp(joint, 'thigh'); wanted_name = {[side, 'FE', plan, axe]};end
    if strcmp(joint, 'shank'); wanted_name = {[side, 'TI', plan, axe]};end
    if strcmp(joint, 'foot'); wanted_name = {[side, 'FO', plan, axe]};end
    if strcmp(joint, 'toe'); wanted_name = {[side, 'TO', plan, axe]};end

 % Virtual markers %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if strcmp(joint, 'CoM'); wanted_name = {['CentreOfMass', axe]};end
    if strcmp(joint, 'CoMF'); wanted_name = {['CentreOfMassFloor', axe]};end
    
% *************************************************************************
else
    if strcmp(joint, 'head'); name = [side, 'Head']; end
    if strcmp(joint, 'neck'); name = [side, 'Neck']; end
    if strcmp(joint, 'trunk'); name = [side, 'Thorax']; end
    if strcmp(joint, 'pelvis'); name = [side, 'Pelvis']; end
   
    if strcmp(joint, 'shoulder'); name = [side, 'Shoulder']; end
    
    if strcmp(joint, 'elbow'); name = [side, 'Elbow']; end
    if strcmp(joint, 'wrist'); name = [side, 'Wrist']; end
    
    if strcmp(joint, 'hip'); name = [side, 'Hip']; end
    if strcmp(joint, 'knee'); name = [side, 'Knee']; end
    if strcmp(joint, 'ankle'); name = [side, 'Ankle']; end
    if strcmp(joint, 'foot'); name = [side, 'FootProgress']; end    
    
    if strcmp(joint, 'PFF'); name = [side, 'GroundReaction']; end 
    
    if  strcmp(model, 'angle') %%%%%%%%% angles
% *************************************************************************      
        wanted_name = {[name, 'Angles', axe]}; 
    elseif  strcmp(model, 'moment') %%%%%%%%% moment
% *************************************************************************
        name = strrep(name, 'Pelvis', 'Waist');
        wanted_name = {[name, 'Moment', axe]};
    elseif  strcmp(model, 'power') %%%%%%%%% power
% *************************************************************************
        name = strrep(name, 'Pelvis', 'Waist');
        wanted_name = {[name, 'Power', axe]};
    elseif  strcmp(model, 'force') %%%%%%%%% force
% *************************************************************************
        name = strrep(name, 'Pelvis', 'Waist');
        wanted_name = {[name, 'Force', axe]};
    end
end

%wanted_name = char(wanted_name);

end
    
    