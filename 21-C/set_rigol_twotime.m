function result_seq=set_rigol_twotime(seq,rigol_time1,rigol_wait2,rigol_time2,Tmax,pw3,rigol_wait1)

mw_channel_no = 44;

seq.Channels(mw_channel_no).Frequency = pw3;
seq.Channels(mw_channel_no).SymmTime1 = rigol_wait1;
seq.Channels(mw_channel_no).Ampmod = rigol_time1;
seq.Channels(mw_channel_no).AmpIQ = rigol_wait2;
seq.Channels(mw_channel_no).Phase = rigol_time2;
seq.Channels(mw_channel_no).Phasemod = Tmax;

result_seq = seq;
end