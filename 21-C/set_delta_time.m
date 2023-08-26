function result_seq=set_delta_time(seq,delta_time)

mw_channel_no = 8;
seq.Channels(mw_channel_no).Frequency = delta_time;

result_seq = seq;
end