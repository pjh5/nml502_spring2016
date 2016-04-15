%%
%% Predicts output
function [pred, r_err] = BPrecall(X, Y, W_1, W_2, drop_p, f_error)

    [~,~,~,pred] = forward_prop(X, W_1, W_2, drop_p);
    r_err = f_error(pred, Y);
end