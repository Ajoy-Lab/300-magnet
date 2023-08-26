disp('Open TCP connection');
t = tcpip('0.0.0.0', 30000, 'NetworkRole', 'server');
fopen(t);
while t.BytesAvailable == 0
    pause(1);
end
data = fread(t, t.BytesAvailable);
disp(data);
% fprintf('%s',data);
