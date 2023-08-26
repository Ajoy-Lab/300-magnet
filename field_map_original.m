clear;
instrreset;
%% Setup magnetometer
s = serial('com3');
set(s, 'Baudrate', 57600);
set(s, 'DataBits', 7);
set(s, 'Parity', 'odd');
set(s, 'StopBits', 1);
set(s, 'FlowControl', 'none');
fopen(s);

%val=lakeshoreReadOut(s)


%% Setup ACS controller

com = actxserver('SPiiPlusCOM660.Channel.1');
com.OpenCommEthernetTCP('10.0.0.100', 701)
com.Enable(com.ACSC_AXIS_0);

com.SetVelocity(com.ACSC_AXIS_0, 10);
com.SetAcceleration(com.ACSC_AXIS_0, 100);
com.SetDeceleration(com.ACSC_AXIS_0, 100);
com.SetJerk(com.ACSC_AXIS_0, 1000);
com.SetKillDeceleration(com.ACSC_AXIS_0, 200);

com.GetFPosition(com.ACSC_AXIS_0)

%com.ToPoint(com.ACSC_AMF_RELATIVE, com.ACSC_AXIS_0, -10);



%% Go to initial position

start_pos=-1300;
curr_pos=com.GetFPosition(com.ACSC_AXIS_0);
move_vel=2;
com.SetVelocity(com.ACSC_AXIS_0, move_vel);
com.ToPoint(com.ACSC_AMF_RELATIVE, com.ACSC_AXIS_0, start_pos-curr_pos); %MOVE



com.WaitMotionEnd (com.ACSC_AXIS_0, 1000+1e3*abs(start_pos-curr_pos)/move_vel);


%% Setup parameters
end_pos = -1580;
distance=end_pos-start_pos;
vel = 0.5;

position_dwell=0.1;
points=abs(distance/position_dwell);
time=abs(distance/vel);
dwell=time/points;

position = zeros(1,points);
field = zeros(1,points);

com.SetVelocity(com.ACSC_AXIS_0, vel);

%% Start motion
com.ToPoint(com.ACSC_AMF_RELATIVE, com.ACSC_AXIS_0, distance);

for j=1:points
tstart = tic;    
position(j) = com.GetFPosition(com.ACSC_AXIS_0);
field(j) = lakeshoreReadOut(s);
telapsed(j) = toc(tstart);
pause(dwell-telapsed(j));
if position(j)>-0.5 || position(j)<-1500
    com.KillAll();break;
end

end

fclose(s);

%% Plot
figure(1);clf;plot(position,field,'ob-');

%% Send email
fp = 'D:\QEG2\21-C\SavedExperiments';
a = datestr(now,'yyyy-mm-dd-HHMMSS');
fn=['map-' a];
filename=[fp '\' fn '.mat'];
save(filename);
%send_email(fn,' ',filename);
