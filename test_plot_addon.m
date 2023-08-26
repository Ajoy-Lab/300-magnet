clear            

            fname='Z:\2017-02-24_22.23.10_carbon_ext_trig_shuttle\complete.fid\fid';
            
            explimits{1}='2017-02-25_16.24.31_carbon_ext_trig_shuttle';
            explimits{2}='2017-02-25_16.53.12_carbon_ext_trig_shuttle';
            
%              explimits{1}='2017-02-24_19.33.12_carbon_ext_trig_shuttle';
%              explimits{2}='2017-02-25_03.56.19_carbon_ext_trig_shuttle';

explimits{1}='2017-02-24_22.23.10_carbon_ext_trig_shuttle';
 explimits{2}='2017-02-24_22.23.10_carbon_ext_trig_shuttle';
 
 explimits{1}='2017-02-26_15.10.06_carbon_ext_trig_shuttle';
 explimits{2}='2017-02-27_04.45.59_carbon_ext_trig_shuttle';

%             
            files_return= agilent_read_dir(explimits);
            figure(1);clf;hold on;
             for j=1:size(files_return,2)
             MatrixOut(j,:)=process_varian(files_return{j});
             norm_data(j,:)= MatrixOut(j,200:end-200)/mean(abs(MatrixOut(j,200:end-200)));
              plot(j+real(smooth(norm_data(j,:),100)));
             end
        