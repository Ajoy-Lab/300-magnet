function result_seq=set_rigol_arb2_sweep(seq2,rigol_on,rigol_Vpp,rigol_dc_offset,rigol_phase,sweep_on, sweep_time,rigol_start_freq,rigol_stop_freq)

%PSeq = set_rigol_arb2_sweep(PSeq,rigol_on,rigol_Vpp,rigol_dc_offset,rigol_phase,sweep_on, sweep_time,rigol_start_freq,rigol_stop_freq);


mw_channel_no = 21;
seq2.Channels(mw_channel_no).Amplitude =rigol_on;
seq2.Channels(mw_channel_no).Frequency = rigol_Vpp;
seq2.Channels(mw_channel_no).FreqmodQ =rigol_dc_offset;
seq2.Channels(mw_channel_no).Phase = rigol_phase;

seq2.Channels(mw_channel_no).FreqIQ = sweep_on;

seq2.Channels(mw_channel_no).AmpIQ =sweep_time; 
seq2.Channels(mw_channel_no).FreqmodI =rigol_start_freq;
seq2.Channels(mw_channel_no).Ampmod =rigol_stop_freq; 

result_seq = seq2;
end