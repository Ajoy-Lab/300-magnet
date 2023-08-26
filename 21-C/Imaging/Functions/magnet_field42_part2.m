clear;
close all;

load magnet_field42.mat;
x=xsweep.Expression1;
y=ysweep.Expression1;
Raw_Data=nvpl_2/max(max(nvpl_2));
Data=Raw_Data;

MR=[0,0;                                                                                         
    0.02,0.3; %this is the important extra point
    0.3,1;
    1,1];
MG=[0,0;
    0.3,0; 
    0.7,1;
    1,1];
MB=[0,0; 
    0.7,0;
    1,1];
hot2 = colormapRGBmatrices(500,MR,MG,MB);

figure(1);clf;
pcolor(x,y,Data);
shading interp;
colormap(hot2);

%axis([-11 -5 15 40]);
axis([-30 30 -30 30]);

set(gca,'xticklabel',[]);
set(gca,'yticklabel',[]);

 set(gca,'XTick',[-30:10:30]);
set(gca,'YTick',[-30:10:30]);

daspect([1 1 1]);
set(gca,'ticklength',[0.02 0.02]);
set(gca,'tickdir','out');
hold on;
rectangle('Position',[-magx/2,-magy/2,magx,magy]);

% h=colorbar;
% set(h,'ticklength',[0.02 0.02]);
% set(h,'yticklabel',[]);
% set(h,'YTick',[0:0.25:1]);

saveas(1, 'E:\paper-drafts\singlet-review\figs\magnet_theory_xy', 'png');