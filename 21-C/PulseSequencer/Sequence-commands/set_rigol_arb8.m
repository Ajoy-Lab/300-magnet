function result_seq4=set_rigol_arb8(seq4,Vpp4,phase4,sweep_time4,symm4,dc_level4,rigol_on4)

mw_channel_no = 7;
seq4.Channels(mw_channel_no).Frequency = Vpp4;
seq4.Channels(mw_channel_no).Phase = phase4;
seq4.Channels(mw_channel_no).AmpIQ = sweep_time4;
seq4.Channels(mw_channel_no).FreqIQ = symm4;
seq4.Channels(mw_channel_no).FreqmodQ =dc_level4;
seq4.Channels(mw_channel_no).Amplitude =rigol_on4;
result_seq4 = seq4;
end