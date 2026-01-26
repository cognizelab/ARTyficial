%% Aesthetic agreement matrix and PCA results

load('../Main_codes/Data/Stimuli_AAT_ratings.mat','AAT_ratings')

AAT_RSM = corr(AAT_ratings(:,1:33)','type','Pearson');
AAT_mean = mean(AAT_ratings(:,1:33),2);

% decompose the matrix by using PCA
[coeff, score, latent, tsquared, explained, mu] = pca(AAT_RSM);
AAT_PCs = score(:,1:10);

%% low-level features of images
QIP = readtable('QIP/QIP_results.csv','VariableNamingRule','preserve');
QIPsorted = sortrows(QIP,"img_file","ascend");
QIPnum = table2array(QIPsorted(:,4:46));
% QIPnum_demean = QIPnum-mean(QIPnum);
QIP_RSM = corr(QIPnum','type','Spearman');

%% semantic similarity of images
load('MAT/MAT_avg.mat')
[coeff_mat, score_mat, latent_mat, tsquared_mat, explained_mat, mu_mat] = pca(MAT_avg);
MAT_PCs = score_mat(:,1:10);

%% CLIP embedings (high-level features) of images
load('../Figure_codes/Figure_data/CLIP_simi_matrix.mat')
CLIP_RSM = corr(CLIP_embeddings','type','Spearman');

%% EMOnet output of images
% This script is a short tutorial explaining how to use EmoNet in MATLAB. 
% For full  details, see https://advances.sciencemag.org/content/5/7/eaaw4358
% This code requires the Deep Learning and Image Processing Toolboxes for MATLAB 
% Get the EmoNet model
% model_filepath='./EmoNet/netTransfer_20cat.mat';
% 
% % Load EmoNet
% fprintf('Loading EmoNet... \n')
% load(model_filepath);
% addpath('./EmoNet/')
% % display the network layers
% % fprintf('Loading complete. Press any button to view the model''s architecture. \n')
% % pause
% % netTransfer.Layers
% 
% % Download and display a random image from Unsplash
% Paintings_path = g_ls('../stimuli/images/*.png');
% emonet_out = cell(96,1);
% emonet_value = zeros(96,20);
% for i =1:96
%     I=imread(Paintings_path{i});
%     I = readAndPreprocessImage(I);
%     probs = netTransfer.predict(I);
%     output_table=table(netTransfer.Layers(23).Classes, probs','VariableNames',{'EmotionCategory','Probability'}); 
%     emonet_out{i} = output_table;
%     emonet_value(i,:) = probs;
% end

load('EmoNet/EmoNet_output.mat')
EMO_RSM = corr(emonet_value','type','Spearman');
figure,imagesc(EMO_RSM)

%% similarity between matrices using matrix upper triangles
% aesthetic agreement matrix v.s. emotional similarity 
upperindx = triu(true(96),1);
[r,p] = corr(EMO_RSM(upperindx),AAT_RSM(upperindx),'Type','Spearman')

% aesthetic agreement matrix v.s. semantic similarity 
[r,p] = corr(MAT_avg(upperindx),AAT_RSM(upperindx),'Type','Spearman')

% aesthetic agreement matrix v.s. low-level similarity 
[r,p] = corr(QIP_RSM(upperindx),AAT_RSM(upperindx),'Type','Spearman')

% aesthetic agreement matrix v.s. high-level similarity 
[r,p] = corr(CLIP_RSM(upperindx),AAT_RSM(upperindx),'Type','Spearman')

%% save matrices
save('RSM_matrices.mat',"AAT_RSM","EMO_RSM","CLIP_RSM","QIP_RSM")

%% relationship between AAT pc scores and MAT pc scores
[r_axs,p_axs] = corr(AAT_PCs(:,1:10),MAT_PCs(:,1:10))
imagesc(abs(r_axs))
imagesc(-log(p_axs))

save("PC_AATvsMAT.mat","r_axs","p_axs","latent_mat","explained_mat");

%% associations after regressed out nine low-level visual features

[r, p] = partialcorr(AAT_PCs(:,1),MAT_PCs(:,1),QIPnum(:,[1:5,24,28,42:43]))
[r, p] = partialcorr(AAT_PCs(:,2),AAT_mean,QIPnum(:,[1:5,24,28,42:43]))

%% AI-features contribute to the first two components

labels = [cellstr("QIP" + (1:43))';cellstr("CLIP" + (1:768))';cellstr("EMO" + (1:20))'];
[r_axq,p_axq] = corr(AAT_PCs(:,1:2),[QIPnum,CLIP_embeddings,emonet_value],'Type','Spearman');

sum(p_axq<0.05/(831*2),2)

imagesc(r_axq)

labels(p_axq(1,:)'<0.05/(831*2))
labels(p_axq(2,:)'<0.05/(831*2))

save("Features_correlation.mat", 'r_axq', 'p_axq');