s1 = serial('COM3');
fopen(s1)
%fwrite(s1,'%X','A03413831155')
a=hexToBinaryVector(A03413831155)