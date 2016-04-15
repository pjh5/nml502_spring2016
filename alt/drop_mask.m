function [drop_mask] = drop_mask(dimy, dimx, p)
    if 0 == p
        drop_mask = ones(dimy, dimx);
    else
        drop_mask = (rand(dimy, dimx) > p) / p;
    end
end