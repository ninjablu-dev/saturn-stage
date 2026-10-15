import os
import pandas as pd
from sklearn.datasets import make_blobs, make_circles, make_moons, make_s_curve

output_dir = "data/synthetic"
os.makedirs(output_dir, exist_ok=True)

# 1. Neat Blobs (1050 campioni, cluster ben separati, come da Tabella 1 del paper)
X_neat, _ = make_blobs(n_samples=1050, centers=3, n_features=2, cluster_std=0.8, random_state=42)
pd.DataFrame(X_neat, columns=["x", "y"]).to_csv(os.path.join(output_dir, "dataset_neat.csv"), index=False)

# 2. Two Moons (1000 campioni, due archi curvilinei non lineari)
X_moons, _ = make_moons(n_samples=1000, noise=0.08, random_state=42)
pd.DataFrame(X_moons, columns=["x", "y"]).to_csv(os.path.join(output_dir, "dataset_moons.csv"), index=False)

# 3. Concentric Circles (1100 campioni, cerchi concentrici multishape)
X_circles, _ = make_circles(n_samples=1100, factor=0.5, noise=0.05, random_state=42)
pd.DataFrame(X_circles, columns=["x", "y"]).to_csv(os.path.join(output_dir, "dataset_circles.csv"), index=False)

# 4. S-Curve (1000 campioni, varietà continua non lineare)
X_scurve, _ = make_s_curve(n_samples=1000, noise=0.05, random_state=42)
pd.DataFrame(X_scurve[:, [0, 2]], columns=["x", "y"]).to_csv(os.path.join(output_dir, "dataset_scurve.csv"), index=False)

print("Tutti i dataset CSV sono stati generati con successo in data/synthetic/")
