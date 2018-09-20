function output = ComputingCoP(FORCEPLATES, FORCEPLATESINFO, REFFRAME)

output = FORCEPLATES;
C3Dkey.numPlatesUsed = length(FORCEPLATES);
x = 1; y=2; z=3;

if nargin<3, REFFRAME.NAME = 'FORCEPLATE';end

for i = 1:C3Dkey.numPlatesUsed   % Force Plate Loop (i)

    [b, a] = butter(4, 50/(FORCEPLATESINFO(i, 1).frequency/2));
    clear vecA
    % Determine local force and moment and filtered its
    % ---------------------------------------------------------------
    Mo_all(:, :, i) = filtfilt(b, a, ([FORCEPLATES(i, 1).channels.(['Mx', num2str(i)]), ...
                       FORCEPLATES(i, 1).channels.(['My', num2str(i)]), ... 
                       FORCEPLATES(i, 1).channels.(['Mz', num2str(i)])]));

    F_all(:, :, i) = filtfilt(b, a, ([FORCEPLATES(i, 1).channels.(['Fx', num2str(i)]), ...
                      FORCEPLATES(i, 1).channels.(['Fy', num2str(i)]), ...
                      FORCEPLATES(i, 1).channels.(['Fz', num2str(i)])])); 

    C3Dkey.numFrames = size(F_all, 1);

    % Determine local force plate origin values
    % This comes from the individual callibration of each force plate
    % ---------------------------------------------------------------
    a = FORCEPLATES(i, 1).origin(x,1);
    b = FORCEPLATES(i, 1).origin(y,1);
    c = FORCEPLATES(i, 1).origin(z,1);

    % Determine vector from FP origin to CoP in FORCE PLATE coordinates
    % Calculate CoP
    % -----------------------------------------------------------------

    X_all(:, x, i) = (((-Mo_all(:,y,i) - (c * F_all(:,x,i))) ./ F_all(:,z,i)) + a);
    X_all(:, y, i) = (( Mo_all(:,x,i) - (c * F_all(:,y,i))) ./ F_all(:,z,i)) + b;
    X_all(:, z, i) = ones(1, C3Dkey.numFrames) * c;

    switch REFFRAME.NAME
        case 'FORCEPLATE'
            if i == 2, X_all(:, x, i) = unphase(X_all(:, x, i), 'real'); end
            if i == 1, X_all(:, y, i) = unphase(X_all(:, y, i), 'real'); end
            output(i, 1).CoP = squeeze(X_all(:, :, i));
        case 'VICON'
            T = [min(FORCEPLATES(i, 1).corners(1,:))+200 min(FORCEPLATES(i, 1).corners(2,:))+300 0];
            if i == 2, R = [1 -1 -1 1];end %% PFF2 to VICON REF
            if i == 1, R = [-1 1 -1 1];end %% PFF1 to VICON REF
            
            
    end
end
    
end

