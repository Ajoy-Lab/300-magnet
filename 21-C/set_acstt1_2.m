function result_seq = set_acstt1_2(seq,toptime,looptime)

mw_channel_no = 10;

% it's a ttl pulsed channel
seq.Channels(mw_channel_no).Frequency = toptime;
seq.Channels(mw_channel_no).Amplitude = looptime;

result_seq = seq;