%############################################################################
%#
%#                          function LP
%#
%#      linear prediction of 1D data (can be complex!)
%#
%#      usage: lpdata=lp(data,nfut,npoles);
%#    
%#             data = data to predict   
%#             nfut = number of points to predict (>0 = future, <0 = past)
%#             npoles = number of reference points in the data (>= number of
%#                      data points - 1). Strongly influences result!
%#    
%#      (c) P. Blümler 2/03
%############################################################################
%----------------------------------------------------------------------------
%  version 1.0 PB 6/2/03    (please change this when code is altered)
%----------------------------------------------------------------------------

function estim=lp(data,nfut,npoles)
if dimension(data)~=1
    disp('ERROR: data must be one-dimensional');
end
switch nargin
case 0, disp('ERROR: No input');
case 1, disp('ERROR: No prediction range specified');
case 2
    npoles=nfut/2;
end
if npoles > length(data)-1
    disp('WARNING: npoles exceeds max range, RESET!');
    npoles = length(data)-1;
end
data=data(:)';
if nfut < 0
     data=fliplr(data);
end
rdat=real(data);
d=memcof(rdat,npoles);
rdat=predic(rdat,d,npoles,abs(nfut));
if length(nonzeros(imag(data)))~=0
    idat=imag(data);
    d=memcof(idat,npoles);
    idat=predic(idat,d,npoles,abs(nfut));
    estim=complex([real(data),rdat],[imag(data),idat])';
else
    estim=[real(data),rdat]';
end
if nfut < 0
     estim=fliplr(estim);
end
 

function cof=memcof(data,m)
n=length(data);
wk1=zeros(1,n);
wk2=zeros(1,n);
wkm=zeros(1,m);
p=sum(data.^2);
pm=p/m;
wk1(1:n-1)=data(1:n-1);
wk2(1:n-1)=data(2:n);
for k=1:m
    num=wk1.*wk2;
    denom=wk1.^2+wk2.^2;
    cof(k)=2*sum(num(1:n-k))/sum(denom(1:n-k));
    pm=pm*(1-cof(k)^2);
    if k~=1
        for i=1:k-1
           cof(i)=wkm(i)-cof(k)*wkm(k-i);
       end
    end
    if k == m 
        return
    end
    wkm(1:k)=cof(1:k);
    for j=1:n-k-1
        wk1(j)=wk1(j)-wkm(k)*wk2(j);
        wk2(j)=wk2(j+1)-wkm(k)*wk1(j+1);
    end
end


function future=predic(data,d,m,nfut)
reg=zeros(1,m);
n=length(data);
for j=1:m
    reg(j)=data(n+1-j);
end
for j=1:nfut
    sum=0;
    for k=1:m
        sum=sum+d(k)*reg(k);
    end
    for k=m:-1:2
        reg(k)=reg(k-1);
    end
    reg(1)=sum;
    future(j)=sum;
end