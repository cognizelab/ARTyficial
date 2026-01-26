%% Aesthetic agreement matrix and PCA results
addpath('../Utilities/')
load('../Main_codes/Data/Stimuli_AAT_ratings.mat','AAT_ratings')

AAT_RSM = corr(AAT_ratings(:,1:33)','type','Pearson');
AAT_mean = mean(AAT_ratings(:,1:33),2);

% decompose the matrix by using PCA
[coeff, score, latent, tsquared, explained, mu] = pca(AAT_RSM);
AAT_PCs = score(:,1:10);
[coeff_orgin, score_orgin, latent_orgin, tsquared_orgin, explained_orgin, mu_orgin] = pca(AAT_ratings(:,1:33));

%% significant of pc components in AAT similarity matrix using Jolliffe’s criteria (eigenvalues > 0.7)
pcid = find(latent(1:2)>0.7)

% parallel analysis
[n_components, actual_eigenvalues, pa_eigenvalues_95] = parallel_analysis(AAT_RSM, 1000);

%% the independent between two component scores
[r_ind,p_ind] = corr(AAT_PCs(:,1),AAT_PCs(:,2))

%% results plot
% component loadings
loadings = coeff .* sqrt(latent)';
imagesc(loadings(:,1:10))

% cumulative variance
cumExplained = cumsum(explained);
figure;
plot(cumExplained(1:40), '-o', 'LineWidth', 2);
xlabel('Number of Principal Components');
ylabel('Cumulative Variance Explained (%)');
title('PCA Cumulative Variance Explained');
grid on;

save('PCA_results_plot.mat',"loadings","n_components","actual_eigenvalues","pa_eigenvalues_95","cumExplained","explained")