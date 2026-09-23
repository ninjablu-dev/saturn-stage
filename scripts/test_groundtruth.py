import numpy as np
import pandas as pd
import scipy
import umap.umap_ as umap
from saturnscore import Saturn_coefficient

print("=== Generazione Ground Truth Saturn (Esempio Ufficiale DISCo) ===")

# 1. Definizione dimensioni e seed di riproducibilità
base = 120
height = 200
this_random_seed = 0
np.random.seed(this_random_seed)

# Generazione matrice casuale gaussiana (120 righe x 200 colonne)
input_data = np.random.randn(base, height)

# 2. Salvataggio della matrice originale in CSV per Julia (Passo 4 della traccia)
np.savetxt("data/input_data.csv", input_data, delimiter=",", fmt="%.8f")
print("-> Matrice di partenza salvata in: data/input_data.csv (120x200)")

# 3. Parametri UMAP come da script del docente
these_n_neighbors = 20
this_min_dist = 0.01
these_n_components = 2
this_metric = 'euclidean'
this_random_state = 42
this_n_jobs = 1
this_n_epochs = 200

print(f"Parametri UMAP: n_neighbors={these_n_neighbors}, min_dist={this_min_dist}, n_jobs={this_n_jobs}")

# 4. Esecuzione UMAP deterministica
fit = umap.UMAP(
    n_neighbors=these_n_neighbors,
    min_dist=this_min_dist,
    n_components=these_n_components,
    metric=this_metric,
    n_jobs=this_n_jobs,
    random_state=this_random_state,
    n_epochs=this_n_epochs,
    verbose=False
)

umap_output_layout = fit.fit_transform(input_data)

# 5. Salvataggio della proiezione UMAP in CSV per Julia
np.savetxt("data/umap_output_layout.csv", umap_output_layout, delimiter=",", fmt="%.8f")
print("-> Proiezione UMAP salvata in: data/umap_output_layout.csv (120x2)")

# 6. Calcolo del Saturn coefficient ufficiale
result = Saturn_coefficient.SaturnCoefficient(input_data, umap_output_layout)
print(f"\n[TARGET GROUND TRUTH] Saturn coefficient = {result:.8f}")

# 7. Salvataggio dello scalare di controllo
with open("data/target_score.txt", "w") as f:
    f.write(f"{result:.8f}\n")
print("-> Valore di controllo archiviato in: data/target_score.txt")
