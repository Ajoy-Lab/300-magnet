function result_seq=set_rigol_mag3(seq,rigol2_Vpp,rigol2_freq,rigol2_offset,rigol2_phase)

mw_channel_no = 42;
seq.Channels(mw_channel_no).AmpIQ = rigol2_Vpp;
seq.Channels(mw_channel_no).FreqIQ = rigol2_freq;
seq.Channels(mw_channel_no).PhaseQ = rigol2_offset;
seq.Channels(mw_channel_no).SymmTime2 = rigol2_phase;

result_seq = seq;
end