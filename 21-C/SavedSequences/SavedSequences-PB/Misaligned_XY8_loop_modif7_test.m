
[fid, msg] = fopen(['D:/QEG/21-C/SavedSequences/SavedSequences-PB/test.xml'], 'w');
    if fid == 1
        error(msg);
    end
    
        
    
        
        for k=1:8
            if mod(k,2) == 0
        str{k}=verbatim;
        %{   
         PSeq = ttl_pulse(PSeq, 4, length_pi_Y);
        %}
            else
                 str{k}=verbatim;
        %{   
         PSeq = ttl_pulse(PSeq, 2, length_pi_X);
        %}
            end
        end
        
         
        for k=1:8
            if mod(k,2) == 0
        str2{k}=verbatim;
        %{   
         PSeq = wait(PSeq,round2(2*tau+2*delta,2e-9));
        %}
            else
                 str2{k}=verbatim;
        %{   
           PSeq = wait(PSeq,round2(tau+delta,2e-9));
        %}
            end
        end
        
        for k=1:8
            fprintf(fid,'%s \n',str{k});
            fprintf(fid,'%s \n',str2{k});
        end