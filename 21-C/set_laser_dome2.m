function result_seq=set_laser_dome2(seq,laser, laser_sequence)

mw_channel_no = 41;
seq.Channels(mw_channel_no).Frequency = laser;
seq.Channels(mw_channel_no).Amplitude = laser_sequence;
result_seq = seq;
end