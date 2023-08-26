function result_seq=multiloop(PSeq, ACS_No, laser_No, MW_switch_No, Hyp1_No, Hyp2_No, No_loops,wait_time,loop_time,d1)

    for i=1:No_loops
    %PSeq = wait(PSeq,d1);
    %PSeq = ttl_pulse(PSeq, ACS_No, 20e-3);        %ACS
    PSeq = ttl_pulse(PSeq, laser_No,wait_time);   %LASER
    PSeq = ttl_pulse(PSeq, MW_switch_No,wait_time,-(wait_time),1); %MW AMP Switch
       %PSeq = ttl_pulse(PSeq, 11,wait_time,-(wait_time),1); % HyperLoop1
       %PSeq = ttl_pulse(PSeq, 13,wait_time,-(wait_time),1); % HyperLoop1
    PSeq = ttl_pulse(PSeq, Hyp1_No ,loop_time,-(wait_time),1); % HyperLoop1
    PSeq = ttl_pulse(PSeq, Hyp2_No ,2*loop_time); %HyperLoop2
    PSeq = ttl_pulse(PSeq, Hyp1_No ,wait_time-3*loop_time);
    %PSeq = wait(PSeq,3);
    end
    
    result_seq=PSeq;

end