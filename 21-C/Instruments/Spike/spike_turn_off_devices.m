function spike_turn_off_devices(pw1,pw2,pw3,pw4,arb1,arb2,arb3,arb4)

pw1.PS_OUTOff;
pw2.PS_OUTOff;
pw3.PS_OUTOff;
pw4.PS_OUTOff;

arb1.MW_RFOff();
arb2.MW_RFOff();
arb3.MW_RFOff();
arb4.MW_RFOff();

end

