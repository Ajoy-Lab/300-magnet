function files_return = agilent_read_dir3_postprocess()

dirName = 'D:\code\SavedExperiments\';
fn=dirName;
 
files = dir( fullfile(dirName,'*shuttle*') );   %# list all *.xyz files
files = {files.name}';     

for j=1:size(files,1)
datestr=files{j}(1:19);
datestr2(j)=str2num([datestr(1:4) datestr(6:7) datestr(9:10) datestr(12:13) datestr(15:16) datestr(18:19) ]);
end

files_return=flipud(files);
