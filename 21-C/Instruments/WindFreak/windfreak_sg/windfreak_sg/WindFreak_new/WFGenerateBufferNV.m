function [ WFBuffer ] = WFGenerateBufferNV( RF, Pwr, Iout, pwrLevel, pwrDown )
%WFGENERATEBUFFER Generates the buffer to be written via bitbang
%   Parameters:
%   RF - desired RF output in MHz
%   Pwr - desired output power, integer from 0-3
%   Iout - desired output current, integer from 0-15 (0.31-5.00 mA)
    
    %SYSTEM PARAMETERS (should not be touched by user)
    Ref = 10;
    Refdiv= 5;
    Phase = 1;
    stepsize = 0.001;
    
    % CALCULATE REGISTER INPUTS
    %fpfd = Ref * (1 + Refm2)/(Refdiv * ( 1 + Refd2 ) );
    fpfd = Ref/Refdiv;
    [Vco, outDiv] = getVco( RF );
    Mod = int32(fpfd/(2^outDiv*stepsize));
    Frac = int32((Vco/fpfd-floor(Vco/fpfd))*Mod);
    Int = int16(floor(Vco/fpfd));
    % Reduce the fraction
    %[ Frac, Mod ] = rat( Frac / Ref, 1e-3 );

    % SET REGISTERS
    %Set Register 5
    reg5 = setRegNumber( 4194309 ); %magic number from labview  
    %Set Register 4
    reg4 = setReg4( Pwr, outDiv, pwrLevel); %sets the 2 bit power
    %Set Register 3
    reg3 = setRegNumber( 1203 ); % magic number from labview
    %Set Register 2
    reg2 = setReg2( Iout, pwrDown ); %sets the 4 bit current
    %Set Register 1
    reg1 = setReg1( Mod, Phase );
    %Set Register 0
    reg0 = setReg0( Int, Frac );
    % Convert registers into 8 bit serial command and put in buffer
    WFBuffer = [1 makeSerialBuffer( [ reg5; reg4; reg3; reg2; reg1; reg0 ] )];
end

%MAKE SERIAL BUFFER
function [ buff ] = makeSerialBuffer( registers )
% Add the serialized version of each register to the buffer
    numRegisters = size( registers, 1 );
    buff = [];
    for i=1:numRegisters
        regx = registers(i,:);
        buff = [ buff regToSerial2( regx ) ];
    end
end

function [ serial ] = regToSerial2 ( reg )
    serial = [];
    for ci = 3:-1:0
        ind1 = 24-ci*8+1;
        s1 = num2str(reg(ind1:ind1+7));
        s2 = strrep(s1,' ','');
        serial = [serial uint8(bin2dec(s2))];
    end    
end

function [ serial ] = regToSerial( reg )
% Convert the input register to: each entry gets mapped to two bytes
    len = size( reg, 2 );
    serial = uint8( zeros( 1, 2*len + 5 ) );
    for i=1:len
        if ( reg(i) == 0 )
            data = 0;
        elseif ( reg(i) == 1 )
            data = 2^2;
        end
            serial( 2*i - 1 ) = uint8( 2^3 + data );
            serial( 2*i ) = uint8( 2^3 + data + 2 );
    end
    
    serial( 2*len + 1 ) = uint8( 8 );
    serial( 2*len + 2 ) = uint8( 8 );
    serial( 2*len + 3 ) = uint8( 9 );
    serial( 2*len + 4 ) = uint8( 9 );
    serial( 2*len + 5 ) = uint8( 0 );
    %serial( 2*len + 1 ) = uint8( bin2byte( [ 0 0 0 0 1 0 0 0 ] ) );
    %serial( 2*len + 2 ) = uint8( bin2byte( [ 0 0 0 0 1 0 0 0 ] ) );
    %serial( 2*len + 3 ) = uint8( bin2byte( [ 0 0 0 0 1 0 0 1 ] ) );
    %serial( 2*len + 4 ) = uint8( bin2byte( [ 0 0 0 0 1 0 0 1 ] ) );
    %serial( 2*len + 5 ) = uint8( bin2byte( [ 0 0 0 0 0 0 0 0 ] ) );

end

% HELPER FUNCTIONS
function [ array ] = dec2BinArray( dec )
    str = dec2bin( dec );
    len = size( str, 2);
    array = zeros( 1, len );
    for i=1:len
        array(i) = str2double( str( i ) );
    end
end

function [ Vco, outDiv ] = getVco( RFin )
%getVco gets the VCO frequency for the given RF input
    r1 =  2200/RFin ; %magic number from labview
    if (r1<=1)
        n=0;
    elseif (r1<=2)
        n=1;
    elseif (r1<=4)
        n=2;
    elseif (r1<=8)
        n=3;
    else 
        n=4;
    end
    Vco = RFin * 2^n;
    outDiv = n;
end

function[ array ] = padLeft( input, n )
% bads the input with zeros to make it length n
    remainder = n - size( input, 2 );
    array = [ zeros( 1, remainder ) input ];
end

% REGISTRY SETTING FUNCTIONS

function [ array ] = setRegNumber( num )
% Gives a register based on a decimal number
    p2 = dec2BinArray( num );
    array = padLeft( p2, 32 );
end

function [ reg4 ] = setReg4( Pwr, outDiv, pwrLevel )
% Sets the value for register 4
    binDiv = padLeft(dec2BinArray(outDiv),3);
    start = [ 0 0 0 0 0 0 0 0 1 ];
    %default Band Select clock divider = 100
    bscl = [ 0 1 1 0 0 1 0 0 ];
    misc = [ 0 1 0 0 0 0 pwrLevel ];
    Parray = padLeft( dec2BinArray( Pwr ), 2 );
    prog = [1 0 0];
    reg4 = [ start binDiv bscl misc Parray prog ];
end

function[ reg2 ] = setReg2( Iout, pwrDown )
% Sets the value of registry 2 for a desired output current
    start = [ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 1 1];
    endPart = [ 0 1 1 pwrDown 0 0 0 1 0 ];
    Iarray = padLeft( dec2BinArray( Iout ), 4);
    reg2 = [ start Iarray endPart ];
end

function[ reg1 ] = setReg1( Mod, Phase )
    part1 = [ 0 0 0 0 1 ];
    phaseArray = padLeft( dec2BinArray( Phase ), 12 );
    modArray = padLeft( dec2BinArray( Mod ), 12 );
    part2 = [ 0 0 1 ];
    reg1 = [ part1 phaseArray modArray part2 ];
end

function[ reg0 ] = setReg0( Int, Frac )
    part1 =  0;
    intArray = padLeft( dec2BinArray( Int ), 16 );
    fracArray = padLeft( dec2BinArray( Frac ), 12 );
    part2 = [ 0 0 0 ];
    reg0 = [ part1 intArray fracArray part2 ];
end

