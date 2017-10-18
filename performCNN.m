function [ TP, FP, FN, TN ] = performCNN( X, Y, layers, options,   )
%PERFORMCNN Summary of this function goes here
%   Detailed explanation goes here
    [n_props, seq_length] = size(imread(X.Files{1}));
    
    
    convnet = trainNetwork(trainPromoterData,layers,options);

end

%%
% Update the plot at each iteration using |plotTrainingAccuracy| and
% |stopTrainingAtThreshold|. Use the custom function |plotTrainingAccuracy|
% to plot |info.TrainingAccuracy| against |info.Iteration|. Use
% |stopTrainingAtThreshold(info,thr)| to stop training if the mean accuracy
% of the previous 50 iterations is greater than |thr|.
function plotTrainingAccuracy(i nfo)

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

