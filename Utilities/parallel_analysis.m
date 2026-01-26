function [n_components, actual_eigenvalues, pa_eigenvalues_95] = parallel_analysis(X, n_simulations)
% parallel_analysis performs Horn's Parallel Analysis for PCA component retention.
%
% Inputs:
%   X (N x P matrix): Your data matrix (N observations, P variables).
%   n_simulations: The number of random datasets to simulate (e.g., 500 or 1000).
%
% Outputs:
%   n_components: The recommended number of principal components to retain.
%   actual_eigenvalues: Eigenvalues from the PCA on your actual data.
%   pa_eigenvalues_95: The 95th percentile eigenvalues from the random data.
%
% Note: The 'pca' function in MATLAB standardizes the data by default
% (uses the correlation matrix), which is the standard practice for PA.

% --- 1. Get data dimensions and initialize ---
[N, P] = size(X); % N = observations, P = variables
simulated_eigenvalues = zeros(n_simulations, P-1);

% --- 2. Calculate Actual Eigenvalues ---
% The 'latent' output of pca contains the eigenvalues (variance explained)
[~, ~, actual_latent] = pca(X);
actual_eigenvalues = actual_latent'; % Ensure it's a row vector of P elements

% --- 3. Monte Carlo Simulation for Random Eigenvalues ---
for i = 1:n_simulations
    % Generate a random data matrix of the same size (N x P)
    % from a standard normal distribution (uncorrelated, pure noise).
    % X_random = randn(N, P);

    X_random = corr(randn(96,33)','type','Spearman');
    % Perform PCA on the random data
    % Since the data is already standardized noise, we use the covariance
    % or correlation matrix. 'pca' handles this by default.
    [~, ~, random_latent] = pca(X_random);
    
    % Store the eigenvalues
    simulated_eigenvalues(i, :) = random_latent';
end

% --- 4. Calculate the Reference (95th Percentile) Eigenvalues ---
% For each component (column), find the 95th percentile eigenvalue across all simulations.
pa_eigenvalues_95 = prctile(simulated_eigenvalues, 95);

% --- 5. Determine the Number of Components to Retain ---
% Retain components where the actual eigenvalue is GREATER than the 95th percentile
% random eigenvalue.
retained_components = actual_eigenvalues(1:10) > pa_eigenvalues_95(1:10);
n_components = sum(retained_components);

% --- 6. Plot the Results (Scree Plot) ---
npc = 30;

figure;
plot(1:npc, actual_eigenvalues(1:npc), '-o', 'LineWidth', 2, 'DisplayName', 'Actual Eigenvalues');
hold on;
plot(1:npc, pa_eigenvalues_95(1:npc), '--x', 'LineWidth', 2, 'DisplayName', 'PA 95th Percentile Threshold');
plot(1:npc, 0.7*ones(1, npc), '--k', 'DisplayName', 'Jolliffe (\lambda = 0.7)'); % Kaiser line for reference

xlabel('Principal Component Number');
ylabel('Eigenvalue (Variance Explained)');
title('Horn''s Parallel Analysis for PCA Component Retention');
legend('show', 'Location', 'Northeast');
grid on;

% Highlight the recommended number of components
if n_components > 0
    xline(n_components + 0.5, 'r-', 'LineWidth', 1, ...
        'Label', ['Retain ' num2str(n_components) ' Components']);
end

hold off;

disp(' ');
disp('--- Parallel Analysis Results ---');
disp(['Recommended number of components to retain: ' num2str(n_components)]);
disp('---------------------------------');

end