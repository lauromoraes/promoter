function [TP, FP, FN, TN] = MyTest02()
%%
rootPath = fullfile('C:','Users', 'Meu computador', 'Desktop', 'Dissertação', 'codes', 'Convolutional Neural Network');
% databaseName = 'Human';
% databaseName = 'Arabidopsis_tata';
% databaseName = 'Arabidopsis_non_tata';
databaseName = 'Bacillus';
promoterDatasetPath = fullfile(rootPath,'data',databaseName);

%%
% promoterData = imageDatastore(promoterDatasetPath,'LabelSource','foldernames', ...
%     'IncludeSubfolders',true, ...
%     'FileExtensions','.png', ...
%      'ReadFcn', @readHandler);

 promoterData = imageDatastore(promoterDatasetPath,'LabelSource','foldernames', ...
    'IncludeSubfolders',true, ...
    'FileExtensions','.png');

%%
CountLabel = promoterData.countEachLabel;

%%
% rng(1) % For reproducibility
[trainPromoterData,testPromoterData] = splitEachLabel(promoterData, 0.75,'randomize');

CountLabel = trainPromoterData.countEachLabel
trainPromoterData.countEachLabel;
testPromoterData.countEachLabel

%%
sequence_length = 246;
% sequence_length = 250;
% sequence_length = 71;
% layers = [imageInputLayer([50 sequence_length 1])          
%           dropoutLayer(0.5)
%           convolution2dLayer([50 3],100,'Stride',[1 3])
%           reluLayer
%           maxPooling2dLayer([1 3],'Stride',[1 1])
% 
%           fullyConnectedLayer(250)
%           dropoutLayer(0.5)
%           
%           fullyConnectedLayer(2)
%           softmaxLayer
%           classificationLayer()];

layers = [imageInputLayer([50 sequence_length 1])

          convolution2dLayer([50 9], 250,'Stride',[1 3])
          reluLayer
          maxPooling2dLayer([1 9],'Stride',[1 3])
          
%           convolution2dLayer([1 3],50,'Stride',[1 1])
%           reluLayer
%           averagePooling2dLayer([1 3],'Stride',[1 3])
          
          fullyConnectedLayer(512)
          dropoutLayer(0.2)
          
%           fullyConnectedLayer(64)
%           reluLayer
%           dropoutLayer(0.2)
          
          fullyConnectedLayer(2)
          softmaxLayer
          classificationLayer()];  
%%
functions = { ...
    @plotTrainingAccuracy, ...
    @(info) stopTrainingAtThreshold(info,98)};

%%
% options = trainingOptions('sgdm','MaxEpochs',30, ...
% 	'InitialLearnRate',0.0001, ...
%     'OutputFcn',@plotTrainingAccuracy); 

% options = trainingOptions('sgdm','MaxEpochs',300, ...
%     'CheckpointPath','C:\Documentos', ...
%     'InitialLearnRate',0.001, ...
%     'OutputFcn',@plotTrainingAccuracy, ...
%     'LearnRateSchedule','piecewise',...
%     'LearnRateDropFactor',0.002,... 
%     'LearnRateDropPeriod',5,...
%     'MiniBatchSize',256); 

options = trainingOptions('sgdm','MaxEpochs',300, ...
    'Momentum',0.8, ...
    'InitialLearnRate',0.001, ...
    'OutputFcn',functions, ...
    'LearnRateSchedule','piecewise',...
    'LearnRateDropFactor',0.02,... 
    'LearnRateDropPeriod',10,...
    'MiniBatchSize',256); 

% , ...
%     'L2Regularization',0.005, ...
%     'LearnRateSchedule','piecewise', ...
%     'LearnRateDropFactor',0.002
%%
tic();
convnet = trainNetwork(trainPromoterData,layers,options);

%%
% Update the plot at each iteration using |plotTrainingAccuracy| and
% |stopTrainingAtThreshold|. Use the custom function |plotTrainingAccuracy|
% to plot |info.TrainingAccuracy| against |info.Iteration|. Use
% |stopTrainingAtThreshold(info,thr)| to stop training if the mean accuracy
% of the previous 50 iterations is greater than |thr|.
function plotTrainingAccuracy(info)

persistent plotObj

if info.State == "start"
    plotObj = animatedline;
    xlabel("Iteration")
    ylabel("Training Accuracy")
elseif info.State == "iteration"
    addpoints(plotObj,info.Iteration,info.TrainingAccuracy)
    drawnow limitrate nocallbacks
end

end

function stop = stopTrainingAtThreshold(info,thr)

stop = false;
if info.State ~= "iteration"
    return
end

persistent iterationAccuracy

% Append accuracy for this iteration
iterationAccuracy = [iterationAccuracy info.TrainingAccuracy];

% Evaluate mean of iteration accuracy and remove oldest entry
if numel(iterationAccuracy) == 50
    stop = mean(iterationAccuracy) > thr;
    
    iterationAccuracy(1) = [];
end

end


%%
[YTest,scores] = classify(convnet,testPromoterData);
toc()
TTest = testPromoterData.Labels;

% for i=1:size(TTest,1)
%     disp(sprintf('%s %.04f %.04f', TTest(i,1), scores(i,1), scores(i,2)));
% end

%%
accuracy = sum(YTest == TTest)/numel(TTest);
acc = accuracy;
%%
C = confusionmat(TTest, YTest);
TP = C(2,2);
FP = C(2,1);
FN = C(1,2);
TN = C(1,1);

Sensitivity = TP/(TP+FN);
Specificity = TN/(TN+FP);
    
Accuracy = (TP + TN)/(TP+FP+FN+TN);
Precision = TP/(TP+FP);
Fmeasure = (2*Precision*Sensitivity)/(Precision+Sensitivity);

CC = ((TP*TN)-(FP*FN))/sqrt((TP+FP)*(TN+FN)*(TP+FN)*(TN+FP));

disp(sprintf('CC: %.04f | F1: %.04f', CC, Fmeasure));



end
