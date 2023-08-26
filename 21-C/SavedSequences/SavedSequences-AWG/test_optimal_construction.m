clear;
m = 0;

% n=4;
% min_interval=1/(4*n);

%sample = 5/16;
sample = 7/16;
% sample2=round2(sample,min_interval);
sample2=sample;
sequence={};
count=0;

for j=1:16
    m = m + sample2; % sample is a fraction like 5/16
if abs(m)<=1/2
    count = count +1;
    sequence{count}=0;
   
else 
    count = count+1;
    sequence{count}=1;
    m = m-1;
end
end
disp(sequence) 