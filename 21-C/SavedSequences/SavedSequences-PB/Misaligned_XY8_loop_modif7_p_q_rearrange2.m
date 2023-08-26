clear

%p=[1 1 2 1 3 1 5 1 7 1 11 1 23 3 5 5 7 11 13];
%q=[1 2 1 3 1 5 1 7 1 11 1 23 1 5 3 7 5 13 11];

 p=[1 15 7 9  23 25 1 47];
 q=[15 1 9 7 25 23 47 1];
% 
% p=[4 5 17 19 35 37 1 8 1 35 1 71];
% q=[5 4 19 17 37 35 8 1 35 1 71 1];



% p=[5 7 1 23 11 13 11 1];
% q=[7 5 23 1 13 11 1 11];

%p=[3 13 5 11 11 37 5 19 7 17 5 43 7 41];
%q=[13 3 11 5 37 11 19 5 17 7 43 5 41 7];
for l=1:length(p)
    clear delay;
k=12;
   
    [fid, msg] = fopen(['D:/QEG/21-C/SavedSequences/SavedSequences-PB/Misaligned_XY8_mod' num2str(k) '_' num2str(p(l)) '_' num2str(q(l))  '_rearrange.xml'], 'w');
    if fid == 1
        error(msg);
    end
    fprintf(fid, '%s \n');
    str = verbatim;
    %{
    
    <sequence>

    <variables>
    
    % these are the variables that can be scanned or switched from the gui
	
    length_trigger = float(50e-9, 2e-9, 0.5)
    
    length_pi_Y = float(60e-9, 2e-9, 0.5)
    length_pi_X = float(60e-9, 2e-9, 0.5)
    length_pi2_X = float(30e-9, 2e-9, 0.5)
    
    tau = float(30e-9,0,500e-6)
    delta = float(0,-500e-6,500e-6)
    
    p = float(0.5,0,500)
    q = float(0.5,0,500) %%%%%% here the p and q are only used to set the U(tau + delta)U(tau+delta+2*(p+q)) it has nothing to do with the shape of the sequence
    
    delay_DC = float(800e-9,-500e-6,500e-6)
    delay_laser= float(0e-6,-500e-6,500e-6)

    
    SRS_freq2 = float(2.87e9, 1e6, 20e9)
    SRS_freq = float(2.87e9, 1e6, 20e9)
    
    SRS_ampl2 = float(-5.6,-50, 12)
    SRS_ampl = float(-5.6,-50, 12)
    
    phase = float(176,-360,360)
  
    
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
    PSeq = wait(PSeq,round2(tau+delta,2e-9));
     
    %}
    
    fprintf(fid, '%s \n', str);
    
    %%%% loop the pulses in XYXYYXYX order
    for j=1:8*k
        if mod(j,8)==1||mod(j,8)==3||mod(j,8)==6||mod(j,8)==0
            str_pulse_normal{j}=verbatim;
            %{
            PSeq = ttl_pulse(PSeq, 2, length_pi_X);
            %}
        else
             str_pulse_normal{j}=verbatim;
        %{   
         PSeq = ttl_pulse(PSeq, 4, length_pi_Y);
        %}
        end
    end
    
    
    %%%% loop the spacing 
    for j=1:8*k
        str_spacing_normal{j}=verbatim;
        %{
         PSeq = wait(PSeq, round2(2*tau+2*delta,2e-9));
        %}
        
       if j==8*k %%%% the last spacing is always tau + delta + 2*(p+q)
       str_spacing_normal{j}=verbatim;
       %{
       PSeq = wait(PSeq,round2(tau+delta,2e-9));
       %}
       end
    end 
    
     for j=1:8*k
        fprintf(fid,'%s \n',str_pulse_normal{j});
        fprintf(fid,'%s \n',str_spacing_normal{j});
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
    %PSeq = wait(PSeq, round2(tau+delta,2e-9));
    
    %}
    
    fprintf(fid, '%s \n', str);

 
 

 str_U0=makeU0(fid);
 str_U1=makeU1(fid);
 pulse_XY=makepulse(fid);
 pulse_YX=fliplr(makepulse(fid));
 pulse=[pulse_XY pulse_YX];

 
count=0;
%for j=1:size(p,2)
    if p(l)<q(l)
        for j=1:p(l)
            count=count+1;
             delay{count}=makeU0(fid);
             for k1=1:fix(q(l)/p(l))
             count=count+1;
             delay{count}=makeU1(fid);
             end
        end
        for j=1:mod(q(l),p(l))
            count=count+1;
            delay{count}=makeU1(fid);
        end
    else
        for j=1:mod(p(l),q(l))
            count=count+1;
            delay{count}=makeU0(fid);
        end
        for j=1:q(l)
            for k2=1:fix(p(l)/q(l))
            count=count+1;
            delay{count}=makeU0(fid);
            end
            count=count+1;
            delay{count}=makeU1(fid);
        end
    end       
%end

delay2=repmat(delay,1,k*4/(p(l)+q(l)));
clear delay;
delay=delay2;

count=0;
for j=1:size(delay,2)
    if mod(j,4)==1||mod(j,4)==2
        sequence{count+1}=delay{j}{1};
        sequence{count+2}=pulse_XY{1};
        sequence{count+3}=delay{j}{2};
        sequence{count+4}=pulse_XY{2};
        sequence{count+5}=delay{j}{3};
        sequence{count+6}=[' '];
        count=count+6;
    else
        sequence{count+1}=delay{j}{1};
        sequence{count+2}=pulse_YX{1};
        sequence{count+3}=delay{j}{2};
        sequence{count+4}=pulse_YX{2};
        sequence{count+5}=delay{j}{3};
        sequence{count+6}=[' '];
        count=count+6;
    end
end
    
     fprintf(fid,'%s \n',sequence{:});
     
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
    

end
