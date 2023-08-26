% This is a script is for Lucid WG Device
clear 
clc

if libisloaded('lucidsdk_x64_cpp.dll')
    unloadlibrary ('lucidsdk_x64_cpp.dll');
end
loadlibrary('lucidsdk_x64_cpp.dll');
disp('loaded lucidsdk_x64_cpp.dll ')
libfunctions('lucidsdk_x64_cpp')
calllib('lucidsdk_x64_cpp','initChannel',0,0,'lucid_log.txt',0)
max_rsp = 1024;
resp = char(zeros(max_rsp,1));

% Ask the idendification of the device
cmd = '*IDN?';   
calllib('lucidsdk_x64_cpp','SendScpi',cmd,resp,length(cmd));

% Set the freqency to 500Mhz
cmd = ':FREQuency 1000000';
calllib('lucidsdk_x64_cpp','SendScpi',cmd,resp,length(cmd));

% Set the power to 0 dBm
cmd = ':POWer 0';
calllib('lucidsdk_x64_cpp','SendScpi',cmd,resp,length(cmd));

% Set output on 
cmd = ':OUTPut ON';
calllib('lucidsdk_x64_cpp','SendScpi',cmd,resp,length(cmd));

