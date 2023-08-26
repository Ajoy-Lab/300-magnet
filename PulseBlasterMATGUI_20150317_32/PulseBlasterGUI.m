function PulseBlasterGUI()
%this is just a standard nam function that points to PulseBlaster_GUI_vX_X
%PulseBlaster_GUI_vX_X is found in the directory /GUI_Files

if (exist('./GUI_Files', 'dir') == 7)
    addpath('./GUI_Files');
else
    error('Cannot find ./GUI_Files');
end

global SPINAPI_DLL_NAME;
global SPINAPI_DLL_PATH;
global CLOCK_FREQ;

CLOCK_FREQ = 100;

SPINAPI_DLL_PATH = 'C:\SpinCore\SpinAPI\lib32\';
SPINAPI_DLL_NAME = 'spinapi';

PulseBlasterGUI_v1_1();