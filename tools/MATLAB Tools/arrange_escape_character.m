function modif_char_array = arrange_escape_character(char_array)
%ARRANGE_ESCAPE_CHARACTER Summary of this function goes here
%   Detailed explanation goes here
ar_size = max(size(char_array));
modif_char_array = '';
for i = 1:ar_size
    modif_char_array(end+1) = char_array(i);
    if strcmp(char_array(i), '\')
        modif_char_array = strcat(modif_char_array, '\');
    end
end
end

