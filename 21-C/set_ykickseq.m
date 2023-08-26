function result_seq=set_rigol_ykickseq(seq,pw3)

mw_channel_no = 45;

seq.Channels(mw_channel_no).Frequency = pw3;

result_seq = seq;
end