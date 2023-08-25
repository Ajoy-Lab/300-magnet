classdef ExperimentalScan < handle
    
    % Class stores experiment results after doing experiment
    
    properties
        
        ExperimentData % Averaged matrix data of the image, cell with different indeices for different acquisitions rises
        ExperimentDataEachAvg
        SequenceName
        Sequence
        vary_begin
        vary_end
        vary_step_size
        vary_points
        vary_prop
        Repetitions
        Averages
        ExperimentDataError
        ExperimentDataErrorEachAvg
        Variable_values
        Bool_values
        DateTime       % Time stamp when data was acquired
        Notes          % Notes field
        Laserpower = zeros(1,2)  %array; (1) -> avg laser power; (2) -> std dev
        SampleRate     %Sample rate with which experiment was produced
        ShapedPulses   %Shaped pulses used in the experiment
        israndom       %if the results were obtained using the random scan button
        istracking     %if results obtained using tracking
        ispower        %if results obtained using power measurements
        scan_nonlinear
        nonlinear_data
    end
    
    methods
        
        function [obj] = ExperimentalScan()
           % ConfocalImage Constructor 
        end
    end
    
end
