function spec3 = process_spectrum(fname1, fname2, begin_flag)
if begin_flag
    [data, SizeTD2, SizeTD1] = Qfidread(fname1, 17000 ,1, 5, 1);
    dataSize = length(data);
    
    f3=apod('lorentz',dataSize,0,128);  %retrieve data1 and apodize
    spec3=nmrft(data.*f3,2^14,'f');
else
    [data1, SizeTD2, SizeTD1] = Qfidread(fname1, 17000 ,1, 5, 1);
    [data2, SizeTD2, SizeTD1] = Qfidread(fname2, 17000 ,1, 5, 1);
    data = data2-data1;
    dataSize = length(data);
    
    f3=apod('lorentz',dataSize,0,128);  %retrieve data1 and apodize
    spec3=nmrft(data.*f3,2^14,'f');
end

end