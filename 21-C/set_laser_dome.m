function result_seq=set_laser_dome(seq,laser)

mw_channel_no = 41;
seq.Channels(mw_channel_no).Frequency = laser;

result_seq = seq;
end