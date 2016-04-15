function cmat = confusion_matrix(desired, output)
    [~,prediction] = classification_accuracy(output, desired);
    cmat = desired' * double(prediction);
end