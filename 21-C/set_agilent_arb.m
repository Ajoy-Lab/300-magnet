function result_seq=set_agilent_arb(seq,Vpp,offset,sweep_time,symm,dc_level)

mw_channel_no = 19;
seq.Channels(mw_channel_no).Frequency = Vpp;
seq.Channels(mw_channel_no).Phase = offset;
seq.Channels(mw_channel_no).AmpIQ = sweep_time;
seq.Channels(mw_channel_no).FreqIQ = symm;
seq.Channels(mw_channel_no).FreqmodQ =dc_level;
result_seq = seq;
end