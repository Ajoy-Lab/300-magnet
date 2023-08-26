classdef stagefunctions < handle
    
    properties
      
        NumPoints
                
    end
    
    methods
       
        function handles = refresh_stage(obj,handles)
            
            zaber_x = handles.zaber_x;
            [ret err] = ZaberReturnCurrentPosition(zaber_x, zaber_x.deviceIndex);
            set(handles.slider_x, 'Value', ret(2)*1e3);
            set(handles.Pos_x, 'String', num2str(ret(2)*1e3));
            
            zaber_y = handles.zaber_y;
            [ret err] = ZaberReturnCurrentPosition(zaber_y, zaber_y.deviceIndex);
            set(handles.slider_y, 'Value', ret(2)*1e3);
            set(handles.Pos_y, 'String', num2str(ret(2)*1e3));
        end
        
        function handles = move_stage_y(obj,handles)
            absolutePosition = str2num(get(handles.Pos_y, 'String'))*1e-3;
            zaber_y = handles.zaber_y;
            [ret err] = ZaberMoveAbsolute(zaber_y, zaber_y.deviceIndex, absolutePosition);
            set(handles.slider_y, 'Value', ret(2)*1e3);
            set(handles.Pos_y, 'String', num2str(ret(2)*1e3));
        end
        
        function handles = move_stage_x(obj,handles)
            absolutePosition = str2num(get(handles.Pos_x, 'String'))*1e-3;
            zaber_x = handles.zaber_x;
            [ret err] = ZaberMoveAbsolute(zaber_x, zaber_x.deviceIndex, absolutePosition);
            set(handles.slider_x, 'Value', ret(2)*1e3);
            set(handles.Pos_x, 'String', num2str(ret(2)*1e3));
        end

    end
end

