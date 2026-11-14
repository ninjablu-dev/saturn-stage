import os
import glob
import time
import numpy as np
import pandas as pd
from saturnscore import Saturn_coefficient

def main():
    bin_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.abspath(os.path.join(bin_dir, ".."))

    orig_dir = os.path.join(project_root, "data", "ehr_datasets_imputed")
    umap_dir = os.path.join(project_root, "data", "ehr_umap_imputed")
    if not os.path.isdir(umap_dir):
        umap_dir = os.path.join(project_root, "data", "ehr_umap")

    csv_files = sorted(glob.glob(os.path.join(orig_dir, "*.csv")))
    if not csv_files:
        print(f"[ERRORE] Nessun CSV trovato in '{orig_dir}'.")
        return

    print("--- RISULTATI SATURN EHR (PYTHON VIA SATURNSCORE) ---")
    t_start = time.perf_counter()

    for orig_path in csv_files:
        fname = os.path.basename(orig_path)
        umap_path = os.path.join(umap_dir, f"umap_{fname}")

        if not os.path.exists(umap_path):
            print(f"[ATTENZIONE] File UMAP mancante per: {fname} (cercato in {umap_path})")
            continue

        df_orig = pd.read_csv(orig_path).select_dtypes(include=[np.number])
        df_umap = pd.read_csv(umap_path).select_dtypes(include=[np.number])

        X = df_orig.to_numpy(dtype=np.float64)
        Y = df_umap.to_numpy(dtype=np.float64)

        saturn_score = Saturn_coefficient.SaturnCoefficient(X, Y)
        print(f"Dataset: {fname:<68} | Saturn Coefficient: {saturn_score:.20f}")

    t_elapsed = time.perf_counter() - t_start
    print(f"[PYTHON LOOP TIME] {t_elapsed:.4f} s")

if __name__ == "__main__":
    main()
