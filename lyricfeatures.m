function lyricfeatures
clc
fileID=fopen('memyself.ezy.txt','r');
C=textscan(fileID,'%s','Delimiter','\n','CommentStyle','[');
%C=textread('rfriends.wst.txt', '%s', 'delimiter', '\n', 'whitespace', '');
C=C{1};
C=C(6:end);
features=zeros(5,1);
features(1)=length(C); %total number of lines in the song
linecharcounts=zeros(length(C),1);
linewordcounts=zeros(length(C),1);
%Dict=containers.Map;
for i=1:length(C)
    C{i}=strrep(C{i},',','');
    C{i}=strrep(C{i},'?','');
    C{i}=strrep(C{i},'(','');
    C{i}=strrep(C{i},')','');
    C{i}=strrep(C{i},'in''','ing');
    C{i}=strrep(C{i},'!','');
    C{i}=strrep(C{i},'{','');
    C{i}=strrep(C{i},'}','');
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
    linecharcounts(i)=length(C{i});
    D=strsplit(C{i},' ');
    linewordcounts(i)=length(D);
end
features(2)=mean(linecharcounts);%average # characters in a line
features(3)=mean(linewordcounts);%average # words in a line
s=strjoin(C);
words=strsplit(s,' ');
features(4)=length(words);%total # of words in the song
[results,num_unique]=wordcount(words,20)
features(5)=num_unique/length(words)% percent of unique words in song

end

function [results,num_unique] = wordcount(words, num)
unique_words = unique(words);
for i = 1:numel(unique_words)-1 %this should remove plural words
    if strcmp(strcat(unique_words(i),'s'),unique_words(i+1))
       words(strcmp(words,unique_words(i+1)))=unique_words(i); end
    if strcmp(strcat(unique_words(i),'es'),unique_words(i+1))
       words(strcmp(words,unique_words(i+1)))=unique_words(i); end
    if strcmp(strcat(unique_words(i),'ed'),unique_words(i+1))
       words(strcmp(words,unique_words(i+1)))=unique_words(i); end
    if strcmp(strcat(unique_words(i),'ped'),unique_words(i+1)) %popped and pop
       words(strcmp(words,unique_words(i+1)))=unique_words(i); end
    if strcmp(strcat(unique_words(i),'ing'),unique_words(i+1))
       words(strcmp(words,unique_words(i+1)))=unique_words(i);  end
    if strcmp(strcat(unique_words(i),'er'),unique_words(i+1))
       words(strcmp(words,unique_words(i+1)))=unique_words(i); end 
    if strcmp(strcat(unique_words(i),'est'),unique_words(i+1))
       words(strcmp(words,unique_words(i+1)))=unique_words(i);  end
    if strcmp(strcat(unique_words(i),'r'),unique_words(i+1)) %believer
       words(strcmp(words,unique_words(i+1)))=unique_words(i); end
    if strcmp(strcat(unique_words(i),'er'),unique_words(i+1)) %dreamer
       words(strcmp(words,unique_words(i+1)))=unique_words(i); end
    if strcmp(strcat(unique_words(i),'z'),unique_words(i+1)) 
       words(strcmp(words,unique_words(i+1)))=unique_words(i); end
end
unique_words = unique(words)
freq = zeros(numel(unique_words), 1);
num_unique=numel(unique_words);
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

results={ 'WORD' 'REL. FREQ' };

count=1;
iter=1;
while count<num
    ind = find(freq == sorted_freq(iter));
    for i=1:length(ind)
        results{count+i-1,1}=unique_words{ind(i)};
        results{count+i-1,2} = freq(ind(i))/numel(words)*100;
    end
    iter=iter+1;
    count=count+length(ind);
end
end