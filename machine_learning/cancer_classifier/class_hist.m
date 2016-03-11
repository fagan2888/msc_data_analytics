% Predict bowel cancer from tissue samples using the following predictors: 
% radius, texture, perimeter, area, smoothness, compactness,
% area−1 concavity, concave points, symmetry, fractal dimension


%% Look at the density distribution
% Plot Histograms
close all; clear; clc;
for i = 1:30              % we have 30 predictors
    subplot(5, 6, i)      % creates a 5 x 6 figure
    class1 = cancer.outputs==0;  % index for class 1;
    class2 = cancer.outputs==1;  % index for class 2;
    histogram(cancer.input(class1, i), 'facecolor', 'b' )
    hold on;
    histogram(cancer.inputs(class2, i), 'facecolor', 'r' )
    title({i})
    ylabel( 'Frequency' )
end
legend('Class 1','Class 2')
