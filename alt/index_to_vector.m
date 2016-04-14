function [pred_vect] = index_to_vector(idxs, max_idx)
    pred_vect = ...
        repmat(1:max_idx, size(idxs, 1), 1) == repmat(idxs, 1, max_idx);
end