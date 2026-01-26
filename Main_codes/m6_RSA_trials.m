%% low dimensioanl space
load('Data/Stimuli_AAT_ratings.mat')
coords_2D = [dm1,dm2];
DistanceMatrix = pdist2(coords_2D,coords_2D,'euclidean');
%imagesc(DistanceMatrix)
%set(gca,'XTick',1:96,'YTick',1:96)

% RSA target
target_dsm=DistanceMatrix;

%% null distribution
n = 96;
R = 2.5;
x0 = 0; % Center of the circle in the x direction.
y0 = 0; % Center of the circle in the y direction.
% Now create the set of points.
rng(0)
t = 2*pi*rand(n,1000);
r = R*sqrt(rand(n,1000));
x = x0 + r.*cos(t);
y = y0 + r.*sin(t);

dsm_rand = cell(1000,1);
for i =1:1000
    coords_temp = [x(:,i),y(:,i)];
    dsm_rand{i,1} = pdist2(coords_temp,coords_temp,'euclidean');
end

%% preparing searchlight to obtain surface-based neighbor informantion  
% wm_surf_L = gifti('../HCP_S1200_Atlas/S1200.L.white_MSMAll.32k_fs_LR.surf.gii');
% wm_surf_R = gifti('../HCP_S1200_Atlas/S1200.R.white_MSMAll.32k_fs_LR.surf.gii');
% gm_surf_L = gifti('../HCP_S1200_Atlas/S1200.L.pial_MSMAll.32k_fs_LR.surf.gii');
% gm_surf_R = gifti('../HCP_S1200_Atlas/S1200.R.pial_MSMAll.32k_fs_LR.surf.gii');
% 
% v_wm = double([wm_surf_L.vertices;wm_surf_R.vertices]);
% f_wm = double([wm_surf_L.faces;wm_surf_R.faces+32492]);
% v_gm = double([gm_surf_L.vertices;gm_surf_R.vertices]);
% f_gm = double([gm_surf_L.faces;gm_surf_R.faces+32492]);
% feature_count=50;
% make the data for COSMO
% surf2_def={v_gm,v_wm,f_gm};
% ds_test.samples = zeros(1,64984);
% ds_test.a.fdim.values{1,1} = 1:64984;
% ds_test.a.fdim.labels{1,1} = 'node_indices';
% ds_test.fa.center_ids = 1:64984;
% ds_test.fa.node_indices = 1:64984;
% ds_test.sa.labels =1;
% ds_test.sa.values =1;
% ds_test.sa.targets =1;
% [nbrhood,vo,fo,out2in]=cosmo_surficial_neighborhood(ds_test, surf2_def, 'count',feature_count);
load('Data/nbrhood.mat')

%% computation of cortical searchlight RSA with pseudo-path
Atlas_MW=cifti_read('../Utilities/HCPtemplates/Human.MedialWall_Conte69.32k_fs_LR.dlabel.nii');
GLMsingleD_path=g_ls('../R*/Surf_interp/TYPED_FITHRF_GLMDENOISE_RR.mat');
Design_DIR = g_ls('../ART/*.csv');
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
    ds_rsm_behav=cosmo_searchlight(ds_test,nbrhood,measure,measure_args,'nproc',4);
   
    %permutaion with null distribution
    rsa_tmp_rands = zeros(1000,64984);
    for ri = 1:1000
        measure_rand=@cosmo_target_dsm_corr_measure;
        measure_args_rand=struct();
        measure_args_rand.target_dsm=dsm_rand{ri};
        measure_args_rand.type = 'Spearman';
        ds_rsm_rand=cosmo_searchlight(ds_test,nbrhood,measure_rand,measure_args_rand,'nproc',5);
        rsa_tmp_rands(ri,:) = ds_rsm_rand.samples;
    end
    
    save(['../RSA_results/',num2str(subj,'%02d'),'_RSA.mat'],'rsa_tmp_rands','ds_rsm_behav','-v7.3');
end

% load results
RSAfiles = g_ls('../RSA_results/*.mat');
surf_ds.samples = zeros(34,64984);
surf_ds.a.fdim.values{1,1} = 1:64984;
surf_ds.a.fdim.labels{1,1} = 'node_indices';
surf_ds.fa.center_ids = 1:64984;
surf_ds.fa.node_indices = 1:64984;
surf_ds.sa.labels =(1:34)';
surf_ds.sa.values =(1:34)';
surf_ds.sa.targets = ones([34,1]);
surf_ds.sa.chunks = (1:34)';
rand_map_avg = zeros(34,64984);
for i = 1:34
    tmpfile= load(RSAfiles{i});
    surf_ds.samples(i,:) = tmpfile.ds_rsm_behav.samples;
    rand_map_avg(i,:) = mean(atanh(tmpfile.rsa_tmp_rands));
    disp(['Subnum-',num2str(i),' Done!']);
end

surf_ds.samples(isnan(surf_ds.samples))=0;
rand_map_avg(isnan(rand_map_avg))=0;
rs_adjusted = atanh(surf_ds.samples)-rand_map_avg;
[h,p,ci,stats] = ttest(rs_adjusted);


%% Run Threshold-Free Cluster Enhancement (TFCE)
surf_L = gifti('../Utilities/HCPtemplates/S1200.L.inflated_MSMAll.32k_fs_LR.surf.gii');
surf_R = gifti('../Utilities/HCPtemplates/S1200.R.inflated_MSMAll.32k_fs_LR.surf.gii');
avsurf.coord = [surf_L.vertices;surf_R.vertices]';
avsurf.tri =  [surf_L.faces;surf_R.faces+32492];
vertices_avsurf = double(avsurf.coord');
faces_avsurf = double(avsurf.tri);

% define neighborhood for each feature
surf_ds_test = surf_datas{k};
cluster_nbrhood=cosmo_cluster_neighborhood(surf_ds_test,'vertices',vertices_avsurf,'faces',faces_avsurf);

opt=struct();
opt.niter=5000;
opt.h0_mean=0;
opt.null=[];

% Run TFCE-based cluster correction for multiple comparisons.
% The output has z-scores for each node indicating the probablity to find the same, or higher, TFCE value under the null hypothesis
tfce_ds_test=cosmo_montecarlo_cluster_stat(surf_ds_test,cluster_nbrhood,opt);
tfce_results = tfce_ds_test;
RSAsignificant_vertices = tfce_results.samples>1.96;

%% computation of subcortical region RSA  
SubsTian = cifti_read('../Utilities/HCPtemplates/Gordon333.32k_fs_LR_Tian_Subcortex_S4.dlabel.nii');
SubcorticalTian = squeeze(struct2cell(SubsTian.diminfo{1,2}.maps.table))';
SubcorticalTian_label = SubcorticalTian(2:55,1:2);
SubcorticalTian_indices = SubsTian.cdata;
SubcorticalTian_indices(1:59412,1)=0;
for i=1:54
    subcnum(i) = sum(SubcorticalTian_indices==i);
end

dsm_target_vec=cosmo_squareform(target_dsm,'tovector')';
subregions_rsm_sub = zeros(34,54);
subregions_rsm_sub_randremove = zeros(34,54);

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

    sub_r_tmp = zeros(1,54);
    % permutaion with null distribution
    sub_r_tmp_rand = zeros(1,54);
    for j =1:54

        region_beta_tmp = trial_avg_tmp(SubcorticalTian_indices==j,:);
        region_rdm_tmp_vec = cosmo_pdist(region_beta_tmp','correlation');
        [sub_r_tmp(1,j),~] = corr(region_rdm_tmp_vec',dsm_target_vec,'type','Spearman');

        rsa_tmp_rands = zeros(1000,1);
        for ri = 1:1000
            [rsa_tmp_rands(ri),~] = corr(region_rdm_tmp_vec',cosmo_squareform(dsm_rand{ri},'tovector')','type','Spearman');
        end
        sub_r_tmp_rand(1,j) = atanh(sub_r_tmp(1,j)) - mean(atanh(rsa_tmp_rands));

    end
    subregions_rsm_sub(subj,:)=sub_r_tmp;
    subregions_rsm_sub_randremove(subj,:)=sub_r_tmp_rand;
end

[h,p,ci,stats] = ttest(subregions_rsm_sub_randremove);
pBon = 0.05/54;