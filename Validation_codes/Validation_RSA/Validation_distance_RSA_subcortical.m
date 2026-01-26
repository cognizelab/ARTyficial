%% low dimensioanl space
load('../../Main_codes/Stimuli_AAT_ratings.mat')
coords_2D = [dm1,dm2];
DistanceMatrix = pdist2(coords_2D,coords_2D,'euclidean');
DistanceMatrix_maha = pdist2(coords_2D,coords_2D,'mahalanobis');
DistanceMatrix_zscore = pdist2(zscore(coords_2D),zscore(coords_2D),'euclidean');

% RSA target
target_dsm_zscore=DistanceMatrix_zscore;
target_dsm_maha=DistanceMatrix_maha;

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

dsm_rand_euc = cell(1000,1);
dsm_rand_maha = cell(1000,1);

for i =1:1000
    coords_temp = [x(:,i),y(:,i)];
    dsm_rand_euc{i,1} = pdist2(coords_temp,coords_temp,'euclidean');
    dsm_rand_maha{i,1} = pdist2(coords_temp,coords_temp,'mahalanobis');
end

%% computation of cortical searchlight RSA with pseudo-path
GLMsingleD_path=g_ls('../GLMsingle/Concat_hp200_s4/R*/Surf_interp/TYPED_FITHRF_GLMDENOISE_RR.mat');
Design_DIR = g_ls('../ART/*.csv');
samplesize = 91282;

%% computation of subcortical region RSA  
% target_dsm = target_dsm_zscore;
% dsm_rand = dsm_rand_euc;

target_dsm = DistanceMatrix_maha;
dsm_rand = dsm_rand_maha;

SubsTian = cifti_read('../../Utilities/HCPtemplates/Gordon333.32k_fs_LR_Tian_Subcortex_S4.dlabel.nii');
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
    disp(['Sub-',num2str(subj)]);
end

[h,p,ci,stats] = ttest(subregions_rsm_sub_randremove);
pBon = 0.05/54;

SubcorticalTian_label(find(p<pBon),1)