close all
clear
clc
%%
train_portion = 0.8;
%% Get data
importfile(uigetfile('D:\Drive\desktop\research\shape_tracking\data\automated\*.mat'));
N = length(data);
Xs = data(:,1:3);
ys = data(:,4:5);
pos_list = unique(data(:,4));

%% Pre-process data set
shuffled = data(randperm(N),:);
train_test_cutoff = floor(N*train_portion);
train_data = shuffled(1:train_test_cutoff-1,:);
test_data = shuffled(train_test_cutoff:end,:);
y_train = train_data(:,4:5);
y_test = test_data(:,4:5);
X_train = train_data(:,1:3);
X_test = test_data(:,1:3);
%% MISO1
disp("MISO 1:");
[regressor_miso1, valid_rmse_miso1] = trainBiaxialDataSingleTargetRegressionModel(train_data,1);%Regenerate these functions using the learner apps, whenever making changes to code
[bias_miso1,std_dev_miso1,y_hat_miso1] = predict(regressor_miso1,X_test,y_test(:,1));
%% MISO2
disp("MISO 2:");
[regressor_miso2, valid_rmse_miso2] = trainBiaxialDataSingleTargetRegressionModel(train_data,2);%Regenerate these functions using the learner apps, whenever making changes to code
[bias_miso2,std_dev_miso2,y_hat_miso2] = predict(regressor_miso2,X_test,y_test(:,2));

%% Non-coupled pre-processing
data_1 = data(data(:,5)==512,[1,2,3,4]);
data_2 = data(data(:,4)==512,[1,2,3,5]);
N1 = length(data_1);
N2 = length(data_2);
shuffled_1 = data_1(randperm(N1),:);
train_test_cutoff = floor(N1*train_portion);
train_data_1 = shuffled_1(1:train_test_cutoff-1,:);
test_data_1 = shuffled_1(train_test_cutoff:end,:);
shuffled_2 = data_2(randperm(N2),:);
train_test_cutoff = floor(N2*train_portion);
train_data_2 = shuffled_2(1:train_test_cutoff-1,:);
test_data_2 = shuffled_2(train_test_cutoff:end,:);
y_train_1 = train_data_1(:,4);
y_test_1 = test_data_1(:,4);
X_train_1 = train_data_1(:,1:3);
X_test_1 = test_data_1(:,1:3);
y_train_2 = train_data_2(:,4);
y_test_2 = test_data_2(:,4);
X_train_2 = train_data_2(:,1:3);
X_test_2 = test_data_2(:,1:3);
%% SISO 1
disp("SISO 1:");
[regressor_siso1, valid_rmse_siso1] = trainUnivariateRegressionModel(train_data_1);%Regenerate these functions using the learner apps, whenever making changes to code
[bias_siso1,std_siso1,y_hat_siso1] = predict(regressor_siso1,X_test_1,y_test_1);
%% SISO 2
disp("SISO 2:");
[regressor_siso2, valid_rmse_siso2] = trainUnivariateRegressionModel(train_data_2);%Regenerate these functions using the learner apps, whenever making changes to code
[bias_siso2,std_siso2,y_hat_siso2] = predict(regressor_siso2,X_test_2,y_test_2);
%% SIMO 1
disp("SIMO 1:");
[bias_simo1,std_simo1,y_hat_simo1] = predict(regressor_siso1,X_test,y_test(:,1));

%% SIMO 2
disp("SIMO 2:");
[bias_simo2,std_simo2,y_hat_simo2] = predict(regressor_siso2,X_test,y_test(:,2));
%% MIMO
disp("MIMO:");
beta = mvregress(X_train,y_train);
y_hat_mimo = X_test*beta;
errors_1 = y_hat_mimo - y_test;
errors_mimo = mean(errors_1,2);
bias_mimo = mean(errors_mimo);
stdev_mimo = std(errors_mimo);
figure
histfit(errors_mimo);
xlabel("Position error")
ylabel("Number of test samples")
title("Distribution of errors for position classification")
disp("Prediction bias: "+bias_mimo);
disp("Prediction standard deviation: "+stdev_mimo);
disp("");
disp("");
%% MIMO Control
disp("MIMO Control:");
y_control = 512*ones(size(y_test));
err_control = y_control - y_test;
errors_control = mean(err_control,2);
bias_control = mean(errors_control);
stdev_control = std(errors_control);
figure
histfit(errors_control);
xlabel("Position error")
ylabel("Number of test samples")
title("Distribution of errors for position classification")
disp("Prediction bias: "+bias_control);
disp("Prediction standard deviation: "+stdev_control);
disp("");
disp("");