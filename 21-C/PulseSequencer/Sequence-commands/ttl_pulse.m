function result_seq = ttl_pulse(seq, channel_no, duration, start_time, is_last)

if nargin == 3
	% only channel, duration and state is given
	start_time = 0.0;
	is_last = true;
end;
if nargin == 4
	% all but is_last is given
	%is_last = true;
end;

absolute_start_time = seq.time_pointer + start_time;

% program rise time for channel
seq.Channels(channel_no).addRise(absolute_start_time, duration);

if is_last
	seq.time_pointer = seq.time_pointer + start_time + duration;
else
    % just move the pointer by start time
   seq.time_pointer = seq.time_pointer + start_time;
end;

result_seq = seq;




