function data= HP8753ESNA( gpib_obj,freq,measurement_mode,measurement_channel,power)
% Input argument:
% gpib_obj: a GPIB object that has been opened. Example:
% gpib_obj=gpib('ni',0,16);fopen(gpib_obj)

% freq: can either be a single number, in which case the program returns
% measurement at the indicated frequency, or
% an array of 2 elements, [freq_center,freq_increment], in which case the
% program returns measurements for the three frequencies
% freq_center-freq_increment,freq_center, and freq_center+freq_increment

% measurement_mode selects what to return of the S parameter S_{ij}=|S_{ij}|*exp(i*theta)
% 1: log magnitude, return absolute value of the S parameter in dB: 20*log(|S|)
% 2: linear magnitude, return absolute value of the S parameter, 0<=|S|<=1
% 3: phase, return the phase of the S parameter in degree, -180<theta<180
% 4: polar, return the real and imaginary value of the measurement , Re[S] and Im[S]

% measurement_channel can be
% 1: S11
% 2: S12
% 3: S22
% 4: S21

% power indicates the input power in dB (typically 0)

% Output data: 
% For measurement_mode=1,2, or 3 corresponding to 
% log magnitude, linear magnitude, or phase), data=[freq (in GHz), measurement]
% For measurement_mode=4 corresponding to polar, data=[freq (in GHz), Re[measurement], Im[measurement]] 


%================= Examples =================
% Set up GPIB object: gpib_obj=gpib('ni',0,16);fopen(gpib_obj)

% With all arguments, single frequency: 
% Command: HP8753ESNA(gpib_obj, 2.5e9,4,2,0)
% Return measurement at single frequency 2.5 GHz, 
% polar mode (indicated by measurement_mode=4)
% S12 channel (indicated by measurement_channel=2), and
% input power 0 dB (indicated by power=0)
% Output: 2.5000   -0.0156   -0.0070

% With all arguments, 3-frequencies: 
% Command: HP8753ESNA(gpib_obj, [2.5e9,.01e9],4,2,0)
% Return measurement at frequencies 2.49, 2.5, and 2.51 GHz, 
% polar mode (indicated by measurement_mode=4)
% S12 channel (indicated by measurement_channel=2), and
% input power 0 dB (indicated by power=0)
% Output: 
%     2.4900   -0.0161   -0.0055
%    2.5000   -0.0157   -0.0069
%    2.5100   -0.0155   -0.0077


% One argument only: displays current status
% Command: HP8753ESNA(gpib_obj)
% Output:
% Start frequency: 2.000000 GHz
% Stop frequency: 3.000000 GHz
% Power: 0.000000 dB
% Number of points: 3
% Channel: S12
% Mode: Log magnitude (in dB)


switch nargin
    
    % Only 1 argument: assume the only argument is gpib_obj
    % Outcome: displays current status of the instrument
    case 1
        
        % Obtain start frequency
        fprintf(gpib_obj,'star?')
        freq_start=str2num(fscanf(gpib_obj));
        
        % Obtain stop frequency
        fprintf(gpib_obj,'stop?')
        freq_stop=str2num(fscanf(gpib_obj));
        
        % Obtain input power
        fprintf(gpib_obj,'powe?')
        input_power=str2num(fscanf(gpib_obj));
        
        % Obtain number of sweep
        fprintf(gpib_obj,'poin?')
        num_points=str2num(fscanf(gpib_obj));
           
        % Check for linear magnitude mode
        fprintf(gpib_obj,'linm?')
        if str2num(fscanf(gpib_obj))==1
            current_mode='Linear magnitude (in W)';
        end

        % Check for log magnitude mode
        fprintf(gpib_obj,'logm?')
        if str2num(fscanf(gpib_obj))==1
            current_mode='Log magnitude (in dB)';
        end

        % Check for phase mode
        fprintf(gpib_obj,'phas?')
        if str2num(fscanf(gpib_obj))==1
            current_mode='Phase (in degree)';
        end
        
        % Check for polar mode
        fprintf(gpib_obj,'pola?')
        if str2num(fscanf(gpib_obj))==1
            current_mode='Polar (Real and imaginary)';
        end
 
        % Check for S11 channel
        fprintf(gpib_obj,'s11?')
        if str2num(fscanf(gpib_obj))==1
            current_channel='S11';
        end       

        % Check for S12 channel
        fprintf(gpib_obj,'s12?')
        if str2num(fscanf(gpib_obj))==1
            current_channel='S12';
        end        

        % Check for S22 channel
        fprintf(gpib_obj,'s22?')
        if str2num(fscanf(gpib_obj))==1
            current_channel='S22';
        end        
        
        if freq_start<1e9&&freq_stop<1e9
            sprintf('Start frequency: %f MHz\nStop frequency: %f MHz\nPower: %f dBm\nNumber of points: %d\nChannel: %s\nMode: %s',[freq_start/1e6,freq_stop/1e6 input_power (num_points)],current_channel,current_mode)
        else
           sprintf('Start frequency: %f GHz\rStop frequency: %f GHz\rPower: %f dBm\rNumber of points: %d\nChannel: %s\nMode: %s',[freq_start/1e9 freq_stop/1e9 input_power (num_points)],current_channel,current_mode)
            
        end
        
        data='';
    
    % For more than 1 arguments: perform measurement
    % 2 arguments: use existing parameter and perform measurement
    % Otherwise: user input power, mode, and channel
    otherwise
        
        % Check for additional arguments
        if(2<nargin)           
            
            % 3 arguments: allow for setting of measurement mode
            switch measurement_mode
                case 1
                    mode='logm';
                case 2
                	mode='linm';
                case 3
                	mode='phas';
                case 4
                	mode='pola';
            end

            
            
            % 4 arguments: allow for setting channel
            if(3<nargin)
                switch measurement_channel
                    case 1
                        channel='s11';
                    case 2
                        channel='s12';
                    case 3
                        channel='s22';
                    case 4
                        channel='s21';
                end
                
                fprintf(gpib_obj,channel);
                
                % 5 arguments: allow for setting input power
                if(4<nargin)
                    
                    % Check for input power
                    if 20<power
                        'Input power has a software limit of 20 dBm'
                        return
                    else
                        fprintf(gpib_obj,['powe ',num2str(power)]);
                    end
                end
            end
            
            % Mode must be set after channel is set
            fprintf(gpib_obj,mode);
        end
        
        % If freq is a scalar, then return the measurement at that frequency
        % If freq is an array, take the first element as center frequency,
        % the second element as incremenet, and return measurements for
        % center-increment, center, and center+increment.
        % All the elements after the first two will be ignored
        if(length(freq)==1)
            
            % If input frequency is above 3 GHz, stop the program
            if 3e9<freq
                'Input frequency cannot be greater than 3 GHz'
                return
            end
            
            % Set start and stop frequency depending on input frequency
            if freq<2.9e9
                freq_start=freq;
                freq_stop=3e9;
            else
                freq_start=1e9;
                freq_stop=freq; 
            end
        else
            
            % If input frequency range is above 3 GHz or 30 kHz, stop the program
            if 3e9<(freq(1)+freq(2))||(freq(1)-freq(2))<30e3
                'Input frequency range cannot be greater than 3 GHz or below 30 kHz'
                return
            end
            
            % Set start and stop frequency depending on input frequency            
                freq_start=freq(1)-freq(2);
                freq_stop=freq(1)+freq(2);
        end
        
        % Set number of point to 3
        fprintf(gpib_obj,'poin 3');
        
        % Set frequency
        fprintf(gpib_obj,['star ',num2str(freq_start),' Hz']);
        fprintf(gpib_obj,['stop ',num2str(freq_stop),' Hz']);
        
        %Perform measurement
        fprintf(gpib_obj,'form4');      % Set the mode for data acquisition to be 'form 4'
        fprintf(gpib_obj,'opc?;sing');  % perform single sweep
        fprintf(gpib_obj,'outpform');   % query to obtain the data 
        data_string=fscanf(gpib_obj);   % Obtain the data in string
        
        data_unsorted=sscanf(data_string,['%f' ',' '%f' '\n']); % Convert data string to array
        
        % Format the output data array: if measurement mode is polar,
        % output data is an array of 3 columns, and 2 columns otherwise
        fprintf(gpib_obj,'pola?');      

        % For the case where measurement mode is polar: 3 columns
        if str2num(fscanf(gpib_obj))==1
            % For single frequency measurement
            if(length(freq)==1)
                if(freq<2.9e9)
                    data=[freq/1e9,data_unsorted(1),data_unsorted(2)];
                else
                    data=[freq/1e9,data_unsorted(5),data_unsorted(6)];
                end
            % For 3-frequencies measurement
            else
                data=[freq_start/1e9,data_unsorted(1),data_unsorted(2);freq(1)/1e9,data_unsorted(3),data_unsorted(4);freq_stop/1e9,data_unsorted(5),data_unsorted(6)];
            end
            
        % For the case where measurement mode is not polar: 2 columns
        else
            % For single frequency measurement
            if(length(freq)==1)
                if(freq<2.9e9)
                    data=[freq/1e9,data_unsorted(1)];
                else
                    data=[freq/1e9,data_unsorted(5)];
                end
            % For 3-frequencies measurement    
            else
                data=[freq_start/1e9,data_unsorted(1);freq(1)/1e9,data_unsorted(3);freq_stop/1e9,data_unsorted(5)];
            end            
        end
end

end

