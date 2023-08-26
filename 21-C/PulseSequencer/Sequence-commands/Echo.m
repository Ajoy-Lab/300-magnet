function result_seq = Echo(seq,sample_rate,mod,length_pi_over_2,tau,aux,aux2,phase0,phase1,phase2,phase3,ch_on)

seq = ttl_pulse(seq, 2, aux2);
seq = ttl_pulse(seq, 2, length_pi_over_2);
seq = wait(seq, tau);
seq = ttl_pulse(seq, 2, aux);
seq = wait(seq,tau);
seq = ttl_pulse(seq, 2, length_pi_over_2);
T=2*length_pi_over_2+2*tau+aux+aux2;

seq.Channels(2).Ampmod = [seq.Channels(2).Ampmod mod*ones(1,int64(sample_rate*(aux2))) mod*ones(1,int64(sample_rate*(length_pi_over_2))) zeros(1,int64(sample_rate*(tau)))...
    mod*ones(1,int64(sample_rate*(aux))) zeros(1,int64(sample_rate*(tau))) mod*ones(1,int64(sample_rate*(length_pi_over_2)))];
%seq.Channels(2).Ampmod = [seq.Channels(2).Ampmod ones(1,int64(sample_rate*(length_pi_over_2))) zeros(1,int64(sample_rate*(tau)))...
%    ones(1,int64(sample_rate*(aux))) zeros(1,int64(sample_rate*(tau))) mod*ones(1,int64(sample_rate*(length_pi_over_2)))];
seq.Channels(2).FreqmodI = [seq.Channels(2).FreqmodI zeros(1,int64(sample_rate*(T)))];
seq.Channels(2).FreqmodQ = [seq.Channels(2).FreqmodQ zeros(1,int64(sample_rate*(T)))];
seq.Channels(2).Phasemod = [seq.Channels(2).Phasemod 2*pi*phase0*ones(1,int64(sample_rate*(aux2))) 2*pi*phase1*ones(1,int64(sample_rate*(length_pi_over_2))) zeros(1,int64(sample_rate*(tau)))...
    2*pi*phase2*ones(1,int64(sample_rate*(aux))) zeros(1,int64(sample_rate*(tau))) 2*pi*phase3*ones(1,int64(sample_rate*(length_pi_over_2)))];

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

