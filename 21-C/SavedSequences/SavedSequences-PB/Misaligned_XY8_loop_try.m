

for k = 1:50
    [fid, msg] = fopen(['D:/QEG/21-C/SavedSequences/SavedSequences-PB/Misaligned_XY8' num2str(k) '.xml'], 'w');
    if fid == 1
        error(msg);
    end
    fprintf(fid, '%s \n');
    str = verbatim;
    %{
    <sequence>

    <variables>
    % these are the variables that can be scanned or switched from the gui
	
    length_trigger = float(10e-9, 2e-9, 0.5)
    
    length_pi_Y = float(10e-9, 2e-9, 0.5)
    length_pi_X = float(10e-9, 2e-9, 0.5)
    length_pi2_X = float(10e-9, 2e-9, 0.5)
    
    tau = float(12e-9,0,500e-6)
    
    
    delay_DC = float(800e-9,-500e-6,500e-6)
    delay_laser= float(0e-6,-500e-6,500e-6)

    
    SRS_freq2 = float(2.87e9, 1e6, 20e9)
    SRS_freq = float(2.87e9, 1e6, 20e9)
    
    SRS_ampl2 = float(-9.4,-50, 12)
    SRS_ampl = float(-9.9,-50, 12)
    
    phase = float(0,-360,360)
  
    
    BNC_ampl = float(2,2, 20)
    BNC_width = float(1e-6,0,10e-6)
    BNC_delay = float(0,-10e-6,10e-6)
    
   
    start_time = float(840e-9,0,2e-6)

</variables>
 
<shaped_pulses>

</shaped_pulses>

<instructions>
    
    PSeq = enable_channels(PSeq, 1:6, [1 1 1 1 1 1]);
    
    
    PSeq = set_microwave(PSeq, SRS_freq, SRS_ampl);
    
    PSeq = set_phase_lock_done(PSeq, SRS_freq2, SRS_ampl2,phase);
    %PSeq = set_rf(PSeq, SRS_freq2, SRS_ampl2);
     %}
     fprintf(fid,'%s \n',str);
    
    
    fprintf(fid,'%s \n',['PSeq = set_BNC2(PSeq, 3*(BNC_width + ' num2str(1+2.2*k) 'e-6),BNC_ampl,BNC_delay);']);
    
     str = verbatim;
    %{
    %%%%%%%%%%%%%%%
    PSeq = polarize(PSeq,500e6);
    PSeq = wait(PSeq,1.5e-6);
    PSeq = detection_and_acquire_ref3(PSeq,500e6,start_time);
    PSeq = wait(PSeq,1e-6);
      
     
   
    PSeq = polarize(PSeq,500e6);
    PSeq = wait(PSeq,1.5e-6);
    PSeq = ttl_pulse(PSeq,2, length_pi_X);
    PSeq = wait(PSeq,100e-9);
    PSeq = detection_and_acquire_ref3(PSeq,500e6,start_time);
    PSeq = wait(PSeq,3e-6);
     
    %%%%%%%%%%%%%%%%%%%%
    PSeq = polarize(PSeq,500e6);
    PSeq = wait(PSeq,1.5e-6);
     
     PSeq = ttl_pulse(PSeq, 5, length_trigger);
     PSeq = wait(PSeq,delay_DC);
     
     % XY8
   
    PSeq = ttl_pulse(PSeq,2, length_pi2_X);
    PSeq = ttl_pulse(PSeq,2, length_pi_X);
    PSeq = wait(PSeq,12e-9);
    %}
    
    fprintf(fid, '%s \n', str);
    
    for j=1:k
        str=verbatim;
        %{
        PSeq = wait(PSeq, tau);
    PSeq = ttl_pulse(PSeq, 2, length_pi_X);
    PSeq = wait(PSeq,2*tau);
    PSeq = ttl_pulse(PSeq, 4, length_pi_Y);
    PSeq = wait(PSeq,2*tau);
    PSeq = ttl_pulse(PSeq, 2, length_pi_X);
    PSeq = wait(PSeq,2*tau);
    PSeq = ttl_pulse(PSeq, 4, length_pi_Y);
    PSeq = wait(PSeq,2*tau);
    PSeq = ttl_pulse(PSeq, 4, length_pi_Y);
    PSeq = wait(PSeq,2*tau);
    PSeq = ttl_pulse(PSeq, 2, length_pi_X);
    PSeq = wait(PSeq,2*tau);
    PSeq = ttl_pulse(PSeq, 4, length_pi_Y);
    PSeq = wait(PSeq,2*tau);
    PSeq = ttl_pulse(PSeq, 2, length_pi_X);
    PSeq = wait(PSeq,tau);
    
        %}
        fprintf(fid,'%s \n',str);
    end
    
   
    
    fprintf(fid,'%s \n',['PSeq = ttl_pulse(PSeq, 2, length_pi2_X);']);
   
    fprintf(fid,'%s \n',['PSeq = wait(PSeq,3*' num2str(5+1.5*k) 'e-6);']);
    
    
     str=verbatim;
    %{
    PSeq = ttl_pulse(PSeq, 1, 1e-6,delay_laser,0); 
    PSeq = wait(PSeq,start_time);
    PSeq = ttl_pulse(PSeq, 3, 300e-9);
    PSeq = wait(PSeq,1e-6);
    %}
    
     fprintf(fid,'%s \n',str);
    
     
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
     str = verbatim;
    %{
      %%%%%%%%%%%%%%%%%%%%
    PSeq = polarize(PSeq,500e6);
    PSeq = wait(PSeq,1.5e-6);
    
     PSeq = ttl_pulse(PSeq, 5, length_trigger);
    
     PSeq = wait(PSeq,delay_DC);
   
     % XY8
 
        PSeq = ttl_pulse(PSeq,2, length_pi_X);
        PSeq = wait(PSeq,12e-9);
        PSeq = ttl_pulse(PSeq,2, length_pi2_X);
     %}
    
    fprintf(fid, '%s \n', str);
    
    for j=1:k
        str=verbatim;
        %{
        PSeq = wait(PSeq, tau);
    PSeq = ttl_pulse(PSeq, 2, length_pi_X);
    PSeq = wait(PSeq,2*tau);
    PSeq = ttl_pulse(PSeq, 4, length_pi_Y);
    PSeq = wait(PSeq,2*tau);
    PSeq = ttl_pulse(PSeq, 2, length_pi_X);
    PSeq = wait(PSeq,2*tau);
    PSeq = ttl_pulse(PSeq, 4, length_pi_Y);
    PSeq = wait(PSeq,2*tau);
    PSeq = ttl_pulse(PSeq, 4, length_pi_Y);
    PSeq = wait(PSeq,2*tau);
    PSeq = ttl_pulse(PSeq, 2, length_pi_X);
    PSeq = wait(PSeq,2*tau);
    PSeq = ttl_pulse(PSeq, 4, length_pi_Y);
    PSeq = wait(PSeq,2*tau);
    PSeq = ttl_pulse(PSeq, 2, length_pi_X);
    PSeq = wait(PSeq,tau);
    
        %}
        fprintf(fid,'%s \n',str);
    end
    
   
    
    fprintf(fid,'%s \n',['PSeq = ttl_pulse(PSeq, 2, length_pi2_X);']);
   
    fprintf(fid,'%s \n',['PSeq = wait(PSeq,3*' num2str(5+1.5*k) 'e-6);']);
    
    
     str=verbatim;
    %{
     PSeq = ttl_pulse(PSeq,2, length_pi_X);
     PSeq = wait(PSeq,12e-9);
    PSeq = ttl_pulse(PSeq, 1, 1e-6,delay_laser,0); 
    PSeq = wait(PSeq,start_time);
    PSeq = ttl_pulse(PSeq, 3, 300e-9);
    PSeq = wait(PSeq,1e-6);
 
</instructions>

</sequence>
    %}
    
     fprintf(fid,'%s \n',str);
     
     
    fclose(fid);
    
end