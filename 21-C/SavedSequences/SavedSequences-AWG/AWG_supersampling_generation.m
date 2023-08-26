clear


load peak_samples_8.mat; %%%%%%%%%%%%%% peak samples for L=4:1:26
n_count=0;

for n =8:1:8
    
     n_count=n_count+1;
  q=peak_q{n_count};
 
  p=peak_p{n_count};
  q1=peak_q1{n_count};p1=peak_p1{n_count};q2=peak_q2{n_count};p2=peak_p2{n_count};m1=peak_m1{n_count};
  
for l=1:length(p)
    clear delay;

pause(0.01);   
    [fid, msg] = fopen(['D:/QEG/21-C/SavedSequences/SavedSequences-AWG/AWG_supersampling_XY8_' num2str(n) '_' num2str(p(l)) '_' num2str(q(l))  '.xml'], 'w');
    if fid == 1
        error(msg);
    end
    fprintf(fid, '%s \n');
    str = verbatim;
    %{
    
    <sequence>

    <variables>
    
    % these are the variables that can be scanned or switched from the gui
	
    length_rabi_pulse = AWGparam(50e-9, 2e-9, 0.5)
    power_pi2_pulse = AWGparam(-10.2,-80, 9)

 	mw_freq = AWGparam(147e6, 1e6, 500e6)
	mw_ampl = AWGparam(-10.2,-80, 9)
    phase = AWGparam(90,0, 359)
    tau = AWGparam(12e-9,0,500e6)
    start_time = float(926e-9,0,2e-6)
    %}
    fprintf(fid,'%s \n',str);
    
    fprintf(fid, ['n= ProtectedPar(' num2str(n) ',1, 40) \n']);
    fprintf(fid, ['p= ProtectedPar(' num2str(p(l)) ',1, 40) \n']);
    fprintf(fid, ['q= ProtectedPar(' num2str(q(l)) ',1, 40) \n']);
    fprintf(fid, ['p1= ProtectedPar(' num2str(p1(l)) ',0, 40) \n']);
    fprintf(fid, ['q1= ProtectedPar(' num2str(q1(l)) ',0, 40) \n']);
    fprintf(fid, ['m1= ProtectedPar(' num2str(m1(l)) ',0, 40) \n']);
    fprintf(fid, ['p2= ProtectedPar(' num2str(p2(l)) ',0, 40) \n']);
    fprintf(fid, ['q2= ProtectedPar(' num2str(q2(l)) ',0, 40) \n']);
 
     str = verbatim;
     %{
</variables>
 
<shaped_pulses>

</shaped_pulses>

<instructions>
    
  
PSeq = enable_channels(PSeq, 1:7, [1 1 1 1 1 0 1]);
PSeq = awg_trigger_pulse(PSeq,500e6,length_rabi_pulse);

PSeq = polarize(PSeq,500e6);
PSeq = wait(PSeq,0.5e-6);
PSeq = detection_and_acquire_ref3(PSeq,500e6,start_time);

PSeq = polarize(PSeq,500e6);

PSeq = ttl_pulse(PSeq,4, 1e-6);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Rabi pulse
    
    
PSeq = wait(PSeq,(8*n+3)*(length_rabi_pulse+2*tau) + 1e-6);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PSeq = detection_and_acquire_ref3(PSeq,500e6,start_time);
     
</instructions>
</sequence>
    %}
    
    fprintf(fid,'%s \n',str);
    
    fclose(fid);
    

end

end
