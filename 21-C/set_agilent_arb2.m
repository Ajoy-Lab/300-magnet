function result_seq=set_agilent_arb2(seq,Vpp,phase,sweep_time,symm,dc_level,agilent_on)

mw_channel_no = 19;
seq.Channels(mw_channel_no).Frequency = Vpp;
seq.Channels(mw_channel_no).Phase = phase;
seq.Channels(mw_channel_no).AmpIQ = sweep_time;
seq.Channels(mw_channel_no).FreqIQ = symm;
seq.Channels(mw_channel_no).FreqmodQ =dc_level;
seq.Channels(mw_channel_no).Amplitude =agilent_on;
result_seq = seq;
end