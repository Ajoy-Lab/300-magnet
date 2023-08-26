function result_seq=set_DAQ(seq,Vmax,Vmin,sweep_time,symm)

mw_channel_no =21;
seq.Channels(mw_channel_no).Frequency = Vmax;
seq.Channels(mw_channel_no).Phase = Vmin;
seq.Channels(mw_channel_no).AmpIQ = sweep_time;
seq.Channels(mw_channel_no).FreqIQ = symm;
result_seq = seq;
end