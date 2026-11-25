#!/usr/bin/env python3.14
import os
import subprocess
import sys

# 1. Controllo ed installazione automatica delle dipendenze
REQUIRED_PACKAGES = {
    "numpy": "numpy",
    "pandas": "pandas",
    "scipy": "scipy",
    "saturnscore": "saturnscore",
}

for package, import_name in REQUIRED_PACKAGES.items():
    try:
        __import__(import_name)
    except ImportError:
        print(f"[PYTHON] Pacchetto '{package}' non installato. Inizio installazione...")
        subprocess.check_call([sys.executable, "-m", "pip", "install", "--user", package])

import numpy as np
import pandas as pd
from saturnscore import Saturn_coefficient


def find_original_file(target: str, project_root: str) -> str | None:
    if os.path.isfile(target):
        return os.path.abspath(target)

    data_dir = os.path.join(project_root, "data")
    basename = os.path.basename(target)
    for root, dirs, files in os.walk(data_dir):
        dirs[:] = [d for d in dirs if not d.endswith("_umap")]
        if basename in files:
            return os.path.join(root, basename)
    return None


def find_umap_file(orig_path: str) -> str | None:
    fname = os.path.basename(orig_path)
    orig_dir = os.path.dirname(orig_path)
    data_root = os.path.dirname(orig_dir)
    folder = os.path.basename(orig_dir)

    candidates = [
        os.path.join(data_root, folder.replace("_datasets", "_umap"), f"umap_{fname}"),
        os.path.join(data_root, f"{folder}_umap", f"umap_{fname}"),
        os.path.join(orig_dir, f"umap_{fname}"),
    ]
    for path in candidates:
        if os.path.isfile(path):
            return path
    return None


def main():
    if len(sys.argv) < 2:
        print("Uso: ./compute_saturn.py <file1.csv> [file2.csv ...]")
        sys.exit(1)

    files = sys.argv[1:]
    bin_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.abspath(os.path.join(bin_dir, ".."))

    col_width = max(28, max(len(os.path.basename(f)) for f in files))
    print("--- RISULTATI SATURN (PYTHON VIA SATURNSCORE) ---")

    for target in files:
        orig_path = find_original_file(target, project_root)
        if not orig_path:
            print(f"[ATTENZIONE] File originale non trovato: {target}")
            continue

        fname = os.path.basename(orig_path)
        umap_path = find_umap_file(orig_path)
        if not umap_path:
            print(f"[ATTENZIONE] File UMAP mancante per: {fname}")
            continue

        df_orig = pd.read_csv(orig_path).select_dtypes(include=[np.number])
        df_umap = pd.read_csv(umap_path).select_dtypes(include=[np.number])

        X = df_orig.to_numpy(dtype=np.float64)
        Y = df_umap.to_numpy(dtype=np.float64)

        saturn_score = Saturn_coefficient.SaturnCoefficient(X, Y)
        print(f"Dataset: {fname:<{col_width}} | Saturn Coefficient: {saturn_score:.20f}")


if __name__ == "__main__":
    main()
