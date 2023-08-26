dirName='Z:\FID_spectra\';
fn=dirName;
 
files1 = dir( fullfile(dirName,'*shuttle') );   %# list all *.xyz files
files2 = dir( fullfile(dirName, '*sequence') );   %# list all *.xyz files
files3 = dir( fullfile(dirName, '*cpmgexp') );   %# list all *.xyz files

files = [{files1.name}'; {files2.name}'; {files3.name}'];     

for j=1:size(files,1)
datestr=files{j}(1:19);
datestr2(j)=str2num([datestr(1:4) datestr(6:7) datestr(9:10) datestr(12:13) datestr(15:16) datestr(18:19) ]);
end

[~,IX]=sort(datestr2,'descend');
clear files_return
ret=1;count=0;
while ret==1
    count=count+1;
files_return{1}=files{IX(count)};
files_return{2}=files{IX(count+1)};
ret=mail_fid(files_return,'complete');
end