function result_seq = echo_with_rf_detection2(seq,sample_rate,tau,delay_wrt_1mus,length_pi_over_2,mod_rf,mod_mw,ch_on)

% RF is always on during spin echo
% RF starts "wait_for_mw" before mw
switch_wait =10e-9;
%wait_for_mw=2e-6+delay_wrt_1mus;
TT = 2*tau+4*length_pi_over_2+3*switch_wait;
t_AOM=TT-(1e-6+delay_wrt_1mus);%Timing of opening AOM so that AOM is on at the same time when mw and rf end.
%delay+ rise of switch
if t_AOM>=0; 
seq = ttl_pulse(seq, 1, 1e-6+delay_wrt_1mus,t_AOM,0);
seq = ttl_pulse(seq,5,TT-switch_wait,switch_wait,0);
seq = ttl_pulse(seq,2,switch_wait+length_pi_over_2);
seq = wait(seq, tau);
seq = ttl_pulse(seq,2, switch_wait+2*length_pi_over_2);
seq = wait(seq, tau);
seq = ttl_pulse(seq, 2, switch_wait+length_pi_over_2);
seq = ttl_pulse(seq, 3, 200e-9);
seq = wait(seq,800e-9);

T =TT+1e-6;%total sequence length

seq.Channels(2).Ampmod = [seq.Channels(2).Ampmod zeros(1,int64(sample_rate*(switch_wait))) mod_mw*ones(1,int64(sample_rate*(length_pi_over_2))) zeros(1,int64(sample_rate*(tau+switch_wait))) mod_mw*ones(1,int64(sample_rate*(2*length_pi_over_2))) zeros(1,int64(sample_rate*(tau+switch_wait))) mod_mw*ones(1,int64(sample_rate*(length_pi_over_2))) zeros(1,int64(sample_rate*(1e-6)))];
seq.Channels(2).FreqmodI = [seq.Channels(2).FreqmodI zeros(1,int64(sample_rate*(T)))];
seq.Channels(2).FreqmodQ = [seq.Channels(2).FreqmodQ zeros(1,int64(sample_rate*(T)))];
seq.Channels(2).Phasemod = [seq.Channels(2).Phasemod zeros(1,int64(sample_rate*(T)))];

if ch_on(4)
seq.Channels(4).Ampmod = [seq.Channels(4).Ampmod zeros(1,int64(sample_rate*T))];
seq.Channels(4).FreqmodI = [seq.Channels(4).FreqmodI zeros(1,int64(sample_rate*T))];
seq.Channels(4).Phasemod = [seq.Channels(4).Phasemod zeros(1,int64(sample_rate*T))];
end

if ch_on(5)
%t = (1/sample_rate/2):(1/sample_rate):length_rf_pulse-(1/sample_rate/2);
%n=int64(length(t)/2);
seq.Channels(5).Ampmod = [seq.Channels(5).Ampmod zeros(1,int64(sample_rate*switch_wait)) mod_rf*ones(1,int64(sample_rate*(TT-switch_wait))) zeros(1,int64(sample_rate*(1e-6)))];
seq.Channels(5).FreqmodI = [seq.Channels(5).Phasemod zeros(1,int64(sample_rate*T))];
%seq.Channels(5).FreqmodI = [seq.Channels(5).FreqmodI zeros(1,int64(sample_rate*(length_pi_over_2+wait_time_before_rf))) mod*sin(2*pi*t(1:n)*rf_freq+pi/2)...
    %zeros(1,int64(sample_rate*(wait_time_after_rf)/2)) zeros(1,int64(2*sample_rate*length_pi_over_2+sample_rate*wait_time_before_rf)) mod*sin(2*pi*t(n+1:end)*rf_freq) zeros(1,int64(sample_rate*(wait_time_after_rf)/2)) zeros(1,int64(sample_rate*s_pulse))];
seq.Channels(5).Phasemod = [seq.Channels(5).Phasemod zeros(1,int64(sample_rate*T))];
end

result_seq = seq;




else
seq = ttl_pulse(seq, 1, 1e-6+delay_wrt_1mus,0,0);
seq = wait(seq,-t_AOM);
seq = ttl_pulse(seq,5,TT-switch_wait,switch_wait,0);
seq = ttl_pulse(seq,2,switch_wait+length_pi_over_2);
seq = wait(seq, tau);
seq = ttl_pulse(seq,2, switch_wait+2*length_pi_over_2);
seq = wait(seq, tau);
seq = ttl_pulse(seq, 2, switch_wait+length_pi_over_2);
seq = ttl_pulse(seq, 3, 200e-9);
seq = wait(seq,800e-9);
T =delay_wrt_1mus+2e-6;%total sequence length
% if T-delay_wrt_1mus<0;
%  seq = wait(seq,-T+delay_wrt_1mus);
% aux=-T+delay_wrt_1mus;
% T=1e-6+delay_wrt_1mus;
% end

seq.Channels(2).Ampmod = [seq.Channels(2).Ampmod zeros(1,int64(sample_rate*(switch_wait-t_AOM))) mod_mw*ones(1,int64(sample_rate*(length_pi_over_2))) zeros(1,int64(sample_rate*(tau+switch_wait))) mod_mw*ones(1,int64(sample_rate*(2*length_pi_over_2))) zeros(1,int64(sample_rate*(tau+switch_wait))) mod_mw*ones(1,int64(sample_rate*(length_pi_over_2))) zeros(1,int64(sample_rate*(1e-6)))];
seq.Channels(2).FreqmodI = [seq.Channels(2).FreqmodI zeros(1,int64(sample_rate*T))];
seq.Channels(2).FreqmodQ = [seq.Channels(2).FreqmodQ zeros(1,int64(sample_rate*(T)))];
seq.Channels(2).Phasemod = [seq.Channels(2).Phasemod zeros(1,int64(sample_rate*(T)))];

if ch_on(4)
seq.Channels(4).Ampmod = [seq.Channels(4).Ampmod zeros(1,int64(sample_rate*T))];
seq.Channels(4).FreqmodI = [seq.Channels(4).FreqmodI zeros(1,int64(sample_rate*T))];
seq.Channels(4).Phasemod = [seq.Channels(4).Phasemod zeros(1,int64(sample_rate*T))];
end

if ch_on(5)
%t = (1/sample_rate/2):(1/sample_rate):length_rf_pulse-(1/sample_rate/2);
%n=int64(length(t)/2);
%seq.Channels(5).Ampmod = [seq.Channels(5).Ampmod zeros(1,int64(sample_rate*T))];
seq.Channels(5).Ampmod = [seq.Channels(5).Ampmod zeros(1,int64(sample_rate*(switch_wait-t_AOM))) mod_rf*ones(1,int64(sample_rate*(TT-switch_wait))) zeros(1,int64(sample_rate*(1e-6)))];
seq.Channels(5).FreqmodI = [seq.Channels(5).Phasemod zeros(1,int64(sample_rate*T))];
%seq.Channels(5).FreqmodI = [seq.Channels(5).FreqmodI zeros(1,int64(sample_rate*(length_pi_over_2+wait_time_before_rf))) mod*sin(2*pi*t(1:n)*rf_freq+pi/2)...
    %zeros(1,int64(sample_rate*(wait_time_after_rf)/2)) zeros(1,int64(2*sample_rate*length_pi_over_2+sample_rate*wait_time_before_rf)) mod*sin(2*pi*t(n+1:end)*rf_freq) zeros(1,int64(sample_rate*(wait_time_after_rf)/2)) zeros(1,int64(sample_rate*s_pulse))];
seq.Channels(5).Phasemod = [seq.Channels(5).Phasemod zeros(1,int64(sample_rate*T))];
end

result_seq = seq;

end
