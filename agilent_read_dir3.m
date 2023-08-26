function files_return = agilent_read_dir3()

%dirName = uigetdir();
dirName = 'Z:\FID_spectra\';
fn=dirName;
 
files = dir( fullfile(dirName,'*shuttle') );   %# list all *.xyz files
files = {files.name}';     

for j=1:size(files,1)
datestr=files{j}(1:19);
datestr2(j)=str2num([datestr(1:4) datestr(6:7) datestr(9:10) datestr(12:13) datestr(15:16) datestr(18:19) ]);
end

[sorted_dates, IX]=sort(datestr2);
files_return= flipud(files(IX));


%mail_fid(files_return,'complete');

% Sort filenames with datetime

%ds = datetime(files,'Format','yyyy-MM-dd');

end