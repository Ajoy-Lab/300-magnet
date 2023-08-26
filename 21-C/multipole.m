pluspole = 'pluspole(pw,pw2,rof1,rof2,neco,dtacq);';
minuspole = 'minuspole(pw,pw2,rof1,rof2,neco,dtacq);';
plusdipole = 'plusdipole(pw,pw2,rof1,rof2,neco,dtacq);';
minusdipole = 'minusdipole(pw,pw2,rof1,rof2,neco,dtacq);';
plusquadrupole = 'plusquadrupole(pw,pw2,rof1,rof2,neco,dtacq);';
minusquadrupole = 'minusquadrupole(pw,pw2,rof1,rof2,neco,dtacq);';

strings = {pluspole, minuspole;
    plusdipole, minusdipole;
    plusquadrupole, minusquadrupole};

    [fid, msg] = fopen(['\\192.168.1.5\vnmrsys\tablib\random_sequence'], 'w');
    if fid == 1
        error(msg);
    end

       str = verbatim;
    %{

loop(v1,v2);

%}
   fprintf(fid,'%s \n',str);

    max = 4000/8;
    index = ceil(2.*rand(1,max));

    for j = 1:max
        fprintf(fid, '%s \n',strings{4,index(j)});
    end

   str = verbatim;
    %{

endloop(v2);

}
%}
   fprintf(fid,'%s \n',str);

   fclose(fid);