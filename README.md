# Saturn score
## Title
Validation and translation of the Saturn coefficient for UMAP dimensionality reduction evaluation from Python to Julia.

## Description
This repository contains Julia and Python scripts that execute experiments to assess the quality of Uniform Manifold Approximation and Projection (UMAP) dimensionality reductions using the **Saturn coefficient**.
For four different geometric datasets, the scripts generate two-dimensional representations, apply UMAP dimensionality reduction, and compare the Saturn coefficient values obtained in Python and Julia to verify exact algebric and numerical correspondence.

## Project structure
Organized according to computational biology project guidelines (Noble, 2009; Schnell, 2015):
- `bin/`: Executable Julia and Python files, including the core Julia implementation (`Saturn.jl`) and dataset generation scripts (`generate_datasets.py`).
- test/: Some snippets of code to get familiar with Julia.

## Datasets availability
The geometric datasets employed in this study are generated deterministically using `scikit-learn` and saved in `data/geometric_datasets/`. Each dataset consists of 2,000 samples ($N=2000$) and 100 features ($M=100$):

- **Concentric Circles** (`dataset_circles.csv`): 2,000 samples across 100 features, featuring 2D concentric circular manifolds (`factor=0.5`, `noise=0.05`) extended to 100D with Gaussian noise (`random_state=42`).

- **Two Moons** (`dataset_moons.csv`): 2,000 samples across 100 features, forming two interleaving non-linear half-circles (`noise=0.05`) extended to 100D with Gaussian noise (`random_state=42`).

- **Anisotropic Blobs** (`dataset_anisotropic.csv`): 2,000 samples across 100 features, generated with 3 clusters (`cluster_std=1.0`) and elongated using an affine transformation matrix (`random_state=170`).

- **Varied Variance Blobs** (`dataset_varied_variance.csv`): 2,000 samples across 100 features, distributed across 3 Gaussian clusters with unequal variances (`cluster_std=[1.0, 2.5, 0.5]`, `random_state=170`).

- **Isotropic / Neat Blobs** (`dataset_blobs.csv`): 2,000 samples across 100 features, distributed across 3 well-separated isotropic Gaussian clusters (`cluster_std=1.0`, `random_state=8`).

- **Uniform / No Structure** (`dataset_no_structure.csv`): 2,000 samples across 100 features, generated from a uniform random distribution without any underlying cluster or manifold structure (`random_state=42`).
To generate different dataset realizations, modify the `random_state` parameter in `bin/generate_datasets.py`. Keeping the same seed guarantees full reproducibility across runs.

## Code information, installation, and requirements
To run the tests in this repository, you need the following software and packages installed on your computer:
- **Python** (version >= 3.9) with packages: `numpy`, `pandas`, `scikit-learn`, `umap-learn`, `SaturnScore`
- **Julia** (version >= 1.9) with packages: `CSV`, `DataFrames`, `Distances`, `LinearAlgebra`, `Statistics`, `UMAP`

You can install the required Python packages through this command:

    pip install numpy pandas scikit-learn umap-learn SaturnScore

You can install the required Julia packages in the Julia REPL through these commands:

    using Pkg
    Pkg.add(["CSV", "DataFrames", "Distances", "UMAP"])

## Methodology
Given an input data matrix $A$ ($n$ rows as samples and $m$ columns as features) and its low-dimensional UMAP projection $U$, the Saturn coefficient quantifies the preservation of both global and local data structures in an unsupervised manner:
1. Both $A$ and $U$ are scaled column-wise to the $[-1, +1]$ range, obtaining $X = \text{scale}(A)$ and $Y = \text{scale}(U)$.
2. Pairwise Euclidean distance matrices $D_X$ and $D_Y$ are computed across all rows of $X$ and $Y$, respectively.
3. The similarity between $D_X$ and $D_Y$ is computed through the Adjusted RV coefficient: $\text{Saturn} = \text{AdjustedRV}(D_X, D_Y)$, yielding a real value in $[0, 1]$, where $0$ indicates no structure preservation and $1$ indicates complete structure preservation.

## Usage instructions
### 1. Generate high-dimensional geometric datasets
    python bin/generate_datasets.py

### 2. Compute 2D UMAP projections for all datasets
    python bin/geometric_data_to_UMAP.py

### 3. Run the complete Julia-Python Saturn benchmark validation
    julia bin/run_pipeline.jl

## Article
Additional information about the Saturn coefficient is available in the reference publication:

Davide Chicco, Simone Melzi, Francesca Gasparini, and Giuseppe Jurman, "The advantages of our proposed Saturn coefficient over continuity and trustworthiness for UMAP dimensionality reduction evaluation", *PeerJ Computer Science*, 12:e3424, 2026.
DOI: [https://doi.org/10.7717/peerj-cs.3424](https://doi.org/10.7717/peerj-cs.3424)

## Contributions
This repository was developed by Francesco Mandunzio under the supervision of Prof. Davide Chicco at the Dipartimento di Informatica, Sistemistica e Comunicazione (DISCo), Università degli Studi di Milano-Bicocca (Milan, Italy).
Questions and possible contributions should be addressed to mandunziofrancesco(at)gmail.com.

## License
This software package is released under the MIT License.
