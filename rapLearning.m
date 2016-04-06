function rapLearning()




end

function [xtest,yrecall,err] = recall(W1,W2,xtest,ytest, K, scaleparams)
    fNET1 = tanh(W1*[ones(1,K);xtest]);
    fNET2 = tanh(W2*[ones(1,K);fNET1]);
    yrecall = unscale(fNET2, scaleparams);
%     yrecall = (fNET2+0.92)*6;%marked - in a general case should i call reshift here?
    err = mean(mean(abs(unscale(ytest, scaleparams) - yrecall)));
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