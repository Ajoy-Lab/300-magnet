classdef Zaber
    properties
        gpib_obj
        axis
    end
    methods
        function obj=Zaber_Open(obj)
            port = serial('COM4');
            
            % Set default serial port properties for the ASCII protocol.
            set(port, ...
                'BaudRate', 115200, ...
                'DataBits', 8, ...
                'FlowControl', 'none', ...
                'Parity', 'none', ...
                'StopBits', 1, ...
                'Terminator','CR/LF');
            set(port, 'Timeout', 0.5)
            warning off MATLAB:serial:fgetl:unsuccessfulRead
            fopen(port);
            protocol = Zaber.AsciiProtocol(port);
            device = Zaber.AsciiDevice.initialize(protocol, 1);
            axes = [];
            if (device.IsAxis)
                axes = device;
            else
                axes = device.Axes;
            end
            
            obj.axis = axes(1);
           
        end
        
        function Zaber_rot(obj,intensity)
            int = 0.01*intensity;
            arcsin_int = asin(int);
            degree = arcsin_int / pi * 2 * 44.646;
            absolutePosition=degree;
            real_absPosition = absolutePosition + 88.25390625;
            axis = obj.axis;
            micrst_change = axis.Units.positiontonative(real_absPosition);
            axis.moveabsolute(micrst_change);
            axis.waitforidle();
            pause(1.0);
            current_pos = axis.Units.nativetoposition(axis.getposition());
        end
        
        
        
    end
end