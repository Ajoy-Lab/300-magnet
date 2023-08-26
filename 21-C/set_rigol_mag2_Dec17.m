function result_seq=set_rigol_mag2(seq,rigol_Vpp,rigol_freq,mod_state,mod_freq,rigol_DC_offset,rep)

mw_channel_no = 42;
seq.Channels(mw_channel_no).FreqmodI = rigol_Vpp;
seq.Channels(mw_channel_no).FreqmodQ = rigol_freq;
seq.Channels(mw_channel_no).SymmTime1 = rep;
seq.Channels(mw_channel_no).Phase = rigol_DC_offset;
seq.Channels(mw_channel_no).Frequency = mod_state;
seq.Channels(mw_channel_no).Amplitude = mod_freq;

result_seq = seq;
end