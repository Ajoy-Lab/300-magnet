classdef ConfocalScan
    %
    % ConfocalImage class
    % jhodges@mit.edu
    % 18 June 2009
    %
    % Class stores images after scanning
    
    properties
        
        ImageData      % Raw matrix data of the image
        RangeY         % Y values for image
        RangeZ         % Z values for image
        RangeX         % X values for image
        DateTime       % Time stamp when image was acquired
        Notes          % Notes field
        DwellTime      % Dwell time
        Laserpower = zeros(1,2)     % array: (1) -> laser power in mW during scan; (2) -> standard deviation in mW 
        Diffs          % difference between sent waveform and recorded one for the ramp direction
        PiezoStability1 
        PiezoStability2 %Piezo stability for: 
        % 1D scan: 1 -> dir kept cst, after ramped direction in x -> y -> z -> x -> ... rule; 2 -> other kept cst direction
        % 2D scan: 1 -> looped direction; 2 -> direction kept constant
        % 3D scan: 1 -> inner-loop direction; 2 -> outer-loop direction
        
    end
    
    methods
        
        function [obj] = ConfocalScan()
             % ConfocalImage Constructor
        end
        
    end
    
end