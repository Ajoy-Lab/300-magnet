function result_seq=set_hp_arb4_2(seq4,Vpp4,phase4,sweep_time4,symm4,dc_level4,hp_on4, bw_range, bw_center, Match_on)

mw_channel_no = 23;
seq4.Channels(mw_channel_no).Frequency = Vpp4;
seq4.Channels(mw_channel_no).Phase = phase4;
seq4.Channels(mw_channel_no).AmpIQ = sweep_time4;
seq4.Channels(mw_channel_no).FreqIQ = symm4;
seq4.Channels(mw_channel_no).FreqmodQ =dc_level4;
seq4.Channels(mw_channel_no).Amplitude =hp_on4;
result_seq = seq4;

seq4.Channels(mw_channel_no).Ampmod =bw_range;
seq4.Channels(mw_channel_no).Phasemod =bw_center;
seq4.Channels(mw_channel_no).FreqmodI= Match_on;
end