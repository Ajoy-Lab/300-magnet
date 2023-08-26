function [Volt] = dBm2Volt(dBm)

% For a 50 Ohm system

Volt = 0.2236*10^(dBm/20);

