function spike_turn_on_devices(pw1,pw2,pw3,pw4,arb1,arb2,arb3,arb4,agilent_on,rigol_on2,rigol_on3,rigol_on4)
if agilent_on==1
pw1.PS_OUTOn;
arb1.MW_RFOn();
end

if rigol_on2==1
pw2.PS_OUTOn;
arb2.MW_RFOn();
end

if rigol_on3==1
pw3.PS_OUTOn;
arb3.MW_RFOn();
end

if rigol_on4==1
pw4.PS_OUTOn;
arb4.MW_RFOn();
end

end

