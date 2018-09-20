function [angle] = anglcmpt(varargin)
sample = 1;
if length(varargin)<4
    
    origine = varargin{1};
    stop = varargin{2};
    plan = varargin{3};
    
    if isnan(origine(sample, 1))~= 1 && isnan(stop(sample, 1))~= 1
        
        if strcmp(plan, 'S')==1
            Ux = stop(sample, 1)-origine(sample, 1); Vx = 0;
            Uy = stop(sample, 2)-origine(sample, 2); Vy = -1;
            Uz = 0; Vz = 0;
            
             %%%%%%%%%%%%%%% Orientation de l'angle
            if Ux > 0, multi = 1;else multi = -1;end
            
        elseif strcmp(plan, 'F')==1
            Ux = 0; Vx = 0;
            Uy = stop(sample, 2)-origine(sample, 2); Vy = -1;
            Uz = stop(sample, 3)-origine(sample, 3); Vz = 0; 
            
            %%%%%%%%%%%%%%% Orientation de l'angle
            if Uz > 0, multi = 1;else multi = -1;end
            
        elseif strcmp(plan, 'T')==1
            Ux = stop(sample, 1)-origine(sample, 1); Vx = 1;
            Uy = 0; Vy = 0;
            Uz = stop(sample, 3)-origine(sample, 3); Vz = 0; 
                   
            %%%%%%%%%%%%%%% Orientation de l'angle
            if Uz > 0, multi = 1;else multi = -1;end

        elseif strcmp(plan, '3D')==1    
            Ux = stop(sample, 1)-origine(sample, 1); Vx = 0;
            Uy = stop(sample, 2)-origine(sample, 2); Vy = -1;
            Uz = stop(sample, 3)-origine(sample, 3); Vz = 0;
            
            %%%%%%%%%%%%%%% Orientation de l'angle
%             if Ux > 0, multi = 1;else multi = -1;end
            multi = 1;
            
        end
        
        angle = multi*acosd((Ux*Vx+Uy*Vy+Uz*Vz)/(((Ux^2+Uy^2+Uz^2)^0.5)*((Vx^2+Vy^2+Vz^2)^0.5)));
        
%         angle2 = asind((((Uz*Vy-Uy*Vz)^2 + (Ux*Vz-Uz*Vx)^2 + (Ux*Vy-Uy*Vx)^2)^0.5)...
%             /(((Ux^2+Uy^2+Uz^2)^0.5)*((Vx^2+Vy^2+Vz^2)^0.5)));
        
    else
        angle = NaN;
    end
    
elseif length(varargin)==4 && strcmp(varargin{4}, '3D')==1
    
    Proximal = varargin{1};
    Mid = varargin{2};
    Distal = varargin{3};
    
    if isnan(Proximal(sample, 1))~= 1 && isnan(Mid(sample, 1))~= 1 && isnan(Distal(sample, 1))~= 1
        %%%%%%%%%%% Define both vectors
        Ux = Proximal(sample, 1)-Mid(sample, 1);Vx = Distal(sample, 1)-Mid(sample, 1);
        Uy = Proximal(sample, 2)-Mid(sample, 2);Vy = Distal(sample, 2)-Mid(sample, 2);
        Uz = Proximal(sample, 3)-Mid(sample, 3);Vz = Distal(sample, 3)-Mid(sample, 3);

%         if Ux > 0
            angle = acosd((Ux*Vx+Uy*Vy+Uz*Vz)/(((Ux^2+Uy^2+Uz^2)^0.5)*((Vx^2+Vy^2+Vz^2)^0.5)));
%         else
%             angle = -acosd((Ux*Vx+Uy*Vy+Uz*Vz)/(((Ux^2+Uy^2+Uz^2)^0.5)*((Vx^2+Vy^2+Vz^2)^0.5)));
%         end
            if angle > 180
                angle  = 360-angle;
            end
    else
        angle = NaN;
    end
    
elseif length(varargin)==4 && (strcmp(varargin{4}, 'S')==1 || strcmp(varargin{4}, 'F')==1 || strcmp(varargin{4}, 'T')==1)
    
    if strcmp(varargin{4}, 'S')==1
        
        Proximal = varargin{1};
        Mid = varargin{2};
        Distal = varargin{3};

        if isnan(Proximal(sample, 1))~= 1 && isnan(Mid(sample, 1))~= 1 && isnan(Distal(sample, 1))~= 1
            %%%%%%%%%%% Define both vectors
            Ux = Proximal(sample, 1)-Mid(sample, 1);Vx = Distal(sample, 1)-Mid(sample, 1);
            Uy = Proximal(sample, 2)-Mid(sample, 2);Vy = Distal(sample, 2)-Mid(sample, 2);
            Uz = 0;Vz = 0;
            
%             if Ux > 0    
                angle = acosd((Ux*Vx+Uy*Vy+Uz*Vz)/(((Ux^2+Uy^2+Uz^2)^0.5)*((Vx^2+Vy^2+Vz^2)^0.5)));
%             else
%                 angle = -acosd((Ux*Vx+Uy*Vy+Uz*Vz)/(((Ux^2+Uy^2+Uz^2)^0.5)*((Vx^2+Vy^2+Vz^2)^0.5)));
%             end
            if angle > 180
                angle  = 360-angle;
            end
        else
        	angle = NaN;
        end            
        
    elseif strcmp(varargin{4}, 'F')==1
        
        Proximal = varargin{1};
        Mid = varargin{2};
        Distal = varargin{3};
        
        if isnan(Proximal(sample, 1))~= 1 && isnan(Mid(sample, 1))~= 1 && isnan(Distal(sample, 1))~= 1
            %%%%%%%%%%% Define both vectors
            Ux = 0;Vx = 0;
            Uy = Proximal(sample, 2)-Mid(sample, 2);Vy = Distal(sample, 2)-Mid(sample, 2);
            Uz = Proximal(sample, 3)-Mid(sample, 3);Vz = Distal(sample, 3)-Mid(sample, 3);

%             if Uz > 0    
                angle = acosd((Ux*Vx+Uy*Vy+Uz*Vz)/(((Ux^2+Uy^2+Uz^2)^0.5)*((Vx^2+Vy^2+Vz^2)^0.5)));
%             else
%                 angle = -acosd((Ux*Vx+Uy*Vy+Uz*Vz)/(((Ux^2+Uy^2+Uz^2)^0.5)*((Vx^2+Vy^2+Vz^2)^0.5)));
%             end
            if angle > 180
                angle  = 360-angle;
            end
        else
        	angle = NaN;
        end            
        
    elseif strcmp(varargin{4}, 'T')==1
        
        Proximal = varargin{1};
        Mid = varargin{2};
        Distal = varargin{3};
        
        if isnan(Proximal(sample, 1))~= 1 && isnan(Mid(sample, 1))~= 1 && isnan(Distal(sample, 1))~= 1
            %%%%%%%%%%% Define both vectors
            Ux = Proximal(sample, 1)-Mid(sample, 1);Vx = Distal(sample, 1)-Mid(sample, 1);
            Uy = 0;Vy = 0;
            Uz = Proximal(sample, 3)-Mid(sample, 3);Vz = Distal(sample, 3)-Mid(sample, 3);

%             if Uz > 0    
                angle = acosd((Ux*Vx+Uy*Vy+Uz*Vz)/(((Ux^2+Uy^2+Uz^2)^0.5)*((Vx^2+Vy^2+Vz^2)^0.5)));
%             else
%                 angle = -acosd((Ux*Vx+Uy*Vy+Uz*Vz)/(((Ux^2+Uy^2+Uz^2)^0.5)*((Vx^2+Vy^2+Vz^2)^0.5)));
%             end
            if angle > 180
                angle  = 360-angle;
            end
        else
        	angle = NaN;
        end         
        
    end
elseif length(varargin)==5 
    S1Proximal = varargin{1};
    S1Distal= varargin{2};
    S2Proximal = varargin{3};
    S2Distal= varargin{4};
        
    switch varargin{5}
        case 'F'
            if isnan(S1Proximal(sample, 1))~= 1 && isnan(S1Distal(sample, 1))~= 1 && isnan(S2Proximal(sample, 1))~= 1 && isnan(S2Distal(sample, 1))~= 1
                %%%%%%%%%%% Define both vectors
                Ux = 0; Vx = 0;
                Uy = S1Proximal(sample, 2)-S1Distal(sample, 2); Vy = S2Proximal(sample, 2)-S2Distal(sample, 2);
                Uz = S1Proximal(sample, 3)-S1Distal(sample, 3); Vz = S2Proximal(sample, 3)-S2Distal(sample, 3);
            end
            
        case 'S'
            if isnan(S1Proximal(sample, 1))~= 1 && isnan(S1Distal(sample, 1))~= 1 && isnan(S2Proximal(sample, 1))~= 1 && isnan(S2Distal(sample, 1))~= 1
                %%%%%%%%%%% Define both vectors
                Ux = S1Proximal(sample, 1)-S1Distal(sample, 1); Vx = S2Proximal(sample, 1)-S2Distal(sample, 1);
                Uy = S1Proximal(sample, 2)-S1Distal(sample, 2); Vy = S2Proximal(sample, 2)-S2Distal(sample, 2);
                Uz = 0;Vz = 0;
            end
            
        case 'T'
            if isnan(S1Proximal(sample, 1))~= 1 && isnan(S1Distal(sample, 1))~= 1 && isnan(S2Proximal(sample, 1))~= 1 && isnan(S2Distal(sample, 1))~= 1
                %%%%%%%%%%% Define both vectors
                Ux = S1Proximal(sample, 1)-S1Distal(sample, 1); Vx = S2Proximal(sample, 1)-S2Distal(sample, 1);
                Uy = 0; Vy = 0;
                Uz = S1Proximal(sample, 3)-S1Distal(sample, 3); Vz = S2Proximal(sample, 3)-S2Distal(sample, 3);
            end
            
        case '3D'
                Ux = S1Proximal(sample, 1)-S1Distal(sample, 1); Vx = S2Proximal(sample, 1)-S2Distal(sample, 1);
                Uy = S1Proximal(sample, 2)-S1Distal(sample, 2); Vy = S2Proximal(sample, 2)-S2Distal(sample, 2);
                Uz = S1Proximal(sample, 3)-S1Distal(sample, 3); Vz = S2Proximal(sample, 3)-S2Distal(sample, 3);            
        otherwise 
            angle = NaN;
    end
    
    if ~isnan(angle)
        angle = acosd((Ux*Vx+Uy*Vy+Uz*Vz)/(((Ux^2+Uy^2+Uz^2)^0.5)*((Vx^2+Vy^2+Vz^2)^0.5)));
        if angle > 180
            angle  = 360-angle;
        else
            angle = NaN;
        end
    end
    
else
     angle = NaN;
end
    
    
    
    
    
    