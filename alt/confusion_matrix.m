function cmat = confusion_matrix(desired, output)
    [~,prediction] = classification_accuracy(desired, output);
    cmat = desired' * double(prediction);
end