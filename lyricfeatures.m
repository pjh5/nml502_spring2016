function lyricfeatures
clc
Artists={'Chance','childish','Drake','Eminem','G-Eazy','Iggy','Jay Z','Kanye','Kendrick','Tyler'};
Songs={};
Songs{1}={'acidrain.ctr','chainsmo.ctr','cocoabut.ctr','ev_good.ctr','everybdy.ctr','fav_song.ctr','good_ass.ctr','interlde.ctr','juice.ctr','lost.ctr','nana.ctr','paranoia.ctr','pushaman.ctr','sm_again.ctr'};
Songs{2}={'allshine.gam','backpack.gam','bonfire.gam','crawl.gam','fire_fly.gam','heartbt.gam','hold_you.gam','kids.gam','LES.gam','let_home.gam','no_exit.gam','outside.gam','sober.gam','sunrise.gam','sweatpnt.gam','telegrap.gam','thtpower.gam','youseeme.gam'};
Songs{3}={'0 to 100.drk','All Me.drk','Best I Ever Had.drk','Energy.drk','Headlines.drk','Hotline Bling.drk','HYFR.drk','Take Care.drk','The Motto.drk','Tuesday.drk'};
Songs{4}={'a_fuck.mnm','bitchshd.mnm','guilty.mnm','if_i_had.mnm','iller.mnm','im_shady.mnm','low_down.mnm','murder.mnm','my_fault.mnm','mynameis.mnm','PSA_shdy.mnm','still.mnm','twoofus.mnm'};
Songs{5}={'allcould.ezy','almost.ezy','hang_ten.ezy','ladykill.ezy','mad.ezy','make-up.ezy','marilyn.ezy','memyself.ezy','random.ezy','run_sue.ezy','wllknown.ezy'};
Songs{6}={'backseat.igg','dropthat.igg','flash.igg','hello.igg','lastsong.igg','memyself.igg','milliond.igg','murdabiz.igg','my_world.igg','pussy.igg','runway.igg','treasure.igg','you.igg'};
Songs{7}={'BBC.jyz','beach_is.jyz','crown.jyz','eff_with.jyz','FUTW.jyz','heaven.jyz','hlygrail.jyz','jayzblue.jyz','la_fam.jyz','nickels.jyz','oceans.jyz','part_2.jyz','picasso.jyz','somewher.jyz','tom_ford.jyz','versus.jyz'};
Songs{8}={'allofthe.wst','feedback.wst','gold_dig.wst','gorgeous.wst','heartlss.wst','nochurch.jay','nomoreLA.wst','power.wst','rfriends.wst','runaway.wst','ultra.wst'};
Songs{9}={'alright.ken','backseat.ken','bitchdnt.ken','blackerb.ken','complex.ken','compton.ken','good_kid.ken','hood_pol.ken','how_much.ken','i_album.ken','im_dying.ken','institut.ken','kngkunta.ken','mAAdcity.ken','momma.ken','montrees.ken','mortalmn.ken','poetic.ken','real.ken','recipe.ken','sherane.ken','sing_abt.ken','swmdrank.ken','th_walls.ken','theartof.ken','u.ken','wesleys.ken'};
Songs{10}={'analog.tye','bitchsck.tye','bopbitch.tye','goblin.tye','golden.tye','her.tye','nightmre.tye','radicals.tye','sandwit.tye','she.tye','transylv.tye','tron_cat.tye','window.tye','yonkers.tye'};
count=1;
tic
FID=fopen('top50words.csv','r');
C=textscan(FID,'%s','delimiter','\n');
C=sort(C{1});
fclose(FID);
wordfreqs=zeros(147,50);
feature=zeros(147,5);
for i=1:10
   disp(i)
   for j=1:length(Songs{i})
       disp(j)
       [feature(count,:),wordfreqs(count,:)]=findfeatures(strcat('Songs/',Artists{i},'/',Songs{i}{j},'.txt'),C);
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