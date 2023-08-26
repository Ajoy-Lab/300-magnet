function ret=mail_fid(files_return,avg_num)

for j=1:size(files_return,2)
    fn=['Z:\FID_spectra\' files_return{j} '\' avg_num '.fid\fid'];
    if ~exist(fn, 'file')
        ret=1;
        continue;
    end
    %fn2=['D:\data\' files_return{j} '\' avg_num '.zip'];
    %zip(fn2, fn);
    fn2=['Q:\' files_return{j} '-' avg_num '.fid'];
%     dirname=['D:\data\' files_return{j} '\'];
    if exist(fn2, 'file')
        ret=0;
        continue;
    end
         
    copyfile(fn, fn2,'f');
%     disp(['... Emailing ' fn]);
    disp(['... Saving data to NAS? folder: ' fn]);
    pause(0.1);
    
%     try
%     send_email(fn,'',fn2);
%     ret=0;
%     catch
%         disp('Email failed to send');
%     end
%     pause(0.1);
end
end