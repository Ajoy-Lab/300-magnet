function line = getNextLine(fid)
    line = fgetl(fid);
    while(line(1) == '#')
        line = fgetl(fid);
    end
end
