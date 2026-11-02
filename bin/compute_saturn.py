import sys
import subprocess
import os

# 1. Controllo ed installazione automatica delle dipendenze
def check_and_install_packages(packages):
    """
    Verifica se i pacchetti Python richiesti sono installati.
    Se ne manca qualcuno, lo installa automaticamente via pip.
    """
    for package, import_name in packages.items():
        try:
            __import__(import_name)
        except ImportError:
            print(f"[PYTHON] Pacchetto '{package}' non installato. Inizio installazione...")
            subprocess.check_call([sys.executable, "-m", "pip", "install", package])

# Mappa: "nome_pacchetto_pip": "nome_modulo_da_importare"
REQUIRED_PACKAGES = {
    "numpy": "numpy",
    "pandas": "pandas",
    "scipy": "scipy",
    "saturnscore": "saturnscore"
}

check_and_install_packages(REQUIRED_PACKAGES)

# 2. Import effettivi
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

        # Carica le righe da disco
        df_orig = pd.read_csv(orig_path, nrows=SAMPLES_LIMIT).select_dtypes(include=[np.number])
        df_umap = pd.read_csv(umap_path, nrows=SAMPLES_LIMIT).select_dtypes(include=[np.number])

        X = df_orig.to_numpy(dtype=np.float64)
        Y = df_umap.to_numpy(dtype=np.float64)

        # Calcolo ufficiale del valore Saturn tramite la libreria
        saturn_score = Saturn_coefficient.SaturnCoefficient(X, Y)
        print(f"Dataset: {fname:<28} | Saturn Coefficient: {saturn_score:.20f}")

if __name__ == "__main__":
    main()
