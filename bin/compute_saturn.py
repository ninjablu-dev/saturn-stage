import sys
import subprocess
import os

# 1. Aggiornamento pip ed installazione automatica dipendenze
bash_command = f"{sys.executable} -m pip install --upgrade pip"
subprocess.run(bash_command, shell=True, capture_output=True, text=True)

libraries = ["numpy", "pandas", "scipy", "saturnscore"]

for lib in libraries:
    try:
        __import__(lib)
    except ImportError:
        print(f"[PYTHON] Pacchetto '{lib}' non trovato. Installazione in corso...")
        subprocess.check_call([sys.executable, "-m", "pip", "install", lib])

import numpy as np
import pandas as pd
from saturnscore import Saturn_coefficient

def main():
    bin_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.abspath(os.path.join(bin_dir, ".."))

    orig_dir = os.path.join(project_root, "data", "geometric_datasets")
    if not os.path.exists(orig_dir):
        orig_dir = os.path.join(project_root, "data", "geometric")
    umap_dir = os.path.join(project_root, "data", "geometric_umap")

    datasets = [
        "dataset_circles.csv",
        "dataset_moons.csv",
        "dataset_anisotropic.csv",
        "dataset_varied_variance.csv",
        "dataset_blobs.csv",
        "dataset_no_structure.csv"
    ]

    # Limite di lettura righe per evitare Out of Memory e velocizzare l'I/O
    SAMPLES_LIMIT = 10000

    print("--- RISULTATI SATURN (PYTHON VIA SATURNSCORE) ---")

    for fname in datasets:
        orig_path = os.path.join(orig_dir, fname)
        umap_path = os.path.join(umap_dir, f"umap_{fname}")

        if not os.path.exists(orig_path) or not os.path.exists(umap_path):
            print(f"[ATTENZIONE] File mancante per: {fname}")
            continue

        # Carica solo le prime 10.000 righe da disco
        df_orig = pd.read_csv(orig_path, nrows=SAMPLES_LIMIT).select_dtypes(include=[np.number])
        df_umap = pd.read_csv(umap_path, nrows=SAMPLES_LIMIT).select_dtypes(include=[np.number])

        X = df_orig.to_numpy(dtype=np.float64)
        Y = df_umap.to_numpy(dtype=np.float64)

        # Calcolo ufficiale del valore Saturn tramite la libreria
        saturn_score = Saturn_coefficient.SaturnCoefficient(X, Y)
        print(f"Dataset: {fname:<28} | Saturn Coefficient: {saturn_score:.20f}")

if __name__ == "__main__":
    main()
