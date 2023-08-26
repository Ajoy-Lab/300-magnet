function result_seq = rabi_pulse_shaped(seq,sample_rate,length_rabi_pulse,number,ch_on)

seq = ttl_pulse(seq, 2, length_rabi_pulse);

seq.Channels(2).Ampmod = [seq.Channels(2).Ampmod seq.ShapedPulses{number}.Amplitude];
seq.Channels(2).FreqmodI = [seq.Channels(2).FreqmodI zeros(1,int64(sample_rate*length_rabi_pulse))];
seq.Channels(2).FreqmodQ = [seq.Channels(2).FreqmodQ zeros(1,int64(sample_rate*length_rabi_pulse))];
seq.Channels(2).Phasemod = [seq.Channels(2).Phasemod zeros(1,int64(sample_rate*length_rabi_pulse))];

% have to build own check function
if length(seq.Channels(2).Ampmod) ~= length(seq.Channels(2).FreqmodI)
   seq.seq_error = 1; 
end

if ch_on(4)
seq.Channels(4).Ampmod = [seq.Channels(4).Ampmod zeros(1,int64(sample_rate*(length_rabi_pulse)))];
seq.Channels(4).FreqmodI = [seq.Channels(4).FreqmodI zeros(1,int64(sample_rate*(length_rabi_pulse)))];
seq.Channels(4).Phasemod = [seq.Channels(4).Phasemod zeros(1,int64(sample_rate*(length_rabi_pulse)))];
end

if ch_on(5)
seq.Channels(5).Ampmod = [seq.Channels(5).Ampmod zeros(1,int64(sample_rate*(length_rabi_pulse)))];
seq.Channels(5).FreqmodI = [seq.Channels(5).FreqmodI zeros(1,int64(sample_rate*(length_rabi_pulse)))];
seq.Channels(5).Phasemod = [seq.Channels(5).Phasemod zeros(1,int64(sample_rate*(length_rabi_pulse)))];
end

result_seq = seq;
%if need to do IY or phase mod, just do the same with Phasemod
