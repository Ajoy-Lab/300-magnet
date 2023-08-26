function circlock
%CIRCLOCK  Circle Clock
% Displays the clock time using 4 circles
%     Red circle is fixed
%     Blue circle moves with hours
%     Green circle moves with minutes
%     Black circle moves with seconds
% 
% Controls:
%     Click on 'Display' -> 'Time String' to view the clock time
%
% Example:
%   circlock; %start the clock
%
% Author: Joseph Kirk
% Email: jdkirk630 at gmail dot com
% Release: 1.1
% Release Date: 6/12/07

% create the figure window
figure('Name','Circle Clock', ...
    'NumberTitle','off', ...
    'MenuBar','none', ...
    'Position',[300 200 450 450], ...
    'Color','w', ...
    'Visible','on', ...
    'DoubleBuffer','on', ...
    'CloseRequestFcn',@closeRequestFcn);
displaymenu = uimenu('Label','Display');
uimenu(displaymenu,'Label','Time String','Callback',@displayTimeFcn);

% draw the outer clock circle
display_time_flag = 0;
t = linspace(0,2*pi,100);
xcir = cos(t);
ycir = sin(t);
plot(8*xcir,8*ycir,'r','LineWidth',4);
axis([-9 9 -9 9]);
axis equal off
hold on

% initialize the clock display
time = clock;
getCircleXY(time);
hcircle = patch(hx,hy,'w','EdgeColor','b','LineWidth',3);
mcircle = patch(mx,my,'w','EdgeColor','g','LineWidth',2);
scircle = patch(sx,sy,'w','EdgeColor','k','LineWidth',1);
time_str = getTimeStr(time);
time_display = text(-2,10,time_str,'FontSize',16,'Visible','off');
hold off;
set(gcf,'HandleVisibility','off');

% start the timer
htimer = timer('TimerFcn',@timerFcn,'Period',0.1,'ExecutionMode','FixedRate');
start(htimer);

    function timerFcn(varargin)
        % update the clock time
        time = clock;
        getCircleXY(time);
        set(hcircle,'Xdata',hx,'Ydata',hy);
        set(mcircle,'Xdata',mx,'Ydata',my);
        set(scircle,'Xdata',sx,'Ydata',sy);
        if display_time_flag
            time_str = getTimeStr(time);
            set(time_display,'String',time_str,'Visible','on');
        else
            set(time_display,'Visible','off');
        end
    end

    function getCircleXY(time)
        % parse the time vector
        s = time(6);
        m = time(5)+s/60;
        h = time(4)+m/60;
        % calculate the circle center positions
        hxc = 4*sin(h*pi/6); hyc = 4*cos(h*pi/6);
        mxc = hxc+2*sin(m*pi/30); myc = hyc+2*cos(m*pi/30);
        sxc = mxc+sin(s*pi/30); syc = myc+cos(s*pi/30);
        % calculate the x/y vectors
        hx = hxc + 4*xcir; hy = hyc + 4*ycir;
        mx = mxc + 2*xcir; my = myc + 2*ycir;
        sx = sxc + xcir; sy = syc + ycir;
    end

    function time_str = getTimeStr(time)
        % format the string as h:mm:ss
        hh = sprintf('%1.0f:',mod(time(4)-1,12)+1);
        if time(5) < 10
            mm = sprintf('0%1.0f:',time(5));
        else
            mm = sprintf('%1.0f:',time(5));
        end
        sec = floor(time(6));
        if sec < 10
            ss = sprintf('0%1.0f',sec);
        else
            ss = sprintf('%1.0f',sec);
        end
        time_str = [hh mm ss];
    end

    function displayTimeFcn(varargin)
        % toggle the time display
        display_time_flag = ~display_time_flag;
    end

    function closeRequestFcn(varargin)
        % stop the timer
        try
            stop(htimer)
            delete(htimer)
        catch
        end
        % close the figure window
        closereq
    end
end
