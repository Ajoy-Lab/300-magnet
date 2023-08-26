function result_seq = enable_channels(seq, channels, state)


for k = channels
	seq.Channels(k).Enable = state(k);
end;


result_seq = seq;




