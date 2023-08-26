function result_seq=set_rigol_arb2(seq2,Vpp2,phase2,sweep_time2,symm2,dc_level2,rigol_on)

mw_channel_no = 21;
seq2.Channels(mw_channel_no).Frequency = Vpp2;
seq2.Channels(mw_channel_no).Phase = phase2;
seq2.Channels(mw_channel_no).AmpIQ = sweep_time2;
seq2.Channels(mw_channel_no).FreqIQ = symm2;
seq2.Channels(mw_channel_no).FreqmodQ =dc_level2;
seq2.Channels(mw_channel_no).Amplitude =rigol_on;

result_seq = seq2;
end