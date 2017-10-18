function M = readHandler( file_name )
%READHANDLER Summary of this function goes here
%   Detailed explanation goes here
    M = imread(file_name);
    if size(M,2)==251
        M = M(:, 170:240);
    else
        M = M(:, 1:79);
    end
%     disp(size(M));
end

