function result_seq=set_rigol_sweep(seq,rigol_start,rigol_stop,Tchirp)

mw_channel_no = 43;
seq.Channels(mw_channel_no).FreqmodI = rigol_start;
seq.Channels(mw_channel_no).FreqmodQ = rigol_stop;
seq.Channels(mw_channel_no).Amplitude = Tchirp;

result_seq = seq;
end