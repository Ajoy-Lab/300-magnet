com = actxserver('SPiiPlusCOM660.Channel.1');
com.OpenCommEthernetTCP('10.0.0.100', 701)
com.Enable(com.ACSC_AXIS_0);

vel=com.GetVelocity(com.ACSC_AXIS_0)
com.SetVelocityImm(com.ACSC_AXIS_0, 10)
vel=com.GetVelocity(com.ACSC_AXIS_0)

acc= com.GetAcceleration(com.ACSC_AXIS_0)
com.SetAcceleration(com.ACSC_AXIS_0, 100)
acc= com.GetAcceleration(com.ACSC_AXIS_0)

dec= com.GetDeceleration(com.ACSC_AXIS_0)
com.SetDeceleration(com.ACSC_AXIS_0, 100)
dec= com.GetDeceleration(com.ACSC_AXIS_0)

com.SetJerk(com.ACSC_AXIS_0, 1000)
com.SetKillDeceleration(com.ACSC_AXIS_0, 200)

com.GetFPosition(com.ACSC_AXIS_0)

com.ToPoint(com.ACSC_AMF_RELATIVE, com.ACSC_AXIS_0, 650); %Perform a relative move.

%com.KillAll()

%

%Line 1 creates a COM object named "com" and references the ACS COM library
%Line 2 opens EthernetTCP communications with the controller
%Line 3 Enables axis 1, to enable axis 0 use com.ACSC_AXIS_0
%Line 4 makes a relative move of 25 units on axis 1





