%% TFCE correction based on results

% RSA_all_files = g_ls('/Users/liangxinyu/Documents/Projects/ART_Final/ART_MatlabCodes/RSA_results_Spearman/R*_RSA.mat');
% 
% RSAinds = zeros(64984,34);
% for i = 1:34
%     cortdata = load(RSA_all_files{i});
%     temp_cort = atanh(cortdata.ds_rsm_behav.samples(1,:));
%     temp_cort_rand_avg = mean(atanh(cortdata.rsa_tmp_rands));
%     RSAinds(:,i) = (temp_cort-temp_cort_rand_avg)';
% end

% load individual RSA maps
RSA_Eucli = load('RSAsearchlight_results/RSAsearchlight_Euclidean.mat');
RSA_Zscore= load('RSAsearchlight_results/RSAsearchlight_zscores.mat');
RSA_Maha = load('RSAsearchlight_results/RSAsearchlight_maha.mat');
RSA_size10 = load('RSAsearchlight_results/RSAsearchlight_sl_size10.mat');
RSA_size20 = load('RSAsearchlight_results/RSAsearchlight_sl_size20.mat');
RSA_size30 = load('RSAsearchlight_results/RSAsearchlight_sl_size30.mat');
RSA_size40 = load('RSAsearchlight_results/RSAsearchlight_sl_size40.mat');

% construct CoSMoMVPA datasets
surf_ds.a.fdim.values{1,1} = 1:64984;
surf_ds.a.fdim.labels{1,1} = 'node_indices';
surf_ds.fa.center_ids = 1:64984;
surf_ds.fa.node_indices = 1:64984;
surf_ds.sa.labels =(1:34)';
surf_ds.sa.values =(1:34)';
surf_ds.sa.targets = ones([34,1]);
surf_ds.sa.chunks = (1:34)';

surf_ds_euc = surf_ds; surf_ds_euc.samples = RSA_Eucli.RSAinds;
surf_ds_zscore = surf_ds; surf_ds_zscore.samples = RSA_Zscore.RSAinds;
surf_ds_maha = surf_ds; surf_ds_maha.samples = RSA_Maha.RSAinds;
surf_ds_size10 = surf_ds; surf_ds_size10.samples = RSA_size10.RSAinds;
surf_ds_size20 = surf_ds; surf_ds_size20.samples = RSA_size20.RSAinds;
surf_ds_size30 = surf_ds; surf_ds_size30.samples = RSA_size30.RSAinds;
surf_ds_size40 = surf_ds; surf_ds_size40.samples = RSA_size40.RSAinds;



%% load surfaces
surf_L = gifti('../../Utilities/HCPtemplates/S1200.L.inflated_MSMAll.32k_fs_LR.surf.gii');
surf_R = gifti('../../Utilities/HCPtemplates/S1200.R.inflated_MSMAll.32k_fs_LR.surf.gii');
avsurf.coord = [surf_L.vertices;surf_R.vertices]';
avsurf.tri =  [surf_L.faces;surf_R.faces+32492];
vertices_avsurf = double(avsurf.coord');
faces_avsurf = double(avsurf.tri);
Atlas_MW=cifti_read('../../Utilities/HCPtemplates/Human.MedialWall_Conte69.32k_fs_LR.dlabel.nii');

%%
surf_datas = {surf_ds_euc;surf_ds_zscore;surf_ds_maha;...
    surf_ds_size10;surf_ds_size20;surf_ds_size30;surf_ds_size40};

%% Run Threshold-Free Cluster Enhancement (TFCE)
% All data is prepared; 
% We want to see if there are clusters that show a significant difference from zero in their response. 
% Thus, .sa.targets is set to all ones (the same condition), 
% whereas .sa.chunks is set to (1:34)', indicating that all samples are assumed to be independent.

tfce_results = cell(7,1);
for k = 1:7
    % define neighborhood for each feature
    % (cosmo_cluster_neighborhood can be used also for meeg or volumetric fmri datasets)

    surf_ds_test = surf_datas{k};
    cluster_nbrhood=cosmo_cluster_neighborhood(surf_ds_test,'vertices',vertices_avsurf,'faces',faces_avsurf);

    opt=struct();
    % number of null iterations. for publication-quality, use >=1000;
    % 10000 is even better
    opt.niter=5000;

    % in this case we run a one-sample test against a mean of 0, and it is necessary to specify the mean under the null hypothesis
    % (when testing classification accuracies, h0_mean should be set to chance level, assuming a balanced crossvalidation scheme was used)
    opt.h0_mean=0;

    % this example uses the data itself (with resampling) to obtain cluster statistcs under the null hypothesis. This is (in this case) somewhat
    % conservative due to how the resampling is performed.
    % Alternatively, and for better estimates (at the cost of computational cost), one can generate a set of (say, 50) datasets using permuted data
    % e.g. using cosmo_randomize_targets), put them in a cell and provide them as the null argument.
    opt.null=[];

    % Run TFCE-based cluster correction for multiple comparisons.
    % The output has z-scores for each node indicating the probablity to find the same, or higher, TFCE value under the null hypothesis
    tfce_ds_test=cosmo_montecarlo_cluster_stat(surf_ds_test,cluster_nbrhood,opt);
    tfce_results{k} = tfce_ds_test;
end

dice_all = zeros(7,7);
for i = 1:7
    for j = 1:7
        dice_all(i,j) = dice(tfce_results{i}.samples>1.96,tfce_results{j}.samples>1.96);
    end
end

% save dice coefficients
save('TFCE_results_5k_ALL.mat','tfce_results','dice_all');

% visualization
% SurfStatViewData_lxy(tfce_ds.samples.*(tfce_ds.samples>1.96), avsurf, [-5,5], 'Z-map', 'Hori')