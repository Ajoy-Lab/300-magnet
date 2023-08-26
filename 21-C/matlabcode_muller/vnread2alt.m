function vnr_output = vnread2alt(filename,filter_linewidth,temperature,pressure,options)

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
unstable_pts = 0;  % left shift and pad with zeros by this number of points
zero_fill_factor = nextpow2(32e3); % power of 2
zero_fill_pts = 2^zero_fill_factor; % total number of points
fid = [fid(unstable_pts+1:end,:);zeros(unstable_pts,s(2))]; % time_shift unstable points
% fid = auto_zero_ord_phase2(fid);

dt = 1/par.sw;
time = [dt:dt:par.at]';
if length(time) < par.nc
    time = [dt:dt:par.at+dt]';
end
time = [time(unstable_pts+1:end);[time(end)+dt.*[1:unstable_pts]]'];  % time_shift unstable points
if isempty(filter_linewidth)
    filter_linewidth = 0;
end
fid = line_broaden(time,fid,filter_linewidth);  % Apply lorentzian filter

% [fid,fid_phase_cor] = auto_zero_ord_phase2(fid);
% fid(:,10) = zero_ord_phase(fid(:,10),110);  % Manually phase specific spectrum
disp('Transforming data with zero filling (optional) ...');
spec_temp = fftshift(fft(fid,zero_fill_pts,1),1);  % each fn acting only along the column vectors

% df_temp = 1/par.at;
df_temp = 1/(dt*zero_fill_pts);
freq = -par.sw/2:df_temp:par.sw/2-df_temp;
if length(freq) < par.nc
    freq = -par.sw/2:df_temp:par.sw/2;
end
if isempty(par.resto)
    par.resto=0;
end
freq = freq - par.resto;
ppm = -freq./par.sfrq;
k0 = find(abs(spec_temp(:,1)) == max(abs(spec_temp(:,1))));
k0range = round([k0-200/df_temp:k0+200/df_temp]);
[a,spec_temp_ang] = auto_zero_ord_phase2(spec_temp(k0range,:));
spec = zero_ord_phase(spec_temp,unwrap(spec_temp_ang));

if nargin > 2
    par.temperature = temperature;
    par.pressure = pressure;
end

vnr_output.filename = filename;
vnr_output.no_skip_points = unstable_pts;
vnr_output.zero_fill_factor = zero_fill_factor;
vnr_output.digital_resolution = 1/(dt*zero_fill_pts);
vnr_output.line_broadening = filter_linewidth;
vnr_output.time = time;
vnr_output.fid = fid;
vnr_output.freq = -freq';
vnr_output.ppm = ppm';
vnr_output.spec = spec;
vnr_output.par = par;
vnr_output.amp = max(abs(spec)) ./max(max(abs(spec)));
vnr_output.phase = spec_temp_ang;


%disp(['seqfil =      ' vnr_output.par.seqfil]);
%disp(['satmod =      ' vnr_output.par.satmod]);
%disp(['bubble =      ' num2str(vnr_output.par.bubble)]);
%disp(['tpwr =        ' num2str(vnr_output.par.tpwr)]);
%disp('Arrayed variables: ');
%disp([vnr_output.par.array{:}]);
%disp(['satdly =      ' num2str(vnr_output.par.satdly)]);
%disp(['satpwr =      ' num2str(vnr_output.par.satpwr)]);
%disp(['tof =         ' num2str(vnr_output.par.tof)]);
%disp(['sattof =      ' num2str(vnr_output.par.sattof)]);
%disp(' ');


% disp('Arrayed variable for acquisition:');

arrays = [vnr_output.par.array{:}];
% for i = 1:length(arrays)
%     disp([arrays{i} ':        ' num2str(eval(['vnr_output.par.' arrays{i}]))]);
% end

% figure;
% if nfids < 17
%     for i = 1:nfids
%         subplot(1,nfids,i);
%         plot(vnr_output.freq,abs(vnr_output.spec(:,i))./max(max(abs(vnr_output.spec))));
%         title(['Spec #' num2str(i)]);
%         axis([min(vnr_output.freq) max(vnr_output.freq) -0.05 1.05]);
%         set(gca,'XDir','reverse');
%     end
% else
%     plot(vnr_output.amp,'bo--');    
% end

disp('');
