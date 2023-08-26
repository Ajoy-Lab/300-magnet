function result_seq=set_helmholtz_techron(seq,voltage)

mw_channel_no = 36;
seq.Channels(mw_channel_no).Frequency = voltage;

result_seq = seq;
end