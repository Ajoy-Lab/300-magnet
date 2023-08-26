function test_txt(GroundPos)
fid = fopen('D:\QEG2\21-C\buffertext2.txt','r');
i = 1;
tline = fgetl(fid);
A{i} = tline;
while ischar(tline)
    i = i+1;
    tline = fgetl(fid);
    A{i} = tline;
end
fclose(fid);
% Change cell A
A{21} = sprintf('POS_GROUND = %d;',-GroundPos);
% Write cell A into txt
fid = fopen('D:\QEG2\21-C\buffertext2.txt', 'wt');
for i = 1:numel(A)
    if A{i+1} == -1
        fprintf(fid,'%s', A{i});
        break
    else
        fprintf(fid,'%s\n', A{i});
        %fprintf(fid,'\n');
    end
end
end