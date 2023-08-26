function result_seq=set_helmholtz2(seq,current)

mw_channel_no = 37;
seq.Channels(mw_channel_no).Frequency = current;

result_seq = seq;
end