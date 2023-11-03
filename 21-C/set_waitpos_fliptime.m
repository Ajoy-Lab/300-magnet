function result_seq=set_waitpos_fliptime(seq,wait_pos,wait_time,fliptime)

mw_channel_no = 24;
seq.Channels(mw_channel_no).Frequency = wait_pos;
seq.Channels(mw_channel_no).FreqmodQ = wait_time;
%seq.Channels(mw_channel_no).Phase = wait_time; %ND Comment
seq.Channels(mw_channel_no).AmpIQ = fliptime;
% seq.Channels(mw_channel_no).AmpIQ = sweep_time;
% seq.Channels(mw_channel_no).Amplitude = amp;
result_seq = seq;
end