function [hObject,handles] = HelmholtzCoilQA(hObject,handles)
%% CLOSE ALL OPEN PORTS
serialObj = instrfind;
s=size(serialObj);
for i=1:s(1,2)
fclose(serialObj(i));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP Power supply        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
psu=Prog_Supply('COM6');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP Lakeshore GaussMeter        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
s = InitializeLakeshore();

Bz = 0;

%% START
    psu.PS_CurrSet(0);
    psu.PS_OUTOn();
    % current = 0;
    counter = 1;
    figure(1);
    hold on;
    box on;
for i = 0:0.1:5
    %Adjust field with helmholtz coil
    helmholtz_current = fix(i*1000)/1000;
    psu.PS_CurrSet(abs(helmholtz_current));
    pause(2);
    
    Bz(counter) = lakeshoreReadOut(s);
   
    current(counter) = i;
    
    plot(i,Bz(counter),'-ob', 'Linewidth',1.5);

    counter = counter + 1;
   
    
end
    
psu.PS_OUTOff();
fclose(s);

figure(2);
hold on;
box on;

plot(current,Bz,'-ob', 'Linewidth',1.5);

set(gca,'linewidth',1.5);
xlabel('Current (A)');
ylabel('Magnetic Field (G)');
set(gca,'FontSize',14);
legend('Bz','Location', 'Northwest');
filename = ['test' datestr(now,'mm-dd-yyyy-HH-MM') '.mat'];
save(filename,'current','Bz');

end
