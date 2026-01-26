%% Liking grades defination
% load the raw data for aesthetic judgment
load('Data/Stimuli_AAT_ratings.mat');

% AAT_ratings: 96 images for each of 34 participants
% image_category: 1. Portraits 0. Landscapes

% The last participant was removed in behavioural analysis, due to the
% binary ratings
AAT_ratings_final =AAT_ratings(:,1:33);

% estimate the group average and standard deviation of ratings
score_gavg = mean(AAT_ratings_final,2);
score_gstd = std(AAT_ratings_final,0,2);

% build the rating similarity matrix
AAT_RSM = corr(AAT_ratings_final','type','Pearson');

% decompose the matrix by using PCA
[coeff, score, latent, tsquared, explained, mu] = pca(AAT_RSM);

% retain the first two PC dimensions according to the scree plot
scree_plot(explained(1:10))
dm1=score(:,1);
dm2=-score(:,2); % change the direction for better visualization

% load the semantic PC score from MAT task

% estimate the behaviour relevance for each dimension
[R_dm1xgavg,P_dm1xgvag] = corr(dm1,score_gavg,'type','Pearson');
[R_dm2xgavg,P_dm2xgvag] = corr(dm2,score_gavg,'type','Pearson');

% estimate the relationship between dimensions and AI generated score
load('../Figure_codes/Figure_data/MUSIQ_AVA_score.mat');
[R_dm1xAI,p_dm1xAI] = corr(zscore(AIscore),dm1);
[R_dm2xAI,p_dm2xAI] = corr(zscore(AIscore),dm2);

% we further quantized the scores on each dimenion to four quartile levels 
% (due to the negative correlation between 2nd dimension and average
% ratings, we flipped the direction of 2nd dimension for better interpreting)
%

grad_num = 4;
grad_thr = (1:(grad_num-1))/grad_num;

Qg1 = quantile(dm1,grad_thr);
DM_grades_1st = discretize(dm1,[min(dm1)-1,Qg1,max(dm1)+1]);
Qg2 = quantile(dm2,grad_thr);
DM_grades_2nd = discretize(dm2,[min(dm2)-1,Qg2,max(dm2)+1]);


%% Average the beta responses for image trials to 4 levels
% GLMsingleD_path=g_ls('../R*/Surf_interp/TYPED_FITHRF_GLMDENOISE_RR.mat');
% Design_DIR = g_ls('../ART/*.csv');
% samplesize = 91282;
% X_Grads = zeros(samplesize,grad_num*34);
% for subj = 1:34
%     ind_tmp = zeros(384,1);
%     designs = Design_DIR((subj*4-3):(subj*4));
%     for i = 1:4
%         t_tmp = readtable(designs{i},'VariableNamingRule','preserve');
%         ind_tmp((96*i-95):(96*i),1) = t_tmp.index;
%     end
% 
%     betas_tmp = load(GLMsingleD_path{subj});
%     betas_sqz = squeeze(betas_tmp.modelmd);
%     betas_Z_tmp = [zscore(betas_sqz(1:samplesize,1:96),0,2),zscore(betas_sqz(1:samplesize,97:192),0,2),...
%         zscore(betas_sqz(1:samplesize,193:288),0,2),zscore(betas_sqz(1:samplesize,289:end),0,2)];
%     trial_avg_tmp = zeros(samplesize,96);
%     for ttt = 1:96
%         trial_avg_tmp(:,ttt) = mean(betas_Z_tmp(:,ind_tmp==ttt),2);
%     end
% 
%     grad_avg_tmp = zeros(samplesize,grad_num);
%     for ggg = 1:grad_num
%         grad_avg_tmp(:,ggg) = mean(trial_avg_tmp(:,DM_grades_1st==ggg),2);
%     end
% 
%     X_Grads(:,((subj-1)*grad_num+1):(subj*grad_num)) = grad_avg_tmp;
% 
%     clear betas_tmp betas_Z_tmp trial_avg_tmp grad_avg_tmp;
% end
% 
% AATpredition = fmri_data;
% AATpredition.dat=X_Grads;
% AATpredition.Y = Y_Grads;
% 
% save('ART_G1_4lvl_predictiondata.mat',"AATpredition");