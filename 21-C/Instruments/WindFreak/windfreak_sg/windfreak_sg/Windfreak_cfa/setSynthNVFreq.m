
% set synthNV frequency
% freq - frequency in MHz
% pwrLevel - optional, sets the power range to low (0) or (1), default is
% high

function [] = setSynthNVFreq(s,freq,pwrLevel,pwrDown)

if (nargin<4)
    pwrDown = 0;
end
if (nargin<3)
    pwrLevel = 1;   
end
if (pwrLevel)
    pwrLevel = 1;
end
if (pwrDown)
    pwrDown = 1;
end
wfbuf = WFGenerateBufferNV(freq,3,15,pwrLevel,pwrDown);
fwrite(s,wfbuf);

end