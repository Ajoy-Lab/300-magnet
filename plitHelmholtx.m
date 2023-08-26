load('test08-22-2018-12-31.mat')
% currTotal = -current;
% BzTotal = -Bz;


currTotal = [];
BzTotal = [];
load('test08-22-2018-12-24.mat')
currTotal = [currTotal current];
BzTotal = [BzTotal -Bz];


figure(3);
hold on;
box on;
plot(currTotal,BzTotal,'-ob', 'Linewidth',1.5);

set(gca,'linewidth',1.5);
xlabel('Current (A)');
ylabel('Magnetic Field (G)');
set(gca,'FontSize',14);
legend('Bz','Location', 'Northwest');

%fit line
coefs = polyfit(currTotal,BzTotal,1);
%plot it, use polyval to calcualte function values of that fit
% plot(-5:0.1:5,polyval(coefs,-5:0.1:5),'-')
plot(0:0.1:5,polyval(coefs,0:0.1:5),'-')