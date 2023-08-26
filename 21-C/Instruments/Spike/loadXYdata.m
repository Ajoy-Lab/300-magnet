function data=loadXYdata(filename, factor, offset)
% data=loadXYdata(filename, factor, offset)
% load raw data from an XY file, with normalization factor and offset.

data=[];

if(nargin < 2)
    factor=1;
    offset=0;
end
if(nargin<3)
    offset=0;
end
[fid, message] = fopen(filename, 'rt');

r = fgetl(fid);

while length(r)>2
	a = sscanf( r , '%f');
    a(1) = a(1) + offset;
    a(2) = a(2) * factor;
	data = [data ; a' ];	
	r = fgetl(fid);
end

fclose(fid);