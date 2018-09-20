function checkpff = checkpffnumber(varargin)
%%%% pff is the ground reaction by side
%%%% forceplates is the analog extraction of forceplates
method = varargin{1};

switch method
    case 'compare_forces'
        pff = varargin{2};
        FORCEPLATES = varargin{3};
        try
            PFF1_Values = sgnnrml([FORCEPLATES(1,1).channels.Fx1 FORCEPLATES(1,1).channels.Fy1 -FORCEPLATES(1,1).channels.Fz1], size(pff, 1));
            PFF2_Values = sgnnrml([FORCEPLATES(2,1).channels.Fx2 FORCEPLATES(2,1).channels.Fy2 -FORCEPLATES(2,1).channels.Fz2], size(pff, 1));
        end
        try
            PFF1_Values = sgnnrml([FORCEPLATES(1,1).channels.Fx2 FORCEPLATES(1,1).channels.Fy2 -FORCEPLATES(1,1).channels.Fz2], size(pff, 1));
            PFF2_Values = sgnnrml([FORCEPLATES(2,1).channels.Fx1 FORCEPLATES(2,1).channels.Fy1 -FORCEPLATES(2,1).channels.Fz1], size(pff, 1));
        end

        %%% Centrer réduire
        X = pff(:, 3);
        Xcr = (X-ones(length(X),1)*mean(X))/diag(std(X));
        Xcrs = Xcr(Xcr>0.05);

        Y1 = PFF1_Values(:, 3);
        Y2 = PFF2_Values(:, 3);
        Y1cr = (Y1-ones(length(Y1),1)*mean(Y1))/diag(std(Y1));Y1cr = Y1cr(Xcr>0.05);%Y1cr(isnan(Y1cr)) = 0;
        Y2cr = (Y2-ones(length(Y2),1)*mean(Y2))/diag(std(Y2));Y2cr = Y2cr(Xcr>0.05);%Y2cr(isnan(Y2cr)) = 0;

        verif = corrcoef(Xcrs, Y1cr);
        verif2 = corrcoef(Xcrs, Y2cr);

        if verif(1, 2)>verif2(1,2), checkpff = 'PFF1';else checkpff = 'PFF2';end
        
    case 'compare_mkers'
        
        PFF1_pos = [0 600 400 1200];
        PFF2_pos = [0 0 400 600];
        LANK = varargin{2};
        RANK = varargin{3};
        FORCEPLATES = varargin{4};
        
        try
            PFF1_Values = sgnnrml([FORCEPLATES(1,1).channels.Fx1 FORCEPLATES(1,1).channels.Fy1 -FORCEPLATES(1,1).channels.Fz1], size(LANK, 1));
            PFF2_Values = sgnnrml([FORCEPLATES(2,1).channels.Fx2 FORCEPLATES(2,1).channels.Fy2 -FORCEPLATES(2,1).channels.Fz2], size(LANK, 1));
        end
        try
            PFF1_Values = sgnnrml([FORCEPLATES(1,1).channels.Fx2 FORCEPLATES(1,1).channels.Fy2 -FORCEPLATES(1,1).channels.Fz2], size(LANK, 1));
            PFF2_Values = sgnnrml([FORCEPLATES(2,1).channels.Fx1 FORCEPLATES(2,1).channels.Fy1 -FORCEPLATES(2,1).channels.Fz1], size(LANK, 1));
        end
        
        %%%% Déterminer quel marker est immobile au moment de la force
        PFF1 = PFF1_Values(PFF1_Values(:, 3)>20, 3); PFF2 = PFF2_Values(PFF2_Values(:, 3)>20, 3);
        LANK_zvel = diff(LANK(:, 3)); RANK_zvel = diff(RANK(:, 3));
        
        if ~isempty(PFF1)
            if nanmean(abs(LANK_zvel(PFF1_Values(:, 3)>20)))>nanmean(abs(RANK_zvel(PFF1_Values(:, 3)>20))), PFF1_Side = 'Right';else PFF1_Side = 'Left';end
        else
            PFF1_Side = 'Not for use';
        end
        
        if ~isempty(PFF2)
            if nanmean(abs(LANK_zvel(PFF2_Values(:, 3)>20)))>nanmean(abs(RANK_zvel(PFF2_Values(:, 3)>20))), PFF2_Side = 'Right';else PFF2_Side = 'Left';end
        else
            PFF2_Side = 'Not for use';
        end
        
        %%%%% Vérifier que le marker est bien dans la bonne zone
        if ~strcmp(PFF1_Side, 'Not for use')
            if strcmp(PFF1_Side, 'Left'), mker1 = LANK(PFF1_Values(:, 3)>20, :); else mker1 = RANK(PFF1_Values(:, 3)>20, :);end
            if size(mker1, 1)>0
                err = find(mker1(:, 1)>PFF1_pos(1) & mker1(:, 1)<PFF1_pos(3) & mker1(:, 2)<PFF1_pos(4) & mker1(:, 2)>PFF1_pos(2));
                if isempty(err), PFF1_Side = 'Not for use';end
            else 
                PFF1_Side = 'Not for use';
            end
        end
        
        if ~strcmp(PFF2_Side, 'Not for use')
            if strcmp(PFF2_Side, 'Left'), mker2 = LANK(PFF2_Values(:, 3)>20, :); else mker2 = RANK(PFF2_Values(:, 3)>20, :);end
            if size(mker2, 1)>0
                err = find(mker2(:, 1)>PFF2_pos(1) & mker2(:, 1)<PFF2_pos(3) & mker2(:, 2)<PFF2_pos(4) & mker2(:, 2)>PFF2_pos(2));
                if isempty(err), PFF2_Side = 'Not for use';end
            else 
                PFF2_Side = 'Not for use';
            end     
        end
        
        checkpff = {'PFF1', 'PFF2'; PFF1_Side, PFF2_Side};
end
