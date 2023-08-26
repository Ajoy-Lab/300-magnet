function result_seq=set_helmholtz_techron_2(seq,voltage)

mw_channel_no = 37;
seq.Channels(mw_channel_no).Frequency = voltage;

result_seq = seq;
end