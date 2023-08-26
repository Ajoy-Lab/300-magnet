function result_sequence = initialize_pulse_sequence(handles)

Number_of_channels = 5;

result_sequence = PulseSequence();

if isfield(handles, 'shaped_pulses')
    result_sequence.ShapedPulses = handles.shaped_pulses;
end

for k=1:1:Number_of_channels
	result_sequence.Channels = [result_sequence.Channels PulseChannel()]; 
	result_sequence.Channels(k).Enable = 0;
end;




