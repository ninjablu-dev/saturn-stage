module Saturn

using LinearAlgebra
using Statistics

export SaturnCoefficient, AdjustedRV, standard_scaler, pairwise_euclidean

function standardize_ddof1(mat::AbstractMatrix{<:Real})
    m = mean(mat, dims=1)
    d = std(mat, dims=1) # ddof=1 di default in Julia
    d_safe = ifelse.(d .== 0, 1.0, σ)
    return (mat .- m) ./ d_safe
end

function AdjustedRV(X1::AbstractMatrix{<:Real}, X2::AbstractMatrix{<:Real}; 
                    version::String="Maye", center::Bool=true)
                    
    # 1. Verifica preliminare delle dimensioni (stesso numero di righe/campioni n)
    nrows1, ncols1 = size(X1)
    nrows2, ncols2 = size(X2)
    
    if nrows1 != nrows2
        throw(DimensionMismatch("X1 e X2 devono avere lo stesso numero di righe (campioni). Trovate: $nrows1 e $nrows2."))
    end
    
    n = nrows1
    
    # Center the matrices by subtracting the mean of each column, if specified
    if center == true
        X1 = X1 .- mean(X1, dims = 1)
        X2 = X2 .- mean(X2, dims = 1)
    end

    # Compute the cross-product matrices for X1 and X2
    AA = X1 * X1'
    BB = X2 * X2'

    if version == "Maye"
        ncols_prod = ncols1 * ncols2
        ncols_1_sq = ncols1^2
        ncols_2_sq = ncols2^2

        # Standardize X1 and X2 if needed
        X1s = standardize_ddof1(X1)
        X2s = standardize_ddof1(X2)
        AAs = X1s * X1s'
        BBs = X2s * X2s'

        # Calculate intermediate values for RV adjustment
        xy = tr(AAs * BBs) / (ncols_prod - (n-1) / (n-2) * (ncols_prod - tr(AAs * BBs) / (n-1)^2))
        xx = tr(AAs * AAs) / (ncols_1_sq - (n-1) / (n-2) * (ncols_1_sq - tr(AAs * AAs) / (n-1)^2))
        yy = tr(BBs * BBs) / (ncols_2_sq - (n-1) / (n-2) * (ncols_2_sq - tr(BBs * BBs) / (n-1)^2))

        # Calculate the adjusted RV value
        RVadj_value = (tr(AA * BB) / xy) / (sqrt(tr(AA * AA) / xx * tr(BB * BB) / yy))
        return RVadj_value

    elseif version == "Ghaziri"
        # Calculate the RV coefficient
        rv = tr(AA * BB) / sqrt(tr(AA * AA) * tr(BB * BB))
        # Calculate the mean RV under the null hypothesis
        mrvB = sqrt(tr(AA)^2 / tr(AA * AA)) * sqrt(tr(BB)^2 / tr(BB * BB)) / (n - 1)
        # Adjusted RV coefficient
        aRV = (rv - mrvB) / (1 - mrvB)
        return aRV

    else
        throw(ArgumentError("Versione non supportata: '$version'. Utilizzare 'Maye' o 'Ghaziri'."))
    end
end

function standard_scaler(mat::AbstractMatrix{<:Real})
    μ = mean(mat, dims=1)
    σ = std(mat, dims=1, corrected=false)
    σ_safe = ifelse.(σ .== 0, 1.0, σ)
    return (mat .- μ) ./ σ_safe
end

function pairwise_euclidean(mat::AbstractMatrix{<:Real})
    n = size(mat, 1)
    D = zeros(Float64, n, n)
    @inbounds for i in 1:n
        for j in (i + 1):n
            d = norm(view(mat, i, :) .- view(mat, j, :))
            D[i, j] = d
            D[j, i] = d
        end
    end
    return D
end

function SaturnCoefficient(original_matrix::AbstractMatrix{<:Real}, 
                           umap_output_layout::AbstractMatrix{<:Real};
                           version::String="Maye")
    
    # 1. Standardizzazione iniziale per feature (ddof=0, esattamente come scikit-learn)
    original_matrix_norm = standard_scaler(original_matrix)
    umap_output_layout_norm = standard_scaler(umap_output_layout)
    
    # 2. Calcolo delle matrici simmetriche delle distanze pairwise (Dx e Dy)
    original_matrix_norm_dist = pairwise_euclidean(original_matrix_norm)
    umap_output_layout_dist = pairwise_euclidean(umap_output_layout_norm)
    
    # 3. Calcolo finale dell'Adjusted RV tra le due matrici di distanza
    saturn = AdjustedRV(original_matrix_norm_dist, 
                        umap_output_layout_dist; 
                        version=version, 
                        center=true)

    return saturn
end

end # module Saturn
