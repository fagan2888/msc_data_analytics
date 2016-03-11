function [predictedLabel, performance] = knn_classifier(inputs, outputs)

% Normalise Data 
% 1 -> subtract mean
normData = bsxfun( @minus, inputs, nanmean(data) );
% 1 -> divide by standard deviation
normData = bsxfun( @rdivide, normData, nanstd(normData) );


% Make sure data are ok
% e.g. treat the missing values appropriately
% Think about removing, interpolating etc. 
okIndex = ~ any( isnan(inputs), 2 ); % Rows without NaN
class = outputs(okIndex);
data = normData(okIndex,:);


% Split Training vs Testing Data
% Classifier 1: K-NN classification
foldIndex = crossvalind( 'Kfold', length(class), 3 );
performances = 0
for i = 1:3
    TestData = data( foldIndex==i, : );
    TestLabels = class( foldIndex==i );
    TrainData = data( foldIndex~=i, : );
    TrainLabels = class( foldIndex~=i );
    
% Important: Remember to check different values of K
clc;
knnModel = fitcknn( TrainData , TrainLabels , 'NumNeighbors', 3); % 'NumNeighbors' is the K
predictedLabel = predict( knnModel, TestData );
% Alternatively, you can use 'rbf' or 'polynomial' kernels
performance = sum( predictedLabel == TestLabels ) / length( TestLabels ) * 100; % correctly predicted / all predictions
end

display( [ 'KNN Prediction Performance: ' num2str( performance, 3) '%' ] );


% perf = 95.3%