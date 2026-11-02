module Saturn

import Pkg

# 1. Funzione per verificare ed installare i pacchetti mancanti
function check_and_install_packages(packages::Vector{String})
    installed = keys(Pkg.project().dependencies)
    missing_pkgs = String[]
    
    for pkg in packages
        if !(pkg in installed)
            push!(missing_pkgs, pkg)
        end
    end
    
    if !isempty(missing_pkgs)
        println("[JULIA - Saturn.jl] Pacchetti mancanti rilevati: ", join(missing_pkgs, ", "))
        println("[JULIA - Saturn.jl] Inizio installazione automatica...")
        Pkg.add(missing_pkgs)
    end
end

# Controllo dipendenze essenziali del modulo
REQUIRED_PACKAGES = ["Statistics", "LinearAlgebra"]
check_and_install_packages(REQUIRED_PACKAGES)

using Statistics
using LinearAlgebra

export standard_scaler, standardize_ddof1, pairwise_euclidean, AdjustedRV, SaturnCoefficient

"""
Standardizzazione ddof=0 in-place senza allocare nuove matrici.
"""
function standard_scaler!(out::Matrix{Float64}, mat::Matrix{Float64})
    n, p = size(mat)
    @inbounds for j in 1:p
        μ = 0.0
        @simd for i in 1:n
            μ += mat[i, j]
        end
        μ /= n
        
        var_sum = 0.0
        @simd for i in 1:n
            diff = mat[i, j] - μ
            var_sum += diff * diff
        end
        σ = sqrt(var_sum / n)
        σ_safe = σ == 0.0 ? 1.0 : σ
        
        @simd for i in 1:n
            out[i, j] = (mat[i, j] - μ) / σ_safe
        end
    end
    return out
end

function standard_scaler(mat::Matrix{Float64})
    out = similar(mat)
    return standard_scaler!(out, mat)
end

function standardize_ddof1!(out::Matrix{Float64}, mat::Matrix{Float64})
    n, p = size(mat)
    @inbounds for j in 1:p
        μ = 0.0
        @simd for i in 1:n
            μ += mat[i, j]
        end
        μ /= n
        
        var_sum = 0.0
        @simd for i in 1:n
            diff = mat[i, j] - μ
            var_sum += diff * diff
        end
        σ = sqrt(var_sum / (n - 1))
        σ_safe = σ == 0.0 ? 1.0 : σ
        
        @simd for i in 1:n
            out[i, j] = (mat[i, j] - μ) / σ_safe
        end
    end
    return out
end

function standardize_ddof1(mat::Matrix{Float64})
    out = similar(mat)
    return standardize_ddof1!(out, mat)
end

"""
Calcolo ultra-veloce della matrice di distanza euclidea tramite BLAS (syrk!).
"""
function pairwise_euclidean!(D::Matrix{Float64}, mat::Matrix{Float64})
    n, p = size(mat)
    norms = Vector{Float64}(undef, n)
    @inbounds for i in 1:n
        s = 0.0
        @simd for j in 1:p
            s += mat[i, j]^2
        end
        norms[i] = s
    end

    # Sfrutta le librerie BLAS C-level per il prodotto Gramiano
    BLAS.syrk!('U', 'N', 1.0, mat, 0.0, D)

    @inbounds for i in 1:n
        D[i, i] = 0.0
        for j in (i+1):n
            gram = D[i, j]
            d2 = norms[i] + norms[j] - 2.0 * gram
            val = d2 > 0.0 ? sqrt(d2) : 0.0
            D[i, j] = val
            D[j, i] = val
        end
    end
    return D
end

function pairwise_euclidean(mat::Matrix{Float64})
    n = size(mat, 1)
    D = Matrix{Float64}(undef, n, n)
    return pairwise_euclidean!(D, mat)
end

"""
Calcola l'Adjusted RV coefficient (Mayer et al., 2011).
"""
function AdjustedRV(X1::Matrix{Float64}, X2::Matrix{Float64}; center::Bool=true)
    n, p = size(X1)
    _, q = size(X2)

    X1_c = center ? X1 .- mean(X1, dims=1) : copy(X1)
    X2_c = center ? X2 .- mean(X2, dims=1) : copy(X2)

    AA = X1_c * X1_c'
    BB = X2_c * X2_c'

    ncols_prod = Float64(p * q)
    ncols_1_sq = Float64(p * p)
    ncols_2_sq = Float64(q * q)

    X1s = standardize_ddof1(X1_c)
    X2s = standardize_ddof1(X2_c)

    AAs = X1s * X1s'
    BBs = X2s * X2s'

    factor = (n - 1.0) / (n - 2.0)
    denom_sq = (n - 1.0)^2

    tr_AAs_BBs = tr(AAs * BBs)
    tr_AAs_AAs = tr(AAs * AAs)
    tr_BBs_BBs = tr(BBs * BBs)

    xy = tr_AAs_BBs / (ncols_prod - factor * (ncols_prod - tr_AAs_BBs / denom_sq))
    xx = tr_AAs_AAs / (ncols_1_sq - factor * (ncols_1_sq - tr_AAs_AAs / denom_sq))
    yy = tr_BBs_BBs / (ncols_2_sq - factor * (ncols_2_sq - tr_BBs_BBs / denom_sq))

    val = (tr(AA * BB) / xy) / sqrt((tr(AA * AA) / xx) * (tr(BB * BB) / yy))
    return val
end

"""
Calcola il Saturn Coefficient tra X e Y.
"""
function SaturnCoefficient(X::Matrix{Float64}, Y::Matrix{Float64})
    Xs = standard_scaler(X)
    Ys = standard_scaler(Y)

    Dx = pairwise_euclidean(Xs)
    Dy = pairwise_euclidean(Ys)

    return AdjustedRV(Dx, Dy; center=true)
end

end # module Saturn
