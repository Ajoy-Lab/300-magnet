% Open connection to instrument with IP address
dev = icdevice('ww257x_64.mdd', 'COM16')
connect(dev);
% Reset device
groupCnf = get(dev, 'Utility');
invoke(groupCnf, 'reset')
% Set the sample clock frequency
groupArb = get(dev, 'Arbitrarywaveformoutput');
invoke(groupArb, 'configuresamplerate', 30E6)
% Create three segments in channel 1 and download waves into them
groupArb = get(dev, 'Arbitrarywaveforminformation');
wfmHandle1 = invoke(groupArb, 'loadarbwfmfromfile', 'CHAN_A', 'sine_1kpts.wav');
wfmHandle2 = invoke(groupArb, 'loadarbwfmfromfile', 'CHAN_A', 'dc_256pts.wav');
wfmHandle3 = invoke(groupArb, 'loadarbwfmfromfile', 'CHAN_A', 'am_ramp_2kpts.wav');
wfmHandles = [wfmHandle1, wfmHandle2, wfmHandle3];
% Create a sequence in the active channel, currently the active
% channel is 1 because the 'loadarbwfmfromfile' function used with 'CHAN_A'
% parameter
%
% Sequence Description:
% Step # Segment # Repeats Count
% [ 1 ] [ Segment 1 ( sine_1kpts.wav )] [ 2 ]
% [ 2 ] [ Segment 2 ( dc_256pts.wav ) ] [ 3 ]
% [ 3 ] [ Segment 3 ( am_ramp_2kpts.wav )] [ 1 ]
%
groupArb = get(dev, 'Arbitrarysequenceinformation');
seqHandle = invoke(groupArb, 'createarbsequence', 3, wfmHandles, [2,3,1]);
% Create the sequence in the active channel, currently the active
groupCnf = get(dev, 'Configuration');
% Output Modes:
% 0 - Standard
% 1 - Arbitrary
% 2 - Sequence
% 3 - Modulated
invoke(groupCnf, 'configureoutputmode', 2)
% Output enable
invoke(groupCnf, 'configureoutputenabled', 'CHAN_A', 1)
% Output SYNC signal enable
%
% SYNC Types:
% 0 - BIT
% 1 - LCOM
sync_type = 1;
invoke(groupCnf, 'configuresyncsignal', wfmHandle1, sync_type, 1, 0)
% Close the connection with the instrument
disconnect(dev);
delete(dev);