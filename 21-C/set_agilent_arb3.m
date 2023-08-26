function result_seq=set_agilent_arb3(seq,Vpp,phase,sweep_time,symm,dc_level,agilent_on,bw_range,bw_center, Match_on)

mw_channel_no = 19;
seq.Channels(mw_channel_no).Frequency = Vpp;
seq.Channels(mw_channel_no).Phase = phase;
seq.Channels(mw_channel_no).AmpIQ = sweep_time;
seq.Channels(mw_channel_no).FreqIQ = symm;
seq.Channels(mw_channel_no).FreqmodQ =dc_level;
seq.Channels(mw_channel_no).Amplitude =agilent_on;

seq.Channels(mw_channel_no).Ampmod =bw_range;
seq.Channels(mw_channel_no).Phasemod =bw_center;
seq.Channels(mw_channel_no).FreqmodI= Match_on;


result_seq = seq;
end