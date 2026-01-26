%% Topic term-based decoding of significant signatures
% load preloaded maps
load('Data/Corticalmaps_preload.mat')

% load the topic term maps projected onto surface
neurosynth_topic_surf = load('Data/data_neurosynth_topic.mat');
LDA100s_L = neurosynth_topic_surf.neurosynth.LDA100.L;
LDA100s_R = neurosynth_topic_surf.neurosynth.LDA100.R;
% only focus on selected terms related to the cognitive processes
load('Data/LDA100terms_naming.mat')
termout = cellfun(@isempty,struct2table(LDA100terms).Label);
feature_names = struct2table(LDA100terms).Label(~termout);

%% calculate the map similarity for postive and negative regions in each signature
pearsons_r1=zeros(100,1);
for ii = 1:100
    topic_temp = [LDA100s_L(:,ii);LDA100s_R(:,ii)];
    pearsons_r1(ii) = corr(PC1_sigpos_cortical(PC1_sigpos_cortical>0), topic_temp(PC1_sigpos_cortical>0), 'type', 'Pearson');
end
pearsons_r1=pearsons_r1(~termout);
[pearsons_r1_sort, idx1] = sort(pearsons_r1, 'descend');
feature_names_sort1 = feature_names(idx1);
wc = wordcloud(feature_names_sort1(pearsons_r1_sort>0.01)', pearsons_r1_sort(pearsons_r1_sort>0.01));
% wc = wordcloud(feature_names_sort1(1:15)', pearsons_r1_sort(1:15));


pearsons_r2=zeros(100,1);
for ii = 1:100
    topic_temp = [LDA100s_L(:,ii);LDA100s_R(:,ii)];
    pearsons_r2(ii) = corr(-PC1_signeg_cortical(PC1_signeg_cortical<0), topic_temp(PC1_signeg_cortical<0), 'type', 'Pearson');
end
pearsons_r2=pearsons_r2(~termout);
[pearsons_r2_sort, idx2] = sort(pearsons_r2, 'descend');
feature_names_sort2 = feature_names(idx2);
wc = wordcloud(feature_names_sort2(pearsons_r2_sort>0.01)', pearsons_r2_sort(pearsons_r2_sort>0.01));
% wc = wordcloud(feature_names_sort2(1:15)', pearsons_r2_sort(1:15));


pearsons_r3=zeros(100,1);
for ii = 1:100
    topic_temp = [LDA100s_L(:,ii);LDA100s_R(:,ii)];
    pearsons_r3(ii) = corr(PC2_sigpos_cortical(PC2_sigpos_cortical>0), topic_temp(PC2_sigpos_cortical>0), 'type', 'Pearson');
end
pearsons_r3=pearsons_r3(~termout);
[pearsons_r3_sort, idx3] = sort(pearsons_r3, 'descend');
feature_names_sort3 = feature_names(idx3);
wc = wordcloud(feature_names_sort3(pearsons_r3_sort>0.01)', pearsons_r3_sort(pearsons_r3_sort>0.01));
% wc = wordcloud(feature_names_sort3(1:15)', pearsons_r3_sort(1:15));

pearsons_r4=zeros(100,1);
for ii = 1:100
    topic_temp = [LDA100s_L(:,ii);LDA100s_R(:,ii)];
    pearsons_r4(ii) = corr(-PC2_signeg_cortical(PC2_signeg_cortical<0), topic_temp(PC2_signeg_cortical<0), 'type', 'Pearson');
end
pearsons_r4=pearsons_r4(~termout);
[pearsons_r4_sort, idx4] = sort(pearsons_r4, 'descend');
feature_names_sort4 = feature_names(idx4);
wc = wordcloud(feature_names_sort4(pearsons_r4_sort>0.01)', pearsons_r4_sort(pearsons_r4_sort>0.01));
% wc = wordcloud(feature_names_sort4(1:15)', pearsons_r4_sort(1:15));


