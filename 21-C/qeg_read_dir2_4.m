function selected_expts=qeg_read_dir2_4(explimits)


dirName='D:\code\SavedExperiments\';
fn=dirName;
 
files = dir( fullfile(dirName,'1DExp-seq-AWG*.mat') );   %# list all *.xyz files
files = {files.name}';     

for j=1:size(explimits,2)
datetag_lim(j)=datenum(datestr([explimits{j}(end-20:end-11) ' ' explimits{j}(end-9:end-8) ':' explimits{j}(end-7:end-6) ':' explimits{j}(end-5:end-4)]));
end

count=0;
for j=1:size(files,1)
datetag(j)=datenum(datestr([files{j}(end-20:end-11) ' ' files{j}(end-9:end-8) ':' files{j}(end-7:end-6) ':' files{j}(end-5:end-4)]));
 if datetag(j)>=datetag_lim(1) && datetag(j)<=datetag_lim(2)
     count=count+1;
      %selected_expts{count}=files{j}(1:end-4);
      selected_expts_index(count)=j;
      selected_datetag(count)=datetag(j);
 end    
end


[sorted_selected_datetag,IX] = sort(selected_datetag);

for j=1:size(IX,2)
    selected_expts{j}=files{selected_expts_index(IX(j))}(1:end-4);
end


%Display experiments used 
selected_expts'
