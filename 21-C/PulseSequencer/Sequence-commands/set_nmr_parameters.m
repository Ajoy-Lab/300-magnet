function result_seq = set_nmr_parameters(seq, pw, tacq, gain, tof, Tmax, sequence_type, pi_pulse)

mw_channel_no = 38;

% it's a ttl pulsed channel
seq.Channels(mw_channel_no).Frequency = pw;
seq.Channels(mw_channel_no).Amplitude = tof;
seq.Channels(mw_channel_no).Phase =  tacq;
seq.Channels(mw_channel_no).PhaseQ = sequence_type;
seq.Channels(mw_channel_no).FreqIQ = gain;
seq.Channels(mw_channel_no).Parameter1 = Tmax;
seq.Channels(mw_channel_no).Parameter2 = pi_pulse;
result_seq = seq;




