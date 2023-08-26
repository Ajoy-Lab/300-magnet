function [rOK,rOU]=sample_stoch_noise(variance,tauC,StepSize,timesteps,realizations)
% function [rOK,rOU]=sample_stoch_noise(variance,tauC,StepSize,timesteps,realizations)
%
% This function samples a stochastic noise distribution
% at fixed time intervals (dt) for /timesteps/ number of points and /realizations/ realizations
% - rOK is the outcome for a stochastic process with 
% correlation function G(dt)=<rOK(t)*rOK(t+dt)>=variance*exp(-dt/tauC),
% - rOU is the outcome for  a Ornstein-Uhlenbeck (OU) process with the  correlation function
% G(dt)=<rOU(t)*rOU(t+dt)>=sqrt(tauC/2)*variance*exp(-dt/tauC)
%
% The solution to the OU random process equation is the following:
%$ S_{i+1} =S_i  e^{-t/\tau_c}+\mu(1-e^{-t/\tau_c}) +\sigma\sqrt{\frac12(\tau_c(1-e^{-2t/\tau_c})} N_{0,1} $
% where N_{0,1} is a normally distributed random number. 
%
% This gives the formula for rOU. However, this results in a zero variance at the beginning, which rises to the correct one only after some time.
% rOK instead has the correct variance from the beginning.

dt=StepSize;
t=dt/tauC;
rOK=zeros(realizations,timesteps);
r=randn(realizations,timesteps) ;
s=sqrt(1-exp(-2*t));
ee=exp(-t);
ss=sqrt(variance*tauC/2);

rOK(:,1)=r(:,1);
rOU=rOK;
for k=2:timesteps   
   rOK(:,k)=ee*rOK(:,k-1)+r(:,k)*s; 
   rOU(:,k)=ee*rOU(:,k-1)+r(:,k)*s*ss; 
end

rOK=sqrt(variance)*rOK;
