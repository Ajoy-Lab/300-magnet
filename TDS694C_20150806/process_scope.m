clear;
load scope-2016-05-04-155649.mat
for j=1:size(scope,2)
    trace(j,:)=scope{j}.scaleYperPoint*scope{j}.trace';
    trace_x(j,:)= 0:scope{j}.scaleXperPoint:scope{j}.scaleXperPoint*(size(scope{j}.trace',2)-1);
    maxtrace(j)=max(trace(j,:));
end
figure(10);plot(maxtrace,'ob-')