function lyricfeatures
clc
Artists={'Chance','childish','Drake','Eminem','G_Eazy','Iggy','Jay_Z','Kanye','Kendrick','Tyler'};
Songs={};
Songs{1}=dir('lyrics/Chance');
Songs{2}=dir('lyrics/childish');
Songs{3}=dir('lyrics/Drake');
Songs{4}=dir('lyrics/Eminem');
Songs{5}=dir('lyrics/G_Eazy');
Songs{6}=dir('lyrics/Iggy');
Songs{7}=dir('lyrics/Jay_Z');
Songs{8}=dir('lyrics/Kanye');
Songs{9}=dir('lyrics/Kendrick');
Songs{10}=dir('lyrics/Tyler');
count=1;
tic
numsongs=20+20+20+20+20+23+31+21+20+20;
FID=fopen('top50words.csv','r');
C=textscan(FID,'%s','delimiter','\n');
C=sort(C{1});
fclose(FID);
wordfreqs=zeros(numsongs,50);
feature=zeros(numsongs,5);
for i=1:10
   disp(i)
   for j=3:length(Songs{i})
       disp(j)
       [feature(count,:),wordfreqs(count,:)]=findfeatures(strcat('lyrics/',Artists{i},'/',Songs{i}(j).name),C);
       count=count+1;
   end    
end
toc
csvwrite('fullfeatures.csv',[feature wordfreqs])
%%%%%this is all to determine what the top 50 words across songs are, which
%%%%%we have saved to a csv file
% resultstotal=[];  
% for i=1:count-1
%     resultstotal=[resultstotal;results{i}];
% end
% resultstotalnew=sortcell(resultstotal,1);
% fixed=[];
% marker=1;
% fixedmarker=1;
% tic
% while marker<length(resultstotalnew)-1
%     [a,b]=resultstotalnew{marker,:};
%     c=resultstotalnew{marker+1,1};
%     fixed=[fixed;{a b}]; 
%     temp=1;
%     while test(a,c)
%        fixed{fixedmarker,2}=fixed{fixedmarker,2}+resultstotalnew{marker+temp,2};
%        temp=temp+1;  
%        c=resultstotalnew{marker+temp,1};
%     end
%     marker=marker+temp;
%     fixedmarker=fixedmarker+1;
% end
% toc
% ff=flipud(sortcell(fixed,2));
end

function bool=test(a,c)
bool=strcmp(a,c) || strcmp(strcat(a,'s'),c) ||strcmp(strcat(a,'es'),c) ||strcmp(strcat(a,'d'),c) ||strcmp(strcat(a,'ped'),c) ||strcmp(strcat(a,'ing'),c) ||strcmp(strcat(a,'in'),c) ||strcmp(strcat(a,'er'),c) ||strcmp(strcat(a,'est'),c) ||strcmp(strcat(a,'ed'),c) ||strcmp(strcat(a,'z'),c);
end

function [features,results]=findfeatures(filename,top50)
fileID=fopen(filename,'r');
C=textscan(fileID,'%s','Delimiter','\n','CommentStyle','[');
C=C{1};
C=C(6:end);
features=zeros(5,1);
features(1)=length(C); %total number of lines in the song
linecharcounts=zeros(length(C),1);
linewordcounts=zeros(length(C),1);
for i=1:length(C)
    C{i}=strrep(C{i},',','');
    C{i}=strrep(C{i},'?','');
    C{i}=strrep(C{i},'(','');
    C{i}=strrep(C{i},')','');
    C{i}=strrep(C{i},'in''','ing');
    C{i}=strrep(C{i},'!','');
    C{i}=strrep(C{i},'{','');
    C{i}=strrep(C{i},'}','');
    C{i}=strrep(C{i},'&','');
    C{i}=strrep(C{i},'$','');
    C{i}=strrep(C{i},'*','');
    C{i}=strrep(C{i},'+','');
    C{i}=strrep(C{i},'%','');
    C{i}=strrep(C{i},'#','');
    C{i}=strrep(C{i},';','');
    C{i}=strrep(C{i},'.','');
    C{i}=strrep(C{i},'''ll',' will');
    C{i}=strrep(C{i},'"','');
    C{i}=strrep(C{i},'-',' ');
    C{i}=lower(C{i});
    C{i}=strrep(C{i},'''','');
    C{i}=strrep(C{i},'couldnt','could not');
    C{i}=strrep(C{i},'cant','can not');
    C{i}=strrep(C{i},'wasnt','was not');
    C{i}=strrep(C{i},'theyre','they are');
    C{i}=strrep(C{i},'aingt','aint');
    linecharcounts(i)=length(C{i});
    D=strsplit(C{i},' ');
    linewordcounts(i)=length(D);
end
features(2)=mean(linecharcounts);%average # characters in a line
features(3)=mean(linewordcounts);%average # words in a line
s=strjoin(C);
words=strsplit(s,' ');
features(4)=length(words);%total # of words in the song
[results,num_unique]=wordcount(words,top50);
features(5)=num_unique/length(words);% percent of unique words in song
fclose(fileID);
end

function [results,num_unique] = wordcount(words,top50)
unique_words = unique(words);
num_unique=numel(unique_words);
freq = zeros(num_unique, 1);
for i = 1:numel(unique_words)
    if max(unique_words{i} ~= ' ')
        for j = 1:numel(words)
            if strcmp(words(j), unique_words{i})
                freq(i) = freq(i) + 1;
            end
        end
    end
end
u_freq = unique(freq);
sorted_freq = sort(u_freq, 'descend');
result={};
count=1;
iter=1;
while count<numel(unique_words)
    ind = find(freq == sorted_freq(iter));
    for i=1:length(ind)
        result{count+i-1,1}=unique_words{ind(i)};
        result{count+i-1,2} = freq(ind(i))/numel(words)*100;
    end
    iter=iter+1;
    count=count+length(ind);
end
resultnew=sortcell(result);
results=zeros(50,1);
count=1;
iter=0;
for i=1:numel(unique_words)
    cond=cstrcmp(top50{count},resultnew{i-iter});
    if cond==0
        if strcmp(top50(count),resultnew{i-iter})
           results(count)=results(count)+resultnew{i-iter,2}; 
           if any(ismember([7,11,12,15,24,25,26,29,35,36,38,46,50],count))
               temp=i-iter+1;
               while test(top50(count),unique_words{temp}) && temp<numel(unique_words)
               results(count)=results(count)+resultnew{temp,2}; 
               temp=temp+1;
               end
           end
           count=count+1;
        end
    elseif cond<0
        count=count+1;
        iter=iter+1;
    end 
    if count>50
        break
    end
end
end

function cmp = cstrcmp( a, b )
    % Force the strings to equal length
    x = char({a;b});
    % Subtract one from the other
    d = x(1,:) - x(2,:);
    % Remove zero entries
    d(~d) = [];
    if isempty(d)
        cmp = 0;
    else
        cmp = d(1);
    end
end