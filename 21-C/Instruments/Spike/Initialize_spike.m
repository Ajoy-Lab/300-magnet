function [start,stop]= Initialize_spike()
LibraryName = 'sa_api';
LibraryFilePath = 'sa_api.dll';
HeaderFilePath = 'sa_api.h';
%Load Spike Library
[status] = loadlibrary(LibraryFilePath,HeaderFilePath,'alias',LibraryName);

%Open Spectrum Analyzer
devicePtr=libpointer('int32Ptr',0);
handle = devicePtr.Value;
message=calllib('sa_api','saOpenDevice',devicePtr);

%Get Device type and serial number (only for testing communications)
% type = libpointer('saDeviceType', 1);
% [status] = calllib(LibraryName,'saGetDeviceType', handle,type); 
% 
% serial = libpointer('int32Ptr', 1);
% [status] = calllib(LibraryName,'saGetSerialNumber',handle,serial);

%Configure detection mode and linear/log scaling
SA_MIN_MAX = uint32(0);
detector = SA_MIN_MAX;
SA_LIN_SCALE = uint32(0);
scale = SA_LIN_SCALE;
settings(1,:) = calllib(LibraryName, 'saConfigAcquisition', handle, detector, scale);

% %Configure sweep frequency range
% center = 2.8e9;
% span = 1.6e9;

% center = 2.4e9;
% span = 1.6e9;

% center = 2.7e9;
% span = 1.2e9;

%  center = 2.8e9;
%  span = 1.4e9;
% 
%    center = 3.1e9;
%    span = 1.4e9;

% 
% center = 2.75e9;
% span = 0.3e9;

% center = 2.75e9;
% span = 2e9;

% center =3e9;
% span = 1.6e9;

% center =2.5e9;
% span = 1.4e9;

%  center = 2.7e9;
%  span = 1.8e9;
% 
  center = 3.3e9;
  span = 1.4e9;
%   
%     center = 3.7e9;
%   span = 1.4e9;

% %-1 manifold
%  center = 2.65e9;
%  span = 1.9e9;

% %+-1 manifold
%   center = 2.8e9;
%   span = 1.6e9;

stop = center + (span/2);
start = center - (span/2);
settings(2,:) = calllib(LibraryName, 'saConfigCenterSpan', handle, center, span);

%Configure reference level
ref = double(18);
settings(3,:) = calllib(LibraryName, 'saConfigLevel', handle, ref);

%Configure gain and attenuation (automatic if function is not called
atten = -1;
gain = -1;
settings(4,:) = calllib(LibraryName, 'saConfigGainAtten', handle, atten, gain, 0);

%Configure RBW/VBW settings
rbw =100e3;
vbw = 100e3;
reject = 1; %enables image rejection
coupling = calllib(LibraryName, 'saConfigSweepCoupling', handle, rbw, vbw, reject);

%Configure VBW Processing
SA_POWER_UNITS = uint32(0);
units = SA_POWER_UNITS;
settings(6,:) = calllib(LibraryName, 'saConfigProcUnits', handle, units);

%Configure RBW Shape
SA_RBW_SHAPE_FLATTOP = uint32(0);
flat = SA_RBW_SHAPE_FLATTOP;
[shape] = calllib(LibraryName, 'saConfigRBWShape', handle, flat);

%Initialize Sweep mode
SA_SWEEPING = uint32(0);
[status] = calllib(LibraryName, 'saInitiate', handle, SA_SWEEPING, 0);

end