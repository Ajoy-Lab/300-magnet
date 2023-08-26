
explimits{1}='2017-06-12_22.25.12_carbon_ext_trig_shuttle';
explimits{2}='2017-06-13_01.09.21_carbon_ext_trig_shuttle';
files_return= agilent_read_dir2(explimits);

mail_fid(files_return,'complete')