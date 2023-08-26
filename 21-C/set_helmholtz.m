function result_seq=set_helmholtz(seq,current)

mw_channel_no = 34;
seq.Channels(mw_channel_no).Frequency = current;

result_seq = seq;
end