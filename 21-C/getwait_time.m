function wait_time=getwait_time(Number)

load 'D:\QEG2\21-C\SavedSequences\SavedSequences-PB\hyp_zeros.mat';
wait_time=round2(xzero(Number),0.01);

end