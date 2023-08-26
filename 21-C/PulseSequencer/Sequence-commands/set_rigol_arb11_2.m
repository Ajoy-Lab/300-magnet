function result_seq=set_rigol_arb11_2(seq2,Vpp2,phase2,sweep_time2,symm2,dc_level2,rigol_on,bw_range,bw_center, Match_on)

mw_channel_no = 27;
seq2.Channels(mw_channel_no).Frequency = Vpp2;
seq2.Channels(mw_channel_no).Phase = phase2;
seq2.Channels(mw_channel_no).AmpIQ = sweep_time2;
seq2.Channels(mw_channel_no).FreqIQ = symm2;
seq2.Channels(mw_channel_no).FreqmodQ =dc_level2;
seq2.Channels(mw_channel_no).Amplitude =rigol_on;

seq2.Channels(mw_channel_no).Ampmod =bw_range;
seq2.Channels(mw_channel_no).Phasemod =bw_center;
seq2.Channels(mw_channel_no).FreqmodI= Match_on;

result_seq = seq2;
end