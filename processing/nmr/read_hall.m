function result=read_hall(varargin)
if nargin~=0
  if exist(varargin{:},'file')==2
     fname = varargin{:};
  else
      disp('ERROR: file not found..please select now!');  
      [filename,dirname]=uigetfile('*.*','Open field file');
      fname=[dirname,filename];
      cd dirname;
  end
else
  [filename,dirname]=uigetfile('*.*','Open field file');
  fname=[dirname,filename];
  cd(dirname);
end
  
% ***************** Start to Read Data **************
fid=fopen(fname);
result.date=fscanf(fid,'%s10');  %Date of measurement
field_component=fscanf(fid,'%i1');  % 0 = Bx, 1 = By, 2 = Bz
switch field_component
case 0, result.field_component = [1,0,0];
case 1, result.field_component = [0,1,0];
case 2, result.field_component = [0,0,1];
end    
stepx=fscanf(fid,'%i5');  % steps in x direction 
stepy=fscanf(fid,'%i5');  % steps in y direction 
stepz=fscanf(fid,'%i5');  % steps in z direction 
result.step=[stepx,stepy,stepz];
result.dim=sign(result.step-1);
result.dimension=sum(result.dim);
result.scan_mode=fscanf(fid,'%i1');  % 0 = cubic, 1 = cylinder axis z, 2 = cylinder axis x, 3 = cylinder axis y, 4 = sphere
switch result.scan_mode
case 0, result.scan_geometry = 'cubic';
case 1, result.scan_geometry = 'cyl_z';
case 2, result.scan_geometry = 'cyl_x';
case 3, result.scan_geometry = 'cyl_y';
case 4, result.scan_geometry = 'spher';
end    
result.unit_mode=fscanf(fid,'%i1');  % 0 = Tesla, 1 = Gauss
switch result.unit_mode
case 0, result.unit = 'T';
case 1, result.unit = 'G';
end
fclose(fid);



[x,y,z,B]=textread(fname,'%f %f %f %f','delimiter','\t','headerlines',7);
result.x_list=x;
result.y_list=y;
result.z_list=z;
result.B_list=B;

xmin=min(x);
xmax=max(x);
ymin=min(y);
ymax=max(y);
zmin=min(z);
zmax=max(z);
x_ax=linspace(xmin,xmax,stepx);
y_ax=linspace(ymin,ymax,stepy);
z_ax=linspace(zmin,zmax,stepz);
switch result.dimension
case 1
       result.x=x;
       result.y=y;
       result.z=z;
       result.B=B;
case 2
     if result.dim==[1,1,0]
        [result.x, result.y]=meshgrid(x_ax,y_ax);
        result.z=z;
        result.B=griddata(x,y,B,result.x, result.y);
     end
     if result.dim==[1,0,1]
        [result.x, result.z]=meshgrid(x_ax,z_ax);
        result.y=y;
        result.B=griddata(x,z,B,result.x, result.z);
     end
     if result.dim==[0,1,1]
        [result.y, result.z]=meshgrid(y_ax,z_ax);
        result.x=x;
        result.B=griddata(y,z,B,result.y, result.z);
     end
case 3
      [result.x, result.y, result.z]=meshgrid(x_ax,y_ax,z_ax);
      result.B=griddata3(x,y,z,B,result.x, result.y, result.z);
end
result.x=squeeze(result.x);
result.y=squeeze(result.y);
result.z=squeeze(result.z);
result.B=squeeze(result.B);

