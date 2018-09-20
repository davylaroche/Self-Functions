function [ output_vars ] = Nexus_MP_reader( filename, parameters )
% This function read and give fields of mp file linked to PiG files

if nargin<2, diplasylist = 1;else diplasylist = 0;end
%% Format string for each line of text:
%   column1: text (%s)
%	column2: text (%s)
%   column3: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%s%f%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec);

%% Close the text file.
fclose(fileID);

%% Create list of variables
S = dataArray{1}; data = dataArray{3};
if diplasylist == 1
    [Selection,~] = listdlg('PromptString','Select variable(s):', 'ListString', S);
else
    for c2 = 1:length(parameters)
        Selection(c2) = find(ismember(S, parameters(c2)));
    end
end

%% Create output variable
for c1=1:length(Selection)
    output_vars(c1, 1:2) = [S(Selection(c1)), num2cell(data(Selection(c1)))];
end
end

