%% 
%% Forward propogates the input vector x, returning all
%% intermediate steps
%%
%% x    the input vector
%%
%% y0   the output of the zeroth layer
%% x1   the net input to the first layer
%% y1   the output of the first layer 
%% x2   the net input to the second layer
%% y2   the output of the second layer
function [NET1,fNET1,NET2,fNET2] = forward_prop(X, W_1, W_2)

    [M,~] = size(X);
    
    % Propogate
    NET1 = [ones(M,1) , X] * W_1';
    fNET1 = tanh(NET1);
    NET2 = [ones(M,1) , fNET1] * W_2';
    fNET2 = tanh(NET2);
end