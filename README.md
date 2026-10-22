# Saturn score
## Title
Validation and translation of the Saturn coefficient for UMAP dimensionality reduction evaluation from Python to Julia.

## Description
This repository contains Julia and Python scripts that execute experiments to assess the quality of Uniform Manifold Approximation and Projection (UMAP) dimensionality reductions using the **Saturn coefficient**.
For four different geometric datasets, the scripts generate two-dimensional representations, apply UMAP dimensionality reduction, and compare the Saturn coefficient values obtained in Python and Julia to verify exact algebric and numerical correspondence.

## Project structure
Organized according to computational biology project guidelines (Noble, 2009; Schnell, 2015):
- `bin/`: Executable Julia and Python files, including the core Julia implementation (`Saturn.jl`) and dataset generation scripts (`generate_datasets.py`).
- `data/geometric_datasets/`: Standardized CSV files for the geometric datasets, UMAP output layouts, and reference Python scores.
- test/: Some snippets of code to get familiar with Julia.

## Datasets availability
The geometric datasets employed in this study are generated deterministically using `scikit-learn` (`random_state=42`) and saved in `data/geometric_datasets/`:
- **Neat Blobs** (`dataset_neat.csv`): 1,050 samples distributed across 3 well-separated Gaussian clusters (`cluster_std=0.8`).
- **Two Moons** (`dataset_moons.csv`): 1,000 samples forming two interleaving non-linear half-circles (`noise=0.08`).
- **Concentric Circles** (`dataset_circles.csv`): 1,100 samples arranged in concentric circular manifolds (`factor=0.5`, `noise=0.05`).
- **S-Curve** (`dataset_scurve.csv`): 1,000 samples projected from a continuous non-linear manifold (`noise=0.05`).

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
1. To generate the geometric datasets in CSV format, run from the project root directory:

    python bin/generate_datasets.py

2. To run the Julia implementation and comparative validation tests from the project root directory:

    julia bin/Saturn.jl

## Article
Additional information about the Saturn coefficient is available in the reference publication:

Davide Chicco, Simone Melzi, Francesca Gasparini, and Giuseppe Jurman, "The advantages of our proposed Saturn coefficient over continuity and trustworthiness for UMAP dimensionality reduction evaluation", *PeerJ Computer Science*, 12:e3424, 2026.
DOI: [https://doi.org/10.7717/peerj-cs.3424](https://doi.org/10.7717/peerj-cs.3424)

## Contributions
This repository was developed by Francesco Mandunzio under the supervision of Prof. Davide Chicco at the Dipartimento di Informatica, Sistemistica e Comunicazione (DISCo), Università degli Studi di Milano-Bicocca (Milan, Italy).
Questions and possible contributions should be addressed to mandunziofrancesco(at)gmail.com.

## License
This software package is released under the MIT License.
