%% load the beta values and grades on visual semantics component
addpath('../Utilities/')

load('Data/ART_G1_4lvl_predictiondata.mat')
grad_num = 4;
nsub = 34;
nrepeat = 10; % for 10X10 cross-validation
nlevel = grad_num; % grades of ratings
predicted_ratings = zeros(length(AATpredition.Y),nrepeat);
rmse_overall = zeros(nrepeat,1);
for repeat = 1:nrepeat
    CVindex = GenerateCV(nsub, nlevel, repeat); 
    [~, stats] = predict(AATpredition,  'algorithm_name', 'cv_svr', 'nfolds', CVindex, 'error_type', 'mse');
    predicted_ratings(:, repeat) = stats.yfit;
    rmse_overall(repeat) = stats.rmse;
end


%% overall (between- and within-subjects) prediction-outcome correlations
true_ratings = AATpredition.Y;
prediction_outcome_corrs = corr(true_ratings, predicted_ratings);
prediction_corrs_avg = mean(prediction_outcome_corrs);
prediction_corrs_std = std(prediction_outcome_corrs);
rmse_overall_avg = mean(rmse_overall);
rmse_overall_std = std(rmse_overall);

%% permutation test for model significance
n_perm = 10000;
perm_pred_r = zeros(n_perm,1);
perm_pred_rmse = zeros(n_perm,1);
tic
parfor pi = 1:n_perm
    CVindex = GenerateCV(nsub, nlevel, repeat);  % follow the 10-fold cross-validation
    rng(pi);
    % only permute the labels within each participant
    perm_result = arrayfun(@(x) randperm(grad_num), 1:nsub, 'UniformOutput', false);
    % estimate the performance based on permutation
    perm = fmri_data();
    perm.dat = AATpredition.dat;
    perm.Y = cell2mat(perm_result)';
    [~, stats_perm] = predict(perm,  'algorithm_name', 'cv_svr', 'nfolds', CVindex, 'error_type', 'mse');
    perm_pred_r(pi,1) = double(stats_perm.pred_outcome_r);
    perm_pred_rmse(pi,1) = stats_perm.rmse;
    disp(['Perm',num2str(pi)]);
end
toc
% calculate the significance based on permutation distribution
p_value_r = mean(perm_pred_r >= prediction_corrs_avg);
p_value_rmse = mean(perm_pred_rmse <= rmse_overall_avg);

p_perm_pred_r  = get_permutation_p(prediction_corrs_avg,perm_pred_r,'right');
p_perm_pred_rmse = get_permutation_p(rmse_overall_avg,perm_pred_rmse,'left');


%% Within-subject prediction-outcome correlations
subject = repmat(1:nsub, nlevel,1);
subject = subject(:);

within_subj_corrs = zeros(nsub, nrepeat);
within_subj_rmse = zeros(nsub, nrepeat);
for n = 1:nrepeat
    for i = 1:nsub
    subY = true_ratings(subject==i);
    subyfit = predicted_ratings(subject==i, n);
    within_subj_corrs(i, n) = corr(subY, subyfit);
    err = subY - subyfit;
    mse = (err' * err)/length(err);
    within_subj_rmse(i, n) = sqrt(mse);
    end
end
mean(within_subj_corrs,"all"),std(within_subj_corrs(:))
sub_predict_corrs = mean(within_subj_corrs,2);
sub_predict_rmse = mean(within_subj_rmse,2);
mean(within_subj_rmse,"all"),std(within_subj_rmse(:))


%% plot overall performance
create_figure('Whole-brain Prediction');
predicted_ratings_avg = mean(predicted_ratings, 2);
predicted_ratings_reshaped = reshape(predicted_ratings_avg, [grad_num, nsub])';
lineplot_columns(predicted_ratings_reshaped, 'color', [.7 .3 .3], 'markerfacecolor', [1 .5 0],'w',5,'markersize',12);
xlabel('True Rating');
ylabel('Predicted Rating')
set(gcf,'position',[10,10,850,750])
a = get(gca,'XTickLabel');  
set(gca,'XTickLabel',[1,2,3,4],'fontsize',40,'FontWeight','bold');
set(gca,'linewidth', 5)
set(gca, 'XTick', 1:grad_num)
xlim([0.8 grad_num+0.2])
ylim([1.2 4])
set(gcf, 'Color', 'w')

%%
% Consider that each subject has their own line:
for i = 1:nsub
    YY{i} = stats.Y(subject == i);
    Yfit{i} = predicted_ratings_avg(subject == i);
end

line_plot_multisubject(YY, Yfit,'MarkerTypes','o');
xlabel('True Rating');
ylabel('Predicted Rating')
set(gcf,'position',[10,10,850,750])
a = get(gca,'XTickLabel');  
set(gca,'XTickLabel',[1,2,3,4],'fontsize',40,'FontWeight','bold');
set(gca,'linewidth', 5)
set(gca, 'XTick', 1:grad_num)
xlim([0.8 grad_num+0.2])
ylim([0 5])
set(gcf, 'Color', 'w')

%% save data for pretty plot
% save("ART_G1_PrePerfomance.mat","predicted_ratings_reshaped","YY","Yfit");

%% classifications
Accuracy_per_level = zeros(nrepeat, 3);
Accuracy_se_per_level = zeros(nrepeat, 3);
Accuracy_p_per_level = zeros(nrepeat, 3);
Accuracy_low_medium_high = zeros(nrepeat, 3);
Accuracy_se_low_medium_high = zeros(nrepeat, 3);
Accuracy_p_low_medium_high = zeros(nrepeat, 3);
for n = 1:nrepeat
    PE = predicted_ratings(:, n);
    PE = reshape(PE, [4, nsub])';
    PE_low = nanmean(PE(:, 1:2), 2);
    PE_medium = nanmean(PE(:, 2:3), 2);
    PE_high = nanmean(PE(:, 3:4), 2);
    % level 2 vs. 1
    ROC = roc_plot([PE(:, 2);PE(:,1)], [ones(nsub,1);zeros(nsub,1)], 'twochoice');
    Accuracy_per_level(n, 1) = ROC.accuracy;
    Accuracy_se_per_level(n, 1) = ROC.accuracy_se;
    Accuracy_p_per_level(n, 1) = ROC.accuracy_p;
    % level 3 vs. 2
    ROC = roc_plot([PE(:, 3);PE(:,2)], [ones(nsub,1);zeros(nsub,1)], 'twochoice');
    Accuracy_per_level(n, 2) = ROC.accuracy;
    Accuracy_se_per_level(n, 2) = ROC.accuracy_se;
    Accuracy_p_per_level(n, 2) = ROC.accuracy_p;
    % level 4 vs. 3
    ROC = roc_plot([PE(:, 4);PE(:,3)], [ones(nsub,1);zeros(nsub,1)], 'twochoice');
    Accuracy_per_level(n, 3) = ROC.accuracy;
    Accuracy_se_per_level(n, 3) = ROC.accuracy_se;
    Accuracy_p_per_level(n, 3) = ROC.accuracy_p;
    
    % low vs. meduim
    ROC = roc_plot([PE_medium;PE_low], [ones(nsub,1);zeros(nsub,1)], 'twochoice');
    Accuracy_low_medium_high(n,1) = ROC.accuracy;
    Accuracy_se_low_medium_high(n,1) = ROC.accuracy_se;
    Accuracy_p_low_medium_high(n,1) = ROC.accuracy_p;
    % medium vs. high
    ROC = roc_plot([PE_high;PE_medium], [ones(nsub,1);zeros(nsub,1)], 'twochoice');
    Accuracy_low_medium_high(n,2) = ROC.accuracy;
    Accuracy_se_low_medium_high(n,2) = ROC.accuracy_se;
    Accuracy_p_low_medium_high(n,2) = ROC.accuracy_p;
    % low vs. high
    ROC = roc_plot([PE_high;PE_low], [ones(nsub,1);zeros(nsub,1)], 'twochoice');
    Accuracy_low_medium_high(n,3) = ROC.accuracy;
    Accuracy_se_low_medium_high(n,3) = ROC.accuracy_se;
    Accuracy_p_low_medium_high(n,3) = ROC.accuracy_p;
end

mean(Accuracy_low_medium_high)
mean(Accuracy_p_low_medium_high)
mean(Accuracy_per_level)
mean(Accuracy_p_per_level)

%% feature weights
% bootstrapping to identify important feature weights
btimes = 10000;
[~, stats_boot] = predict(AATpredition,  'algorithm_name', 'cv_svr', 'nfolds', 1, 'error_type', 'mse', 'bootweights', 'bootsamples', btimes,'savebootweights');
data_threshold = threshold(stats_boot.weight_obj, .05, 'fdr');

%% haufe transformation
% this step needs lots of computational resoures including memory and cpu
% please make sure you have enough memory space and time to run it(~ 1 day)
btimes = 10000;
samplesize = 91282;
Haufe_weight = zeros(samplesize,btimes);

% use fast_haufe function to save the memory requirement
for n = 1:btimes
    bx = AATpredition.dat';
    w = stats_boot.WTS.w(n,:)';
    % Haufe_weight(:,n) = cov(bx)*w/cov(w'*bx');
    bricks = 200; % this parameter is set according to computational ability
    Haufe_weight(:,n) = fast_haufe(bx,w,bricks);
    disp(['bootstrap ', num2str(n)]);
end

Haufe_bootmean = mean(Haufe_weight');
Haufe_bootste = std(Haufe_weight');
Haufe_boot_Z = Haufe_bootmean./Haufe_bootste;
Haufe_boot_p_z = 2 * (1 - normcdf(abs(Haufe_boot_Z)));
