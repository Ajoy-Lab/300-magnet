function send_email(subject,message,attach)

%myaddress = 'qeg.pines@gmail.com';
% myaddress = 'qeg.pines3@gmail.com';
myaddress = 'qeg.pines5@zohomail.com';
% mypassword = 'pineslab3'; for gmail
mypassword = 'Pineslab5!';

setpref('Internet','E_mail',myaddress);
% setpref('Internet','SMTP_Server','smtp.gmail.com');
setpref('Internet','SMTP_Server','smtp.zoho.com');
setpref('Internet','SMTP_Username',myaddress);
setpref('Internet','SMTP_Password',mypassword);

props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', ...
                  'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');


add={};
%add{1}='qeg.pines@gmail.com';
% add{1}='qeg.pines3@gmail.com';
add{1}='qeg.pines5@zohomail.com';

% sendmail(add,...
%            'Test subject','Test message',...
%          {'D:/QEG/21-C/SavedImages/sumo_echo4.pptx'});
     
sendmail(add,...
           subject,message,...
         {attach});
end