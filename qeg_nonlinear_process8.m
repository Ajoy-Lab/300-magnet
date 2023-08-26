
% To process spin echo

clear;
close all;
opengl software;



%fn='C:\code\QEG\21-C\SavedExperiments\';
fn='D:\QEG\21-C\SavedExperiments\';

data=['1DExp-seq-PBSpinEcho3-vary-tau-2014-08-03-215456'];

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

y=1-(Rise1Mean-Rise3Mean)./(Rise1Mean-Rise2Mean);
% y=(Rise3Mean-Rise1Mean);
% y=(Rise3Mean);
% y=y/max(y);


fh=figure(2);clf;
set(fh, 'color', 'white');
col=['b' 'r' 'k' 'm' 'g' 'y' 'c' 'r'];
hold on;

plot(x,Rise1Mean,'ob-',x,Rise2Mean,'or-',x,Rise3Mean,'ok-');

xlabel('Time \tau');
ylabel('kcps');
grid();
drawnow();


fh=figure(1);clf;
set(fh, 'color', 'white');
col=['b' 'r' 'k' 'm' 'g' 'y' 'c' 'r'];


plot(x,y,'ok');P=fit_exp_cpp(x,y,0);xx=linspace(0,2*max(x),300);yy= P(1).*exp(-P(2).*xx);hold on;plot(xx,yy,'r','Linewidth',2);

xlabel('Time \tau');
ylabel('kcps');
grid();
drawnow();

