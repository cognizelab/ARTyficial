function [similarity_score, RV_coeff, B_rotated] = pca_structure_comparison(LoadingsA, LoadingsB)
    % INPUTS:
    % LoadingsA: (N_features x 10) Target structure
    % LoadingsB: (N_features x 10) Structure to align
    %
    % OUTPUTS:
    % similarity_score: A measure of fit (1 = perfect identity, 0 = no match)
    % RV_coeff: The RV coefficient (multivariate correlation)
    % B_rotated: The LoadingsB matrix after being rotated to match A
    
    %% Method 1: Orthogonal Procrustes Analysis (OPA)
    % We want to find Rotation Matrix Q such that norm(A - B*Q) is minimized.
    % We do NOT translate (center) because PCA origin (0,0) is meaningful.
    
    % 1. Calculate A' * B
    C = LoadingsA' * LoadingsB;
    
    % 2. SVD of the product
    [U, ~, V] = svd(C);
    
    % 3. Calculate optimal Rotation Matrix Q
    % Q = V * U'
    Q = V * U';
    
    % 4. Rotate B
    B_rotated = LoadingsB * Q;
    
    % 5. Calculate Similarity Score (Congruence after Rotation)
    % This is the trace of the product of normalized matrices (Cosine similarity of matrices)
    numerator = trace(LoadingsA' * B_rotated);
    denominator = sqrt(trace(LoadingsA' * LoadingsA) * trace(B_rotated' * B_rotated));
    similarity_score = numerator / denominator;
    
    
    %% Method 2: RV Coefficient
    % A scalar measure of similarity between two matrices (0 to 1)
    % Formula: tr(A*A' * B*B') / sqrt(tr((A*A')^2) * tr((B*B')^2))
    % Note: Using XX' is more efficient if N_features < N_dims, 
    % but usually N_features > 10, so we use X'X form which is equivalent for trace.
    
    AA = LoadingsA * LoadingsA';
    BB = LoadingsB * LoadingsB';
    
    num_rv = trace(AA * BB);
    den_rv = sqrt(trace(AA * AA) * trace(BB * BB));
    RV_coeff = num_rv / den_rv;
    
    %% Display Results
    % fprintf('--- Structural Comparison (10 Dimensions) ---\n');
    % fprintf('1. Procrustes Similarity (after optimal rotation): %.4f\n', similarity_score);
    % fprintf('   (This represents the overlap of the two subspaces)\n');
    % fprintf('2. RV Coefficient: %.4f\n', RV_coeff);
    
end