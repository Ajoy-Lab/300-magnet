function result_seq = rabi_pulse_mod_for_OU(seq,sample_rate,length_rabi_pulse,mod_depth,noisevc,ch_on)

seq = ttl_pulse(seq, 2, length_rabi_pulse);

vector_mod_plus_noise =  (mod_depth)*ones(1,int64(sample_rate*(length_rabi_pulse))) + noisevc;

% constraining values to [-1, 1]
vector_mod_plus_noise =  min(max(vector_mod_plus_noise,-1),1);

seq.Channels(2).Ampmod = [seq.Channels(2).Ampmod vector_mod_plus_noise];
seq.Channels(2).FreqmodI = [seq.Channels(2).FreqmodI zeros(1,int64(sample_rate*(length_rabi_pulse)))];
seq.Channels(2).FreqmodQ = [seq.Channels(2).FreqmodQ zeros(1,int64(sample_rate*(length_rabi_pulse)))];
seq.Channels(2).Phasemod = [seq.Channels(2).Phasemod zeros(1,int64(sample_rate*(length_rabi_pulse)))];

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