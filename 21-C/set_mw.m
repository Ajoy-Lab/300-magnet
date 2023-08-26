function result_seq=set_mw(seq,freq,amp,Position)

mw_channel_no = 16;
seq.Channels(mw_channel_no).Frequency = freq;
seq.Channels(mw_channel_no).Amplitude = amp;
seq.Channels(mw_channel_no).Phase = Position;
result_seq = seq;
end