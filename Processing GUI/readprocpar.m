function [par] = readprocpar(fpath, ext)

% READPROCPAR reads in parameter used in FID acquisition
%
%   PAR = READPROCPAR(FPATH) reads the parameters in the the
%   procpar file in the FID directory FPATH
%
% see also WRITEPROCPAR, READFID, WRITEFID


% Written by L Martyn Klassen
% Copyright 2003 Robarts Research Institute

if nargin < 1
   error('READPROCPAR requires one input argument.');
end

if nargin < 2
   ext = [];
end

% Check for validity of file
fp = fopen([fpath '\procpar' ext], 'r', 'ieee-be');
if fp == -1
   fp = fopen([fpath '.fid\procpar' ext], 'r', 'ieee-be');
   if fp == -1
      fp = fopen([fpath '.par\procpar' ext], 'r', 'ieee-be');
      if fp == -1
         error(['READPROCPAR unable to open ' fpath ' for reading.']);
      else
         fpath = [fpath '.par'];
      end
   else
      fpath = [fpath '.fid'];
   end
end

% Initialize outputs
par.path     = fpath;
par.dp       = [];
par.seqfil   = [];
par.nf       = [];
par.ni       = [];
par.sw       = [];
par.ns       = [];
par.ne1      = [];
par.ne2      = [];
par.rfspoil  = [];
par.rfphase  = [];
par.nt       = [];
par.np       = [];
par.nv       = [];
par.nv2      = [];
par.nv3      = [];
par.ne       = [];
par.polarity = [];
par.evenecho = [];
par.tr       = [];
par.te       = [];
par.esp      = [];
par.espincr  = [];
par.nprof    = [];
par.tproj    = [];
par.phi      = [];
par.psi      = [];
par.theta    = [];
par.vpsi     = [];
par.vphi     = [];
par.vtheta   = [];
par.array{1} = [];
par.arraydim = [];
par.seqcon   = [];
par.lro      = [];
par.lpe      = [];
par.lpe2     = [];
par.pro      = [];
par.ppe      = [];
par.ppe2     = [];
par.pss      = [];
par.thk      = [];
par.thk2     = [];
par.pos1     = [];
par.pos2     = [];
par.pos3     = [];
par.vox1     = [];
par.vox2     = [];
par.vox3     = [];
par.nD       = [];
par.cntr     = [];
par.gain     = [];
par.shimset  = [];
par.z1       = [];
par.z2       = [];
par.z3       = [];
par.z4       = [];
par.z5       = [];
par.z6       = [];
par.z7       = [];
par.z8       = [];
par.x1       = [];
par.y1       = [];
par.xz       = [];
par.yz       = [];
par.xy       = [];
par.x3       = [];
par.y3       = [];
par.x4       = [];
par.y4       = [];
par.z1c      = [];
par.z2c      = [];
par.z3c      = [];
par.z4c      = [];
par.xz2      = [];
par.yz2      = [];
par.xz2      = [];
par.yz2      = [];
par.zxy      = [];
par.z3x      = [];
par.z3y      = [];
par.zx3      = [];
par.zy3      = [];
par.z4x        = [];
par.z4y        = [];
par.z5x        = [];
par.z5y        = [];
par.x2y2       = [];
par.z2xy       = [];
par.z3xy       = [];
par.z2x3       = [];
par.z2y3       = [];
par.z3x3       = [];
par.z3y3       = [];
par.z4xy       = [];
par.zx2y2      = [];
par.z2x2y2     = [];
par.z3x2y2     = [];
par.z4x2y2     = [];
par.petable    = [];
par.nrcvrs     = [];
par.trise      = [];
par.at         = [];
par.gro        = [];
par.gmax       = [];
par.intlv      = [];
par.rcvrs      = [];
par.celem      = [];
par.arrayelemts = [];
par.contrast   = [];
par.tep        = [];
par.date       = [];
par.ti         = [];
par.gss2       = [];
par.gss        = [];
par.tpwri      = [];
par.tpwr1      = [];
par.tpwr2      = [];
par.orient     = [];
par.tof        = [];
par.resto      = [];
par.grox       = [];
par.groy       = [];
par.fov        = [];
par.res        = [];
par.npix       = [];
par.nseg       = [];
par.nzseg      = [];
par.waveform   = [];
par.SR         = [];
par.gradfrac   = [];
par.sfrq       = [];
par.B0         = [];
par.dtmap      = [];
par.nnav       = [];
par.tnav       = [];
par.fast       = [];
par.bt         = [];
par.nhomo      = [];
par.fpmult     = [];
par.d1         = [];
par.ss         = [];
par.ssc        = [];
par.r1         = [];
par.r2         = [];
par.ps_coils   = [];
par.coil_array = [];
par.nav        = [];
par.fliplist   = [];
par.varflip    = [];
par.nfreq      = [];
par.flip       = [];
par.flip1      = [];
par.flipprep   = [];
par.seg        = [];
par.state      = [];
par.rfdelay    = [];
par.gro        = [];
par.gimp       = [];
par.SR         = [];
par.readaxis   = [];
par.timescale  = [];
par.etl        = [];
par.grof       = [];
par.Po         = [];
par.Psl        = [];
par.console    = [];
par.shimcoils  = [];
par.spiral_gmax      = [];
par.spiral_gamma     = [];
par.spiral_delay     = [];
par.spiral_tep       = [];
par.dtg              = [];
par.nturns           = [];
par.direction        = [];
par.ninterleave      = [];
par.tn               = [];
par.randomseed       = [];
par.interleave_order = [];
par.profile          = [];
par.image            = [];
par.spiral_version   = [];
par.spiral_filter    = [];
par.spiral_alpha     = [];
par.spiral_density   = [];
par.navigator        = [];
par.tfirst           = [];
par.tpe              = [];
par.ky_order         = [];
par.alternate        = [];
par.offlineAverages  = [];
par.satpwr           = [];
par.sattof           = [];
par.satfreq          = [];
par.settle           = [];
par.satdly           = [];
par.bubble           = [];
par.wait             = [];
par.exchange        = [];
par.exchange1        = [];
par.exchange2        = [];
par.rfdelay          = [];
par.gamp             = [];
par.gwidth           = [];
par.gaxis            = [];
par.pw               = [];
par.tpwr             = [];
par.p1               = [];
par.temp             = [];
par.rof1             = [];
par.rof2             = [];
par.satmod           = [];
par.samplename       = [];
par.page             = [];
par.notebook         = [];
par.satcycle         = [];
par.echo2            =[];
par.width            =[];
par.idelay           =[];
par.nscan            =[];
par.sl_n            = [];
par.tpwr_sl          =[];
par.p2              =[];
par.d2               =[];
par.p1pat              =[];
par.p2pat           =[];
par.idelay        =[];
par.g1           =[];
par.g2 =        [];
par.lg1     =[];
par.lg2 =  [];
par.tcp =[];
par.RG1 =[];
par.RG2 = [];
par.pa = [];
par.read=[];
par.pre = [];
par.sat=[];
par.tof1=[];
par.tof2=[];
par.d3=[];
par.d4=[];
% The structure par MUST use parameter names which match the
% parameter names used by VNMR or it will not read correctly

% This function extracts the first letter of each field name
% in order to quickly discard any line which does not being
% with one of the parameters of interest.
names = fieldnames(par);
value = char(zeros(1,size(names,1)));
m     = 1;
value(m) = names{1}(1);
for n = 2:size(names,1)
    if isempty(strfind(value, names{n}(1)))
      m = m + 1;
      value(m) = names{n}(1);
   end
end
value = value(1:m);
clear n names;

buffer = fgets(fp);

% Parse the ASCII procpar file
while ( buffer ~= -1 )
   % Check to see if the first letter in the buffer matches
   % the first character of any parameter of interest
   % This provides a 3 to 4 fold speed up.
   if (strfind(value, buffer(1)))

      % Get only the first word of the buffer, the parameter name
      ind = strfind(buffer, ' ');
      lenb = ind(1)-1;
      buffer = buffer(1:lenb);

      % Read in required parameters
      if (lenb == 2)
         if any(strcmp(buffer, {'z1','z2','z3','z4','z5','z6','z7','z8', ...
               'x1','y1','xz','yz','xy','x3','y3','x4','y4','nD', ...
               'nf','ni','np','ns','nv','ne','ss','nt','ti','te', ...
               'tr','sw','at','bt','d1','SR','r1','r2','B0','SR', ...
               'Po','pw','p1','p2','d2','g1','g2','pa','d3','d4'}))
            val = sscanf(fgets(fp), '%f');
            par.(buffer) = val(2:end).';
            fgets(fp);
         elseif any(strcmp(buffer, {'dp','tn'}))
            tmpbuffer = fgets(fp);
            ind = strfind(tmpbuffer, '"');
            par.(buffer) = tmpbuffer(ind(1)+1:ind(2)-1);
            fgets(fp);
         end
      elseif (lenb == 3),
         if any(strcmp(buffer, {'z1c','z2c','z3c','z4c','xz2','yz2', ...
               'zxy','z3x','z3y','zx3','zy3','z4x','z4y','z5x', ...
               'z5y','ssc','nv2','nv3','ne2','tep','esp','lro', ...
               'pro','lpe','ppe','pss','phi','psi','thk','gro', ...
               'gss','tof','fov','res','gro','etl','Psl','dtg', ...
               'tpe','ne1','lg1','lg2','RG1','RG2','tcp','pre','sat'}))
            val = sscanf(fgets(fp), '%f');
            par.(buffer) = val(2:end).';
            fgets(fp);
         elseif any(strcmp(buffer, {'nav','seg'}))
            tmpbuffer = fgets(fp);
            ind = strfind(tmpbuffer, '"');
            par.(buffer) = tmpbuffer(ind(1)+1:ind(2)-1);
            fgets(fp);
         end
      elseif (lenb == 4)
         if any(strcmp(buffer, {'x2y2','z2xy','z3xy','z2x3','z2y3', ...
               'z3x3','z3y3','z4xy','lpe2','ppe2','thk2','pos1', ...
               'pos2','pos3','thk2','vox1','vox2','vox3','vpsi', ...
               'vphi','gmax','flip','gss2','sfrq','nnav','tnav', ...
               'grox','groy','nseg','npix','gain','cntr','gimp', ...
               'grof','gamp','rof1','rof2','wait','tpwr','temp','sl_n','read','tof1','tof2'}))
            val = sscanf(fgets(fp), '%f');
            par.(buffer) = val(2:end).';
            fgets(fp);
         elseif any(strcmp(buffer,{'date','fast','page'}))
            tmpbuffer = fgets(fp);
            ind = strfind(tmpbuffer, '"');
            par.(buffer) = tmpbuffer(ind(1)+1:ind(2)-1);
            fgets(fp);
         end
      elseif (lenb == 5)
         if any(strcmp(buffer, {'zx2y2','celem','tproj','trise', ...
               'tpwr1','tpwr2','tpwri','theta','resto','nhomo', ...
               'nfreq','dtmap','nzseg','nproj','state','flip1', ...
               'image','gaxis','echo2','width','nscan','p1pat','p2pat','idelay'}))
            val = sscanf(fgets(fp), '%f');
            par.(buffer) = val(2:end).';
            fgets(fp);
         elseif (strcmp(buffer, 'rcvrs'))
            buffer = fgets(fp);
            % Count the number of 'y' values to find number of receivers
            ind = strfind(buffer, '"');
            buffer = buffer(ind(1)+1:ind(2)-1);
            par.rcvrs = buffer;
            par.nrcvrs = sum(double(buffer) == 121);
            fgets(fp);
         elseif (strcmp(buffer, 'intlv'))
            buffer = fgets(fp);
            ind = strfind(buffer, '"');
            par.intlv = buffer(ind(1)+1:ind(2)-1);
            fgets(fp);
         elseif (strcmp(buffer, 'array'))
            buffer = fgets(fp);
            % Strip the buffer down to the core data
            ind = strfind(buffer, '"');
            buffer = buffer((ind(1)+1):(ind(2)-1));

            % Parse the data string
            index1 = 1;
            index2 = 1;
            incr = 0;
            par.array{1}{1} = [];
            for o = 1:length(buffer)
               switch buffer(o)
               case '('
                  incr = incr + 1;
                  if incr > 1
                     error('invalid coupling in array paramater.');
                  end
               case ')'
                  incr = incr - 1;
                  if incr == 0
                     index2 = 1;
                  elseif incr < 0
                     error('invalid coupling in array paramater.');
                  end
               case ','
                  if incr > 0
                     index2 = index2 + 1;
                  else
                     index1 = index1 + 1;
                  end
                  par.array{index1}{index2} = [];
               otherwise
                  par.array{index1}{index2} = [par.array{index1}{index2} buffer(o)];
               end
            end
            fgets(fp);
         end
      elseif (lenb == 6)
         if any(strcmp(buffer, {'z2x2y2','z3x2y2','z4x2y2','vtheta', ...
               'fpmult','nturns', 'tfirst','satpwr','sattof','gwidth','settle','satdly','bubble','idelay'}))
            val = sscanf(fgets(fp), '%f');
            par.(buffer) = val(2:end).';
            fgets(fp);
         elseif any(strcmp(buffer, {'seqfil','seqcon','orient','satmod'}))
            tmpbuffer = fgets(fp);
            ind = strfind(tmpbuffer, '"');
            par.(buffer) = tmpbuffer(ind(1)+1:ind(2)-1);
            fgets(fp);
         end
      elseif (lenb == 7)
         if any(strcmp(buffer, {'espincr','rfphase','shimset','rfdelay','satfreq','tpwr_sl'}))
            val = sscanf(fgets(fp), '%f');
            par.(buffer) = val(2:end).';
            fgets(fp);
         elseif any(strcmp(buffer, {'rfspoil','varflip','petable', ...
               'console','profile'}))
            tmpbuffer= fgets(fp);
            ind = strfind(tmpbuffer, '"');
            par.(buffer) = tmpbuffer(ind(1)+1:ind(2)-1);
            fgets(fp);
         end
      elseif (lenb == 8)
         if any(strcmp(buffer, {'evenecho','polarity','arraydim', ...
               'fliplist','gradfrac','exchange','satcycle'}))
            val = sscanf(fgets(fp), '%f');
            par.(buffer) = val(2:end).';
            fgets(fp);
         elseif any(strcmp(buffer, {'waveform','contrast', ...
               'flipprep','readaxis','ky_order','notebook'}))
            tmpbuffer = fgets(fp);
            ind = strfind(tmpbuffer, '"');
            par.(buffer) = tmpbuffer(ind(1)+1:ind(2)-1);
            fgets(fp);
         elseif (strcmp(buffer, 'ps_coils'))
            tmpbuffer = fgets(fp);
            n = sscanf(tmpbuffer, '%f', 1);
            for m = 1:n
               ind = strfind(tmpbuffer, '"');
               par.(buffer){m} = tmpbuffer(ind(1)+1:ind(2)-1);
               tmpbuffer = fgets(fp);
            end
         end
      elseif (lenb == 9)
         if any(strcmp(buffer, {'direction','exchange1','exchange2'}))
            val = sscanf(fgets(fp), '%f');
            par.(buffer) = val(2:end).';
            fgets(fp);
         elseif any(strcmp(buffer, {'timescale','navigator','alternate'}))
            tmpbuffer = fgets(fp);
            ind = strfind(tmpbuffer, '"');
            par.(buffer) = tmpbuffer(ind(1)+1:ind(2)-1);
            fgets(fp);
        elseif (strcmp(buffer, 'shimcoils'))
            tmpbuffer = fgets(fp);
            n = sscanf(tmpbuffer, '%f', 1);
            for m = 1:n
               ind = strfind(tmpbuffer, '"');
               par.(buffer){m} = tmpbuffer(ind(1)+1:ind(2)-1);
               tmpbuffer = fgets(fp);
            end
         end
      elseif (lenb == 10)
         if any(strcmp(buffer, {'spiral_tep','randomseed'}))
            val = sscanf(fgets(fp), '%f');
            par.(buffer) = val(2:end).';
            fgets(fp);
         elseif any(strcmp(buffer, {'samplename'}))
            tmpbuffer = fgets(fp);
            ind = strfind(tmpbuffer, '"');
            par.(buffer) = tmpbuffer(ind(1)+1:ind(2)-1);
            fgets(fp);
         elseif any(strcmp(buffer, {'coil_array'}))
            tmpbuffer = fgets(fp);
            n = sscanf(tmpbuffer, '%f', 1);
            for m = 1:n
               ind = strfind(tmpbuffer, '"');
               par.(buffer){m} = tmpbuffer(ind(1)+1:ind(2)-1);
               tmpbuffer = fgets(fp);
            end
         end
      elseif (lenb == 11)
         if any(strcmp(buffer, {'arrayelemts','spiral_gmax','ninterleave'}))
            val = sscanf(fgets(fp), '%f');
            par.(buffer) = val(2:end).';
            fgets(fp);
         end
      elseif (lenb == 12)
         if any(strcmp(buffer, {'spiral_gamma', 'spiral_delay', 'spiral_alpha'}))
            val = sscanf(fgets(fp), '%f');
            par.(buffer) = val(2:end).';
            fgets(fp);
         end
      elseif (lenb == 13)
         if any(strcmp(buffer, {'spiral_filter'}))
            val = sscanf(fgets(fp), '%f');
            par.(buffer) = val(2:end).';
            fgets(fp);
         end
      elseif (lenb == 14)
         if any(strcmp(buffer, {'spiral_version','spiral_density'}))
            val = sscanf(fgets(fp), '%f');
            par.(buffer) = val(2:end).';
            fgets(fp);
         end
      elseif (lenb == 15)
         if any(strcmp(buffer, {'offlineAverages'}))
            val = sscanf(fgets(fp), '%f');
            par.(buffer) = val(2:end).';
            fgets(fp);
         end
      elseif (lenb == 16)
         if any(strcmp(buffer, {'interleave_order'}))
            tmpbuffer = fgets(fp);
            ind = strfind(tmpbuffer, '"');
            par.(buffer) = tmpbuffer(ind(1)+1:ind(2)-1);
            fgets(fp);
         end
      end
   end

   buffer = fgets(fp);
end  % End of while loop

% Close file
fclose(fp);

return
