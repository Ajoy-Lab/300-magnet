function result_seq = polarize_and_acquire_ref2(seq,sample_rate,start_time)

%polarize and acquire ref - original
seq = ttl_pulse(seq, 1, 1.2e-6,0,false); %This is for polarizing nitrogen.
seq = wait(seq,start_time);
seq = ttl_pulse(seq, 3, 300e-9);
seq = wait(seq,300e-9);
seq = wait(seq,300e-9);
seq = wait(seq,300e-9);
seq = wait(seq,100e-9);


seq.Channels(2).Ampmod = [seq.Channels(2).Ampmod zeros(1,int64(sample_rate*2e-6))];
seq.Channels(2).FreqmodI = [seq.Channels(2).FreqmodI zeros(1,int64(sample_rate*2e-6))];
seq.Channels(2).FreqmodQ = [seq.Channels(2).FreqmodQ zeros(1,int64(sample_rate*2e-6))];
seq.Channels(2).Phasemod = [seq.Channels(2).Phasemod zeros(1,int64(sample_rate*2e-6))];


result_seq = seq;