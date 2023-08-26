function [leftside,rightside]= getsides(x,y)
minvalue=min(y);
height=y(1)-minvalue;
maxheight=0.7*(max(y)-min(y));
i=1;
 while height<maxheight
    i=i+1;
    height=y(i)-minvalue;
 end
leftside=x(i)/1e9;

i=length(x);
height=y(i)-minvalue;
while height<maxheight
    i=i-1;
    height=y(i)-minvalue;
end
rightside=x(i)/1e9;
end