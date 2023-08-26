function result_seq=set_mw2(seq,freq,amp)

mw_channel_no = 16;
seq.Channels(mw_channel_no).Frequency = freq;
seq.Channels(mw_channel_no).Amplitude = amp;
result_seq = seq;
end