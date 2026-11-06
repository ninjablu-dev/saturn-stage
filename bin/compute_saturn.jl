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
        println("[JULIA] Pacchetti mancanti rilevati: ", join(missing_pkgs, ", "))
        println("[JULIA] Inizio installazione automatica...")
        Pkg.add(missing_pkgs)
    end
end

bin_dir = @__DIR__
project_root = abspath(joinpath(bin_dir, ".."))

Pkg.activate(project_root)

# Controllo dipendenze essenziali registrate
REQUIRED_PACKAGES = ["CSV", "LinearAlgebra", "Statistics", "Printf"]
check_and_install_packages(REQUIRED_PACKAGES)

using CSV
using LinearAlgebra
using Statistics
using Printf

# Includiamo il modulo locale Saturn.jl
saturn_path = joinpath(bin_dir, "Saturn.jl")
include(saturn_path)
using .Saturn

function fast_read_csv(filepath::String)
    rowtable = CSV.File(filepath)
    n_rows = length(rowtable)
    
    first_row = first(rowtable)
    num_cols = count(val -> val isa Number, first_row)
    
    mat = Matrix{Float64}(undef, n_rows, num_cols)
    
    for (i, row) in enumerate(rowtable)
        col_idx = 1
        for val in row
            if val isa Number
                mat[i, col_idx] = Float64(val)
                col_idx += 1
            end
        end
    end
    return mat
end

function main()
    orig_dir = joinpath(project_root, "data", "geometric_datasets")
    if !isdir(orig_dir)
        orig_dir = joinpath(project_root, "data", "geometric")
    end
    umap_dir = joinpath(project_root, "data", "geometric_umap")

    datasets = [
        "dataset_circles.csv",
        "dataset_moons.csv",
        "dataset_anisotropic.csv",
        "dataset_varied_variance.csv",
        "dataset_blobs.csv",
        "dataset_no_structure.csv"
    ]

    println("--- RISULTATI SATURN (JULIA - CALCOLO IN MEMORIA) ---")

    # Warmup della compilazione JIT per isolare il benchmark
    _dummy = Saturn.SaturnCoefficient(rand(10, 2), rand(10, 2))

    t_start = time()
    for fname in datasets
        orig_path = joinpath(orig_dir, fname)
        umap_path = joinpath(umap_dir, "umap_$fname")

        if !isfile(orig_path) || !isfile(umap_path)
            continue
        end

        X = fast_read_csv(orig_path)
        Y = fast_read_csv(umap_path)

        saturn_score = Saturn.SaturnCoefficient(X, Y)

        @printf("Dataset: %-28s | Saturn Coefficient: %.20f\n", fname, saturn_score)
    end
    t_elapsed = time() - t_start
    @printf("[JULIA WARM MATH TIME] %.4f s\n", t_elapsed)
end

main()
