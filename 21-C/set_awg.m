function result_seq=set_awg(seq,awg_start_freq,awg_stop_freq,awg_amp,sweep_freq,sweep_sigma)

mw_channel_no = 39;
seq.Channels(mw_channel_no).Frequency = awg_start_freq;
seq.Channels(mw_channel_no).Phase = awg_stop_freq;
seq.Channels(mw_channel_no).Amplitude = awg_amp;
seq.Channels(mw_channel_no).PhaseQ = sweep_freq;
seq.Channels(mw_channel_no).FreqIQ = sweep_sigma;
result_seq = seq;
end