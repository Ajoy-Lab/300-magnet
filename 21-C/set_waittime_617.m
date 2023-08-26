function result_seq=set_waittime_617(seq,wait_pos,wait_time)

mw_channel_no = 9;
seq.Channels(mw_channel_no).Frequency = wait_pos;
seq.Channels(mw_channel_no).Phase = wait_time;
% seq.Channels(mw_channel_no).AmpIQ = sweep_time;
% seq.Channels(mw_channel_no).Amplitude = amp;
result_seq = seq;
end