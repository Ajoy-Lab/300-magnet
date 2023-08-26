
% set synthNV power
% pdB is in dB below maximal output power, which is ~15dBm

function [] = setSynthNVPower(s,pdB)

if (pdB<-31.5)
    pdB = -31.5;
end
if (pdB>0)
    pdB = 0;
end
wfpwr = setWFNVpower(pdB);
fwrite(s,wfpwr);

end