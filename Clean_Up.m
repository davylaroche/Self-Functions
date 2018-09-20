function  Clean_Up(filename, sheet, datatype)
% cette macro permet de détecter les points extrêmes
% elle se base sur la mediane et quartiles
% un point atypique correspond : valeur du point de données > VSB + c.a.*(VSB - VIB)
% ou valeur du point de données < VIB - c.a.*(VSB - VIB)
% un point atypique correspond : valeur du point de données > VSB + 2*c.a.*(VSB - VIB)
% ou valeur du point de données < VIB - 2*c.a.*(VSB - VIB)
% c.a. est fixé par défault à 1.5
% de plus la macro colore en jaune les cycles contenant des données atypiques et rouge les points extrêmes
% les valeurs en gras colorées indiques la (ou les) variables atypiques trouvées
% Type should be 'Screen', 'DelXtrem', 'DelAll'
% Screen just screen data fr Xtrem/atyical data
% DelXtrem remove Xtrem values
% DelAll remove Xtrem & Atypical values

%% Initialize parameters

Fd = 9; Ld = 73; %% col of first and last variables
ID = 1; %% col of subject ID
IDClass = 2; %% col of class for the subjects
indic = struct('Atyp', [], 'Xtrem', []);
ca = 2;
xlsfilename = filename;%'E:\DATA\Damart\damart_data_19-Aug-2015.xlsx';
type = 'delall'; % delall or delxtrem
%% read data sheet
if nargin<2
    [~, ~, R] = xlsread(xlsfilename);
    datatype = 'linear';
elseif nargin<3
    [~, ~, R] = xlsread(xlsfilename, sheet);
    datatype = 'linear';
end

%% specify filter criterii (at most 4)
cr1 = 2; typcr1 = 'num'; % col of 1st criterion, -1 if absent
cr2 = 3; typcr2 = 'str';% col of 2nd criterion, -1 if absent
cr3 = -1; typcr3 = 'str';% col of 3rd criterion, -1 if absent
cr4 = -1; typcr4 = 'str';% col of 4th criterion, -1 if absent


if cr1~=-1, Ucr1 = funique(R, cr1, typcr1);Lcr1=length(Ucr1);else Ucr1 = [];Lcr1=1;end
if cr2~=-1, Ucr2 = funique(R, cr2, typcr2);Lcr2=length(Ucr2);else Ucr2 = [];Lcr2=1;end
if cr3~=-1, Ucr3 = funique(R, cr3, typcr3);Lcr3=length(Ucr3);else Ucr3 = [];Lcr3=1;end
if cr4~=-1, Ucr4 = funique(R, cr4, typcr4);Lcr4=length(Ucr4);else Ucr4 = [];Lcr4=1;end

data2save = R;

for c2 = 1:size(R(:, Fd:Ld), 2)
    debx = 1; deba = 1; 

    for c1 = 1:Lcr1
        for c3 = 1:Lcr2
            for c4 = 1:Lcr3
                for c5 = 1:Lcr4
                    clear datatemp XtremTresh VSB VIB ligne
                    if isempty(Ucr4)
                        if isempty(Ucr3)
                            if isempty(Ucr2)
                                if isempty(Ucr1)
                                    ligne = 1:size(R, 1)-1;
                                else
                                    ligne = fnc_sortData(R(:, cr1), Ucr1(c1), typcr1);
                                end
                            else
                                ligne = fnc_sortData(R(:, [cr1 cr2]), Ucr1(c1), typcr1, Ucr2(c3), typcr2);
                            end
                        else
                            ligne = fnc_sortData(R(:, [cr1 cr2 cr3]), Ucr1(c1), typcr1, Ucr2(c3), typcr2, Ucr3(c4), typcr2);
                        end
                    else
                        ligne = fnc_sortData(R(:, [cr1 cr2 cr3]), Ucr1(c1), typcr1, Ucr2(c3), typcr2, Ucr3(c4), typcr3, Ucr4(c5), typcr4);
                    end
                    
                    %         ligne = find(ismember(R(:, 1), IDu(c1)));
                    %         datatemp = cell2mat(R(ismember(R(:, 1), IDu(c1)), init+c2-1));
                    datatemp = cell2mat(R(ligne+1, Fd+c2-1));
                    
                    switch datatype
                        case 'linear'
                            VSB = quantile(datatemp, 0.75);
                            VIB = quantile(datatemp, 0.25);
                            XtremTresh(1) = VSB + 2*ca*(VSB - VIB);
                            XtremTresh(2) = VIB - 2*ca*(VSB - VIB);
                            AtypTresh(1) = VSB + ca*(VSB - VIB);
                            AtypTresh(2) = VIB - ca*(VSB - VIB);
                            XtremVal = find(datatemp>XtremTresh(1) | datatemp<XtremTresh(2));
                            AtypiVal = find(datatemp>AtypTresh(1) | datatemp<AtypTresh(2));

                        case 'cicrular'
                            percentiles = circ_rm_Xtrem(datatemp,[5 95]);
                            VSB = percentiles(2);
                            VIB = percentiles(1);
                            
                            
                            XtremTresh(1) = wrapToPi(VSB + 2*ca*(VSB - VIB));
                            XtremTresh(2) = wrapToPi(VIB - 2*ca*(VSB - VIB));
                            AtypTresh(1) = wrapToPi(VSB + ca*(VSB - VIB));
                            AtypTresh(2) = wrapToPi(VIB - ca*(VSB - VIB));    
                            
                            XtremVal = find(datatemp>XtremTresh(1) | datatemp<XtremTresh(2));
                            AtypiVal = find(datatemp>AtypTresh(1) | datatemp<AtypTresh(2));
                    end

                    fina = deba+length(AtypiVal)-1;
                    finx = debx+length(XtremVal)-1;
                    %if ~isempty(AtypiVal)
                    indic.Atyp(deba:fina, c2)=ligne(AtypiVal);
                    %else
                    %     []
                    %end
                    %if ~isempty(XtremVal)
                    indic.Xtrem(debx:finx, c2)=ligne(XtremVal);
                    %else
                    %    []
                    %end

                    deba = fina+1;
                    debx = finx+1;
                            
                end
            end
        end
    end
end

switch lower(type)
    case 'delxtrem'
        for c2 = 1:size(R(:, Fd:Ld), 2)
            if ~isempty(indic.Xtrem(indic.Xtrem(:, c2)~=0, c2))
                R(indic.Xtrem(indic.Xtrem(:, c2)~=0, c2), Fd+c2-1) = num2cell(NaN);
            end
        end
    case 'delall'
        for c2 = 1:size(R(:, Fd:Ld), 2)
            if ~isempty(indic.Xtrem(indic.Xtrem(:, c2)~=0, c2))
                R(indic.Xtrem(indic.Xtrem(:, c2)~=0, c2), Fd+c2-1) = num2cell(NaN);
            end
            if ~isempty(indic.Atyp(indic.Atyp(:, c2)~=0, c2))
                R(indic.Atyp(indic.Atyp(:, c2)~=0, c2), Fd+c2-1) = num2cell(NaN);
            end
        end
end

xls_layout(xlsfilename, R, indic, Fd, Ld);

end

function xls_layout(xlsfilename, data, indic, Fd, Ld)

%%% creation du serveur et du workbbok
Excel = actxserver('Excel.Application');
Excel.Visible = true;
Workbook = Excel.Workbooks.Add;

% Récupération de la première feuille de calcul dans la variable
% Activesheet pour simplifier le code par la suite
ActiveSheet = Excel.Worksheets.Item(1);

% Modification du nom de la première feuille de calcul.
% L'onglet de cette feuille prend le nom "Températures"
ActiveSheet.Name = 'Cleaned';

% Écriture des données ici
range = ActiveSheet.Range('A1').get('Resize',size(data,1),size(data,2));
range.Value = data;

% Mise en forme des données ici
for c1 = 1:Ld-Fd
    for c2 = 2:size(data, 1)
        verif = 0;
        
        if ~isempty(find(indic.Atyp(:, c1)==c2, 1)) 
            rgb = [1 .65 0]; verif = 1;
        end
        if ~isempty(find(indic.Xtrem(:, c1)==c2, 1))
            rgb = [1 0 0]; verif = 1;
        end
        
        if verif ==1
            r = ActiveSheet.Range('A1').get('Cells',c2, c1+Fd-1);
            %r(2) = r(1).End('xlToRight');
            range =  ActiveSheet.get('Range', r, r);
            range.Interior.Color = 256.^(0:2)*round(rgb(:)*255);
            %range.Font.Color = 256.^(0:2)*round(rgb(:)*255);
            range.Font.Bold = true;
        end
    end
end

%%%% Save as
xlsfile = strrep(xlsfilename, '.xlsx', '_cleaned.xlsx');
%Workbook.SaveAs(xlsfile, 'xlsx');
%Workbook.Close;
Quit(Excel);
delete(Excel);



%#################### Initialisation
% ############################################################
% load obsFrance.mat -mat
% 
% Excel = actxserver('Excel.Application');
% 
% Excel.Visible = false;
% 
% Workbook = Excel.Workbooks.Add;
% 
% % Écriture des données ici
% 
% % Mise en forme des données ici
% 
% xlspath = pwd ;
% xlsfile = 'obsFrance.xlsx' ;
% 
% Workbook.SaveAs(fullfile(xlspath,xlsfile));
% 
% Workbook.Close;
% 
% Quit(Excel);
% 
% delete(Excel);

%#################### Ecriture des données
% ############################################################

% % Récupération de la première feuille de calcul dans la variable
% % Activesheet pour simplifier le code par la suite
% ActiveSheet = Excel.Worksheets.Item(1);
% 
% % Modification du nom de la première feuille de calcul.
% % L'onglet de cette feuille prend le nom "Températures"
% ActiveSheet.Name = 'Températures';
% 
% % Fusion des cellules B2 à Z3 pour écrire un titre avec une police de
% % grande taille
% range = get(ActiveSheet.Range('B2'),'Resize',2,25);
% range.Merge;
% 
% % Écriture du titre "Température du ??? au ???" dans les cellules
% % fusionnées précédemment
% titre = sprintf('Températures du %s au %s (en °C)', ...
%     datestr(echeance(1),'dd/mm/yyyy'), ...
%     datestr(echeance(end),'dd/mm/yyyy'));
% range.Name = 'titre';
% range.Value = titre;
% 
% % Fusion des cellules B4 et B5 pour améliorer le rendu visuel de la cellule
% % contenant le titre "Villes"
% range = ActiveSheet.Range('B4:B5');
% range.Merge;
% range.Value = 'Villes';
% 
% % Remplissage des noms des villes 
% range = ActiveSheet.Range('B6').get('Resize',numel(indicatif),1);
% range.Value = nom;
% 
% % Attribution du nom "villes" à la plage contenant les noms des villes pour
% % simplifier la mise en forme ultérieure
% range.Name = 'villes';
% 
% % Modification des dates en fonction des réglages Excel
% if Workbook.Date1904   
%     echeance = echeance-datenum('01-Jan-1904 00:00:00');
% else
%     echeance = echeance-datenum('30-Dec-1899 00:00:00');
% end
% 
% % Mise en place de la première ligne des dates correspondant aux jours des
% % relevés de températures
% for n = 1:6
%     
%     r(1) = ActiveSheet.Range('C4').get('Cells', 1, 4*(n-1)+1);
%     r(2) = ActiveSheet.Range('C4').get('Cells', 1, 4*n);
%     range =  ActiveSheet.get('Range', r(1), r(2));
%     
%     range.Merge;
%     range.Value = echeance(4*(n-1)+1);
% 
% end
% 
% clear r
% 
% % Mise en place de la première ligne des dates correspondant aux heures des
% % relevés de températures
% range = ActiveSheet.Range('C5').get('Resize', 1, 24);
% range.value = echeance;
% 
% % Écriture des valeurs des relevés de températures
% range = ActiveSheet.Range('C6').get('Resize',numel(indicatif),size(temperature,2));
% range.Value = temperature;

%#################### mise en page
% ############################################################

% % Définition des constantes VBA utiles
% xlCenter = -4108;
% xlMedium = -4138;
% 
% % Mise en place des bordures internes et externes du tableau
% r = ActiveSheet.Range('B2').CurrentRegion;
% r.Borders.Item('xlInsideHorizontal').LineStyle = 1;
% r.Borders.Item('xlInsideHorizontal').Weight = 2;
% r.Borders.Item('xlInsideVertical').LineStyle = 1;
% r.Borders.Item('xlInsideVertical').Weight = 2;
% r.BorderAround([],xlMedium);
% 
% % Mise en forme de la cellule (fusionnée) contenant le titre
% range = ActiveSheet.Range('titre');
% rgb = [0.7569 0.8667 0.7765];
% range.Interior.Color = 256.^(0:2)*round(rgb(:)*255);
% range.Font.Size = 28;
% rgb = [0.2314 0.4431 0.3373];
% range.Font.Color = 256.^(0:2)*round(rgb(:)*255);
% range.Font.Bold = true;
% range.HorizontalAlignment = xlCenter;
% 
% % Mise en forme de la cellule (fusionnée) contenant l'entête "Villes"
% range = ActiveSheet.Range('B4');
% range.HorizontalAlignment = xlCenter;
% range.VerticalAlignment = xlCenter;
% rgb = [0.9059 0.9059 0.9059];
% range.Interior.Color = 256.^(0:2)*round(rgb(:)*255);
% 
% % Mise en forme des cellules contenant les entêtes des dates sous forme de
% % jour
% for n = 1:6
%     range = ActiveSheet.Range('C4').get('Cells', 1, 4*(n-1)+1);
%     range.NumberFormatLocal = 'jj/mm';
%     range.HorizontalAlignment = xlCenter;
%     rgb = [0.9059 0.9059 0.9059];
%     range.Interior.Color = 256.^(0:2)*round(rgb(:)*255);
% end
% 
% % Mise en forme des cellules contenant les entêtes des dates sous forme
% % d'heures
% r(1) = ActiveSheet.Range('C5');
% r(2) = ActiveSheet.Range('C5').End('xlToRight');
% range =  ActiveSheet.get('Range', r(1), r(2));
% 
% range.NumberFormatLocal = 'hh:mm';
% range.HorizontalAlignment = xlCenter;
% rgb = [0.9059 0.9059 0.9059];
% range.Interior.Color = 256.^(0:2)*round(rgb(:)*255);
% 
% clear r
% 
% range = ActiveSheet.Range('C4').get('Resize', 1, numel(echeance));
% range =  ActiveSheet.get('Range', r(1), r(2));
% 
% range.BorderAround([],xlMedium);
% 
% clear r
% 
% % Mise en forme des valeurs des températures
% r(1) = ActiveSheet.Range('C6');
% r(2) = ActiveSheet.Range('C6').End('xlToRight').End('xlDown');
% range =  ActiveSheet.get('Range', r(1), r(2));
% range.HorizontalAlignment = xlCenter;
% 
% clear r
% 
% % Mise en forme d'une ligne sur deux pour les températures
% for n = 2:2:numel(indicatif)
%     r(1) = ActiveSheet.Range('C6').get('Cells',n,1);
%     r(2) = r(1).End('xlToRight');
%     range =  ActiveSheet.get('Range', r(1), r(2));
%     rgb = [0.8941 0.9412 0.9020];
%     range.Interior.Color = 256.^(0:2)*round(rgb(:)*255);
% end
% 
% clear r
% 
% ActiveSheet.Range('B4').BorderAround([],xlMedium);
% 
% % Mise en forme de la colonne contenant les noms des villes
% range = ActiveSheet.Range('villes');
% rgb = [0.8039 0.8784 0.9686];
% range.Interior.Color = 256.^(0:2)*round(rgb(:)*255);
% rgb = [0 0 1];
% range.Font.Color = 256.^(0:2)*round(rgb(:)*255);
% range.BorderAround([],xlMedium);
% 
% % Réduction esthétique de la largeur de la première colonne (A)
% ActiveSheet.Range('A:A').ColumnWidth = 3;
% 
% % Ajustement automatique de la largeur des colonnes de l'ensemble du tableau
% ActiveSheet.Range('B2').CurrentRegion.Columns.AutoFit;
% 
% clear r

end

function out = funique(R, cr, type)

if strcmp(type, 'num')
    if cr~=-1, out = unique(cell2mat(R(2:end, cr)));else out = [];end
    out = num2cell(out);
else
    if cr~=-1, out = unique(R(2:end, cr));else out = [];end
end

end

function datatemp = fnc_sortData(varargin)

if nargin==3 % 1 criterion
    R = varargin{1}; cr = varargin{2}; typcr = varargin{3};
    if strcmp(typcr, 'num')
        datatemp = find(cell2mat(R(2:end, 1))==cr);
    else
        datatemp = find(ismember(R(:, 1), cr)==1);
    end
elseif nargin==5 % 2 criterion
    R = varargin{1}; cr1 = varargin{2}; typcr1 = varargin{3};cr2= varargin{4}; typcr2 = varargin{5};
    if strcmp(typcr1, 'num') && strcmp(typcr2, 'num')
        datatemp = find(cell2mat(R(2:end, 1))==cr1 & cell2mat(R(2:end, 2))==cr2);
    elseif strcmp(typcr1, 'num') && strcmp(typcr2, 'str')
        datatemp = find(cell2mat(R(2:end, 1))==cell2mat(cr1) & ismember(R(2:end, 2), cr2)==1);
    elseif strcmp(typcr1, 'str') && strcmp(typcr2, 'num')
        datatemp = find(cell2mat(R(2:end, 2))==cell2mat(cr2) & ismember(R(2:end, 1), cr1)==1);
    elseif strcmp(typcr1, 'str') && strcmp(typcr2, 'str')
        datatemp = find(ismember(R(:, 2), cr2)==1 & ismember(R(:, 1), cr1)==1);
    end  
elseif nargin==7 % 3 criterion
    R = varargin{1}; cr1 = varargin{2}; typcr1 = varargin{3};cr2= varargin{4}; typcr2 = varargin{5}; cr3= varargin{6}; typcr3 = varargin{7};
    
elseif nargin==9 % 4 criterion
    R = varargin{1}; cr1 = varargin{2}; typcr1 = varargin{3};cr2= varargin{4}; typcr2 = varargin{5}; cr3= varargin{6}; typcr3 = varargin{7}; cr4= varargin{8}; typcr4 = varargin{9};
    
else
    error 'wrong number of argument'
end

end





