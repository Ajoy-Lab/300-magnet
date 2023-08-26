function result_seq=set_srs(seq,srs_freq,srs_amp)

mw_channel_no = 39;
seq.Channels(mw_channel_no).FreqmodI = srs_freq;
seq.Channels(mw_channel_no).FreqmodQ = srs_amp;

result_seq = seq;
end