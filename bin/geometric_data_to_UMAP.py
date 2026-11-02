import os
import glob
import pandas as pd
import numpy as np
import umap

def main():
    # 1. Risale di un livello da bin/ per accedere alla radice del repository
    bin_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.abspath(os.path.join(bin_dir, ".."))

    input_dir = os.path.join(project_root, "data", "geometric_datasets")
    output_dir = os.path.join(project_root, "data", "geometric_umap")

    if not os.path.exists(input_dir):
        # Fallback al nome alternativo data/geometric se geometric_datasets non esiste
        input_dir = os.path.join(project_root, "data", "geometric")

    if not os.path.exists(input_dir):
        print(f"[ERRORE] Impossibile trovare la cartella di input in '{input_dir}'.")
        return

    os.makedirs(output_dir, exist_ok=True)
    print("=== TRASFORMAZIONE UMAP (Dati Geometrici -> 6 CSV UMAP) ===")
    print(f"Directory Input:  {input_dir}")
    print(f"Directory Output: {output_dir}\n")

    # 2. Elenco dei 6 dataset geometrici ufficiali scikit-learn
    target_files = [
        "dataset_circles.csv",
        "dataset_moons.csv",
        "dataset_anisotropic.csv",
        "dataset_varied_variance.csv",
        "dataset_blobs.csv",
        "dataset_no_structure.csv"
    ]
    processed_count = 0

    for fname in target_files:
        filepath = os.path.join(input_dir, fname)
        if not os.path.exists(filepath):
            print(f"[ATTENZIONE] File non trovato: '{filepath}'")
            continue

        # Carica il dataset ed estrae solo le colonne numeriche delle coordinate
        df = pd.read_csv(filepath)
        df_numeric = df.select_dtypes(include=[np.number])
        X = df_numeric.to_numpy(dtype=np.float64)

        # Inizializza UMAP deterministico (random_state=42, n_jobs=1)
        reducer = umap.UMAP(
            n_neighbors=15,
            min_dist=0.1,
            n_components=2,
            random_state=42,
            n_jobs=1
        )

        # Fit & Transform: calcola la proiezione Y (n_samples x 2)
        Y = reducer.fit_transform(X)

        # Salva le coordinate del layout 2D in data/geometric_umap/
        umap_df = pd.DataFrame(Y, columns=["u1", "u2"])
        out_filename = f"umap_{fname}"  # produce es. umap_dataset_circles.csv
        out_filepath = os.path.join(output_dir, out_filename)
        umap_df.to_csv(out_filepath, index=False)

        print(f"[+] '{fname}' ({X.shape[0]} punti) -> Salvato come '{out_filename}'")
        processed_count += 1

    print(f"\n[ESITO POSITIVO] Generati con successo {processed_count} file UMAP in '{output_dir}/'.")

if __name__ == "__main__":
    main()
