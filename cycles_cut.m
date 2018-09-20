function cycles_cut(filename)

H = btkReadAcquisition(filename);
frequ = btkGetPointFrequency(H);
FF = btkGetFirstFrame(H);
data = btkGetMarkers(H);
btkClearEvents(H);

FootStrike = {1, 'Foot Strike',  'The instant the heel strikes the ground'};
FootOff =  {2, 'Foot Off',  'The instant the toe leaves the ground'};

for c5 = 1:2
    clear Xheel XTO Xsacrum tHS tTO HS TO TOFF METADATA
    if c5 == 1
        side = 'Left';
        Xheel = data.LHEE(:,2);
        XTO = data.LTOE(:, 2);              
    else
        side = 'Right';
        Xheel = data.RHEE(:,2);
        XTO = data.RTOE(:, 2); 
    end

    Xsacrum = (data.RPSI(:,2) + data.LPSI(:,2))/2;
    
    if Xsacrum(end, 1)-Xsacrum(1, 1)>0
        tHS = -Xsacrum + Xheel;
    else
        tHS = Xsacrum - Xheel;
    end
    [HS, ~, TO]= Peaks_Select(tHS, 'semi-automatic');
    HS = HS+FF;
    %[CTO, ~, ~]= Peaks_Select(tTO , 'semi-automatic');
    %TOFF = CTO(1:end-1)+TO+FF;
    TOFF = HS(1:end-1)+TO;

    %%% Inscrire les événements

    METADATA = btkGetMetaData(H, 'SUBJECTS', 'NAMES');
    for c3 = 1:length(HS)
         btkAppendEvent(H, FootStrike{2}, HS(c3)/frequ, side, char(METADATA.info.values), FootStrike{3}, FootStrike{1});
    end
    for c4 = 1:length(TOFF)
         btkAppendEvent(H, FootOff{2}, TOFF(c4)/frequ, side, char(METADATA.info.values), FootOff{3}, FootOff{1});
    end
end

btkWriteAcquisition(H, filename);

end