function result_seq = modified_CP(seq,sample_rate,length_pi_over_2,tau,ch_on)

seq = ttl_pulse(seq, 2, 2*length_pi_over_2);
seq = ttl_pulse(seq, 2, length_pi_over_2);
seq = wait(seq, tau/2);
seq = ttl_pulse(seq, 2, 2*length_pi_over_2);
seq = wait(seq, tau);
seq = ttl_pulse(seq, 2, 2*length_pi_over_2);
seq = wait(seq, tau/2);
seq = ttl_pulse(seq, 2, length_pi_over_2);

T=8*length_pi_over_2+2*tau;

seq.Channels(2).Ampmod = [seq.Channels(2).Ampmod 0*ones(1,int64(sample_rate*(2*length_pi_over_2))) ones(1,int64(sample_rate*(length_pi_over_2)))  zeros(1,int64(sample_rate*(tau/2)))...
 ones(1,int64(sample_rate*(2*length_pi_over_2))) zeros(1,int64(sample_rate*(tau)))...
 ones(1,int64(sample_rate*(2*length_pi_over_2))) zeros(1,int64(sample_rate*(tau/2)))...
 ones(1,int64(sample_rate*(length_pi_over_2)))];

seq.Channels(2).FreqmodI = [seq.Channels(2).FreqmodI zeros(1,int64(sample_rate*(T)))];
seq.Channels(2).FreqmodQ = [seq.Channels(2).FreqmodQ zeros(1,int64(sample_rate*(T)))];
seq.Channels(2).Phasemod = [seq.Channels(2).Phasemod zeros(1,int64(sample_rate*(2*length_pi_over_2))) zeros(1,int64(sample_rate*(length_pi_over_2))) zeros(1,int64(sample_rate*(tau/2)))...
 0*ones(1,int64(sample_rate*(2*length_pi_over_2))) zeros(1,int64(sample_rate*(tau)))...
 0*ones(1,int64(sample_rate*(2*length_pi_over_2))) zeros(1,int64(sample_rate*(tau/2+length_pi_over_2)))];
%  seq.Channels(2).Phasemod = [seq.Channels(2).Phasemod zeros(1,int64(sample_rate*(tau/2+length_pi_over_2)))...
%   pi/2*zeros(1,int64(sample_rate*(2*length_pi_over_2))) zeros(1,int64(sample_rate*(tau)))...
%   pi/2*zeros(1,int64(sample_rate*(2*length_pi_over_2))) zeros(1,int64(sample_rate*(tau/2+length_pi_over_2)))];
if ch_on(4)
seq.Channels(4).Ampmod = [seq.Channels(4).Ampmod zeros(1,int64(sample_rate*(T)))];
seq.Channels(4).FreqmodI = [seq.Channels(4).FreqmodI zeros(1,int64(sample_rate*(T)))];
seq.Channels(4).Phasemod = [seq.Channels(4).Phasemod zeros(1,int64(sample_rate*(T)))];
end

if ch_on(5)
seq.Channels(5).Ampmod = [seq.Channels(5).Ampmod zeros(1,int64(sample_rate*(T)))];
seq.Channels(5).FreqmodI = [seq.Channels(5).FreqmodI zeros(1,int64(sample_rate*(T)))];
seq.Channels(5).Phasemod = [seq.Channels(5).Phasemod zeros(1,int64(sample_rate*(T)))];
end

result_seq = seq;