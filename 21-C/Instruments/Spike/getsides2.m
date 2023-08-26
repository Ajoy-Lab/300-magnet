function [leftside,rightside]= getsides2(x,y)
y_smooth=smooth(y,400);
maxheight=0.7*(max(y_smooth)-min(y_smooth));

y_th=zeros(1,size(y,2));
y_th(y-min(y)>maxheight)=1;

yth_smooth=smooth(y_th,400);
box_func=find(yth_smooth>0.7&yth_smooth+400>0.7);
leftside=x(min(box_func))/1e9;
rightside=x(max(box_func))/1e9;

% %% Fix the bug when there are some spikes on the right
% if size(box_func,1)>500
% while yth_smooth(max(box_func)-300)<0.8||yth_smooth(max(box_func)-500)<0.8
%     yth_smooth=yth_smooth(1:(max(box_func)-500));
%     box_func=find(yth_smooth>0.5&yth_smooth+100>0.5);
%     leftside=x(min(box_func))/1e9;
%     rightside=x(max(box_func))/1e9;
% end
% end

end