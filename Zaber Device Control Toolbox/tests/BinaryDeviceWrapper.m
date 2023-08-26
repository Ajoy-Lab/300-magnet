classdef BinaryDeviceWrapper < Zaber.BinaryDevice
%BINARYDEVICEWRAPPER Wrapper to expose protected methods for testing.
    
    methods
        function obj = BinaryDeviceWrapper(aProtocol, aDeviceNumber, aDeviceId)
            obj = obj@Zaber.BinaryDevice(aProtocol, aDeviceNumber, aDeviceId);
        end
    end
    
end

