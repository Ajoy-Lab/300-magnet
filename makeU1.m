function [str_spacing]=makeU1(fid)
str_spacing{1}=verbatim;
%{
   PSeq = wait(PSeq,round2(tau+(p+q)*2e-9 + delta,2e-9));
%}

str_spacing{2}=verbatim;
%{
   PSeq = wait(PSeq,round2(2*tau+(p+q)*4e-9 + 2*delta,2e-9));
%}

str_spacing{3}=verbatim;
%{
      PSeq = wait(PSeq,round2(tau+(p+q)*2e-9+ delta,2e-9));
%}

%fprintf(fid,'%s \n',str_spacing);