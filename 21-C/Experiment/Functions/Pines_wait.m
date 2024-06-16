function Pines_wait(localport,str_n)
u2 = udp('192.168.1.3', 'RemotePort', 1901, 'LocalPort', localport);
on = 1;
off = 0;
fopen(u2);
t_counter = 0;
sparse_t = 0;
while(u2.BytesAvailable == 0 && t_counter < 30)
    if t_counter >= sparse_t
        fprintf('This is TIME: %.3f \n', t_counter);
        sparse_t = sparse_t + 1;
    end
    t_counter = t_counter + 0.01;
    pause(0.01);
end
if (u2.BytesAvailable ~= 0)
    readBytes = fscanf(u2);
    fprintf("Time took to run Sage %s : %.3f seconds \n", readBytes, t_counter);
    fprintf("Case %s done in Sage \n", readBytes);
    fclose(u2);
    assert(readBytes == str_n, "Sage need to end with the correctly indicated process")
else
    fclose(u2);
    fprintf("Sage_write did not happen in 30 seconds \n");
end