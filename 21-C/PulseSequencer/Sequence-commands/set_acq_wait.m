function result_seq = set_acq_wait(seq, acq_time)

mw_channel_no = 9;

% it's a ttl pulsed channel
seq.Channels(mw_channel_no).Frequency =acq_time;
result_seq = seq;




