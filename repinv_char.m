function [target_name] = repinv_char(target)
%%% this function replace all invalide characters in target by '_'

symbols = [' ', '\', '/', ':', '*', '?', '"', '<', '>','|', '&','(', '}', '{', ')', '[',']', ...
    '^', '@', ',', '$', '=', '+', '!', '#', '~',  '%',  '.'];

for x = 1:length(symbols)
    
    target = strrep(target, symbols(x), '_');

end

target_name = target;

end