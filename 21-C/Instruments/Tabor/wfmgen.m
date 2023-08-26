function [Fs]=wfmgen(fn,freq,n,pha,amp)

%filedir='C:\Users\qegpi\Desktop\sound files\';
%filedir='C:\Program Files\IVI Foundation\IVI\Drivers\ww257x\examples\matlab\waves\';
%freq=1953.125; %Hz
%fn=[filedir 'arbwfm' num2str(floor(freq)) '.asc'];
%fn=[filedir 'sine_1kpts.wav'];
%lol=audioread(fn);

% leng=0.05; %s
% cyc=floor(leng*freq);
cyc=1;
%n=2048; %no of points in a cycle
N=n*cyc; %total no of points
Fs=floor(n*freq);
x=1/Fs:1/Fs:N/Fs;
y=sin(2*pi*freq*x+pha/360*2*pi);
%y(1:floor(N/2)+200-1)=0*y(1:floor(N/2)+200-1);
%y(1:floor(N/2))=0.2*y(1:floor(N/2));
%y(floor(N/2):end)=y(floor(N/2):end)*0.2;
%y(floor(N/2):end)=y(floor(N/2):end)*5;
% y(1024:1536)=-y(1024:1536);
 y=int16(((y/max(abs(y))+1)/2*65535-32768)*amp);

% figure();
% plot(x,y);
%audiowrite(fn,y,Fs);
dlmwrite(fn,y,' ');
end