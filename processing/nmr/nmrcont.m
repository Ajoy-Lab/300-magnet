%############################################################################
%#
%#                           function NMRCONT
%#
%#     draws a contour plot with typical features to display NMR-spectra.
%#     no annotations, all black,axes specified by 1D vectors
%#
%#      usage: nmrcont(data,v);      low level application
%#                    data=2D real data array
%#                       v=1D [OPTIONAL] vector specifying the contour levels
%#                            if submitted as a single number, v levels  
%#                            are drawn from min to max, default = 10
%#
%#      usage: nmrcont(data,x,y,v,thick); 
%#                    data=2D real data array
%#                       x=1D vector specifying the range of the x-axis 
%#                       y=1D vector specifying the range of the y-axis 
%#                       v=1D vector specifying the contour levels
%#                            if submitted as a single number, v levels are drawn 
%#                            from min to max
%#                   thick=[optional] sets the linewidth, default=1
%#
%#      (c) P. Blümler 10/03 dedicated to Dr. R. Graf and this special wishes
%############################################################################
%----------------------------------------------------------------------------
%  version 1.0 PB 25/10/03    (please change this when code is altered)
%----------------------------------------------------------------------------
function data=nmrcont(data,x,y,v,thick)
[nx,ny]=size(data);
data_min=min(min(data));
data_max=max(max(data));

switch nargin
case 1
    x=[1:nx]; y=[1:ny];
    [X,Y]=meshgrid(x,y);
    v=linspace(data_min,data_max,10);
    thick=1;
case 2
    v=x;
    x=[1:nx]; y=[1:ny];
    [X,Y]=meshgrid(x,y);
    thick=1;
case 3
    v=y;
    y=[1:ny];
    [X,Y]=meshgrid(x,y);
    thick=1;
case 4
    [X,Y]=meshgrid(x,y);
    thick=1;    
case 5
    [X,Y]=meshgrid(x,y);
end

if length(v)==1
   v=linspace(data_min,data_max,v);
end
contour(X,Y,data',v);
h = findobj('Type','patch');
set(h,'LineWidth',thick,'EdgeColor','k');