function result_seq = echo_with_rf(seq,sample_rate,tau,length_pi_over_2,rf_freq,mod_rf,mod_mw,ch_on)

% RF is always on during spin echo
% RF starts after first pi/2 and ends before last pi/2
switch_wait =10e-9;
Aux=0;%1*1/rf_freq;%This is offset to rf length 

T = 2*tau+4*length_pi_over_2+3*switch_wait;
RF_length=2*tau+2*switch_wait+2*length_pi_over_2-Aux;

%delay+ rise of switch
seq = ttl_pulse(seq,2,switch_wait+length_pi_over_2);
seq = ttl_pulse(seq,5,RF_length,0,0);
seq = wait(seq, tau);
seq = ttl_pulse(seq,2, switch_wait+2*length_pi_over_2);
seq = wait(seq, tau);
seq = ttl_pulse(seq, 2, switch_wait+length_pi_over_2);


seq.Channels(2).Ampmod = [seq.Channels(2).Ampmod zeros(1,int64(sample_rate*(switch_wait))) mod_mw*ones(1,int64(sample_rate*(length_pi_over_2))) zeros(1,int64(sample_rate*(tau+switch_wait))) mod_mw*ones(1,int64(sample_rate*(2*length_pi_over_2))) zeros(1,int64(sample_rate*(tau+switch_wait))) mod_mw*ones(1,int64(sample_rate*(length_pi_over_2)))];
seq.Channels(2).FreqmodI = [seq.Channels(2).FreqmodI zeros(1,int64(sample_rate*T))];
seq.Channels(2).FreqmodQ = [seq.Channels(2).FreqmodQ zeros(1,int64(sample_rate*(T)))];
seq.Channels(2).Phasemod = [seq.Channels(2).Phasemod zeros(1,int64(sample_rate*(T)))];

if ch_on(4)
seq.Channels(4).Ampmod = [seq.Channels(4).Ampmod zeros(1,int64(sample_rate*T))];
seq.Channels(4).FreqmodI = [seq.Channels(4).FreqmodI zeros(1,int64(sample_rate*T))];
seq.Channels(4).Phasemod = [seq.Channels(4).Phasemod zeros(1,int64(sample_rate*T))];
end

if ch_on(5)
t = (1/sample_rate/2):(1/sample_rate):RF_length-(1/sample_rate/2);
%n=int64(length(t)/2);
seq.Channels(5).Ampmod = [seq.Channels(5).Ampmod zeros(1,int64(sample_rate*T))];
%seq.Channels(5).FreqmodI = [seq.Channels(5).Phasemod zeros(1,int64(sample_rate*T))];
seq.Channels(5).FreqmodI = [seq.Channels(5).FreqmodI zeros(1,int64(sample_rate*(switch_wait+length_pi_over_2))) mod_rf*sin(2*pi*t*rf_freq) zeros(1,int64(sample_rate*(length_pi_over_2+Aux)))]; 
    %zeros(1,int64(sample_rate*(wait_time_after_rf)/2)) zeros(1,int64(2*sample_rate*length_pi_over_2+sample_rate*wait_time_before_rf)) mod*sin(2*pi*t(n+1:end)*rf_freq) zeros(1,int64(sample_rate*(wait_time_after_rf)/2)) zeros(1,int64(sample_rate*s_pulse))];
seq.Channels(5).Phasemod = [seq.Channels(5).Phasemod zeros(1,int64(sample_rate*T))];
end

result_seq = seq;

% function result_seq = echo_with_rf(seq,sample_rate,tau,length_pi_over_2,mod_rf,mod_mw,ch_on)
% 
% % RF is always on during spin echo
% % RF starts "wait_for_mw" before mw
% switch_wait =10e-9;
% 
% T = 2*tau+4*length_pi_over_2+3*switch_wait;
% %delay+ rise of switch
% seq = ttl_pulse(seq,5,T-switch_wait,switch_wait,0);
% seq = ttl_pulse(seq,2,switch_wait+length_pi_over_2);
% seq = wait(seq, tau);
% seq = ttl_pulse(seq,2, switch_wait+2*length_pi_over_2);
% seq = wait(seq, tau);
% seq = ttl_pulse(seq, 2, switch_wait+length_pi_over_2);
% 
% 
% seq.Channels(2).Ampmod = [seq.Channels(2).Ampmod zeros(1,int64(sample_rate*(switch_wait))) mod_mw*ones(1,int64(sample_rate*(length_pi_over_2))) zeros(1,int64(sample_rate*(tau+switch_wait))) mod_mw*ones(1,int64(sample_rate*(2*length_pi_over_2))) zeros(1,int64(sample_rate*(tau+switch_wait))) mod_mw*ones(1,int64(sample_rate*(length_pi_over_2)))];
% seq.Channels(2).FreqmodI = [seq.Channels(2).FreqmodI zeros(1,int64(sample_rate*T))];
% seq.Channels(2).FreqmodQ = [seq.Channels(2).FreqmodQ zeros(1,int64(sample_rate*(T)))];
% seq.Channels(2).Phasemod = [seq.Channels(2).Phasemod zeros(1,int64(sample_rate*(T)))];
% 
% if ch_on(4)
% seq.Channels(4).Ampmod = [seq.Channels(4).Ampmod zeros(1,int64(sample_rate*T))];
% seq.Channels(4).FreqmodI = [seq.Channels(4).FreqmodI zeros(1,int64(sample_rate*T))];
% seq.Channels(4).Phasemod = [seq.Channels(4).Phasemod zeros(1,int64(sample_rate*T))];
% end
% 
% if ch_on(5)
% %t = (1/sample_rate/2):(1/sample_rate):length_rf_pulse-(1/sample_rate/2);
% %n=int64(length(t)/2);
% seq.Channels(5).Ampmod = [seq.Channels(5).Ampmod zeros(1,int64(sample_rate*(switch_wait))) mod_rf*ones(1,int64(sample_rate*(T-switch_wait)))];
% seq.Channels(5).FreqmodI = [seq.Channels(5).Phasemod zeros(1,int64(sample_rate*T))];
% %seq.Channels(5).FreqmodI = [seq.Channels(5).FreqmodI zeros(1,int64(sample_rate*(length_pi_over_2+wait_time_before_rf))) mod*sin(2*pi*t(1:n)*rf_freq+pi/2)...
%     %zeros(1,int64(sample_rate*(wait_time_after_rf)/2)) zeros(1,int64(2*sample_rate*length_pi_over_2+sample_rate*wait_time_before_rf)) mod*sin(2*pi*t(n+1:end)*rf_freq) zeros(1,int64(sample_rate*(wait_time_after_rf)/2)) zeros(1,int64(sample_rate*s_pulse))];
% seq.Channels(5).Phasemod = [seq.Channels(5).Phasemod zeros(1,int64(sample_rate*T))];
% end
% 
% result_seq = seq;