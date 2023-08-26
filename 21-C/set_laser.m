function result_seq=set_laser(seq,laser)

mw_channel_no = 20;
seq.Channels(mw_channel_no).Frequency = laser;

result_seq = seq;
end