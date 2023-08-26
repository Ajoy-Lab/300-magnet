clear;
fp = getpref('nv','SavedImageDirectory');

% image list
listing=dir(fp)
a=listing.name;
start_pos= '2DXY-Image-2014-04-19-222839';
end_pos='2DXY-Image-2014-04-20-231614';
grid=[6 3];
act_start=[5.6821 7.2217];
grid_axis_X=act_start(1):100e-9/1e-3:act_start(1)+40e-6/1e-3*grid(1);
grid_axis_Y=act_start(2):100e-9/1e-3:act_start(2)+40e-6/1e-3*grid(2);

for j=1:size(listing,1)
    if strcmp(listing(j).name,[start_pos '.mat'])
        start_pos_index=j;
    elseif  strcmp(listing(j).name,[end_pos '.mat']);
        end_pos_index=j;
    end
end

count=0;
for j=1:size(listing,1)
    if listing(j).datenum>=listing(start_pos_index).datenum && listing(j).datenum<=listing(end_pos_index).datenum && strncmp(listing(j).name,'2DXY-',5)
        count=count+1;
        smaller_list(count, :)=listing(j).name;
    end
end
        




count=0;
smaller_list_grid=cell(grid(1),grid(2));
for j=1:grid(1)*grid(2)
    smaller_list_grid{j} = smaller_list(j,:);
end

% flip the X axis
smaller_list_grid=transpose(smaller_list_grid);
smaller_list_grid=fliplr(smaller_list_grid);
grid_axis_X=fliplr(grid_axis_X);


BiggerImage=[];
for j=1:grid(1)
    BigImage=[];
    for k=1:grid(2)
        count=count+1;
        cImage = load([fp '\' smaller_list(count,:)]);
        BigImage=[BigImage cImage.Scan.ImageData];
    end
    BiggerImage=[BiggerImage;BigImage];
end

figH=1;
figure(figH);clf;
textxlabel='x (\mum)';
textylabel='y (\mum)';
imagesc(grid_axis_X,grid_axis_X,BiggerImage);
axis square;
set(gca,'YDir','normal');
h = colorbar('EastOutside');
set(get(h,'ylabel'),'String','kcps');
% 
% cutoff=10;
% cImage = load([fp '\2DXY-Image-2013-09-23-105808.mat']);
% cImage.Scan.ImageData(cImage.Scan.ImageData>cutoff) = cutoff;
% 
% argData = cImage.Scan.ImageData;
% argX=cImage.Scan.RangeX;
% argY=cImage.Scan.RangeY;
% textxlabel='x (\mum)';
% textylabel='y (\mum)';
% figH=1;
% figure(figH);clf;
% 
% imagesc(argX,argY,argData);
% axis square;
% set(gca,'YDir','normal');
% xlabel(textxlabel);
% ylabel(textylabel);
% axis([min(argX), max(argX), min(argY), max(argY)]);
% h = colorbar('EastOutside');
% set(get(h,'ylabel'),'String','kcps');