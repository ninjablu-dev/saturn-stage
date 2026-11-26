#!/usr/bin/env julia
using Pkg

const BIN_DIR = @__DIR__
const PROJECT_ROOT = abspath(joinpath(BIN_DIR, ".."))
Pkg.activate(PROJECT_ROOT; io=devnull)

using CSV
using DataFrames
using Printf

include(joinpath(BIN_DIR, "Saturn.jl"))
using .Saturn

const SATURN_FN = isdefined(Saturn, :SaturnCoefficient) ? Saturn.SaturnCoefficient : Saturn.saturn_coefficient

function find_original_file(target::AbstractString, project_root::AbstractString)::Union{String, Nothing}
    if isfile(target)
        return abspath(target)
    end

    data_dir = joinpath(project_root, "data")
    isdir(data_dir) || return nothing

    target_name = basename(target)
    for (root, dirs, files) in walkdir(data_dir)
        filter!(d -> !endswith(d, "_umap"), dirs)
        if target_name in files
            return joinpath(root, target_name)
        end
    end
    return nothing
end

function find_umap_file(orig_path::AbstractString)::Union{String, Nothing}
    fname = basename(orig_path)
    orig_dir = dirname(orig_path)
    data_root = dirname(orig_dir)
    folder = basename(orig_dir)

    candidates = [
        joinpath(data_root, replace(folder, "_datasets" => "_umap"), "umap_" * fname),
        joinpath(data_root, folder * "_umap", "umap_" * fname),
        joinpath(orig_dir, "umap_" * fname),
    ]

    for path in candidates
        if isfile(path)
            return path
        end
    end
    return nothing
end

function numeric_matrix(csv_path::AbstractString)::Matrix{Float64}
    df = CSV.read(csv_path, DataFrame)
    num_cols = [col for col in names(df) if nonmissingtype(eltype(df[!, col])) <: Number]
    return Matrix{Float64}(df[:, num_cols])
end

function main()
    if isempty(ARGS)
        println("Uso: ./compute_saturn.jl <file1.csv> [file2.csv ...]")
        exit(1)
    end

    col_width = max(28, maximum(length(basename(f)) for f in ARGS))
    println("--- RISULTATI SATURN (JULIA - CALCOLO IN MEMORIA) ---")

    for target in ARGS
        orig_path = find_original_file(target, PROJECT_ROOT)
        if orig_path === nothing
            println("[ATTENZIONE] File originale non trovato: $target")
            continue
        end

        fname = basename(orig_path)
        umap_path = find_umap_file(orig_path)
        if umap_path === nothing
            println("[ATTENZIONE] File UMAP mancante per: $fname")
            continue
        end

        X = numeric_matrix(orig_path)
        Y = numeric_matrix(umap_path)

        saturn_score = SATURN_FN(X, Y)
        @printf("Dataset: %-*s | Saturn Coefficient: %.20f\n", col_width, fname, saturn_score)
    end
end

main()
