function [val] = lakeshoreReadOut(s)
fprintf(s, 'RDGFIELD?');
val =str2double(fscanf(s));
end