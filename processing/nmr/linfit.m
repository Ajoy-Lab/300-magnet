%#############################################
%                                            #
%           function linfit(x,y,dy)          #
%                                            #
% performs a linear fit to the data vector y #
% as a function of vector x, also regarding  #
% the y-errors dy                            #
%                                            #
% dimensions of x,y and dy have to be equal  #
%                                            #
% fit function: y=m*x+b                      #
%                                            #
% output is: vector [m,b,dm,db,c]            #
% where dm, db are the errors of slope and   #
% y-intercept and c is chi square by         #
% number(degrees of freedom)                 #
%                                            #
% formulae taken from:                       #
% Physikalisches Praktikum für               #
% Naturwissenschaftler Teil I                #
% Einführung und Vorversuche                 #
% Institut für Physik                        #
% Johannes Gutenberg Universität Mainz       #
% Skript vom WS 2000/2001                    #
%                                            #
% V 1.0 (c) S. Hiebel 07/05/04               #
%                                            #
%#############################################

function ret_v=linfit(x,y,dy)

s=sum(dy.^-2);
sx=sum(x.*dy.^-2);
sy=sum(y.*dy.^-2);
sxy=sum(x.*y.*dy.^-2);
sxx=sum(x.*x.*dy.^-2);

b=(sx*sxy-sxx*sy)/(sx^2-sxx*s);
m=(sx*sy-s*sxy)/(sx^2-sxx*s);
db=sqrt(sxx/abs(s*sxx-sx^2));
dm=sqrt(s/abs(s*sxx-sx^2));

c=sum((y-m*x-b).^2.*dy.^-2)/(length(x)-2);

ret_v=[m,b,dm,db,c];