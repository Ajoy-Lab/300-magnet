
% To process spin echo

clear;
close all;
opengl software;



fn='D:\QEG\21-C\SavedExperiments\';

%data=['1DExp-seq-PBSpinEcho3-vary-tau-2014-08-03-215456'];
data=['1DExp-seq-PBRabi_xy_compare-vary-length_rabi_pulse-2014-08-05-104147'];

for ind=1:size(data,1)
    clear Rise1 Rise2 Rise3 Rise4 avg x n3 n4 xData yData yModel
    load([fn data(ind,:) '.mat']);
    
    
    Rise1=Scan.ExperimentData{1}{1};
    Rise2=Scan.ExperimentData{1}{2};
    Rise3=Scan.ExperimentData{1}{3};
    
    avg=size(Scan.ExperimentDataEachAvg{1});
    
    x=Scan.vary_begin:Scan.vary_step_size:Scan.vary_end;
    
    
    for k=1:size(x,2)
        clear Rise1_temp_vec Rise2_temp_vec Rise3_temp_vec Rise4_temp_vec;
        for j=1:avg(2)
            Rise1_temp_vec(j)=Scan.ExperimentDataEachAvg{1}{j}{1}(k);
            Rise2_temp_vec(j)=Scan.ExperimentDataEachAvg{1}{j}{2}(k);
            Rise3_temp_vec(j)=Scan.ExperimentDataEachAvg{1}{j}{3}(k);
        end
        
        Rise1Mean(k)=mean(Rise1_temp_vec);
        Rise2Mean(k)=mean(Rise2_temp_vec);
        Rise3Mean(k)=mean(Rise3_temp_vec);
    end
end

%y=(Rise3Mean-Rise1Mean)./(Rise2Mean-Rise1Mean);
%y=(Rise3Mean-Rise1Mean);
y=(Rise3Mean);
y=y/max(y);


fh=figure(2);clf;
set(fh, 'color', 'white');
col=['b' 'r' 'k' 'm' 'g' 'y' 'c' 'r'];

plot(x,Rise1Mean,'ob-',x,Rise2Mean,'or-',x,Rise3Mean,'ok-');

xlabel('Time \tau');
ylabel('kcps');
grid();
drawnow();


fh=figure(1);clf;
set(fh, 'color', 'white');
col=['b' 'r' 'k' 'm' 'g' 'y' 'c' 'r'];
plot(x,y,'ok-');

xlabel('Time \tau');
ylabel('kcps');
grid();
drawnow();

%Masashi's code

delta=abs(x(1)-x(2));
Fs =1/delta;%Sampling frequency
L=length(x);%th of handles.signal
NFFT = 2*2^nextpow2(L); % Next power of 2 from length of x
Y = fft(y-mean(y),NFFT)/L;
Freq = Fs/2*linspace(0,1,NFFT/2+1);
DataY=abs(Y(1:NFFT/2+1)).^2;
DataX=Freq;
[v,b]=max(DataY);
 

coeff{1}=0;coeff{2}=DataX(b);coeff{3}=1;coeff{4}=0;
fh=figure(3);clf;
set(fh, 'color', 'white');
col=['b' 'r' 'k' 'm' 'g' 'y' 'c' 'r'];
hold on;
out =Fit_Rabi_for_auto(coeff,y,x);

%plot(x,y,'*');P=fit_cos_cpp(x,y);xx=linspace(0,max(x),300);yy= P(2)*( cos( P(3) * xx  ) ) + P(1);hold on;plot(xx,yy,'r')

