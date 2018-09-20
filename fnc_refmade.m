function [MkO, MkX, MkY, MkZ] = fnc_refmade(Origine, Main_Axis, Orientation_Axis, axis_1, axis_2)
%%%% This function compute the reference defined by the input point
%%%% Origine will be set as Origine
%%%% axis_1 defined the orientation of the  Origine to Main_axis vector
%%%% axis_2 defined the orientation of the  Origine to Orientation_Axis vector
%%%% Vectoriel product of both determine last axis 

%%%% Input must be m*3 matrix
%%%% MkO, MkX, MkY, MkZ will be m*3 matrix

%%% mémo for orthonormal reference
%%% to obain X cross_product(Y, Z)
%%% to obain Y cross_product(Z, X)
%%% to obain Z cross_product(X, Y)

if strcmp(axis_1, 'X')
    if strcmp(axis_2, 'Y')
        vect_X=(Main_Axis-Origine);      
        vect_y_temp=(Orientation_Axis-Origine);     % both vectors defined the plan 
        vect_z_temp=cross(vect_X,vect_y_temp);      % Determine oriented vector normal to the previous plan 
        vect_Y=cross(vect_z_temp, vect_X);          % Determine vector in plan normal to the 2 others
        vect_Z=cross(vect_X, vect_Y);               % Finally determine 3rth vector normal                                           
    else % Then axis_2 = 'Z'
        vect_X=(Main_Axis-Origine);  
        vect_z_temp=(Orientation_Axis-Origine);
        vect_y_temp=cross(vect_z_temp,vect_X);   
        vect_Z=cross(vect_X, vect_y_temp); 
        vect_Y=cross(vect_Z, vect_X); 
    end
elseif strcmp(axis_1, 'Y')
    if strcmp(axis_2, 'X')
        vect_Y=(Main_Axis-Origine);      
        vect_x_temp=(Orientation_Axis-Origine);
        vect_z_temp=cross(vect_x_temp, vect_Y);      
        vect_X=cross(vect_Y, vect_z_temp);          
        vect_Z=cross(vect_X, vect_Y);        
    else % Then axis_2 = 'Z'
        vect_Y=(Main_Axis-Origine);      
        vect_z_temp=(Orientation_Axis-Origine);
        vect_x_temp=cross(vect_Y, vect_z_temp);      
        vect_Z=cross(vect_x_temp, vect_Y);          
        vect_X=cross(vect_Y, vect_Z);        
    end
else     % Then axis_1 = 'Z'
    if strcmp(axis_2, 'X')
        vect_Z=(Main_Axis-Origine);      
        vect_x_temp=(Orientation_Axis-Origine);
        vect_y_temp=cross(vect_Z, vect_x_temp);      
        vect_X=cross(vect_y_temp, vect_Z);          
        vect_Y=cross(vect_Z, vect_X);          
    else % Then axis_2 = 'Y'
        vect_Z=(Main_Axis-Origine);      
        vect_y_temp=(Orientation_Axis-Origine);
        vect_x_temp=cross(vect_y_temp, vect_Z);      
        vect_Y=cross(vect_Z, vect_x_temp);          
        vect_X=cross(vect_Y, vect_Z);         
    end
end

%%%%%%%% Computing to obtain orthonormal reference
for yy=1:size(vect_X, 1)
    vect_X(yy,:)=vect_X(yy,:)/norm(vect_X(yy,:));
    vect_Y(yy,:)=vect_Y(yy,:)/norm(vect_Y(yy,:));
    vect_Z(yy,:)=vect_Z(yy,:)/norm(vect_Z(yy,:));
end  

%%%% Computing vector
MkO = Origine;
MkX = vect_X;
MkY = vect_Y;
MkZ = vect_Z;

end