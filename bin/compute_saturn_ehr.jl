import Pkg

bin_dir = @__DIR__
project_root = abspath(joinpath(bin_dir, ".."))
Pkg.activate(project_root)

using CSV
using LinearAlgebra
using Statistics
using Printf

include(joinpath(bin_dir, "Saturn.jl"))
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
    orig_dir = joinpath(project_root, "data", "ehr_datasets_imputed")
    umap_dir = joinpath(project_root, "data", "ehr_umap_imputed")
    if !isdir(umap_dir)
        umap_dir = joinpath(project_root, "data", "ehr_umap")
    end

    files = sort(filter(f -> endswith(f, ".csv"), readdir(orig_dir)))
    if isempty(files)
        println("[ERRORE] Nessun CSV trovato in '$orig_dir'.")
        return
    end

    println("--- RISULTATI SATURN EHR (JULIA - CALCOLO IN MEMORIA) ---")

    # Warmup JIT per isolare la compilazione dal tempo di esecuzione puro
    _dummy = Saturn.SaturnCoefficient(rand(10, 2), rand(10, 2))

    t_start = time()
    for fname in files
        orig_path = joinpath(orig_dir, fname)
        umap_path = joinpath(umap_dir, "umap_$fname")

        if !isfile(orig_path) || !isfile(umap_path)
            println("[ATTENZIONE] File UMAP mancante per: $fname")
            continue
        end

        X = fast_read_csv(orig_path)
        Y = fast_read_csv(umap_path)

        saturn_score = Saturn.SaturnCoefficient(X, Y)
        @printf("Dataset: %-68s | Saturn Coefficient: %.20f\n", fname, saturn_score)
    end
    t_elapsed = time() - t_start
    @printf("[JULIA WARM MATH TIME] %.4f s\n", t_elapsed)
end

main()
