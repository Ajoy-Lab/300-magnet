function files_return = agilent_read_dir2(explimits)

for j=1:size(explimits,2)
 datestr=explimits{j}(1:19);
explimitstr(j)=str2num([datestr(1:4) datestr(6:7) datestr(9:10) datestr(12:13) datestr(15:16) datestr(18:19) ]);
end

dirName='D:\code\SavedExperiments\';
fn=dirName;
 
files = dir( fullfile(dirName,'*shuttle*') );   %# list all *.xyz files
files = {files.name}';     

for j=1:size(files,1)
datestr=files{j}(1:19);
datestr2(j)=str2num([datestr(1:4) datestr(6:7) datestr(9:10) datestr(12:13) datestr(15:16) datestr(18:19) ]);
end

indices=find(datestr2>=explimitstr(1) & datestr2<=explimitstr(2));

for j=1:size(indices,2)
files_return{j}=files{indices(j)};
end

%mail_fid(files_return,'complete');

% Sort filenames with datetime

%ds = datetime(files,'Format','yyyy-MM-dd');
