function lyricfeatures
clc
%Artists={'Chance','childish','Drake','Eminem','G_Eazy','Iggy','Jay_Z','Kanye','Kendrick','Tyler'};
Artists={'Chance','childish','Drake','Eminem','G_Eazy','Kendrick','Tyler'};
Songs={};
Songs{1}=dir('lyrics/Chance');
Songs{2}=dir('lyrics/childish');
Songs{3}=dir('lyrics/Drake');
Songs{4}=dir('lyrics/Eminem');
Songs{5}=dir('lyrics/G_Eazy');
% Songs{6}=dir('lyrics/Iggy');
% Songs{7}=dir('lyrics/Jay_Z');
% Songs{8}=dir('lyrics/Kanye');
Songs{6}=dir('lyrics/Kendrick');
Songs{7}=dir('lyrics/Tyler');
count=1;
tic
%numsongs=20+20+20+20+20+23+31+21+20+20;
a=ones(17,1);
b=ones(18,1);
c=ones(20,1);
vec=[a;2*a;3*a;4*a;5*b;6*c;7*c];
numsongs=size(vec,1);
FID=fopen('newtopwords.csv','r');
C=textscan(FID,'%s','delimiter',',');
bb=C{1}(1:44);
cc=C{1}(45:end);
[sorted, inds]=sort(cc);
classes=str2num(cell2mat(bb(inds)));
fclose(FID);
wordfreqs=zeros(numsongs,7);
feature=zeros(numsongs,5);
for i=1:length(Artists)
   disp(i)
   for j=3:length(Songs{i})
       disp(j)
       [feature(count,:),wordfreqs(count,:)]=findfeatures(strcat('lyrics/',Artists{i},'/',Songs{i}(j).name),sorted,classes);
       count=count+1;
   end    
end
toc

csvwrite('fullfeatures.csv',[vec feature wordfreqs])
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

function [features,results]=findfeatures(filename,artistwords,classes)
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
[results,num_unique]=wordcount(words,artistwords,classes);
features(5)=num_unique/length(words);% percent of unique words in song
fclose(fileID);
end

function [results,num_unique] = wordcount(words,artistwords,classes)
unique_words = unique(words);
num_unique=numel(unique_words);
% freq = zeros(num_unique, 1);
% for i = 1:numel(unique_words)
%     if max(unique_words{i} ~= ' ')
%         for j = 1:numel(words)
%             if strcmp(words(j), unique_words{i})
%                 freq(i) = freq(i) + 1;
%             end
%         end
%     end
% end
% u_freq = unique(freq);
% sorted_freq = sort(u_freq, 'descend');
% result={};
% count=1;
% iter=1;
% while count<numel(unique_words)
%     ind = find(freq == sorted_freq(iter));
%     for i=1:length(ind)
%         result{count+i-1,1}=unique_words{ind(i)};
%         result{count+i-1,2} = freq(ind(i))/numel(words)*100;
%     end
%     iter=iter+1;
%     count=count+length(ind);
% end
results=zeros(7,1);
count=1;
for i=1:numel(unique_words)
    cond=cstrcmp(artistwords{count},unique_words{i});
%         artistwords{count}
%          unique_words{i}
    if cond==0
        %artistwords{count}
        results(classes(count))=results(classes(count))+1; 
        count=count+1;
        if any(ismember([5,9,13,30],count))
            %this is just the case where it's the word for 2 artists
            results(classes(count))=results(classes(count))+1; 
            count=count+1;
        end
    elseif cond<0
        count=count+1;
        if count<45
        cond=cstrcmp(artistwords{count},unique_words{i});
        if cond==0
            disp('ass')
            results(classes(count))=results(classes(count))+1; 
            count=count+1;
        end
        end
        if any(ismember([5,9,13,30],count))
            %this is just the case where it's the word for 2 artists
            count=count+1;
        end
    end 
    if count>44
        break
    end
end
results
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