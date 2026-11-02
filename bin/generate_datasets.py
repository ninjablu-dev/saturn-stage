import os
import numpy as np
import pandas as pd
from sklearn.datasets import make_blobs, make_circles, make_moons

# PARAMETRI CONFIGURABILI
N_SAMPLES = 5000      # Numero di campioni (N)
N_FEATURES = 1000     # Numero di parametri/dimensioni (M)

output_dir = os.path.join("..", "data", "geometric_datasets")
os.makedirs(output_dir, exist_ok=True)

# Nomi colonne: dim_1, dim_2, ..., dim_100
cols = [f"dim_{i+1}" for i in range(N_FEATURES)]

# 1. Concentric Circles (2D esteso a 100D con rumore)
X_circles_2d, _ = make_circles(n_samples=N_SAMPLES, factor=0.5, noise=0.05, random_state=42)
noise_circles = np.random.RandomState(42).normal(0, 0.05, size=(N_SAMPLES, N_FEATURES - 2))
X_circles = np.hstack([X_circles_2d, noise_circles])
pd.DataFrame(X_circles, columns=cols).to_csv(
    os.path.join(output_dir, "dataset_circles.csv"), index=False
)

# 2. Interleaved Moons (2D esteso a 100D con rumore)
X_moons_2d, _ = make_moons(n_samples=N_SAMPLES, noise=0.05, random_state=42)
noise_moons = np.random.RandomState(42).normal(0, 0.05, size=(N_SAMPLES, N_FEATURES - 2))
X_moons = np.hstack([X_moons_2d, noise_moons])
pd.DataFrame(X_moons, columns=cols).to_csv(
    os.path.join(output_dir, "dataset_moons.csv"), index=False
)

# 3. Anisotropic / Elongated Blobs (100D con trasformazione affine casuale)
X_aniso_base, _ = make_blobs(n_samples=N_SAMPLES, n_features=N_FEATURES, centers=3, cluster_std=1.0, random_state=170)
rng_trans = np.random.RandomState(170)
transformation = rng_trans.randn(N_FEATURES, N_FEATURES) * 0.1 + np.eye(N_FEATURES)
X_aniso = np.dot(X_aniso_base, transformation)
pd.DataFrame(X_aniso, columns=cols).to_csv(
    os.path.join(output_dir, "dataset_anisotropic.csv"), index=False
)

# 4. Varied Variance Blobs (100D)
X_varied, _ = make_blobs(
    n_samples=N_SAMPLES,
    n_features=N_FEATURES,
    centers=3,
    cluster_std=[1.0, 2.5, 0.5],
    random_state=170
)
pd.DataFrame(X_varied, columns=cols).to_csv(
    os.path.join(output_dir, "dataset_varied_variance.csv"), index=False
)

# 5. Isotropic Blobs / Neat Blobs (100D)
X_blobs, _ = make_blobs(n_samples=N_SAMPLES, n_features=N_FEATURES, centers=3, cluster_std=1.0, random_state=8)
pd.DataFrame(X_blobs, columns=cols).to_csv(
    os.path.join(output_dir, "dataset_blobs.csv"), index=False
)

# 6. Uniform / No Structure (100D)
rng = np.random.RandomState(42)
X_null = rng.rand(N_SAMPLES, N_FEATURES)
pd.DataFrame(X_null, columns=cols).to_csv(
    os.path.join(output_dir, "dataset_no_structure.csv"), index=False
)

print(f"Generati con successo 6 dataset in '{output_dir}' con N={N_SAMPLES} campioni e M={N_FEATURES} parametri ciascuno.")
