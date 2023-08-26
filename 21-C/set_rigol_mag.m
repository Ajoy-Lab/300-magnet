function result_seq=set_rigol_mag(seq,rigol_Vpp,rigol_freq)

mw_channel_no = 42;
seq.Channels(mw_channel_no).FreqmodI = rigol_Vpp;
seq.Channels(mw_channel_no).FreqmodQ = rigol_freq;

result_seq = seq;
end