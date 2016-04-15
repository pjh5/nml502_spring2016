function [accuracy, prediction] = classification_accuracy(...
    output, desired)

    [~, pred_class] = max(output, [], 2);
    [~, real_class] = max(desired, [], 2);
    prediction = index_to_vector(pred_class, size(desired,2));
    
    accuracy = sum(pred_class == real_class) / numel(pred_class);
end