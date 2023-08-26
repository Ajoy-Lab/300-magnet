% Test data
db = Zaber.DeviceDatabase.instance();

%% Test device/peripheral IDs exist and can be retrieved.
ids = db.getalldeviceids();
assert(~isempty(ids));
for (i = 1:length(ids))
    deviceRecord = db.finddevice(ids(i));
    assert(~isempty(deviceRecord));
    assert(deviceRecord.DeviceId == ids(i)); % This knows an implementation detail.
    perIds = db.getallperipheralids(deviceRecord);
    assert(~isempty(perIds))
    for (j = 1:length(perIds))
        pId = perIds(j);
        periRecord = db.findperipheral(deviceRecord, pId);
        assert(~isempty(periRecord));
        assert(periRecord.PeripheralId == pId); % This knows an implementation detail.
        name = db.getdevicename(deviceRecord, periRecord);
        assert(~isempty(name));
        [type, units] = db.determinemotiontype(deviceRecord, periRecord);
        if (type ~= Zaber.MotionType.None)
            assert(units.PositionUnitScale > 0);
            assert(units.VelocityUnitScale > 0);
            assert(units.AccelerationUnitScale > 0);
        end
    end
end

%% Test units of measure are as expected for a few choice devices.
% RST-120AK
devRec = db.finddevice(50001);
[type, units] = db.determinemotiontype(devRec);
assert(type == Zaber.MotionType.Rotary);
units.Resolution = 64;
assert(issimilar(units.nativetoposition(1), 0.00015625));
assert(issimilar(units.positiontonative(1), 6400));
assert(issimilar(units.nativetovelocity(1), 0.00015625));
assert(issimilar(units.velocitytonative(1), 6400));
assert(issimilar(units.nativetoacceleration(0.6400 * 1.6384), 1.0));
assert(issimilar(units.accelerationtonative(1/1.6384), 0.6400));
% X-LHM100A
devRec = db.finddevice(50081);
[type, units] = db.determinemotiontype(devRec);
assert(type == Zaber.MotionType.Linear);
units.Resolution = 64;
assert(issimilar(units.nativetoposition(1), 0.124023437 / 1000000));
assert(issimilar(units.positiontonative(1), 8062992.15, 0.1));
assert(issimilar(units.nativetovelocity(1), 0.124023437 / 1000000));
assert(issimilar(units.velocitytonative(1), 8062992.15, 0.1));
assert(issimilar(units.nativetoacceleration(8062992.15 * 1.6384), 10000, 1));
assert(issimilar(units.accelerationtonative(0.124023437 / 1.6384), 100, 0.1));
% X-GSM40
devRec = db.finddevice(50315);
[type, units] = db.determinemotiontype(devRec);
assert(type == Zaber.MotionType.Rotary);
units.Resolution = 64;
assert(issimilar(units.nativetoposition(1), 0.00016252216));
% T-OMG
devRec = db.finddevice(311);
[type, units] = db.determinemotiontype(devRec);
assert(type == Zaber.MotionType.Tangential);
% X-JOY
devRec = db.finddevice(51000);
[type, units] = db.determinemotiontype(devRec);
assert(type == Zaber.MotionType.None);


%% Cleanup
clear all;


% Helpers
function ans = issimilar(a, b, tolerance)

    tol = 0.000000001;
    if (nargin > 2)
        tol = tolerance;
    end

    ans = (abs(a - b) < tol);
end
