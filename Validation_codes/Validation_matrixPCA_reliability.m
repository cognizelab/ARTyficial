%% Aesthetic ratings
load('../Main_codes/Data/Stimuli_AAT_ratings.mat','AAT_ratings')

% all sample used for similarity matrix and further PCA
AllSamples = AAT_ratings(:,1:33)';

% aesthetic agreement matrix
AAT_RSM = corr(AllSamples,'type','Pearson');


%% split-half reliability
nSub = 33;
nIter = 1000;
K=10;

splits = cell(nIter, 2);  % each row: {group1, group2}
rng(1);  % for reproducibility


r_half_scores = zeros(K,nIter); % correlation between PC scores
trr_splithalf_scores = zeros(K,nIter); % test-retest reliability between PC scores
RV_mat_splithalf = zeros(nIter,1);  % CI of matrix structures
CI_struct_splithalf = zeros(K,nIter); % CI of PCA structures

for i = 1:nIter
    % random split
    idx = randperm(nSub); 
    splits{i,1} = idx(1:17);     % first half
    splits{i,2} = idx(18:end);    % second half

    X1 = corr(AllSamples(idx(1:17),:),'type','Pearson');
    X2 = corr(AllSamples(idx(18:end),:),'type','Pearson');
    
    [~, RV_mat_splithalf(i,1), ~] = pca_structure_comparison(X1, X2);

    % PCA in each half
    [coeff1,score1,~,~,~,mu1] = pca(X1, 'Centered', true);
    [coeff2, ~] = pca(X2, 'Centered', true);

    coeff1 = coeff1(:,1:10);
    coeff2 = coeff2(:,1:10);
    
    X2_centered = X2 - mu1;
    score2 = X2_centered * coeff1;

    for n = 1:10
        A = coeff1(:,1:n);
        B = coeff2(:,1:n);

        [CI_struct_splithalf(n,i), ~, ~] = pca_structure_comparison(A, B);

        r_half_scores(n,i)  = corr(score1(:,n),score2(:,n));
        trr_splithalf_scores(n,i) = 2*r_half_scores(n,i)/(1+r_half_scores(n,i));
    end
    disp(num2str(i));

end


%% bootstrap analysis

% X: subjects × variables
[coeff_ref,score_ref,~,~,~,mu1_ref] = pca(AAT_RSM, 'Centered', true);

K =10;
coeff_ref = coeff_ref(:,1:K);

nSubj = 33;
nBoot = 1000;

r_boot_scores = zeros(K,nBoot); 
trr_boot_scores = zeros(K,nBoot);
CI_struct_boot = zeros(K, nBoot);
RV_mat_boot = zeros(nBoot,1);  

for b = 1:nBoot
    
    % --- resample subjects ---
    idx = randsample(nSubj, nSubj, true);
    Xb = corr(AllSamples(idx,:),'type','Pearson');
    
    [~, RV_mat_boot(b,1), ~] = pca_structure_comparison(AAT_RSM, Xb);

    % --- PCA on bootstrap sample ---
    [coeff_b,  ~, ~] = pca(Xb, 'Centered', true);
    coeff_b = coeff_b(:,1:K);

    Xb_centered = Xb - mu1_ref;
    scoreb = Xb_centered * coeff_ref;

    % --- iterative CI for first n components ---
    for n = 1:K
        A = coeff_ref(:,1:n);
        B = coeff_b(:,1:n);

        [CI_struct_boot(n,b), ~, ~] = pca_structure_comparison(A, B);
        r_boot_scores(n,b)  = corr(score_ref(:,n),scoreb(:,n));
        trr_boot_scores(n,b) = 2*r_boot_scores(n,b)/(1+r_boot_scores(n,b));
    end
    disp(num2str(b));
end

% save results
save('Validation_reliability.mat',...
    "trr_splithalf_scores","RV_mat_splithalf","CI_struct_splithalf",...
    "RV_mat_boot","CI_struct_boot","r_boot_scores");
