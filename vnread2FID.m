function fid = vnread2(filename)

% Usage:
% [time,fid,fidmodel,freq,spec,specmodel,par,linewidth,init_params,final_params,exitflag,resnorm] = vnread(filename,filter_linewidth,temperature,pressure);
%

% History: July 2009 - written by Todd Stevens
%          July 2009 - added in arrayed data functionality (TKS)

disp(' ');

%% Read in data and transform, create time and freq arrays, and apply zero order phase corrections
% disp('Reading in FIDs ...');
[par,b,c,d] = fidread(filename);
fid = squeeze(c);
% fid = fid(:,1:75);

nfids = min(size(fid));

s = size(fid);
if s(1) < s(2)
    fid = fid.';   % make sure individual FIDs are column vectors 
    s = s.';
end
