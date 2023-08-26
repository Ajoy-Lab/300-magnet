function result_seq = set_tektronix_AFG_31000(seq, tek_freq, tek_Vpp, tek_DC_offset, tek_phase)
mw_channel_no = 45;
seq.Channels(mw_channel_no).Frequency = tek_freq;
seq.Channels(mw_channel_no).Amplitude = tek_Vpp;
seq.Channels(mw_channel_no).Parameter1 = tek_DC_offset;
seq.Channels(mw_channel_no).Phase = tek_phase;
result_seq = seq;
end