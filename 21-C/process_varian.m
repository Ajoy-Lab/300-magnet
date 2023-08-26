function  MatrixOut=process_varian2(fn,avg_num)
 fname=['Z:\' fn '\' avg_num '.fid\fid'];
 FTtype=1;
 [y, SizeTD2, SizeTD1] = Qfidread(fname, 17000 ,1, 5, 1);
 MatrixOut1 = matNMRApodize1D(y, 4, 75,75, 6.25);
 MatrixOut2 = matNMRFT1D(MatrixOut1, FTtype);
 MatrixOut = matNMRSetPhase1D(MatrixOut2);
 MatrixOut = matNMRSetPhase1D(MatrixOut);
end
            