function result_seq=set_rigol_mag3(seq,rigol_Vpp,rigol_freq)

mw_channel_no = 42;
seq.Channels(mw_channel_no).AmpIQ = rigol_Vpp;
seq.Channels(mw_channel_no).FreqIQ = rigol_freq;


result_seq = seq;
end