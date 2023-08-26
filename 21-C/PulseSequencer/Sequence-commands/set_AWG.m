function result_seq = set_AWG(seq, SegmentNumber)

rf_channel_no = 7;

%it's a ttl pulsed channel. 
%use amplitude as a dummy for segment number
seq.Channels(rf_channel_no).Amplitude = SegmentNumber;


result_seq = seq;




