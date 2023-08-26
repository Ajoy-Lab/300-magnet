function result_seq = detection(seq,sample_rate,delay_wrt_1mus,ch_on)

% %Detection

 seq = ttl_pulse(seq, 1, 1e-6+delay_wrt_1mus); %for AWG, best acquisition window is 1.05mus after laser pulse
 
 %seq = wait(seq,100e-9);
 seq = ttl_pulse(seq, 3, 300e-9);
 seq = wait(seq,700e-9);

seq.Channels(2).Ampmod = [seq.Channels(2).Ampmod zeros(1,int64(sample_rate*(2e-6+delay_wrt_1mus)))];
seq.Channels(2).FreqmodI = [seq.Channels(2).FreqmodI zeros(1,int64(sample_rate*(2e-6+delay_wrt_1mus)))];
seq.Channels(2).FreqmodQ = [seq.Channels(2).FreqmodQ zeros(1,int64(sample_rate*(2e-6+delay_wrt_1mus)))];
seq.Channels(2).Phasemod = [seq.Channels(2).Phasemod zeros(1,int64(sample_rate*(2e-6+delay_wrt_1mus)))];

if ch_on(4)
 seq.Channels(4).Ampmod = [seq.Channels(4).Ampmod zeros(1,int64(sample_rate*(2e-6+delay_wrt_1mus)))];
 seq.Channels(4).FreqmodI = [seq.Channels(4).FreqmodI zeros(1,int64(sample_rate*(2e-6+delay_wrt_1mus)))];
 seq.Channels(4).Phasemod = [seq.Channels(4).Phasemod zeros(1,int64(sample_rate*(2e-6+delay_wrt_1mus)))];
end

if ch_on(5)
 seq.Channels(5).Ampmod = [seq.Channels(5).Ampmod zeros(1,int64(sample_rate*(2e-6+delay_wrt_1mus)))];
 seq.Channels(5).FreqmodI = [seq.Channels(5).FreqmodI zeros(1,int64(sample_rate*(2e-6+delay_wrt_1mus)))];
 seq.Channels(5).Phasemod = [seq.Channels(5).Phasemod zeros(1,int64(sample_rate*(2e-6+delay_wrt_1mus)))];
end
 
result_seq = seq;
