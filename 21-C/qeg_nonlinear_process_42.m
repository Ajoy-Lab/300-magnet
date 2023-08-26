% Use this to try fitting ODMR, also used in magnet experiments.

clear;
opengl software;


fn='D:\QEG\21-C\SavedExperiments\';

%data='1DExp-seq-PBODMR20ms-vary-mw_freq-2014-07-12-205850';

data='1DExp-seq-PBODMR20ms-vary-mw_freq-2014-07-29-153540';

%data='1DExp-seq-PBODMR20ms-vary-mw_freq-2014-07-29-153146';

%data='1DExp-seq-PBODMR20ms-vary-mw_freq-2014-07-29-152749';

%data='1DExp-seq-PBODMR20ms-vary-mw_freq-2014-07-12-203059';

load([fn data '.mat']);


Rise1=Scan.ExperimentData{1}{1};

avg=size(Scan.ExperimentDataEachAvg{1});

if isempty(Scan.nonlinear_data)
    x=Scan.vary_begin:Scan.vary_step_size:Scan.vary_end;
else
x=Scan.nonlinear_data.x;
end


for k=1:size(x,2)
    clear Rise1_temp_vec Rise2_temp_vec Rise3_temp_vec Rise4_temp_vec;
    for j=1:avg(2)
        Rise1_temp_vec(j)=Scan.ExperimentDataEachAvg{1}{j}{1}(k);
    end
    Rise1Error(k)=std(Rise1_temp_vec);    
end

%% Fitting
y=Rise1;
out=fit_Lorentzian(x,y)

% 
% coeff{1}=2.07e9;
% coeff{2}=0;
% coeff{3}=0;
% 
% %f=mean(x);
% f=2.32e9;
% y=Rise1;
% myfun =@(c,x) -c(4).*(x-x(1))+c(5)- c(1)./2./(1+((x-c(2))/c(3)).^2);
% %myfun =@(c,x) c(5)- c(1)./2./(1+((x-c(2))/c(3)).^2);
% 
% cont=y(1)-min(y);
% drift=(y(1)-y(end))./(x(end)-x(1));
% pinit=[cont,f,0.5e6,drift,y(1)];
% % LB=[cont*0.5,f*0.99,0.1e3,drift*0.5,y(1)*0.9];
% % UB=[cont*3,f*1.01,1e6*11,drift*1.5,y(1)*1.9];
% 
% LB=[cont*0.5,f*0.95,0.1e3,drift*0.5,y(1)*0.9];
% UB=[cont*3,f*1.05,1e6*11,drift*1.5,y(1)*1.9];
% 
% 
% [pbest,delta_p]=easyfit(x, y, pinit, myfun, LB, UB);
% dip=min(myfun(pbest,x));
% contrast=100*(pbest(5)-dip)/(pbest(5))
% 
% Out = Fit_CW(coeff,y,x)

% yData=Rise1;xData=x;
% threshold=0.5;
% yOffset = median(yData);
% yData = yData - median(yData);
% yAmplitude = max(abs(yData));
% ySign = sign(max(yData) + min(yData));
% 
% xData = linspace(1, 10, size(yData,2));
% 
% sample = find(abs(yData) > threshold*yAmplitude);
% sampleStart = max(min(sample) - 5, 1);
% sampleEnd = min(max(sample) + 5, length(xData));
% 
% yDataMod = yData(sampleStart:sampleEnd);
% xDataMod = xData(sampleStart:sampleEnd);
% 
% curveType=3;
% 
% [coeffs,R,J,CovB,MSE,ErrorModelInfo] = nlinfit(xDataMod, yDataMod, @modelLorentzian, [median(xDataMod), 1, median(yDataMod)]);
% yModel =modelLorentzian(coeffs, xData);
% yModel = yModel + yOffset;
% 
% coeffsPr = [0 0 0];
% coeffsPr(1) = ((coeffs(1) - 1)/9)*(x(end) - x(1)) + x(1);
% coeffsPr(2) = 9*coeffs(2)/(x(end) - x(1));
% coeffsPr(3) = coeffs(3);
% 
% freq=coeffsPr(1);

    
% fh=figure(2);clf;
% set(fh, 'color', 'white');
% plot(x,Rise1,'.b-','MarkerSize',15,'LineWidth',1);
% hold on;
% ciplot(Rise1-Rise1Error/2,Rise1+Rise1Error/2,x,'b');
% hold on;
% xlabel(Scan.vary_prop{1});
% ylabel('kcps');
% title([Scan.SequenceName ' ' Scan.DateTime]);
% grid();
% %showfit(pbest);
% plot(x,yModel,'r-','linewidth',2);
% 
% drawnow();
% 
