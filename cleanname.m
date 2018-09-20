function output = cleanname(input, ext)
%%% this funciton remove special characters [^\d\w~!@#$%^&()_\-{}.]* from
%%% the input name in char format 
%%% it returns output char cleaned
%%% ext must be 1 (file with extension) or 0 (file without extension) in order to clean extension 

if nargin<2
    ext = 0; %% Default
end

if ext == 1, oldfilename = input(1:end-4); else oldfilename = input;end

output = regexprep(oldfilename, '[^\d\w~!@#$%^&()_\-{}.]*','');

end