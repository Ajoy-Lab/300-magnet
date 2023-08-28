# -*- coding: utf-8 -*-
"""
Created on Mon Oct  3 15:23:24 2022

@author: qegpi
"""
import socket
def Sage_write(vals):
    UDP_IP = "192.168.1.4";
    UDP_PORT = 9090;
    MESSAGE = vals.encode();
    
    # print("UDP target IP: %s" % UDP_IP)
    # print("UDP target port: %s" % UDP_PORT)
    # print("message: %s" % MESSAGE)
    
    sock = socket.socket(socket.AF_INET, # Internet
                         socket.SOCK_DGRAM) # UDP
    sock.sendto(MESSAGE, (UDP_IP, UDP_PORT));