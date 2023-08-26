
% Set int/ext reference command

function [] = setSynthNVRef(s,int)

if int
    int = 1;
else
    int = 0;
end
refBuf = [uint8(6) uint8(int)];
fwrite(s,refBuf);

end