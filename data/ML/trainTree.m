% Auto-generated in MATLAB

function [trainedModel, validationRMSE] = trainTree(trainingData)
inputTable = array2table(trainingData, 'VariableNames', {'column_1', 'column_2'});

predictorNames = {'column_1'};
predictors = inputTable(:, predictorNames);
response = inputTable.column_2;
isCategoricalPredictor = [false];

% Train a regression model
% This code specifies all the model options and trains the model.
regressionTree = fitrtree(...
    predictors, ...
    response, ...
    'MinLeafSize', 4, ...
    'Surrogate', 'off');

% Create the result struct with predict function
predictorExtractionFcn = @(x) array2table(x, 'VariableNames', predictorNames);
treePredictFcn = @(x) predict(regressionTree, x);
trainedModel.predictFcn = @(x) treePredictFcn(predictorExtractionFcn(x));

% Add additional fields to the result struct
trainedModel.RegressionTree = regressionTree;
trainedModel.About = 'This struct is a trained model exported from Regression Learner R2023a.';
trainedModel.HowToPredict = sprintf('To make predictions on a new predictor column matrix, X, use: \n  yfit = c.predictFcn(X) \nreplacing ''c'' with the name of the variable that is this struct, e.g. ''trainedModel''. \n \nX must contain exactly 1 columns because this model was trained using 1 predictors. \nX must contain only predictor columns in exactly the same order and format as your training \ndata. Do not include the response column or any columns you did not import into the app. \n \nFor more information, see <a href="matlab:helpview(fullfile(docroot, ''stats'', ''stats.map''), ''appregression_exportmodeltoworkspace'')">How to predict using an exported model</a>.');

% Extract predictors and response
% This code processes the data into the right shape for training the
% model.
% Convert input to table
inputTable = array2table(trainingData, 'VariableNames', {'column_1', 'column_2'});

predictorNames = {'column_1'};
predictors = inputTable(:, predictorNames);
response = inputTable.column_2;
isCategoricalPredictor = [false];

% Perform cross-validation
partitionedModel = crossval(trainedModel.RegressionTree, 'KFold', 5);

% Compute validation predictions
validationPredictions = kfoldPredict(partitionedModel);

% Compute validation RMSE
validationRMSE = sqrt(kfoldLoss(partitionedModel, 'LossFun', 'mse'));
