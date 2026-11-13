#!/bin/bash

echo "=================================================="
echo "     BENCHMARK SATURN: PYTHON vs JULIA (BASH)     "
echo "=================================================="
echo ""

echo "[1/2] Esecuzione Python (Multi-thread nativo)..."
time python3 bin/compute_saturn.py

echo ""
echo "[2/2] Esecuzione Julia (Multi-thread / All Cores)..."
time julia -t auto bin/compute_saturn.jl

echo ""
echo "Benchmark completato."
