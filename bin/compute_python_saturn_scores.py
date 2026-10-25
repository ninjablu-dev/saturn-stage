import os
import pandas as pd
import numpy as np
import saturnscore.Saturn_coefficient as sc

def main():
    # 1. Calcola la radice del repository risalendo di un livello da bin/
    bin_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.abspath(os.path.join(bin_dir, ".."))

    # 2. Definisce le directory di input e il file di output target
    input_x_dir = os.path.join(project_root, "data", "geometric_datasets")
    if not os.path.exists(input_x_dir):
        input_x_dir = os.path.join(project_root, "data", "geometric")

    input_y_dir = os.path.join(project_root, "data", "geometric_umap")
    output_csv = os.path.join(project_root, "data", "geometric_py_saturn_score.csv")

    if not os.path.exists(input_x_dir):
        print(f"[ERRORE] Cartella dei dati X non trovata in '{input_x_dir}'.")
        return

    if not os.path.exists(input_y_dir):
        print(f"[ERRORE] Cartella dei dati UMAP Y non trovata in '{input_y_dir}'.")
        return

    # I 4 dataset sintetici geometrici del Passaggio 4 (Chicco et al., 2026)
    target_names = ["neat", "moons", "circles", "scurve"]
    results = []

    print("=== CALCOLO PYTHON SATURN SCORES (Ground Truth) ===")
    print(f"Directory Input X: {input_x_dir}")
    print(f"Directory Input Y: {input_y_dir}")
    print(f"File Output CSV:   {output_csv}\n")

    for name in target_names:
        file_x = os.path.join(input_x_dir, f"dataset_{name}.csv")
        file_y = os.path.join(input_y_dir, f"umap_dataset_{name}.csv")

        if not os.path.exists(file_x):
            print(f"[ATTENZIONE] File X mancante: '{file_x}'")
            continue
        if not os.path.exists(file_y):
            print(f"[ATTENZIONE] File Y mancante: '{file_y}'")
            continue

        # Carica X e Y ed estrae solo le colonne numeriche delle coordinate
        df_x = pd.read_csv(file_x).select_dtypes(include=[np.number])
        df_y = pd.read_csv(file_y).select_dtypes(include=[np.number])

        X = df_x.to_numpy(dtype=np.float64)
        Y = df_y.to_numpy(dtype=np.float64)

        # Calcola il Saturn Coefficient ufficiale della libreria Python
        score = sc.SaturnCoefficient(X, Y)

        results.append({
            "dataset": name,
            "n_samples": len(df_x),
            "saturn_score_python": score
        })

        print(f"[+] Dataset '{name}' ({len(df_x)} punti) -> Saturn Score (Python): {score:.6f}")

    # 3. Salva la tabella nel file richiesto: data/geometric_py_saturn_score.csv
    out_df = pd.DataFrame(results)
    out_df.to_csv(output_csv, index=False)
    print(f"\n[ESITO POSITIVO] File '{output_csv}' salvato con successo!")

if __name__ == "__main__":
    main()
