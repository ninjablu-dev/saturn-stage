using LinearAlgebra
using CSV
using DataFrames
using Statistics

function standardize(mat)
	return((mat .- mean(mat, dims = 1)) ./ std(mat, dims = 1, corrected = true))
	end


A = [1 2 3; 4 5 6; 7 8 9]
B = [9 8 7; 6 5 4; 3 2 1]
center = true
trace = tr(A)

println("\nMatrice di esempio:\n", A)

println("\nTraccia matrice di esempio:\n", trace)

r, c = size(A)
#calcolo media collassando tutta la matrice da una NxP a una 1xP
med = mean( A, dims = 1)
#calcolo la deviazione della matrice 1xP e userà la correzzione come da python ddof=1
dev = std( A, dims = 1, corrected = true)
#calcolo per standardizzare la matrice
stdmat = ( A .- med) ./ dev

println("\nLa matrice A standardizzata è:\n", stdmat)

if center
	A1 = A .- med
end

println("\nLa matrice centrata è:\n", A1)

# Get the number of rows and columns in X1 and the number of columns in X2
n, p = size(A)
q = size(B, 2)

	AA = A * A'
	BB = B * B'

	pq = p * q
	pp = p * p
	qq = q * q
	
	As = standardize(A)
	Bs = standardize(B)
	AAs = As * As'
	BBs = Bs * Bs'
println("\nLa matrice del prodotto matriciale tra B(standardizzata) e B(standardizzata) trasposta è:\n", BBs)

xy = tr(AAs * BBs) / (pq - (n-1) / (n-2) * (pq - tr(AAs * BBs) / (n-1)^2))
xx = tr(AAs * AAs) / (pp - (n-1) / (n-2) * (pp - tr(AAs * AAs) / (n-1)^2))
yy = tr(BBs * BBs) / (qq - (n-1) / (n-2) * (qq - tr(BBs * BBs) / (n-1)^2))

RVadj_value = (tr(AA * BB) / xy) / (sqrt(tr(AA * AA) / xx * tr(BB * BB) / yy))
println("\nL' RV adjusted value è: ",RVadj_value)
