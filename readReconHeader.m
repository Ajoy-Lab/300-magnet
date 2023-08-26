function dims = readReconHeader(filenameBase)
    filename = strcat(filenameBase,'.hdr');
    fid = fopen(filename);
    
    line = getNextLine(fid);
    dims = str2num(line);
    
    fclose(fid);
end