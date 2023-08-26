function Initialize
Serial_Port = serial('COM3');

if strcmp(Serial_Port.Status,'closed')== 1
   fopen(Serial_Port);
end    


%fclose(s1)

USBTime=1e3; %factor
Serial_Port.BaudRate = 115200*USBTime;
pause_Time=1e-1;