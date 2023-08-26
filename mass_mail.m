function mass_mail(files_return,avg_num)

for j=1:size(files_return,2)
    fn=['K:\Test2\' files_return{j} '\' avg_num '.fid\fid'];
   % fn=['Z:\FID_spectra\' files_return{j} '\' avg_num '.fid\fid'];
    if ~exist(fn, 'file')
        ret=1;
        continue;
    end
    
    %fn2=['D:\data\' files_return{j} '\' avg_num '.zip'];
    %zip(fn2, fn);
    %     fn2=['D:\data\' files_return{j} '-' avg_num '.fid'];
     %NAS path: Q:\ should go to test "shuttler data" folder 
    fn2=['K:\Test2\' files_return{j} '-' avg_num '.fid'];
    %fn2=['D:\data_2020\Dropbox\' files_return{j} '-' avg_num '.fid'];
    
%     if exist(fn2, 'file')
%         ret=0;
%         continue;
%     end
    
    try
        copyfile (fn, fn2);
    catch
        continue
    end
    
    copyfile(fn, fn2,'f');
    %     disp(['... Emailing ' fn]);
    disp(['... Saving data to dropbox folder: ' fn]);
    pause(0.1);
    
    %     try
    %     send_email(fn,'',fn2)
    %     catch
    %         try
    %           send_email(fn,'',fn2)
    %         catch
    %            send_email(fn,'',fn2)
    %         end
    %     end
    %     disp(['... Emailing ' fn2]);
    %     pause(1);
end

end