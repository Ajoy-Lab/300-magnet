function result_seq = set_BNC2(seq, new_width, new_ampl,new_delay)

rf_channel_no = 6;

% it's a ttl pulsed channel. 
%use frequency as a dummy for pulse length.
seq.Channels(rf_channel_no).Frequency = new_width;
seq.Channels(rf_channel_no).Amplitude = new_ampl;
seq.Channels(rf_channel_no).Phase = new_delay;

result_seq = seq;




