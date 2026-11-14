#!/bin/bash

echo "=================================================="
echo "    BENCHMARK SATURN EHR: PYTHON vs JULIA         "
echo "=================================================="
echo ""

echo "[1/2] Esecuzione Python (saturnscore)..."
time python3 bin/compute_saturn_ehr.py

echo ""
echo "[2/2] Esecuzione Julia (Saturn.jl - All Cores)..."
time julia -t auto bin/compute_saturn_ehr.jl

echo ""
echo "Benchmark EHR completato."
