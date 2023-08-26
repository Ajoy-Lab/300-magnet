% FIDPATH gets the path of Varian FID data

% Note that the filename one chooses in the path doesn't really
% matter since the Varian *.fid directory contains 4 files,
% and they are always named "fid" (FID data), "procpar" (MR
% parameters), "log" (acquisition on/off), and text (PSD name).

function fpath = fidpath(fpath, checkfid, title)

if nargin < 3
   title = 'Select Varian FID/PAR Directory';
   if nargin < 2
      checkfid = false;
      if nargin < 1
         fpath = cd;
      end
   end
end

if isempty(fpath)
   fpath = cd;
end
if isempty(checkfid)
   checkfid = false;
end
if isempty(title)
   title = 'Select Varian FID/PAR Directory';
end
   
if fileexist(fpath, checkfid)
   return
end

% Check if the user forgot to add .fid extension
fpathnew = [fpath '.fid'];
if fileexist(fpathnew, checkfid)
   fpath = fpathnew;
   return
end

% Check if the user forgot to add .par extension
fpathnew = [fpath '.par'];
if fileexist(fpathnew, false)
   fpath = fpathnew;
   return
end

% Get FID file path/name
contflag = 1;
while (contflag == 1),
    fpath = uigetdir(fpath, title);

    % Make sure "fid" and "procpar" files exist
    if isequal(fpath, 0)
        error('No directory selected.')
    elseif ~fileexist(fpath, checkfid)
        disp('GETPATH unable to locate fid and/or procpar file in selected directory. Try again.')
    else
        contflag = 0;
    end
end

drawnow;
return



% LOCAL FUNCTION
function res = fileexist(fpath, checkfid)

if checkfid
   if (exist([fpath '/fid'], 'file') ~= 2)
      res = 0;
      return
   end
end

if exist([fpath '/procpar'], 'file') == 2
   res = 1;
else
   res = 0;
end

return

