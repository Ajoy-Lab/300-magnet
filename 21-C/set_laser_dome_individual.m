function result_seq=set_laser_dome_individual(seq,single_laser)

mw_channel_no = 42;
seq.Channels(mw_channel_no).Frequency = single_laser;

result_seq = seq;
end