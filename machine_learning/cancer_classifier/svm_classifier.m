function [predictedLabel, performance] = svm_classifier(inputs, outputs)

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


% Classifier 2: Support Vector Machines
foldIndex = crossvalind( 'Kfold', length(class), 3 );
for i = 1:3
    TestData = data( foldIndex==i, : );
    TestLabels = class( foldIndex==i );
    TrainData = data( foldIndex~=i, : );
    TrainLabels = class( foldIndex~=i );
    
% You can also use weights based on distance using: 'DistanceWeight','inverse'
clc;
bayesModel = fitcsvm( TrainData , TrainLabels , 'KernelFunction', 'linear'); 
predictedLabel = predict( bayesModel, TestData );
performance = sum( predictedLabel == TestLabels ) / length( TestLabels ) * 100;
end

display( [ 'SVM Prediction Performance: ' num2str( performance, 3) '%' ] );

% perf = 97.4%