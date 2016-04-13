function rapLearning
features = csvread('fullestfeatures.csv',1);
clc
close all
[M, d] = size(features);
numClasses = 10;
desired = zeros(M,numClasses);
for song = 1:M
   desired(song,features(song,1)) = 1;       
end
desired=2*desired-1;
inputs=features(:,2:end);
[~,d] = size(inputs);
scaleparams=zeros(2,size(inputs,2));
for i=1:size(inputs,2)
   scaleparams(1,i)=min(inputs(:,i));
   scaleparams(2,i)=max(inputs(:,i));
   inputs(:,i)=scaled(inputs(:,i),[scaleparams(1,i),scaleparams(2,i),-.9,.9]);
end

% Split into training and testing 

allData = [inputs desired];
randData = allData(randperm(M), :);
perc=.7;
X_train = randData(1:ceil(M*perc), 1:d);
X_test = randData((ceil(M*perc) + 1):end, 1:d);
D_train = randData(1:ceil(M*perc), (d + 1):end);
D_test = randData((ceil(M*perc) + 1):end, (d + 1):end);
alpha=.001;
nepoch=2500;
a=0;
errstop=.01;


[Wx,Wy,trainerr,testerr]=trainMLP(d,20,10,alpha,X_train,D_train,X_test,D_test,nepoch,a,errstop,scaleparams);
plot(trainerr)
hold on
plot(testerr,'r')
title('Learning history');
xlabel('Learn step (xEpochSize');
ylabel('Misclassification Rate');
legend('training error','testing error')
    

end
function [fNET2] = recall(W1,W2,xtest, K)
    fNET1 = tanh(W1*[ones(1,K);xtest']);
    fNET2 = tanh(W2*[ones(1,K);fNET1]);
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
function [val] = scaled(in_val,scaleparams)
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
function [Wx,Wy,trainerr,testerr]=trainMLP(p,H,m,alpha,X,D, X_test, D_test, nepoch,a,errstop,scaleparams)
%   p: number of the inputs.
%   H: number of hidden neurons
%   m: number of output neurons
%   alpha: learning-rate parameter
%   X: SCALED -1 to 1 input 
%   D: SCALED desired response
%   nepoch: maximum number of epochs to train.
%   a: momentum constant
%   errstop: error target.
%   Xtest: SCALED test data set to test recall at each iteration
%   Dtest: SCALED expected output
%   f2: function to return scaled entries to the original value
%   class: whether this is a classification problem, to produce plots or
%   charts
%
%   Wx: Hidden layer weight matrix. Wx is a (H x p+1) dimensional matrix.
%   Wy: Output layer weight matrix. Wy is a (m x H+1) dimensional matrix.
%   trainerr: the model training error at each epoch
%   testerr: the model testing error at each epoch
Wx = rand(H,p+1)/5-.1;
Wy = rand(m,H+1)/5-.1;
trainerr=zeros(nepoch,1);
testerr=zeros(nepoch,1);
%K samples in each epoch
K = size(X,1);
deltaWxold=zeros(size(Wx));
deltaWyold=zeros(size(Wy));
%random sequence of samples
for epoch = 1:nepoch

    %sample code for building BP network
    k = randperm(K);
    xk = X(k,:)'; %1*200
    NET1 = Wx*[ones(1,K);xk]; %10*200
    fNET1 = tanh(NET1); %10*200
    NET2 = Wy*[ones(1,K);fNET1]; %1*200
    fNET2 = tanh(NET2); %1*200
    yk = fNET2; %1*200
    Dk = D(k,:)'; %1*200
    
    delta_l2 = (Dk - yk) .* (1-(fNET2).^2); %1*200
    delta_l1 = (1-(fNET1).^2).* (Wy(:,2:end)'*delta_l2); %10*200
    
    Wx = Wx + alpha * (delta_l1 * [ones(1,K);xk]') + a*deltaWxold;
    Wy = Wy + alpha * (delta_l2 * [ones(1,K);fNET1]') + a*deltaWyold;  
    deltaWxold=alpha * (delta_l1 * [ones(1,K);xk]' + a*deltaWxold);
    deltaWyold=alpha * (delta_l2 * [ones(1,K);fNET1]'+ a*deltaWyold);
    
    %calculate training and testing errors for all outputs
    [~,f]=max(Dk);
    [~,b]=max(yk);
    c=confusionmat(f',b);
    trainerr(epoch)=1-sum(diag(c))/length(f);
	
	[~,ftest] = max(D_test');
	[~,btest] = max(recall(Wx, Wy, X_test, size(X_test,1)));
    testerr(epoch) = 1 - sum(diag(confusionmat(ftest, btest')) / length(ftest));
    %[~,tt] = recall(Wx,Wy,Xtest,Dtest,f2);    
    %testerr(epoch)=mean(tt);
    
%     if trainerr(epoch)<errstop
%         disp([num2str(epoch*K),' training error:  ',num2str(trainerr(epoch)),' test error:  ',num2str(testerr(epoch))])
%             %this generates data for a confusion matrix for both the
%             %training and testing data sets and shows the misclassification
%         [~,f]=max(Dk);
%         [~,b]=max(yk);
%         confusionmat(f',b)
%         return
%     end
end

%this does the same stuff as above if the error threshold is not reached
disp(['training error:  ',num2str(trainerr(epoch))])
[~,a]=max(Dk);
[~,b]=max(yk);
confusionmat(a',b)
disp(['testing error:  ',num2str(testerr(epoch))])
[~,ftest] = max(D_test');
[~,btest] = max(recall(Wx, Wy, X_test, size(X_test,1)));
confusionmat(ftest, btest')
end