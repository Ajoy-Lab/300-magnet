<sequence>

<variables>
	
sample_rate = float(50e6,1e7,5e9)
mw_freq = float(4.3394e9, 1e6, 15e9)
mw_ampl = float(14, -20, 15)
ampIQ = float(0,-30,17) %in dBm
freqIQ = float(12.5e6, 0,500*1e6)
length_CNOT_pulse = float(420e-9,0,3000e-9) 
length_Hard_pulse = float(260e-9,0,3000e-9) 
mod_CNOT_pulse = float(0.2,0,1)
mod_Hard_pulse = float(0.3,0,1)

pi_over_2_rf_pulse = float(3.6e-6,0,50e-6) 
tau = float(0,0,10e-3)
delay_wrt_1mus = float(80e-9,0,500e-9) %calibrated by PL curve 11-08-05 13-17-48
freqN = float(7273438, 0,500*1e6)
ampN = float(0,-30,1) %in dBmus

</variables>

<shaped_pulses>

%shaped_pulses{1} = load('blackman.mat');

</shaped_pulses>

<instructions>


ch_on = [1 1 1 0 1];

    
PSeq = set_sample_rate(PSeq, sample_rate);

PSeq = enable_channels(PSeq, 1:5, ch_on); 

PSeq = set_microwave(PSeq, mw_freq, mw_ampl,ampIQ,freqIQ);

PSeq = set_nitrogen_rf(PSeq, freqN, ampN);


% polarize and detection of mI= 0 state
PSeq = polarize(PSeq,sample_rate, ch_on);
PSeq = detection(PSeq,sample_rate,delay_wrt_1mus, ch_on);

%reference from (me=1,mI=0) state 
PSeq = rabi_pulse_mod(PSeq,sample_rate,length_Hard_pulse,mod_Hard_pulse,ch_on);
PSeq = rf_pulse(PSeq,sample_rate,2*pi_over_2_rf_pulse,ch_on);
PSeq = detection(PSeq,sample_rate,delay_wrt_1mus, ch_on);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Hard pulse

PSeq = rabi_pulse_mod(PSeq,sample_rate,length_Hard_pulse,mod_Hard_pulse,ch_on);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%R.F.pulse(Ramsey)
PSeq = rf_pulse(PSeq,sample_rate,pi_over_2_rf_pulse,ch_on);
PSeq = wait_for_awg(PSeq,sample_rate,tau,ch_on);
PSeq = rf_pulse(PSeq,sample_rate,2*pi_over_2_rf_pulse,ch_on);
PSeq = wait_for_awg(PSeq,sample_rate,tau,ch_on);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%CNOT gate

PSeq = rabi_pulse_mod(PSeq,sample_rate,length_CNOT_pulse,mod_CNOT_pulse,ch_on);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% detection
PSeq = detection(PSeq,sample_rate,delay_wrt_1mus, ch_on);



  

</instructions>

</sequence>
