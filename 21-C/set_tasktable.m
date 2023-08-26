function result_seq=set_tasktable(seq,poltime1,poltime2,poltime3,poltime4,poltime5,poltime6,starting_pol_sign)

mw_channel_no = 46;
seq.Channels(mw_channel_no).FreqmodI = poltime1;
seq.Channels(mw_channel_no).FreqmodQ = poltime2;
seq.Channels(mw_channel_no).SymmTime1 = poltime3;
seq.Channels(mw_channel_no).Phase = poltime4;
seq.Channels(mw_channel_no).Frequency = poltime5;
seq.Channels(mw_channel_no).FreqIQ = poltime6;
seq.Channels(mw_channel_no).Amplitude = starting_pol_sign;

result_seq = seq;
end