function spike_turn_off_devices_8VCOs(pw1,pw2,pw3,pw4,pw5,pw6,pw7,arb1,arb2,arb3,arb4,arb9,arb10,arb11,arb12)

pw1.PS_OUTOff;
pw2.PS_OUTOff;
pw3.PS_OUTOff;
pw4.PS_OUTOff;
% pw5.PS_OUTOff;
% pw6.PS_OUTOff;
% pw7.PS_OUTOff;
%pw8.PS_OUTOff;

arb1.MW_RFOff();
arb2.MW_RFOff();
arb3.MW_RFOff();
arb4.MW_RFOff();
% arb9.MW_RFOff();
% arb10.MW_RFOff();
% arb11.MW_RFOff();
% arb12.MW_RFOff();

end

