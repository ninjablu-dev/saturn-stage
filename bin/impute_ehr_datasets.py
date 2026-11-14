import os
import glob
import numpy as np
import pandas as pd

def main():
    bin_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.abspath(os.path.join(bin_dir, ".."))

    input_dir = os.path.join(project_root, "data", "ehr_datasets")
    output_dir = os.path.join(project_root, "data", "ehr_datasets_imputed")
    os.makedirs(output_dir, exist_ok=True)

    csv_files = sorted(glob.glob(os.path.join(input_dir, "*.csv")))
    if not csv_files:
        print(f"[ERRORE] Nessun CSV trovato in '{input_dir}'.")
        return

    print("=== 1. IMPUTAZIONE DATASET EHR (Media di Colonna) ===")
    for filepath in csv_files:
        fname = os.path.basename(filepath)
        df = pd.read_csv(filepath).select_dtypes(include=[np.number])

        n_nans = int(df.isna().sum().sum())
        df_imputed = df.fillna(df.mean())

        out_name = f"imputed_{fname}"
        out_path = os.path.join(output_dir, out_name)
        df_imputed.to_csv(out_path, index=False)

        note = f" (sostituiti {n_nans} NaN con media)" if n_nans > 0 else " (nessun NaN)"
        print(f"[+] {fname:<60} -> {out_name}{note}")

if __name__ == "__main__":
    main()
