function Pines_wait(str_n)
u2 = udp('192.168.1.3', 'RemotePort', 1901, 'LocalPort', 2020);
on = 1;
off = 0;
fopen(u2);
t_counter = 0;
while(u2.BytesAvailable == 0)
    if mod(t_counter, 1) < 1e-6
        fprintf('This is TIME: %d \n', t_counter);
    end
    t_counter = t_counter + 0.01;
    pause(0.01);
end
readBytes = fscanf(u2);
fprintf("Time took to run Sage %s : %.3f seconds \n", readBytes, t_counter);
fprintf("Case %s done in Sage \n", readBytes);
fclose(u2);
assert(readBytes == str_n, "Sage need to end with the correctly indicated process")
end