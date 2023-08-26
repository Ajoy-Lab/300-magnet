classdef RigolDS7024
    properties
        gpib_obj
        port_name
    end
    methods
        function obj=RigolDS7024()
            % Check open ports with Rigol scopes and close any if open
            serialObj = instrfind;
            s=size(serialObj);
            for i=1:s(1,2)
                if strcmp(serialObj(i).Name,'VISA-USB-0-0x1AB1-0x0514-DS7A241600226-0')
                    fclose(serialObj(i));
                end
            end
            for i=1:s(1,2)
                if strcmp(serialObj(i).Status,'closed')
                    delete(serialObj(i));
                end
            end

            clear b1 SampRate yor data1 DS1000z
            obj.gpib_obj = instrfind('Type', 'visa-usb', 'RsrcName', 'USB0::0x1AB1::0x0514::DS7A241600226::INSTR', 'Tag', '');

            % Create the VISA-USB object if it does not exist
            % otherwise use the object that was found.
            if isempty(obj.gpib_obj)
                 obj.gpib_obj = visa('NI', 'USB0::0x1AB1::0x0514::DS7A241600226::INSTR');
            else
                fclose(obj.gpib_obj);
                obj.gpib_obj = obj.gpib_obj(1);
            end
            % Set the device property. In this demo, the length of the input buffer is set to 2048.
            obj.gpib_obj.InputBufferSize = 20480;
            % Connect to instrument object, obj1.
            fopen(obj.gpib_obj);
        end

        function set_single(obj)
            fprintf(obj.gpib_obj, ':SING' );
        end

        function close(obj)
           fclose(obj.gpib_obj);
        end

        function [timeaxis,data1]=Acquire(obj)
           
            % Set channel
            fprintf(obj.gpib_obj, ':WAV:SOURce CHAN1' );
            % Normal Mode
            fprintf(obj.gpib_obj, ':WAV:MODE NORM' );
            % Samplerate T?
            fprintf(obj.gpib_obj, ':WAVeform:XINCrement?');
            SampRate = str2num(fscanf(obj.gpib_obj));
            % Query Yorigin
            fprintf(obj.gpib_obj, ':WAVeform:YOR?' ); yor=num2str(fscanf(obj.gpib_obj));
            % Set in Ascii mode
            fprintf(obj.gpib_obj, ':wav:form asc' );
            % set points to maximum
            fprintf(obj.gpib_obj, ':wav:points max' );
            % query number of points
            fprintf(obj.gpib_obj, ':wav:points?' );
            points=str2num(fscanf(obj.gpib_obj));
            % set start and stop
            fprintf(obj.gpib_obj, [':WAVeform:STOP ' num2str(points)]);
            fprintf(obj.gpib_obj, ':WAVeform:STAR 1');
            % Begin acquisition
            fprintf(obj.gpib_obj, ':WAVeform:BEG' );
            % Read the data
            fprintf(obj.gpib_obj, ':WAVeform:DATA?' );
            a=  fread(obj.gpib_obj);
            b1=char(a(1:end-1))';
            for j=1:points
                data1(j)=str2num(b1(12+12*(j-1)+2*(j-1): 24+12*(j-1) + 2*(j-1)));
            end
            timeaxis=SampRate*[1:points];
            start_fig(100,[5 1]);
            p1=plot_preliminaries(timeaxis*1e3,data1,2,'nomarker');
            set(p1,'linewidth',0.5);
            plot_labels('Time [ms]','Signal [V]');
        end
    end
end