function str_spacing=makeU0(fid)
str_spacing{1}=verbatim;
%{
   PSeq = wait(PSeq,round2(tau + delta,2e-9));
%}

str_spacing{2}=verbatim;
%{
   PSeq = wait(PSeq,round2(2*tau + 2*delta,2e-9));
%}

str_spacing{3}=verbatim;
%{
   PSeq = wait(PSeq,round2(tau+ delta,2e-9));
%}
% fprintf(fid,'%s \n',str_spacing);