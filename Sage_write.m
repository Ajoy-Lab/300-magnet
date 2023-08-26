function Sage_write(n)
%  Definitely not written by Maxwell McAllister, 10/15/2020 
%  Send script, for Automizer, aka Host 1
%  For communication between PCs, replace '127.0.0.1' with
% the DNS or DHCP (?) host name or IP address of Host 2
u1 = udp('192.168.1.6', 'RemotePort', 9090, 'LocalPort', 2020);
u1.EnablePortSharing = 'on';
try
fopen(u1); % open the port
catch
    fclose(u1);
end
% Loop to send messages; wait for response before going on

% Send a message - k cast to uint8
fwrite(u1, n);
%disp('Sent: "' + string(n) + '"') % debug
%fprintf(u1, 'hjjh');

fclose(u1); % close the port when you're fully done with it
end
 
