%############################################################################
%#
%#                           function CLOSEST
%#
%#      like command find but finds closest match  
%#      
%#
%#      (c) P. Blümler 12/06
%############################################################################
%----------------------------------------------------------------------------
%  version 1.1 PB 1/12/06    (please change this when code is altered)
%----------------------------------------------------------------------------

function i=closest(vect,value)

i=find(vect == value);

if isempty(i)
    chi=abs(value-vect);
    i=find(chi == min(chi));
end
