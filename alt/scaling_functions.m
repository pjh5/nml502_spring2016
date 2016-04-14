function [f_scale, f_un] = scaling_functions(Y, scale, by_column)

    if (by_column)
        rangeY = range(Y,1);
        midY = (max(Y,[],1) + min(Y,[],1)) / 2;
        f_scale = @(y) 2*scale * ...
            bsxfun(@rdivide, ...
                   bsxfun(@minus, y, midY), ...
                   rangeY);
        f_un = @(y) bsxfun(@plus, ...
                           bsxfun(@times, y, rangeY) / (2*scale), ...
                           midY);
    else
       rangeY = max(max(Y)) - min(min(Y));
       midY = (max(max(Y)) + min(min(Y))) / 2;
       f_scale = @(y) 2*scale * (y - midY) / rangeY;
       f_un = @(y) y * rangeY / (2*scale) + midY;
    end
end