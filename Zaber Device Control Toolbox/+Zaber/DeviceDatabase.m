classdef DeviceDatabase < handle
%   DEVICEDATABASE Access point for table lookups about Zaber devices.
%   This class is a singleton that Zaber.Device instances consult to learn
%   the properties of devices, such as their names, types and physical
%   units of measure.
%
%   The default implementation loads the information from a .mat file that
%   is generated offline by a Python script. Zaber provides a publicly
%   downloadable sqlite3 database of device information, and the Python
%   script translates this into a MATLAB .mat file. You can optionally
%   re-run the Python script yourself to update the data.
%
%   You can also optionally replace the singleton instance of this class
%   with your own implementation that reads the sqlite3 database directly,
%   or for fast, low-memory results have it just return hardcoded values
%   for the devices you know you have. To do this, define your own class
%   with the same methods and pass an instance of it to the instance()
%   method before using any other parts of this toolbox.
%
%   See also Zaber.Device, Zaber.AsciiDevice, Zaber.BinaryDevice

%   Author: Zaber Technologies Software Team <contact@zaber.com>
    
    
    
%% Protected instance properties
    properties (Access = protected)
        Data
    end

    
%% Public static methods
    methods (Static)
        function obj = instance(aImplementation)
        % INSTANCE Get or replace the singleton instance of the device database.
        % db = Zaber.DeviceDatabase.instance()
        % db = Zaber.DeviceDatabase.instance(myImpl)
        %
        % myImpl - Optional; allows overriding the default
        %          implementation with a customized one. Pass in an
        %          instance of your custom implementation. If providing
        %          your own implementation, you should only pass it in
        %          once. You can also pass in the empty array to force
        %          use of the default implementation.
        % db     - Return value - the single instance of this class or
        %          of the custom version passed in.
        
            persistent sTheInstance;

            if (nargin > 0)
                if (isempty(aImplementation))
                    if (isempty(sTheInstance) || ~isa(sTheInstance, 'Zaber.DeviceDatabase'))
                        sTheInstance = Zaber.DeviceDatabase();
                    end
                else
                    sTheInstance = aImplementation;
                end
            elseif isempty(sTheInstance)
                sTheInstance = Zaber.DeviceDatabase();
            end
            
            obj = sTheInstance;
        end
    end

    
 %% Public instance methods
    methods
        function obj = DeviceDatabase(aFile)
        % DEVICEDATABASE Constructor. Loads a .mat file.
        % db = DEVICEDATABASE();
        % db = Zaber.DeviceDatabase.instance(DEVICEDATABASE('myfile.mat'));
        %
        % aFile - Optional. Specifies the file name of a .mat table to
        %         load. By default this class loads DeviceDatabase.mat
        %         from the same location as this class.
        % db    - An initialized instance of this database object.
            
            obj.Data = [];
            if (nargin > 0)
                filename = aFile;
            else
                myPath = mfilename('fullpath');
                [path, name, ext] = fileparts(myPath);
                path = sprintf('%s/DeviceDatabase.mat', path);
                filename = fullfile(path);
            end
            
            table = load(filename);
            obj.Data = table.devices;
        end
        
        
        function ids = getalldeviceids(obj)
        % GETALLDEVICEIDS Get all known device IDs.
        % list = dg.GETALLDEVICEIDS();
        %
        % Returns an array of integers representing all the device IDs
        % in the database. This exists mainly for testing purposes.
        %
        % See also finddevice, getallperipheralids
            
            ids = [obj.Data.DeviceId];
        end
        
        
        function record = finddevice(obj, aDeviceId)
        % FINDDEVICE Get the database record for a device.
        % record = db.FINDDEVICE(deviceId);
        %
        % deviceId     - Numeric ID of the device to look for.
        % record       - Output. An opaque type that represents the
        %                database record for the specified device. This
        %                is meant to be used as a handle and passed to
        %                other database methods to get specific data
        %                out of it. Returns the empty array on failure.
        %
        % See also findperipheral
            
            record = obj.Data([obj.Data.DeviceId] == aDeviceId);
        end
        
        
        function ids = getallperipheralids(obj, aDeviceRecord)
        % GETALLPERIPHERALIDS Get all valid peripheral IDs for the
        % given device.
        % list = dg.GETALLPERIPHERALIDS(deviceRecord);
        %
        % Returns an array of integers representing all the peripheral IDs
        % in the database that correspond with the given device record.
        % This exists mainly for testing purposes. 
        %
        % See also findperipheral, getalldeviceids
            
            ids = [aDeviceRecord.Peripherals.PeripheralId];
        end

        
        function record = findperipheral(obj, aDeviceRecord, aPeripheralId)
        % FINDPERIPHERAL Get the database record for a device's peripheral.
        % record = db.FINDPERIPHERAL(deviceRecord, peripheralId);
        %
        % deviceRecord - A record returned by FINDDEVICE.
        % peripheralId - Numeric ID of the peripheral to look for.
        % record       - Output. An opaque type that represents the
        %                database record for the specified peripheral. This
        %                is meant to be used as a handle and passed to
        %                other database methods to get specific data
        %                out of it. Returns the empty array on failure.
        %
        % Note that integrated devices will always have a peripheral
        % record, but the peripheral ID will be 0 in the case that the
        % device is not a standalone controller. This is to enable some
        % consistency in where physical properties are stored in the
        % database.
        %
        % See also finddevice
            
            record = aDeviceRecord.Peripherals(...
                [aDeviceRecord.Peripherals.PeripheralId] == aPeripheralId);
        end
        
        
        function name = getdevicename(obj, aDeviceRecord, aPeripheralRecord)
        % GETDEVICENAME Get a human-readable name for a device.
        % name = db.GETDEVICENAME(deviceRecord, peripheralRecord);
        %
        % deviceRecord     - Device information from FINDDEVICE.
        % peripheralRecord - Peripheral information from % FINDPERIPHERAL.
        % name             - Name for the device + peripheral combination.
        %
        % See also finddevice, findperipheral
        
            if ((nargin > 2) && ~isempty(aPeripheralRecord.Name))
                name = sprintf('%s + %s', aDeviceRecord.Name, aPeripheralRecord.Name);
            else
                name = aDeviceRecord.Name;
            end
            
            if (isempty(name))
                name = sprintf('Device type %d + peripheral type %d', ...
                    aDeviceRecord.DeviceId, aPeripheralRecord.PeripheralId);
            end
        end
        
        
        function [type, units] = determinemotiontype(obj, aDeviceRecord, aPeripheralRecord)
        % DETERMINEMOTIONTYPE Get the motion type and unit conversions
        % for a device and peripheral.
        % [type, units] = db.DETERMINEMOTIONTYPE(deviceRecord, peripheralRecord);
        %
        % deviceRecord     - Device information from FINDDEVICE.
        % peripheralRecord - Peripheral information from % FINDPERIPHERAL.
        % type             - Motion type of the device. See also 
        %                    Zaber.MotionType.
        % units            - Unit conversion table for the device. See
        %                    also Zaber.DeviceUnits.
        %
        % See also finddevice, findperipheral
            
            if (nargin > 2)
                peripheral = aPeripheralRecord;
            else
                peripheral = aDeviceRecord.Peripherals(1);
            end
            
            type = Zaber.MotionType(peripheral.MotionType);
            units = Zaber.DeviceUnits();
            units.PositionUnitScale = double(peripheral.PositionUnitScale);
            units.VelocityUnitScale = double(peripheral.VelocityUnitScale);
            units.AccelerationUnitScale = double(peripheral.AccelerationUnitScale);
            units.ForceUnitScale = double(peripheral.ForceUnitScale);
        end
    end
    
end

