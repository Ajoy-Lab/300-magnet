function result_seq = add_OUnoise_on_pulse(seq,noisevcthislength,Aux)

noise_Ampmod=[zeros(1,Aux) noisevcthislength];

aux3 = seq.Channels(2).Ampmod+noise_Ampmod;
seq.Channels(2).Ampmod =  min(max(aux3,-1),1);

result_seq = seq;

end

