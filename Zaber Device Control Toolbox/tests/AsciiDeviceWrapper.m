classdef AsciiDeviceWrapper < Zaber.AsciiDevice
%ASCIIDEVICEWRAPPER Wrapper to expose protected methods for testing.
    
    methods
        function obj = AsciiDeviceWrapper(aProtocol, aDeviceNumber, aDeviceId)
            obj = obj@Zaber.AsciiDevice(aProtocol, aDeviceNumber, aDeviceId);
        end
    end
    
end

