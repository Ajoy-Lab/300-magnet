function result_seq=set_rigol_mag3_2(seq,rigol3_Vpp,rigol3_freq,rigol3_offset,rigol3_phase)

mw_channel_no = 42;
seq.Channels(mw_channel_no).Parameter1 = rigol3_Vpp;
seq.Channels(mw_channel_no).Parameter2 = rigol3_freq;
seq.Channels(mw_channel_no).Parameter3 = rigol3_offset;
seq.Channels(mw_channel_no).Parameter4 = rigol3_phase;

result_seq = seq;
end