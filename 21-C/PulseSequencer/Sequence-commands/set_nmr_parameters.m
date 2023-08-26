function result_seq = set_nmr_parameters(seq,pw,d3,gain,loop_num,sequence_type)

mw_channel_no = 38;

% it's a ttl pulsed channel
seq.Channels(mw_channel_no).Frequency = pw;
seq.Channels(mw_channel_no).Amplitude = loop_num;
seq.Channels(mw_channel_no).Phase =  d3;
seq.Channels(mw_channel_no).PhaseQ = sequence_type;
seq.Channels(mw_channel_no).FreqIQ = gain;
result_seq = seq;




