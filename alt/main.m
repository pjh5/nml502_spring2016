clc;

%% Read in data
rawData = csvread('../fullestfeatures.csv',1);

% Dimensions
PERCENT_TRAINING = 0.7
[M, ~] = size(rawData);
n_train = round(PERCENT_TRAINING * M);

% Split data into train and test
rawData = rawData(randperm(M), :);
Xraw = rawData(:, 2:end);
Yraw = rawData(:, 1);
Yraw = index_to_vector(Yraw, max(max(Yraw)));

% Scaling Functions
scale = 0.85;
[f_scalex, f_unscalex] = scaling_functions(Xraw, scale, true);
[f_scaley, f_unscaley] = scaling_functions(Yraw, scale, false);

% Split up data into sets
X_train = f_scalex(Xraw(          1:n_train, :));
X_test  = f_scalex(Xraw((n_train+1):end    , :));
Y_train = f_scaley(Yraw(          1:n_train, :));
Y_test  = f_scaley(Yraw((n_train+1):end    , :));

%% Training Parameters
K = M;
max_epochs = 1000;
learning_rate = 0.03;
momentum = 0.9;
tolerance = 0.01;
N_hid = 10;
w_max = 0.1;
bplearn_params = [K, max_epochs, learning_rate, momentum, ...
    tolerance, N_hid, w_max];

% Error Function
f_per_acc = @(output, desired) 1 - classification_accuracy(output, desired);


%% Train Network
log_file = fopen(['logs/bplearn_', num2str(N_hid), '_', ...
    num2str(learning_rate), '_', num2str(momentum), '_', ...
    num2str(max_epochs), '.txt'], 'w');
[W_1, W_2, train_e, test_e, s_epochs, steps] = ...
    BPlearn(data_sets, bplearn_params, f_per_acc, log_file);
fclose(log_file);


%% Display Results

% Learning curves
figure;
plot(s_epochs * K, train_e, 'linewidth', 3);
hold on;
plot(s_epochs * K, test_e, 'linewidth', 3);
hold off;
title('Learning History', 'fontsize', 16)
xlabel('Learning Step', 'fontsize', 16)
ylabel('Percent Misclassification', 'fontsize', 16)
legend({'Training Error', 'Test Error'})
print(['learn_history_' num2str(N_hid), '_', ...
    num2str(learning_rate), '_', ...
    num2str(momentum), '_', num2str(max_epochs), '.png'], '-dpng');


% Confusion matrices
train_confusion_mat = confusion_matrix(...
    Y_train, BPrecall(X_train, Y_train, W_1, W_2, f_per_acc));
test_confusion_mat = confusion_matrix(...
    Ytest, BPrecall(Xtest, Ytest, W_1, W_2, f_per_acc));

% Print confusion matrices
fprintf('\n\n Training Data Confusion Matrix:\n');
disp(train_confusion_mat);
fprintf('\n Testing Data Confusion Matrix:\n');
disp(test_confusion_mat);

confusion_file = fopen(['logs/cmat_', num2str(N_hid), '_', ...
        num2str(learning_rate), '_', num2str(momentum), '.txt'], 'w');
fprintf(confusion_file, 'Training Data Confusion Matrix:\n');
print_matrix(confusion_file, train_confusion_mat);
fprintf(confusion_file, '\nTest Data Confusion Matrix:\n');
print_matrix(confusion_file, test_confusion_mat);
fclose(confusion_file);
