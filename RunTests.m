M = [];
num_exp = 1;
for i=1:num_exp
    [TP, FP, FN, TN] = MyTest02();
    M = [M; [TP, FP, FN, TN]];
    close all;
end

for i=1:num_exp
    disp(sprintf('%d, %d, %d, %d', M(i,1), M(i,2), M(i,3), M(i,4)));
end




