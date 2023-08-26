
% Read NVSynth IDN (just to make sure)

function [idn] = getSynthNVIDN(s)

fwrite(s,uint8(7));
[idn,cc] = fscanf(s,'%s',24);
if (cc~=24)
    disp(['Read: ' idn '. Number of bytes read was ' num2str(cc) ' instead of 24.']);
end

end