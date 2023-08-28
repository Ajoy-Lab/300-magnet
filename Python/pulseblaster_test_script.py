# -*- coding: utf-8 -*-
"""
Created on Thu Sep 15 17:47:50 2022

@author: qegpi
"""
import spinapi_py as sp

# Enable the log file
sp.pb_set_debug(0)

print("Copyright (c) 2015 SpinCore Technologies, Inc.");
print("Using SpinAPI Library version %s" % sp.pb_get_version())
print("Found %d boards in the system.\n" % sp.pb_count_boards())
 
print("This example program tests the TTL outputs of the PBESR-PRO-500.\n\n");
print("The main pulse program will generate a pulse train with all Flag "\
      "Bits HIGH for 200 ms and then LOW for 200 ms.\n"); 
 
sp.pb_select_board(0)

if sp.pb_init() != 0:
	print("Error initializing board: %s" % sp.pb_get_error())
	input("Please press a key to continue.")
	#exit(-1)

# Configure the core clock
sp.pb_core_clock(100)

# Program the pulse program

sp.pb_start_programming(sp.PULSE_PROGRAM)
start = sp.pb_inst_pbonly(0xFFFFFF, sp.Inst.CONTINUE, 0, 2.0 * sp.s)
sp.pb_inst_pbonly(0x0, sp.Inst.BRANCH, start, 2.0 * sp.s)
sp.pb_stop_programming()

# Trigger the board
sp.pb_reset() 
sp.pb_start()

print("Continuing will stop program execution\n");
input("Please press a key to continue.")

sp.pb_stop()
sp.pb_close()
