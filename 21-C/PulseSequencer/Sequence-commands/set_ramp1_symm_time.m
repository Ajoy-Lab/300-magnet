function result_seq=set_ramp1_symm_time(seq,sweep_freq,Vpp1,dc_level1,phase1,bw_range1,bw_center1, Match_on_arb1,ramp1_on,symm_time1,symm_time2)

mw_channel_no = 30;
seq.Channels(mw_channel_no).Frequency = sweep_freq;
seq.Channels(mw_channel_no).Phase = Vpp1;
seq.Channels(mw_channel_no).AmpIQ = dc_level1;
seq.Channels(mw_channel_no).FreqIQ = phase1;
seq.Channels(mw_channel_no).FreqmodQ =bw_range1;
seq.Channels(mw_channel_no).Amplitude =bw_center1;

seq.Channels(mw_channel_no).Ampmod =Match_on_arb1;
seq.Channels(mw_channel_no).FreqmodI =ramp1_on;
seq.Channels(mw_channel_no).SymmTime1 =symm_time1;
seq.Channels(mw_channel_no).SymmTime2 =symm_time2;
result_seq = seq;
end