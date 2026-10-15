import os
import pandas as pd
import umap.umap_ as umap
from saturnscore import Saturn_coefficient

data_dir = "data/synthetic"
datasets = ["neat", "moons", "circles", "scurve"]

# Iperparametri UMAP fissati per riproducibilità deterministica
these_n_neighbors = 15
this_min_dist = 0.1
these_n_components = 2
this_random_state = 42

results = []

print("=== AVVIO CALCOLO PACCHETTO PYTHON DI RIFERIMENTO (UMAP + SATURN) ===")

for name in datasets:
    input_path = os.path.join(data_dir, f"dataset_{name}.csv")
    
    # 1. Carica le coordinate originali dello spazio ad alta dimensione (X)
    df = pd.read_csv(input_path)
    X = df[["x", "y"]].values
    
    # 2. Applica la riduzione di dimensionalità UMAP
    fit = umap.UMAP(
        n_neighbors=these_n_neighbors,
        min_dist=this_min_dist,
        n_components=these_n_components,
        random_state=this_random_state,
        n_jobs=1
    )
    Y = fit.fit_transform(X)
    
    # 3. Salva le coordinate del layout 2D proiettato (Y)
    layout_path = os.path.join(data_dir, f"umap_layout_{name}.csv")
    pd.DataFrame(Y, columns=["u1", "u2"]).to_csv(layout_path, index=False)
    
    # 4. Calcola il punteggio della metrica Saturn ufficiale
    saturn_val = Saturn_coefficient.SaturnCoefficient(X, Y)
    results.append({
        "dataset": name,
        "n_samples": len(X),
        "saturn_score": saturn_val
    })
    
    print(f"Dataset {name:8s} | Campioni: {len(X):4d} | Saturn Score: {saturn_val:.6f} | Salvato layout: {layout_path}")

# 5. Salva la tabella complessiva dei punteggi di riferimento
df_results = pd.DataFrame(results)
summary_path = os.path.join(data_dir, "reference_scores_python.csv")
df_results.to_csv(summary_path, index=False)

print("\n=== VALORI UFFICIALI DI RIFERIMENTO (PYTHON) ===")
print(df_results.to_string(index=False))
print(f"\nRiepilogo esportato con successo in: {summary_path}")
