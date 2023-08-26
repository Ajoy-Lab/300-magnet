function result_seq = adiabatic_inversion_N(seq,sample_rate,sweep_range,sweep_time,freqIQ,offset_from_res,lengthpipulse,is_shaped,number,ch_on)

% offset_from_res: - means the level to be addressed is below the
% resonance, + is above the resonance

%put mw Pi pulse
if is_shaped %shaped pi-pulse
seq = ttl_pulse(seq,2,length(seq.ShapedPulses{number}.Amplitude)/sample_rate);

seq.Channels(2).Ampmod = [seq.Channels(2).Ampmod seq.ShapedPulses{number}.Amplitude];
seq.Channels(2).FreqmodI = [seq.Channels(2).FreqmodI zeros(1,length(seq.ShapedPulses{number}.Amplitude))];
seq.Channels(2).FreqmodQ = [seq.Channels(2).FreqmodQ zeros(1,length(seq.ShapedPulses{number}.Amplitude))];
seq.Channels(2).Phasemod = [seq.Channels(2).Phasemod zeros(1,length(seq.ShapedPulses{number}.Amplitude))];

if ch_on(5)
seq.Channels(5).Ampmod = [seq.Channels(5).Ampmod zeros(1,length(seq.ShapedPulses{number}.Amplitude))];
seq.Channels(5).FreqmodI = [seq.Channels(5).FreqmodI zeros(1,length(seq.ShapedPulses{number}.Amplitude))];
seq.Channels(5).Phasemod = [seq.Channels(5).Phasemod zeros(1,length(seq.ShapedPulses{number}.Amplitude))];
end

if ch_on(4)
seq.Channels(4).Ampmod = [seq.Channels(4).Ampmod zeros(1,length(seq.ShapedPulses{number}.Amplitude))];
seq.Channels(4).FreqmodI = [seq.Channels(4).FreqmodI zeros(1,length(seq.ShapedPulses{number}.Amplitude))];
seq.Channels(4).Phasemod = [seq.Channels(4).Phasemod zeros(1,length(seq.ShapedPulses{number}.Amplitude))];
end

else %Hard pi-pulse

seq = ttl_pulse(seq,2,lengthpipulse);
% mw channel has a different wavelength for this time of the Pi pulse
tpi = (1/sample_rate/2):(1/sample_rate):(lengthpipulse)-(1/sample_rate/2);
seq.Channels(2).Ampmod = [seq.Channels(2).Ampmod zeros(1,int64(sample_rate*(lengthpipulse)))];
seq.Channels(2).FreqmodI = [seq.Channels(2).FreqmodI sin(2*pi*(freqIQ + offset_from_res)*tpi)];
seq.Channels(2).FreqmodQ = [seq.Channels(2).FreqmodQ cos(2*pi*(freqIQ + offset_from_res)*tpi)];
seq.Channels(2).Phasemod = [seq.Channels(2).Phasemod zeros(1,int64(sample_rate*(lengthpipulse)))];

if ch_on(5)
seq.Channels(5).Ampmod = [seq.Channels(5).Ampmod zeros(1,int64(sample_rate*(lengthpipulse)))];
seq.Channels(5).FreqmodI = [seq.Channels(5).FreqmodI zeros(1,int64(sample_rate*(lengthpipulse)))];
seq.Channels(5).Phasemod = [seq.Channels(5).Phasemod zeros(1,int64(sample_rate*(lengthpipulse)))];
end

if ch_on(4)
seq.Channels(4).Ampmod = [seq.Channels(4).Ampmod zeros(1,int64(sample_rate*(lengthpipulse)))];
seq.Channels(4).FreqmodI = [seq.Channels(4).FreqmodI zeros(1,int64(sample_rate*(lengthpipulse)))];
seq.Channels(4).Phasemod = [seq.Channels(4).Phasemod zeros(1,int64(sample_rate*(lengthpipulse)))];
end

end

%sweep rf across N resonance
seq = ttl_pulse(seq, 5, sweep_time);
t = (1/sample_rate/2):(1/sample_rate):sweep_time-(1/sample_rate/2);
if ch_on(5)
seq.Channels(5).Ampmod = [seq.Channels(5).Ampmod zeros(1,int64(sample_rate*(sweep_time)))];
seq.Channels(5).FreqmodI = [seq.Channels(5).FreqmodI chirp(t,0,sweep_time,sweep_range,'linear',0)];
seq.Channels(5).Phasemod = [seq.Channels(5).Phasemod zeros(1,int64(sample_rate*(sweep_time)))];
end

seq.Channels(2).Ampmod = [seq.Channels(2).Ampmod zeros(1,int64(sample_rate*(sweep_time)))];
seq.Channels(2).FreqmodI = [seq.Channels(2).FreqmodI zeros(1,int64(sample_rate*(sweep_time)))];
seq.Channels(2).FreqmodQ = [seq.Channels(2).FreqmodQ zeros(1,int64(sample_rate*(sweep_time)))];
seq.Channels(2).Phasemod = [seq.Channels(2).Phasemod zeros(1,int64(sample_rate*(sweep_time)))];

if ch_on(4)
seq.Channels(4).Ampmod = [seq.Channels(4).Ampmod zeros(1,int64(sample_rate*(sweep_time)))];
seq.Channels(4).FreqmodI = [seq.Channels(4).FreqmodI zeros(1,int64(sample_rate*(sweep_time)))];
seq.Channels(4).Phasemod = [seq.Channels(4).Phasemod zeros(1,int64(sample_rate*(sweep_time)))];
end

result_seq = seq;
