function result_seq=set_mw_sweep2(seq,start_freq,stop_freq,sweep_time,amp)

mw_channel_no = 18;
seq.Channels(mw_channel_no).Frequency = start_freq;
seq.Channels(mw_channel_no).Phase = stop_freq;
seq.Channels(mw_channel_no).AmpIQ = sweep_time;
seq.Channels(mw_channel_no).Amplitude = amp;
result_seq = seq;
end