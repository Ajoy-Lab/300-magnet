%############################################################################
%#
%#                           function CSHIFT
%#
%#      shifts data (up to 4D) cyclically, shifts can be positive or 
%#      negative or zero. If a shift range is not specified, the routine
%#      applies the shifts to the first dimension(s) and assumes zero shift
%#      for the others.
%#
%#      usage: shdata=cshift(data,s1,s2,...);
%#
%#
%#      (c) P. Blümler 12/02
%############################################################################
%----------------------------------------------------------------------------
%  version 1.1 PB 5/1/03    (please change this when code is altered)
%----------------------------------------------------------------------------



function data=cshift(data,s1,s2,s3,s4)
switch nargin
case 1
    s=zeros(1,4);
case 2
    s=[s1,zeros(1,3)];
case 3
    s=[s1,s2,zeros(1,2)];    
case 4
    s=[s1,s2,s3,0];
case 5
    s=[s1,s2,s3,s4];
end

data=squeeze(data);
[n1,n2,n3,n4]=size(data);
n=[n1,n2,n3,n4];
dim=ndims(data);
if (prod(n) == length(data)) & (n(1)==1)
    n(1)=n(2);
    n(2)=1;
end
    
for t=1:4
   s(t)=mod(s(t),n(t));
   s(t)=int32(s(t));
end

tdat=data;

switch dim
case 2
    if prod(n) == length(data)
        %Data is 1D
        tdat(1:s(1))=data(n(1)-s(1)+1:n(1));
        tdat(s(1)+1:n(1))=data(1:n(1)-s(1));
    else
        %data is 2D
        tdat(1:s(1),:)=data(n(1)-s(1)+1:n(1),:);
        tdat(s(1)+1:n(1),:)=data(1:n(1)-s(1),:);
        data=tdat;
        tdat(:,1:s(2))=data(:,n(2)-s(2)+1:n(2));
        tdat(:,s(2)+1:n(2))=data(:,1:n(2)-s(2));
    end
case 3
    %data is 3D
    tdat(1:s(1),:,:)=data(n(1)-s(1)+1:n(1),:,:);
    tdat(s(1)+1:n(1),:,:)=data(1:n(1)-s(1),:,:);
    data=tdat;
    tdat(:,1:s(2),:)=data(:,n(2)-s(2)+1:n(2),:);
    tdat(:,s(2)+1:n(2),:)=data(:,1:n(2)-s(2),:);
    data=tdat;
    tdat(:,:,1:s(3))=data(:,:,n(3)-s(3)+1:n(3));
    tdat(:,:,s(3)+1:n(3))=data(:,:,1:n(3)-s(3));
case 4
    %data is 4D
    tdat(1:s(1),:,:,:)=data(n(1)-s(1)+1:n(1),:,:,:);
    tdat(s(1)+1:n(1),:,:,:)=data(1:n(1)-s(1),:,:,:);
    data=tdat;
    tdat(:,1:s(2),:,:)=data(:,n(2)-s(2)+1:n(2),:,:);
    tdat(:,s(2)+1:n(2),:,:)=data(:,1:n(2)-s(2),:,:);
    data=tdat;
    tdat(:,:,1:s(3),:)=data(:,:,n(3)-s(3)+1:n(3),:);
    tdat(:,:,s(3)+1:n(3),:)=data(:,:,1:n(3)-s(3),:);
    data=tdat;
    tdat(:,:,:,1:s(4))=data(:,:,:,n(4)-s(4)+1:n(4));
    tdat(:,:,:,s(4)+1:n(4))=data(:,:,:,1:n(4)-s(4));
otherwise
    disp('ERROR: data is not 1-4 dimensional!')
    return
end
    
data=tdat;
 