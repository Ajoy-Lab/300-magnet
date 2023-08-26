
% close synthNV serial port

function [] = closeSynthNV(s)

fclose(s);
delete(s);
clear s;
evalin('base','sobj = instrfindall(''Type'',''serial'',''port'',''COM5'');');
evalin('base','delete(sobj);');

end