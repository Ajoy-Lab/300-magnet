function result_seq3=set_rigol_arb7(seq3,Vpp3,phase3,sweep_time3,symm3,dc_level3,rigol_on3)

mw_channel_no = 6;
seq3.Channels(mw_channel_no).Frequency = Vpp3;
seq3.Channels(mw_channel_no).Phase = phase3;
seq3.Channels(mw_channel_no).AmpIQ = sweep_time3;
seq3.Channels(mw_channel_no).FreqIQ = symm3;
seq3.Channels(mw_channel_no).FreqmodQ =dc_level3;
seq3.Channels(mw_channel_no).Amplitude =rigol_on3;
result_seq3 = seq3;
end