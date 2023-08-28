

name_base = "laser_loop_All_Nine_TWO_NMR_AWG_symm_tof_opower"
name_combos = "combos"

base_f = open(name_base+".xml","r")
base_text = base_f.read()
split_base = base_text.split("$$$$$")

combos_f = open(name_combos,"r")
combos_text = combos_f.read()
split_combos = combos_text.split("$$$$$")

for i in range(0,len(split_combos)-1):
    exp_name = name_base+str(i)+".xml"
    print(exp_name)
    exp_f = open(exp_name,"w")
    file_text = split_base[0]+split_combos[i]+split_base[1]
    exp_f.write(file_text)
    exp_f.close()
    
base_f.close()
combos_f.close()