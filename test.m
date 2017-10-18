values = [];
for i=1:10
    acc = MyTest02();
    figure();
    values = [values acc];
    
end

disp(mean(values));