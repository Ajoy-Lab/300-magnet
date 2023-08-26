function result_seq = set_acs_position2(seq,tt1)

mw_channel_no = 10;

% it's a ttl pulsed channel
seq.Channels(mw_channel_no).Frequency = tt1;

result_seq = seq;