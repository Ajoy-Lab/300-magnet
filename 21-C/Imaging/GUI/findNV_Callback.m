function handles= findNV_Callback(hObject, ~, handles)
%findNV();
%Gimg=rgb2gray(handles.ConfocalScanDisplayed.ImageData);
Gimg=handles.ConfocalScanDisplayed.ImageData;
xax=handles.ConfocalScanDisplayed.RangeX;
yax=handles.ConfocalScanDisplayed.RangeY;

BW=Gimg>str2double(get(handles.cutoffEdit, 'String'));
rp=regionprops(BW,Gimg,'WeightedCentroid');
count=0;
nv_pos_x=[];
nv_pos_y=[];
for j=1:size(rp,1)
    nv_pos_x_temp=xax(floor(rp(j).WeightedCentroid(1)));
    nv_pos_y_temp=yax(floor(rp(j).WeightedCentroid(2)));
    if nv_pos_x_temp>=str2num(get(handles.minX,'String')) && nv_pos_x_temp<=str2num(get(handles.maxX,'String')) && nv_pos_y_temp>=str2num(get(handles.minY,'String')) && nv_pos_y_temp<=str2num(get(handles.maxY,'String'))
        count=count+1;
        nv_pos_x(count)= nv_pos_x_temp;
        nv_pos_y(count)= nv_pos_y_temp;
    end
end    

%handles.ImagingFunctions.LoadImagesFromScan(handles);
%filterButton_Callback(1,2,handles)
hold (handles.imageAxes,'on');
scatter(handles.imageAxes,nv_pos_x,nv_pos_y);
hold (handles.imageAxes,'off');
handles.nv_pos_x = nv_pos_x;
handles.nv_pos_y = nv_pos_y;
handles.nv_pos_z = handles.ConfocalScanDisplayed.RangeZ;
guidata(hObject, handles);
end