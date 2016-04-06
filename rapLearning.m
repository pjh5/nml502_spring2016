function rapLearning()
    fullfeatures = csvread('fullfeatures.csv');

end

function [xtest,yrecall,err] = recall(W1,W2,xtest,ytest, K, scaleparams)
    fNET1 = tanh(W1*[ones(1,K);xtest]);
    fNET2 = tanh(W2*[ones(1,K);fNET1]);
    yrecall = unscale(fNET2, scaleparams);
    err = calculateMisclassification(ytest, yrecall);
end

function val = calculate_misclassification(ytest, yrecall)
    M = size(ytest, 1);
    ytest_c = my_classify(ytest);
    yrecall_c = my_classify(yrecall);
    
    val = 1 - (sum(ytest_c == yrecall_c) / M);
    
end

function [ class ] = my_classify(vec)
    [~, class] = max(vec,[],2);
end

function [val] = scale(in_val,scaleparams)
%this makes an assumption of the in_val range
    ymin = scaleparams(1);
    ymax = scaleparams(2);
    fmin = scaleparams(3);
    fmax = scaleparams(4);
    val = ((in_val - ymin)/(ymax - ymin)) * (fmax - fmin) + fmin;
end

function [val] = unscale(in_val,scaleparams)
    ymin = scaleparams(1);
    ymax = scaleparams(2);
    fmin = scaleparams(3);
    fmax = scaleparams(4);
    val = ((in_val - fmin)/(fmax - fmin)) * (ymax - ymin) + ymin;
end