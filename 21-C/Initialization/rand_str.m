function str=rand_str(nc)
temp=randi([0 1],[1,nc],'int8');
str='[';
str=[str num2str(temp,'''%i'', ')];
str=str(1:end-1);
str=[str ']'];
end