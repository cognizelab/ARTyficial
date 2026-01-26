%% get the prediction models
G1_data = load('../Main_codes/Data/ART_G1_4lvl_predictiondata.mat');
G2_data = load('../Main_codes/Data/ART_G2_4lvl_predictiondata.mat');

svrobj_G1 = svr({'C=1', 'optimizer="andre"', kernel('linear')});
svrobj_G2 = svr({'C=1', 'optimizer="andre"', kernel('linear')});

dataobj_G1 = data('spider data', double(G1_data.AATpredition.dat)', G1_data.AATpredition.Y);
dataobj_G2 = data('spider data', double(G2_data.AATpredition.dat)', G2_data.AATpredition.Y);
[~, svrobj_G1] = train(svrobj_G1, dataobj_G1, loss);
[~, svrobj_G2] = train(svrobj_G2, dataobj_G2, loss);

weights_G1 = get_w(svrobj_G1)';
weights_G2 = get_w(svrobj_G2)';

%% computation model expression for each image trial
Atlas_MW=cifti_read('../Utilities/HCPtemplates/Human.MedialWall_Conte69.32k_fs_LR.dlabel.nii');
GLMsingleD_path=g_ls('../TYPED_FITHRF_GLMDENOISE_RR.mat');
Design_DIR = g_ls('../ART/*.csv');
samplesize = 91282;

subject_trials_g1reactive = zeros(34,96);
subject_trials_g2reactive = zeros(34,96);

for subj = 1:34
    ind_tmp = zeros(384,1);
    designs = Design_DIR((subj*4-3):(subj*4));
    for i = 1:4
        t_tmp = readtable(designs{i},'VariableNamingRule','preserve');
        ind_tmp((96*i-95):(96*i),1) = t_tmp.index;
    end

    betas_tmp = load(GLMsingleD_path{subj});
    betas_sqz = squeeze(betas_tmp.modelmd);
    betas_Z_tmp = [zscore(betas_sqz(1:samplesize,1:96),0,2),zscore(betas_sqz(1:samplesize,97:192),0,2),...
        zscore(betas_sqz(1:samplesize,193:288),0,2),zscore(betas_sqz(1:samplesize,289:end),0,2)];
    trial_avg_tmp = zeros(samplesize,96);
    for ttt = 1:96
        trial_avg_tmp(:,ttt) = mean(betas_Z_tmp(:,ind_tmp==ttt),2);
    end

    subject_trials_g1reactive(subj,:) = canlab_pattern_similarity(weights_G1, trial_avg_tmp, 'cosine_similarity');
    subject_trials_g2reactive(subj,:) = canlab_pattern_similarity(weights_G2, trial_avg_tmp, 'cosine_similarity');
end

% get the levels on each dimension
load('../Main_codes/Stimuli_AAT_ratings.mat')
grad_num = 4;
grad_thr = (1:(grad_num-1))/grad_num;

Qg1 = quantile(dm1,grad_thr);
DM_grades_1st = discretize(dm1,[min(dm1)-1,Qg1,max(dm1)+1]);
Qg2 = quantile(dm2,grad_thr);
DM_grades_2nd = discretize(dm2,[min(dm2)-1,Qg2,max(dm2)+1]);

% find the median response across participants
g1_response_group = median(subject_trials_g1reactive);
g2_response_group = median(subject_trials_g2reactive);

table_sorted = sortrows(t_tmp,1);
image_path = table_sorted.stim_path;

%% g1
[B,I] = mink(g1_response_group(DM_grades_1st == 1),4)
g1_lvl1_path = image_path(DM_grades_1st == 1);
g1_lvl1_path(I)

[B,I] = mink(g1_response_group(DM_grades_1st == 2),4)
g1_lvl2_path = image_path(DM_grades_1st == 2);
g1_lvl2_path(I)

[B,I] = maxk(g1_response_group(DM_grades_1st == 3),4)
g1_lvl3_path = image_path(DM_grades_1st == 3);
g1_lvl3_path(I)

[B,I] = maxk(g1_response_group(DM_grades_1st == 4),4)
g1_lvl4_path = image_path(DM_grades_1st == 4);
g1_lvl4_path(I)

%% g2

[B,I] = mink(g2_response_group(DM_grades_2nd == 1),4)
g2_lvl1_path = image_path(DM_grades_2nd == 1);
g2_lvl1_path(I)

[B,I] = mink(g2_response_group(DM_grades_2nd == 2),4)
g2_lvl2_path = image_path(DM_grades_2nd == 2);
g2_lvl2_path(I)

[B,I] = maxk(g2_response_group(DM_grades_2nd == 3),4)
g2_lvl3_path = image_path(DM_grades_2nd == 3);
g2_lvl3_path(I)

[B,I] = maxk(g2_response_group(DM_grades_2nd == 4),4)
g2_lvl4_path = image_path(DM_grades_2nd == 4);
g2_lvl4_path(I)
