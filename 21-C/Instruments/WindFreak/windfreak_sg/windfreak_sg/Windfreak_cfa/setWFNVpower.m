
% Set power command
% pdB is in dB below maximal output power, which is ~15dBm

function [pwrBuf] = setWFNVpower(pdB)

pwrbyte = dec2bin(pdB*2+63);
filler = strrep(blanks(8-length(pwrbyte)),' ','0');
pwrBuf = fliplr([filler pwrbyte]);
pwrBuf(7:8) = '11';

pwrBuf = [3 uint8(bin2dec(fliplr(pwrBuf)))];

end

