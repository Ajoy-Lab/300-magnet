
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test_FTD2XX_NET_BitBang.m
%    Simple test file demonstrates:
%       1. Calling FTDI FTD2XX_NET.dll from Matlab script
%       2. Demonstrates FTDI bitbang functionality. 
%             (Only tested on FT232BM device (DLP USB245M)
%       3. Code could be useful starting point for practicing calling 
%               other FTDI functions and possibly calling other .net dlls.
%      
%    Notes:
%       For me, appears to be a nice way to get parallel I/O capability
%           inside of Matlab apps on computers w/o classic parallel port. 
%           Evidently USB parallel port cables and peripherals such as 
%           Edgeports only appear to Windows as printer devices.
%       Tested on Windows 7, ASUS P6T Deluxe, Matlab R2010b.
%       I used 10K pullup resistor on 'D0' when testing.
%       As might be typical when messing with direct dll calls:
%          save application data and possibly backup system before starting
%          testing.  Eliminate pauses at your own risk.  My machine hung up
%          necessitating hard reset at least 4 times during this 
%          short script development.
%       You need some FTDI USB drivers on your PC before starting out:
%          http://www.ftdichip.com/Drivers/D2XX.htm
%       A real programmer would check all FTD2XX_NET return values.
%
%
%  References:
%  DLP USB245 device:
%   http://www.dlpdesign.com/usb/dlp-usb245mv15.pdf
%  FTDI related:
%   http://www.ftdichip.com/Support/Documents/DataSheets/ICs/DS_FT245BM.pdf
%   http://www.ftdichip.com/Support/Documents/AppNotes/AN232R-01_FT232RBitBangModes.pdf
%   http://www.ftdichip.com/Support/Documents/ProgramGuides/D2XX_Programmer's_Guide(FT_000071).pdf
%   
% Author: Roger M. Ellingson, Sept 29, 2010, Portland, OR USA
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Place dll in directory of your choice.
f = NET.addAssembly('C:\FTD2XX_NET.dll');

% Helpful to view other function calling parameters.
methodsview( 'FTD2XX_NET.FTDI');

fo=FTD2XX_NET.FTDI;

pause( 1);

r = OpenByIndex(fo,0);

pause( 1);

x = uint8([0,0,0]);

allBitsOutputMask = uint8(255); % '1' bit is output
bitBangMode = uint8(1); % '1' mode is async bitbang
resetMode = uint8(0);  % terminate bitbang

high = uint8(255);
low = uint8(0);

r = SetBitMode( fo, allBitsOutputMask, bitBangMode);

for n=1:5

    beep;
    x(1) = high;
    r = Write( fo, x, 1, 0);
    pause( 0.5);
    
    x(1) = low;
    r = Write( fo, x, 1, 0);
    pause(0.5);

end

% this statement sets the bits back to input mode, apparently letting 
%      DC level float.  I want it to stay low.
%r = SetBitMode( fo, allBitsOutputMask, resetMode);

r = Close(fo);
beep;
pause(0.5);
beep;
