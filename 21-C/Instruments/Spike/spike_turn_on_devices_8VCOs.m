function spike_turn_on_devices_8VCOs(pw1,pw2,pw3,pw4,pw5,pw6,pw7,pw8,arb1,arb2,arb3,arb4,arb9,arb10,arb11,arb12,agilent_on,rigol_on2,rigol_on3,rigol_on4,rigol_on5,rigol_on6,rigol_on7,rigol_on8)
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

if rigol_on5==1
pw5.PS_OUTOn;
arb9.MW_RFOn();
end

if rigol_on6==1
pw6.PS_OUTOn;
arb10.MW_RFOn();
end

if rigol_on7==1
pw7.PS_OUTOn;
arb11.MW_RFOn();
end

if rigol_on8==1
pw8.PS_OUTOn;
arb12.MW_RFOn();
end

end

