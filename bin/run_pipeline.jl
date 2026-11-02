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

# 2. Configurazione ambiente
bin_dir = @__DIR__
project_root = abspath(joinpath(bin_dir, ".."))

Pkg.activate(project_root)

# Controllo dipendenze essenziali (SOLO pacchetti di sistema / registrati su General)
REQUIRED_PACKAGES = ["Printf", "CSV", "DataFrames", "Distances", "LinearAlgebra", "Statistics"]
check_and_install_packages(REQUIRED_PACKAGES)

using Printf

function parse_script_output(output_str::String)
    results = Dict{String, Float64}()
    lines = split(output_str, "\n")
    for line in lines
        if contains(line, "Saturn Coefficient:") || contains(line, "Adjusted RV:")
            parts = split(line, "|")
            if length(parts) == 2
                dataset_part = strip(parts[1])
                score_part   = strip(parts[2])
                
                dataset_name = replace(dataset_part, "Dataset:" => "") |> strip
                val_str = split(score_part, ":")[end] |> strip
                val = parse(Float64, val_str)
                
                results[dataset_name] = val
            end
        end
    end
    return results
end

function run_pipeline()
    println("=========================================================================================================")
    println("                               BENCHMARK SATURN: JULIA vs PYTHON                                        ")
    println("=========================================================================================================\n")

    jl_script = joinpath(bin_dir, "compute_saturn.jl")
    py_script = joinpath(bin_dir, "compute_saturn.py")

    jl_out = IOBuffer()
    py_out = IOBuffer()

    # 1. Esecuzione Live Julia con misurazione del tempo
    print("[1/2] Calcolo in corso con Julia...")
    t_jl_start = time()
    if isfile(jl_script)
        try
            run(pipeline(`$(Base.julia_cmd()) $jl_script`, stdout=jl_out))
            t_jl_elapsed = time() - t_jl_start
            @printf(" COMPLETATO in %.4f s (%.2f ms)\n", t_jl_elapsed, t_jl_elapsed * 1000)
        catch e
            println(" ERRORE!")
            @error "Errore durante l'esecuzione dello script Julia:" exception=e
            t_jl_elapsed = NaN
        end
    else
        println(" FILE NON TROVATO ($jl_script)")
        t_jl_elapsed = NaN
    end

    # 2. Esecuzione Live Python con misurazione del tempo
    print("[2/2] Calcolo in corso con Python...")
    t_py_start = time()
    if isfile(py_script)
        try
            run(pipeline(`python3 $py_script`, stdout=py_out))
            t_py_elapsed = time() - t_py_start
            @printf(" COMPLETATO in %.4f s (%.2f ms)\n", t_py_elapsed, t_py_elapsed * 1000)
        catch e
            println(" ERRORE!")
            @error "Errore durante l'esecuzione dello script Python:" exception=e
            t_py_elapsed = NaN
        end
    else
        println(" FILE NON TROVATO ($py_script)")
        t_py_elapsed = NaN
    end

    jl_results = parse_script_output(String(take!(jl_out)))
    py_results = parse_script_output(String(take!(py_out)))

    # 3. Tabella comparativa (Valori + Tempi)
    println("\n" * "="^115)
    @printf("%-28s | %-12s | %-55s\n", "DATASET", "LINGUAGGIO", "VALORE SATURN (20 DECIMALI)")
    println("="^115)

    all_datasets = unique(vcat(collect(keys(jl_results)), collect(keys(py_results))))

    for ds in all_datasets
        val_jl = get(jl_results, ds, NaN)
        val_py = get(py_results, ds, NaN)

        str_jl = isnan(val_jl) ? "N/A" : @sprintf("%.20f", val_jl)
        str_py = isnan(val_py) ? "N/A" : @sprintf("%.20f", val_py)

        diff_str = if isnan(val_jl) || isnan(val_py)
            "N/A"
        else
            @sprintf("%.20e", abs(val_jl - val_py))
        end

        @printf("%-28s | %-12s | %s\n", ds, "JULIA", str_jl)
        @printf("%-28s | %-12s | %s\n", "", "PYTHON", str_py)
        @printf("%-28s | %-12s | Δ (|J - P|): %s\n", "", "DIFFERENZA", diff_str)
        println("-"^115)
    end

    # 4. Riepilogo Tempi di Esecuzione Totali
    println("="^115)
    println("                                   RIEPILOGO TEMPI DI ESECUZIONE                                         ")
    println("="^115)
    @printf("Tempo Totale Esecuzione Julia  : %.4f secondi (%.2f ms)\n", t_jl_elapsed, t_jl_elapsed * 1000)
    @printf("Tempo Totale Esecuzione Python : %.4f secondi (%.2f ms)\n", t_py_elapsed, t_py_elapsed * 1000)
    
    if !isnan(t_jl_elapsed) && !isnan(t_py_elapsed)
        speedup = t_py_elapsed / t_jl_elapsed
        if speedup > 1.0
            @printf("Risultato Performance          : Julia è %.2fx più veloce di Python\n", speedup)
        else
            @printf("Risultato Performance          : Python è %.2fx più veloce di Julia\n", 1.0 / speedup)
        end
    end
    println("="^115)
end

run_pipeline()
