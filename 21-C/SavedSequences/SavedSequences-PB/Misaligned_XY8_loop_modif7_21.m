p=2;q=1;
k=6;

    [fid, msg] = fopen(['D:/QEG/21-C/SavedSequences/SavedSequences-PB/Misaligned_XY8_mod' num2str(k) '_' num2str(p)num2str(q).xml'], 'w');
    if fid == 1
        error(msg);
    end
    fprintf(fid, '%s \n');
    str = verbatim;
    %{
    
    %%
    <sequence>

    <variables>
    % these are the variables that can be scanned or switched from the gui
	
    length_trigger = float(10e-9, 2e-9, 0.5)
    
    length_pi_Y = float(10e-9, 2e-9, 0.5)
    length_pi_X = float(10e-9, 2e-9, 0.5)
    length_pi2_X = float(10e-9, 2e-9, 0.5)
    
    tau = float(12e-9,0,500e-6)
    delta = float(0,-500e-6,500e-6)
   
   
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
    
    
    fprintf(fid,'%s \n',['PSeq = set_BNC2(PSeq, BNC_width + ' num2str(1+2.8*k) 'e-6,BNC_ampl,BNC_delay);']);
    
    
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
   
    
    PSeq = ttl_pulse(PSeq,2, length_pi_X);
    PSeq = wait(PSeq,12e-9);
    PSeq = ttl_pulse(PSeq,2, length_pi2_X);
     
    %}
    
    fprintf(fid, '%s \n', str);
    
    
    if k==1
        str=verbatim;
        %{
         PSeq = wait(PSeq, round2(tau+delta,2e-9));
         PSeq = ttl_pulse(PSeq, 2, length_pi_X);
         PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
         PSeq = ttl_pulse(PSeq, 4, length_pi_Y);
         PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
         PSeq = ttl_pulse(PSeq, 2, length_pi_X);
         PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
         PSeq = ttl_pulse(PSeq, 4, length_pi_Y);
         PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
         PSeq = ttl_pulse(PSeq, 4, length_pi_Y);
         PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
         PSeq = ttl_pulse(PSeq, 2, length_pi_X);
         PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
         PSeq = ttl_pulse(PSeq, 4, length_pi_Y);
         PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
         PSeq = ttl_pulse(PSeq, 2, length_pi_X);
         PSeq = wait(PSeq,round2(tau+delta,2e-9));
        %}
        
         fprintf(fid, '%s \n', str);
    end
    
    if k==2
        str=verbatim;
        %{
         PSeq = wait(PSeq, round2(tau+delta,2e-9));
         PSeq = ttl_pulse(PSeq, 2, length_pi_X);
         PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
         PSeq = ttl_pulse(PSeq, 4, length_pi_Y);
         PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
         PSeq = ttl_pulse(PSeq, 2, length_pi_X);
         PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
         PSeq = ttl_pulse(PSeq, 4, length_pi_Y);
         PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
         PSeq = ttl_pulse(PSeq, 4, length_pi_Y);
         PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
         PSeq = ttl_pulse(PSeq, 2, length_pi_X);
         PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
         PSeq = ttl_pulse(PSeq, 4, length_pi_Y);
         PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
         PSeq = ttl_pulse(PSeq, 2, length_pi_X);
        %PSeq = wait(PSeq,tau+delta);
         PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
        %PSeq = wait(PSeq, tau+delta);
         PSeq = ttl_pulse(PSeq, 2, length_pi_X);
         PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
         PSeq = ttl_pulse(PSeq, 4, length_pi_Y);
         PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
         PSeq = ttl_pulse(PSeq, 2, length_pi_X);
         PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
         PSeq = ttl_pulse(PSeq, 4, length_pi_Y);
         PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
         PSeq = ttl_pulse(PSeq, 4, length_pi_Y);
         PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
         PSeq = ttl_pulse(PSeq, 2, length_pi_X);
         PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
         PSeq = ttl_pulse(PSeq, 4, length_pi_Y);
         PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
         PSeq = ttl_pulse(PSeq, 2, length_pi_X);
         PSeq = wait(PSeq,round2(tau+delta,2e-9));
        
        %}
        
         fprintf(fid, '%s \n', str);
    end
        
    
    if k>2
        
        str=verbatim;
        %{
         PSeq = wait(PSeq, round2(tau+delta,2e-9));
         PSeq = ttl_pulse(PSeq, 2, length_pi_X);
         PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
         PSeq = ttl_pulse(PSeq, 4, length_pi_Y);
         PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
         PSeq = ttl_pulse(PSeq, 2, length_pi_X);
         PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
         PSeq = ttl_pulse(PSeq, 4, length_pi_Y);
         PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
         PSeq = ttl_pulse(PSeq, 4, length_pi_Y);
         PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
         PSeq = ttl_pulse(PSeq, 2, length_pi_X);
         PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
         PSeq = ttl_pulse(PSeq, 4, length_pi_Y);
         PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
         PSeq = ttl_pulse(PSeq, 2, length_pi_X);
         %PSeq = wait(PSeq,tau+delta);
        
        %}
        
        fprintf(fid,'%s \n',str);
        
        for j=1:k-2
            str=verbatim;
            %{
            PSeq = wait(PSeq, round2(2*tau+2*delta,2e-9));
        PSeq = ttl_pulse(PSeq, 2, length_pi_X);
        PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
        PSeq = ttl_pulse(PSeq, 4, length_pi_Y);
        PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
        PSeq = ttl_pulse(PSeq, 2, length_pi_X);
        PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
        PSeq = ttl_pulse(PSeq, 4, length_pi_Y);
        PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
        PSeq = ttl_pulse(PSeq, 4, length_pi_Y);
        PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
        PSeq = ttl_pulse(PSeq, 2, length_pi_X);
        PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
        PSeq = ttl_pulse(PSeq, 4, length_pi_Y);
        PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
        PSeq = ttl_pulse(PSeq, 2, length_pi_X);
        %PSeq = wait(PSeq,tau+delta);

            %}
            fprintf(fid,'%s \n',str);
        end
    
        
        str=verbatim;
        %{
    
         PSeq = wait(PSeq, round2(2*tau+2*delta,2e-9));
         PSeq = ttl_pulse(PSeq, 2, length_pi_X);
         PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
         PSeq = ttl_pulse(PSeq, 4, length_pi_Y);
         PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
         PSeq = ttl_pulse(PSeq, 2, length_pi_X);
         PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
         PSeq = ttl_pulse(PSeq, 4, length_pi_Y);
         PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
         PSeq = ttl_pulse(PSeq, 4, length_pi_Y);
         PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
         PSeq = ttl_pulse(PSeq, 2, length_pi_X);
         PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
         PSeq = ttl_pulse(PSeq, 4, length_pi_Y);
         PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
         PSeq = ttl_pulse(PSeq, 2, length_pi_X);
         PSeq = wait(PSeq,round2(tau+delta,2e-9));
        
         %}
        
         fprintf(fid, '%s \n', str);
    
    
    end
   
    
    fprintf(fid,'%s \n',['PSeq = ttl_pulse(PSeq, 2, length_pi2_X);']);
   
    %fprintf(fid,'%s \n',['PSeq = wait(PSeq,' num2str(5+1.5*k) 'e-6);']);
    
    
     str=verbatim;
    %{
    PSeq = ttl_pulse(PSeq, 1, 1e-6,delay_laser,0); 
    PSeq = wait(PSeq,start_time);
    PSeq = ttl_pulse(PSeq, 3, 300e-9);
    PSeq = wait(PSeq,3e-6);
    %}
    
     fprintf(fid,'%s \n',str);
    
     
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      str=verbatim;
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
    PSeq = wait(PSeq, round2(tau+delta,2e-9));
    
    %}
    
    fprintf(fid, '%s \n', str);
    
    
    %%%% loop the pulses in XYXYYXYX order
    for j=1:8*k
        if mod(j,8)==1||mod(j,8)==3||mod(j,8)==6||mod(j,8)==0
            str_pulse{j}=verbatim;
            %{
            PSeq = ttl_pulse(PSeq, 2, length_pi_X);
            %}
        else
             str_pulse{j}=verbatim;
        %{   
         PSeq = ttl_pulse(PSeq, 4, length_pi_Y);
        %}
        end
    end
    
    
    %%%% loop the spacing according to the combination of p and q
    for j=1:8*k
        if mod(j,2*(p+q))>=1&&mod(j,2*(p+q))<=2*p-1
            str_spacing{j}=verbatim;
            %{
            PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
            %}
        elseif mod(j,2*(p+q))==2*p||mod(j,2*(p+q))==0
            str_spacing{j}=verbatim;
            %{
            PSeq = wait(PSeq,round2(2*tau+2*delta+(p+q)*2e-9,2e-9));
            %}
        elseif mod(j,2*(p+q))>=2*p+1&&mod(j,2*(p+q))<=2*(p+q)-1
            str_spacing{j}=verbatim;
            %{
            PSeq = wait(PSeq,round2(2*tau+2*delta+(p+q)*4e-9,2e-9));
            %}  
        end
        
       if j==8*k %%%% the last spacing is always tau + delta + 2*(p+q)
       str_spacing{j}=verbatim;
       %{
       PSeq = wait(PSeq,round2(tau+delta+(p+q)*2e-9,2e-9));
       %}
       end
    end 
    
     for j=1:8*k
        fprintf(fid,'%s \n',str_pulse{j});
        fprintf(fid,'%s \n',str_spacing{j});
    end
    
    fprintf(fid,'%s \n',['PSeq = ttl_pulse(PSeq, 2, length_pi2_X);']);
    
    %fprintf(fid,'%s \n',['PSeq = wait(PSeq,' num2str(5+1.5*k) 'e-6);']);
    
   
    
    
    str=verbatim;
    %{
    PSeq = ttl_pulse(PSeq, 1, 1e-6,delay_laser,0);
    PSeq = wait(PSeq,start_time);
    PSeq = ttl_pulse(PSeq, 3, 300e-9);
    PSeq = wait(PSeq,1e-6);
     
</instructions>
</sequence>
    %}
    
    fprintf(fid,'%s \n',str);
    
    fclose(fid);
    
