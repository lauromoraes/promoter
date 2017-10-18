%%

%%
exampleType = 0;

rootPath = fullfile('C:','Users', 'Meu computador', 'Desktop', 'Dissertação', 'codes', 'Convolutional Neural Network');
% rootPath = fullfile('C:','Users', 'Meu computador', 'Desktop', 'Dissertação', 'codes');

% databaseName = 'Arabidopsis_tata';
% databaseName = 'Arabidopsis_non_tata';
% databaseName = 'Human';
% databaseName = 'Bacillus';
databaseName = 'Ecoli';

if exampleType == 1
    promoterPositiveDatasetPathTmp = fullfile(rootPath,'data',databaseName,'pos');
    cd(promoterPositiveDatasetPathTmp);
else
    promoterNegativeDatasetPathTmp = fullfile(rootPath,'data',databaseName,'neg');
    cd(promoterNegativeDatasetPathTmp);
end

%%
F = dir('*.dat');

M = csvread(F(1).name);
numSamples = size(M,1);
%%
sequence_length = size(M,2);
samples = zeros(numSamples,sequence_length,50);

%%
for j=1:length(F)
    M = csvread(F(j).name);
    disp(size(M))
    for i = 1:sequence_length
        limInf = min(M(:, i));
        limSup = max(M(:, i));
        denom = limSup - limInf;
        M(:, i) = (M(:, i) - limInf) / denom;
    end
    disp(j);
%     disp(size(samples));
%     disp(size(M));
    samples(:, :, j) = M;
%     disp(imgs(:, :, j));
%     disp('=========');
end
%%
pIni=140;
pVar=30;
lenSeq=70;

for i=1:numSamples
    if exampleType == 1
        % select sample
        s = squeeze(samples(i, :, :));
        s = s';
        
        % generate derived sample 01
        fname = sprintf('positive-%06d.png', i);
        imwrite(s(:, :), fname);
%         % generate derived sample 02
%         fname = sprintf('positive-%06d.png', 2*i);
%         pTmp=randi(pVar);
%         imwrite(s(:, pIni+pTmp:pIni+pTmp+lenSeq), fname);
%         % generate derived sample 03
%         fname = sprintf('positive-%06d.png', 3*i);
%         pTmp=randi(pVar);
%         imwrite(s(:, pIni+pTmp:pIni+pTmp+lenSeq), fname);
        
    else
        % select sample
        s = squeeze(samples(i, :, :));
        s = s';
        
        % generate derived sample 01
        fname = sprintf('negative-%06d.png', i);
        imwrite(s(:, :), fname);
%         % generate derived sample 02
%         fname = sprintf('negative-%06d.png', 2*i);
%         pTmp=randi(pVar);
%         imwrite(s(:, pIni+pTmp:pIni+pTmp+lenSeq), fname);
%         % generate derived sample 03
%         fname = sprintf('negative-%06d.png', 3*i);
%         pTmp=randi(pVar);
%         imwrite(s(:, pIni+pTmp:pIni+pTmp+lenSeq), fname);
    end
%     
%     s(:,:) = samples(i, :, :);
%     imwrite(s', fname);
end



