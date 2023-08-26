function result_seq = set_microwave(seq, new_freq, new_ampl,ampiq, freqiq)

mw_channel_no = 2;

% it's a ttl pulsed channel
seq.Channels(mw_channel_no).Frequency = new_freq;
seq.Channels(mw_channel_no).Amplitude = new_ampl;

if nargin > 3 
seq.Channels(mw_channel_no).AmpIQ = ampiq;
seq.Channels(mw_channel_no).FreqIQ = freqiq;

seq.Channels(mw_channel_no).Ampmod = [];
seq.Channels(mw_channel_no).FreqmodI = [];
seq.Channels(mw_channel_no).FreqmodQ = [];
seq.Channels(mw_channel_no).Phasemod = [];
end

result_seq = seq;




