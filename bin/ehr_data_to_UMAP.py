import os
import glob
import numpy as np
import pandas as pd
import umap

def main():
    bin_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.abspath(os.path.join(bin_dir, ".."))

    input_dir = os.path.join(project_root, "data", "ehr_datasets_imputed")
    output_dir = os.path.join(project_root, "data", "ehr_umap_imputed")
    os.makedirs(output_dir, exist_ok=True)

    csv_files = sorted(glob.glob(os.path.join(input_dir, "imputed_*.csv")))
    if not csv_files:
        print(f"[ERRORE] Nessun file 'imputed_*.csv' trovato in '{input_dir}'. Esegui prima impute_ehr_datasets.py.")
        return

    print("\n=== 2. GENERAZIONE UMAP SU DATASET IMPUTATI ===")
    for filepath in csv_files:
        fname = os.path.basename(filepath)
        df = pd.read_csv(filepath).select_dtypes(include=[np.number])
        X = df.to_numpy(dtype=np.float64)

        reducer = umap.UMAP(
            n_neighbors=15,
            min_dist=0.1,
            n_components=2,
            random_state=42,
            n_jobs=1
        )
        Y = reducer.fit_transform(X)

        out_name = f"umap_{fname}"
        out_path = os.path.join(output_dir, out_name)
        pd.DataFrame(Y, columns=["u1", "u2"]).to_csv(out_path, index=False)
        print(f"[+] {fname:<68} | shape={X.shape} -> {out_name}")

if __name__ == "__main__":
    main()
