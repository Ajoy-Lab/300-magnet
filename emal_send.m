myaddress = 'qeg.mit@gmail.com';
mypassword = 'getmeoutofhere';

setpref('Internet','E_mail',myaddress);
setpref('Internet','SMTP_Server','smtp.gmail.com');
setpref('Internet','SMTP_Username',myaddress);
setpref('Internet','SMTP_Password',mypassword);

props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', ...
                  'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');


add={};
add{1}='qeg.batman@gmail.com';

sendmail(add,...
           'Test subject','Test message',...
         {'D:/QEG/21-C/SavedImages/sumo_echo4.pptx'});