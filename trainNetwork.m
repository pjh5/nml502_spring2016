function [W_l1, W_l2, trainerr, testerr] = trainNetwork(in,hid,out,nepoch,tol,eta,mom,X,D,xtest,ytest, scaleparams)

     %initialize weights; first column is bias
    W_l1 = (rand(hid,in + 1)-0.5)/5;
    W_l2 = (rand(out,hid+1)-0.5)/5;
    
    %K samples in each epoch
    K = size(X,1);
    W_l1_old = zeros(size(W_l1));
    W_l2_old = zeros(size(W_l2));

    for epoch = 1:nepoch

        %get random sequence of samples for current epoch
        k = randperm(K);
        xk = X(k,:)'; %1*200
        NET1 = W_l1*[ones(1,K);xk]; %10*200
        fNET1 = tanh(NET1); %10*200
        NET2 = W_l2*[ones(1,K);fNET1]; %1*200
        fNET2 = tanh(NET2); %1*200
        yk = fNET2; %1*200
        Dk = D(k,:)'; %1*200
        
        xtestk = xtest(k,:)';
        ytestk = ytest(k,:)';

        delta_l2 = (Dk - yk) .* (1-(fNET2).^2); %1*200
        delta_l1 = (1-(fNET1).^2).* (W_l2(:,2:end)'*delta_l2); %10*200


        W_l1 = W_l1 + eta * (delta_l1 * [ones(1,K);xk]') + (mom * W_l1_old);
        W_l2 = W_l2 + eta * (delta_l2 * [ones(1,K);fNET1]') + (mom * W_l2_old);
        W_l1_old = eta * (delta_l1 * [ones(1,K);xk]') + (mom * W_l1_old);
        W_l2_old = eta * (delta_l2 * [ones(1,K);fNET1]') + (mom * W_l2_old);
        
        trainerr(epoch) = mean(mean(abs(unscale(Dk, scaleparams)-unscale(yk, scaleparams))));
        [~,~,testerr(epoch)] = recall(W_l1,W_l2, xtestk, ytestk,K, scaleparams);
%         disp(trainerr(epoch));
%         disp(testerr(epoch));
        
        if testerr(epoch) <= tol
            break;
        end
    end

end

function [xtest,yrecall,err] = recall(W1,W2,xtest,ytest, K, scaleparams)
    fNET1 = tanh(W1*[ones(1,K);xtest]);
    fNET2 = tanh(W2*[ones(1,K);fNET1]);
    yrecall = unscale(fNET2, scaleparams);
%     yrecall = (fNET2+0.92)*6;%marked - in a general case should i call reshift here?
    err = mean(mean(abs(unscale(ytest, scaleparams) - yrecall)));
end
