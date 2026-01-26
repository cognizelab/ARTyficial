function [] = get_RSAsearchlight_results(GLMsingleD_path,Design_DIR,target_dsm,dsm_rand,nbrhood,savepath)
%% run RSA searchlight and save results
% Computes the mean absolute reconstruction error between V and its projection onto W.
%
% Inputs:
%   GLMsingleD_path - beta values
%   Design_DIR - design matrix
%   target_dsm - RSA target matrix
%   dsm_rand - distance matrices based on randomise location of dots
%   nbrhood - precalculated surface-based neighbor informantion  
%   savepath - path for saving results
% Output:
%   empty

%%
Atlas_MW=cifti_read('../../Utilities/HCPtemplates/Human.MedialWall_Conte69.32k_fs_LR.dlabel.nii');
samplesize = 59412;

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

    ds_test.samples = zeros([96,64984]);
    ds_test.samples(:,~Atlas_MW.cdata) = trial_avg_tmp';
    ds_test.a.fdim.values{1,1} = 1:64984;
    ds_test.a.fdim.labels{1,1} = 'node_indices';

    ds_test.fa.center_ids = 1:64984;
    ds_test.fa.node_indices = 1:64984;
    ds_test.sa.labels =(1:96)';
    ds_test.sa.values =(1:96)';
    ds_test.sa.targets = (1:96)';

    %%
    % set measure
    measure=@cosmo_target_dsm_corr_measure;
    measure_args=struct();
    measure_args.target_dsm=target_dsm;
    measure_args.type = 'Spearman';

    % run searchlight
    ds_rsm_behav=cosmo_searchlight(ds_test,nbrhood,measure,measure_args,'nproc',20);
   
    %permutaion with null distribution
    rsa_tmp_rands = zeros(1000,64984);
    for ri = 1:1000
        measure_rand=@cosmo_target_dsm_corr_measure;
        measure_args_rand=struct();
        measure_args_rand.target_dsm=dsm_rand{ri};
        measure_args_rand.type = 'Spearman';
        ds_rsm_rand=cosmo_searchlight(ds_test,nbrhood,measure_rand,measure_args_rand,'nproc',20);
        rsa_tmp_rands(ri,:) = ds_rsm_rand.samples;
    end
    
    save([savepath,num2str(subj,'%02d'),'_RSA.mat'],'rsa_tmp_rands','ds_rsm_behav','-v7.3');

end

end