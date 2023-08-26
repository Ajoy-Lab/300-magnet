function [Volt] = dBm2Voltpp(dBm)

% For a 50 Ohm system

Volt = 0.632*10^(dBm/20);

