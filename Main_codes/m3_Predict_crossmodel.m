%% cross dimension validation
addpath('../Utilities/')

nsub = 34;
nlevel = 4;
G1_data = load('Data/ART_G1_4lvl_predictiondata.mat');
G2_data = load('Data/ART_G2_4lvl_predictiondata.mat');

%% permutation for labels
% --- Parameters ---
nParticipants = 34;
nLabels = 4;
nPermutations = 1000;

% --- Pre-allocation ---
% We create a 3D matrix to store the results:
% Dimension 1: 34 Participants
% Dimension 2: 4 Labels
% Dimension 3: 1000 Iterations
shuffled_data = zeros(nParticipants, nLabels, nPermutations);

% --- Execution ---
% Set a seed for reproducibility (optional)
rng('default'); 

for k = 1:nPermutations
    for i = 1:nParticipants
        % randperm(4) returns a random permutation of integers 1 to 4
        shuffled_data(i, :, k) = randperm(nLabels);
    end
end

permuted_data = permute(shuffled_data, [2, 1, 3]);
suffled_Y = reshape(permuted_data, [], 1000);

%% cross prediction based on 10-fold cross-validation with permutations
acc_inter=zeros(2,10,10);
acc_within=zeros(2,10);

acc_model1predict2 = zeros(1000,10);
acc_model2predict1 = zeros(1000,10);
acc_model1predict1 = zeros(1000,10);
acc_model2predict2 = zeros(1000,10);

for repeat = 1:10
    CVindex = GenerateCV(nsub, nlevel, repeat,10);
    [~, stats_G1] = predict(G1_data.AATpredition,  'algorithm_name', 'cv_svr', 'nfolds', CVindex, 'error_type', 'mse');
    [~, stats_G2] = predict(G2_data.AATpredition,  'algorithm_name', 'cv_svr', 'nfolds', CVindex, 'error_type', 'mse');
    acc_within(1,repeat) = stats_G1.pred_outcome_r;
    acc_within(2,repeat) = stats_G2.pred_outcome_r;

    cv_predict12 = zeros(1000,10);
    cv_predict21 = zeros(1000,10);
    cv_predict11 = zeros(1000,10);
    cv_predict22 = zeros(1000,10);
    for cv_i = 1:10
        cv_Y_a = G1_data.AATpredition.Y(CVindex==cv_i);
        dat_subj_a = G1_data.AATpredition.dat(:, CVindex==cv_i);
        cv_Y_c = G2_data.AATpredition.Y(CVindex==cv_i);
        dat_subj_c = G2_data.AATpredition.dat(:, CVindex==cv_i);

        a_weights =stats_G1.other_output_cv{cv_i,1}(:,1);
        cv_a_c = a_weights' * dat_subj_c;
        acc_inter(1,cv_i,repeat) = corr(cv_Y_c,cv_a_c');

        c_weights =stats_G2.other_output_cv{cv_i,1}(:,1);
        cv_c_a = c_weights' * dat_subj_a;
        acc_inter(2,cv_i,repeat) = corr(cv_Y_a,cv_c_a');

        cv_a_a = a_weights' * dat_subj_a;
        cv_c_c = c_weights' * dat_subj_c;
        cv_predict12(:,cv_i) =  corr(suffled_Y(CVindex==cv_i,:),cv_a_c');
        cv_predict21(:,cv_i) =  corr(suffled_Y(CVindex==cv_i,:),cv_c_a');
        cv_predict11(:,cv_i) =  corr(suffled_Y(CVindex==cv_i,:),cv_a_a');
        cv_predict22(:,cv_i) =  corr(suffled_Y(CVindex==cv_i,:),cv_c_c');
    end

    acc_model1predict2(:,repeat) = mean(cv_predict12,2);
    acc_model2predict1(:,repeat) = mean(cv_predict21,2);
    acc_model1predict1(:,repeat) = mean(cv_predict11,2);
    acc_model2predict2(:,repeat) = mean(cv_predict22,2);
end

cross_repeats =squeeze(mean(acc_inter,2))';
in_repeats = acc_within';

% permutated difference between predictive accuracies
dist_diff_model1 = (acc_model1predict1-acc_model1predict2);
dist_diff_model2 = (acc_model2predict2-acc_model2predict1);

diff_1to2 = crossprediction_data_plot(:,2)-crossprediction_data_plot(:,1);
diff_2to1 = crossprediction_data_plot(:,3)-crossprediction_data_plot(:,4);

pperm1to2 = 1-sum(mean(diff_1to2)>mean(dist_diff_model1,2))/1000;
pperm2to1 = 1-sum(mean(diff_2to1)>mean(dist_diff_model2,2))/1000;

save('Dissociation_Permutation.mat','crossprediction_data_plot','dist_diff_model1','dist_diff_model2');

crossprediction_data_plot = [cross_repeats(:,1),in_repeats,cross_repeats(:,2)];
boxplot([cross_repeats(:,1),in_repeats,cross_repeats(:,2)])

% test the indivdiual predictive performance between models 
[h,p,ci,stats] =ttest(crossprediction_data_plot(:,2),crossprediction_data_plot(:,1))
[h,p,ci,stats] =ttest(crossprediction_data_plot(:,3),crossprediction_data_plot(:,4))