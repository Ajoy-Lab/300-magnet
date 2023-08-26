%############################################################################
%#
%#                           function DIG2ANA
%#
%#      converts data acquired with BRUKERs digital filter into regular
%#      analog NMR-data. This is a preliminary version of the routine which 
%#      needs some information from the acqus file, and therefore will work 
%#      only if you are in the datafolder of spectrometers or you have copied 
%#      the acqus file together with the data (which is not a bad idea in any case).  
%#
%#      usage: data_ana=dig2ana(data_dig);
%#
%#      (c) R. Graf 2/03
%#
%#      to do: adopte this function to our 'BRUKER-DATA-HANDLING-SYSTEM' ..
%#
%############################################################################
%----------------------------------------------------------------------------
%  version 1.0 RG 4/2/03    (please change this when code is altered)
%----------------------------------------------------------------------------

function data=dig2ana(data)

digtab=[-2 2 3 4 6 8 12 16 24 32 48 64 96 128 192  256 384 512 768 1024 1536 2048; -10 44.75 33.5 66.625 59.0833 68.5625 60.375 69.5313 61.0208 70.0156 61.3438 70.2578 61.5052 70.3789 61.5859 70.4395 61.6263 70.4697 61.6465 70.4849 61.6566 70.4924; -11 46 36.5 48 50.1667 53.25 69.5 72.25 70.1667 72.75 70.5 73 70.6667 72.5 71.3333 72.25 71.6667 72.125 71.8333 72.0625 71.9167 72.0313; -12 46.311 36.530 47.87 50.229 53.289 69.551 71.6 70.184 72.138 70.528 72.348 70.7 72.524 -1 -1 -1 -1 -1 -1 -1 -1; -13 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1];  


%##########################################################################
%#  
%#      find DSPFVS and DECIM value
%#
%##########################################################################

%paramf=fopen('acqus','r');

fname = '/Users/raffinazaryan/Desktop/FID/2017-06-15_22.54.07_carbon_ext_trig_shuttle/complete.fid/procpar'
paramf=fopen(fname,'r');

if paramf==-1
    disp('ERROR: file not found');
    data=data;
    return
end
while feof(paramf) == 0
   tline = fgetl(paramf);
   num = findstr(tline, '##$DSPFVS= ');
   if num > 0
       [dummy,DSPFVSS]=strtok(tline);
       dspfvs=str2num(DSPFVSS);
       dspfvs=find(digtab==(-1*dspfvs));
   end
   num = findstr(tline, '##$DECIM= ');
   if num > 0
       [dummy,DECIMS]=strtok(tline);
       decim=str2num(DECIMS);
       decim=ceil(find(digtab==decim)/5);
   end
end
fclose(paramf);

ls=-1*digtab(dspfvs,decim);
if(ls<0) 
    tdat=zshift(data,ls); 
    data=tdat;
end;
data=squeeze(data);
