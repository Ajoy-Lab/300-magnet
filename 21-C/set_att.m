function result_seq=set_att(seq,attenuation)

mw_channel_no = 29;
seq.Channels(mw_channel_no).Amplitude = attenuation;
result_seq = seq;
end