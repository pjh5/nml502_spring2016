%%
%% Tries to learn the mapping from X to y
%%
%% X    a matrix whose ith row is input vector i
%% Y    a matrix whose ith row is output vector i
function [W_1, W_2, train_e, test_e, s_epochs, steps] = ...
    BPlearn(data_sets, params, f_error, log_file)

    %% Unpack Sets
    X = data_sets{1};
    Y = data_sets{2};
    Xt = data_sets{3};
    Yt = data_sets{4};

    %% Initialize variables
    [M,x_dim] = size(X);
    [~,y_dim] = size(Y);
    
    %% Unpack learning parameters
    K = params(1);
    max_epochs = params(2);
    learn_rate = params(3);
    momentum = params(4);
    tolerance = params(5);
    N_hidden = params(6);
    w_max = params(7);
   
    %% Weight Matrices
    rand_weight = @(m, n) 2*w_max*rand(m, n) - w_max;
    W_1 = rand_weight(N_hidden, x_dim + 1);
    W_2 = rand_weight(y_dim, N_hidden + 1);
    W_1p = zeros(size(W_1));
    W_2p = zeros(size(W_2));
    
    %% Error matrices
    s_epochs = round(linspace(1,max_epochs,min(100, max_epochs)));
    train_e = zeros(1, numel(s_epochs));
    test_e = zeros(1, numel(s_epochs));
    samples_taken = 0;

    % Log stuff
    fprintf('Starting to train...\n');
    %num_output_dots = 0;
    
    %% Loop until error is small enough
    for epoch = 1:max_epochs
        steps = epoch*K; % number of learning steps taken
    
        %% Batch learning with K steps
        idx = randsample(1:M, K, true);
        Xk = X(idx,:);
        Yk = Y(idx,:);

        %% Forward Propogate
        [~,fNET1,~,fNET2] = forward_prop(Xk, W_1, W_2);
        
        %% Backward Propogate
        delta_2 = (Yk - fNET2) .* (1 - fNET2.^2);
        delta_1 = (1 - fNET1.^2) .* (delta_2 * W_2(:,2:end));
        
        %% Update Weights
        W_1d = learn_rate*(delta_1' * [ones(K,1) , Xk] / K...
            + momentum * W_1p);
        W_2d = learn_rate*(delta_2' * [ones(K,1) , fNET1] / K...
            + momentum * W_2p);
        W_1 = W_1 + W_1d;
        W_2 = W_2 + W_2d;
        W_1p = W_1d;
        W_2p = W_2d;
        
        %% Calculate train error
        [~, train_error] = BPrecall(Xk, Yk, W_1, W_2, f_error);
        
        %% Display periodic progress
        if (mod(epoch,max_epochs / 1000) == 0)
            [~,test_error] = BPrecall(Xt, Yt, W_1, W_2, f_error);
            
            % Log
            fprintf(log_file, ['Step %10d: training error is' ...
                '%10f, testing error is %10f\n'], ...
                steps, train_error, test_error);
            %{
            if (mod(epoch, max_epochs / 100000) == 0)
                fprintf('.');
                num_output_dots = num_output_dots + 1;
                if (num_output_dots == 50)
                    fprintf('\n');
                    num_output_dots = 0;
                end
            end
            %}
        end
    
        %% Stop if error is low enough
        if (train_error < tolerance)
            fprintf('\nDesired tolerance reached!!');
            
            samples_taken = samples_taken + 1;
            train_e = train_e(1:samples_taken);
            test_e = test_e(1:samples_taken);
            s_epochs = s_epochs(1:samples_taken);
            
            train_e(samples_taken) = train_error;
            [~,test_e(samples_taken)] ...
                = BPrecall(Xt, Yt, W_1, W_2, f_error);
            break;
        end
        
        %% Record errors (RMSE)
        sample_idx = find(s_epochs == epoch);
        if (numel(sample_idx) == 1)
            train_e(sample_idx) = train_error;
            [~,test_e(sample_idx)] ...
                = BPrecall(Xt, Yt, W_1, W_2, f_error);
            samples_taken = samples_taken + 1;
        end
    end
    
    %% Return results
    fprintf('\nTraining stopped at %d steps\n', steps);
    fprintf('Final training error: %10f\n', ...
        train_e(samples_taken));
    fprintf('Final testing error: %10f\n', ...
        test_e(samples_taken));
    
    fprintf(log_file, '\n\nTraining stopped at %d steps\n', ...
        steps);
    fprintf(log_file, 'Final training error: %10f\n', ...
        train_e(samples_taken));
    fprintf(log_file, 'Final testing error: %10f\n', ...
        test_e(samples_taken));
end