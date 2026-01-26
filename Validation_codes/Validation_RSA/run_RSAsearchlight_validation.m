%%  
% Given the sustantial computational resources required by the searchlight analysis, 
% all validation analyses were conducted on server clusters using parallel computation.
% We highly recommend confirming the available RAM (>16GB) and the number of threads (>4) for
% the parallel pool before running this analysis.

%% low dimensioanl space
load('../../Main_codes/Stimuli_AAT_ratings.mat')
coords_2D = [dm1,dm2];

%% preparing searchlight to obtain surface-based neighbor informantion  
% 
% feature_count=[10,20,30,40,50];
% 
% surf_L = gifti('../HCP_S1200_Atlas/S1200.L.inflated_MSMAll.32k_fs_LR.surf.gii');
% surf_R = gifti('../HCP_S1200_Atlas/S1200.R.inflated_MSMAll.32k_fs_LR.surf.gii');
% avsurf.coord = [surf_L.vertices;surf_R.vertices]';
% avsurf.tri =  [surf_L.faces;surf_R.faces+32492];

% wm_surf_L = gifti('../HCP_S1200_Atlas/S1200.L.white_MSMAll.32k_fs_LR.surf.gii');
% wm_surf_R = gifti('../HCP_S1200_Atlas/S1200.R.white_MSMAll.32k_fs_LR.surf.gii');
% gm_surf_L = gifti('../HCP_S1200_Atlas/S1200.L.pial_MSMAll.32k_fs_LR.surf.gii');
% gm_surf_R = gifti('../HCP_S1200_Atlas/S1200.R.pial_MSMAll.32k_fs_LR.surf.gii');
% 
% v_wm = double([wm_surf_L.vertices;wm_surf_R.vertices]);
% f_wm = double([wm_surf_L.faces;wm_surf_R.faces+32492]);
% v_gm = double([gm_surf_L.vertices;gm_surf_R.vertices]);
% f_gm = double([gm_surf_L.faces;gm_surf_R.faces+32492]);
% 
% % make the data for COSMO
% surf2_def={v_gm,v_wm,f_gm};
% ds_test.samples = zeros(1,64984);
% ds_test.a.fdim.values{1,1} = 1:64984;
% ds_test.a.fdim.labels{1,1} = 'node_indices';
% ds_test.fa.center_ids = 1:64984;
% ds_test.fa.node_indices = 1:64984;
% ds_test.sa.labels =1;
% ds_test.sa.values =1;
% ds_test.sa.targets =1;
% nbrhood_multilevels = cell(5,1);
% for i =1:5
%     [nbrhood,vo,fo,out2in]=cosmo_surficial_neighborhood(ds_test, surf2_def, 'count',feature_count(i));
%     nbrhood_multilevels{i} = nbrhood;
% end
% save('/Users/liangxinyu/Documents/Projects/ART_Final/Validation_codes_NC/nbrhood_multilevels.mat','nbrhood_multilevels')
load('nbrhood_multilevels.mat')

%% load single-trial betas and task designs
GLMsingleD_path=g_ls('../GLMsingle/Concat_hp200_s4/R*/Surf_interp/TYPED_FITHRF_GLMDENOISE_RR.mat');
Design_DIR = g_ls('../ART/*.csv');

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


%% target validation

% RSA target - normalized scores
DistanceMatrix_zscore = pdist2(zscore(coords_2D),zscore(coords_2D),'euclidean');
target_dsm_zscore=DistanceMatrix_zscore;
nbrhood_zscore = nbrhood_multilevels{5};
savepath_zscore = '';
get_RSAsearchlight_results(GLMsingleD_path,Design_DIR,target_dsm_zscore,dsm_rand_euc,nbrhood_zscore,savepath_zscore)


% RSA target - mahalanobis distance
DistanceMatrix_maha = pdist2(coords_2D,coords_2D,'mahalanobis');
target_dsm_maha=DistanceMatrix_maha;
nbrhood_maha = nbrhood_multilevels{5};
savepath_maha = '';
get_RSAsearchlight_results(GLMsingleD_path,Design_DIR,target_dsm_maha,dsm_rand_maha,nbrhood_maha,savepath_maha)


%% searchlight size validation

DistanceMatrix = pdist2(coords_2D,coords_2D,'euclidean');
target_dsm=DistanceMatrix;
for i = 1:4
    nbrhood_zscore = nbrhood_multilevels{i};
    savepath_zscore = '';
    get_RSAsearchlight_results(GLMsingleD_path,Design_DIR,target_dsm,dsm_rand_euc,nbrhood_zscore,savepath_zscore)
end

