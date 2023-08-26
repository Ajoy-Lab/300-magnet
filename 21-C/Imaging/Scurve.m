
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
%% Go to initial position

start_pos=1;
curr_pos=com.GetFPosition(com.ACSC_AXIS_0);
move_vel=1;
com.SetVelocity(com.ACSC_AXIS_0, move_vel);
com.ToPoint(com.ACSC_AMF_RELATIVE, com.ACSC_AXIS_0, start_pos-curr_pos); %MOVE



com.WaitMotionEnd (com.ACSC_AXIS_0, 1000+1e3*abs(start_pos-curr_pos)/move_vel);
%S-curve trajectory.
%Only call after bringing rod to start position.
vel_max=10;
total_time = 20000;
coord_1=-10;
vel_1=vel_max;
coord_2=-90;
vel_2=vel_max;
coord_3=-160;  %end point
vel_3 = 0;
com.SetVelocity(com.ACSC_AXIS_0, 15);
com.SetAcceleration(com.ACSC_AXIS_0, 2);
com.SetDeceleration(com.ACSC_AXIS_0, 2);
com.SetJerk(com.ACSC_AXIS_0, 10);
com.ToPoint(com.ACSC_AMF_WAIT, com.ACSC_AXIS_0, coord_3);
com.Go(com.ACSC_AXIS_0);

%plot

%% Setup parameters

end_pos = -160;
distance=end_pos-start_pos;
vel = 15;

position_dwell=0.05;
points=abs(distance/position_dwell);
time=abs(distance/vel);
dwell=time/points;

position = zeros(1,points);

%% Run

vel_max=10;
total_time = 20000;
coord_1=-10;
vel_1=vel_max;
coord_2=-90;
vel_2=vel_max;
coord_3=-160;  %end point
vel_3 = 0;
com.SetVelocity(com.ACSC_AXIS_0, 15);
com.SetAcceleration(com.ACSC_AXIS_0, 2);
com.SetDeceleration(com.ACSC_AXIS_0, 2);
com.SetJerk(com.ACSC_AXIS_0, 10);
com.ToPoint(com.ACSC_AMF_WAIT, com.ACSC_AXIS_0, coord_3);
com.Go(com.ACSC_AXIS_0);




%% 

% i = 1;
% while i < 60
%     pause(.1);
%     com.GetFPosition(com.ACSC_AXIS_0)
%     i = i + 1;
% end
    

com.Spline(com.ACSC_AMF_CUBIC, com.ACSC_AXIS_0, 12000);
%com.AddPVPoint(com.ACSC_AXIS_0, coord_1, vel_1);
com.AddPVPoint(com.ACSC_AXIS_0, coord_3, vel_3);
com.EndSequence(com.ACSC_AXIS_0);
com.Go(com.ACSC_AXIS_0);

com.SetVelocity(com.ACSC_AXIS_0, 0)
com.GetVelocity(com.ACSC_AXIS_0)

com.SetOutput(0, 1, 1);
com.GetOutput(0, 1);





