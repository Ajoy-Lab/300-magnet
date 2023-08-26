function spike_capture()



for i=1:1

handle = uint32(0);
LibraryName = 'sa_api';
LibraryFilePath = 'sa_api.dll';
HeaderFilePath = 'sa_api.h';
%Returns relevant characteristics of a sweep after device configuration
sweeplen = libpointer('int32Ptr', 1);
startf = libpointer('doublePtr', 1);
binsize = libpointer('doublePtr', 2);
trace = calllib('sa_api', 'saQuerySweepInfo', handle, sweeplen, startf, binsize);

min = libpointer('singlePtr', zeros(1, sweeplen.Value));
max = libpointer('singlePtr', zeros(1, sweeplen.Value));
sweep = calllib(LibraryName, 'saGetSweep_32f', handle, min, max);
data = max.value;
%start=1.75e9; stop=3.75e9; 
%start=2.6e9; stop=2.9e9;
start=2.1e9; stop=3.5e9;

freq_vec=linspace(start,stop,sweeplen.Value);
if i==1
    data_total=zeros(1,size(freq_vec,2));
end
data_total = data_total + data;
end

data_avg = data_total/1;
figure(10);
clf;
plot_preliminaries(freq_vec,data_avg,1,'nomarker');

f_spike=sprintf('D:/New folder/IMD/Spike_%s.mat',datestr(now,'mm-dd-yyyy HH-MM-SS'));
save(f_spike,'freq_vec','data_avg');

end