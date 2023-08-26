%############################################################################
%#
%#                           function OPLOT
%#
%#     adaption of WAVE command OPLOT. Simply overplots previous plot.
%#
%#      usage: oplot(x,y,'...');
%#
%#
%#      (c) P. Blümler 10/03
%############################################################################
%----------------------------------------------------------------------------
%  version 1.0 PB 25/10/03    (please change this when code is altered)
%----------------------------------------------------------------------------
function data=oplot(x,varargin)
hold on;
plot(x,varargin{:});
hold off;
