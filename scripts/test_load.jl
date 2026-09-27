using CSV
using DataFrames

path = normpath(joinpath(@__DIR__, "../data/input_data.csv"))
df = CSV.read(path, DataFrame; header=false)

println("Tipo: ", typeof(df))
println("Dimensioni (righe, colonne): ", size(df))

println("\nPrime 5 righe:\n", first(df, 5))
println("\nUltime 5 righe:\n", last(df, 5))
println("\nStatistiche prime 5 colonne:\n", describe(df[1:10, 1:5]))

#modi diversi per ottenere il numero di righe e colonne

n_righe, n_colonne = size(df)

n = size(df, 1)
m = size(df, 2)

n1 = nrow(df)
m1 = ncol(df)

println("--- Verifica Metodo 1: Tupla da size(df) ---")
println("Tupla intera size(df): ", size(df))
println("Numero di righe (n):   ", n_righe)
println("Numero di colonne (m): ", n_colonne)

println("\n--- Verifica Metodo 2: size con asse ---")
println("Asse 1 (righe n):      ", n)
println("Asse 2 (colonne m):    ", m)

println("\n--- Verifica Metodo 3: DataFrames (nrow / ncol) ---")
println("nrow(df) (righe n):    ", n1)
println("ncol(df) (colonne m):  ", m1)