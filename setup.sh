#!/bin/bash
set -e

# Include nella sessione corrente i percorsi standard di user-binary e juliaup
export PATH="$HOME/.local/bin:$HOME/.juliaup/bin:$PATH"

echo "=================================================="
echo "   SETUP AUTOMATICO AMBIENTE: saturn-stage        "
echo "=================================================="

# --------------------------------------------------
# 1. VERIFICA / INSTALLAZIONE PYTHON 3.14
# --------------------------------------------------
find_python314() {
    if command -v python3.14 >/dev/null 2>&1; then
        echo "python3.14"
        return 0
    elif python3 -c 'import sys; sys.exit(0 if sys.version_info[:2] == (3, 14) else 1)' 2>/dev/null; then
        echo "python3"
        return 0
    fi
    return 1
}

PY_BIN=$(find_python314 || true)

if [ -z "$PY_BIN" ]; then
    echo "[1/4] Python 3.14 non trovato. Avvio installazione automatica..."
    if command -v dnf >/dev/null 2>&1; then
        echo " -> Rilevato Fedora/RHEL (dnf): installazione pacchetto python3.14..."
        sudo dnf install -y python3.14
    elif command -v brew >/dev/null 2>&1; then
        echo " -> Rilevato Homebrew (macOS/Linux): installazione python@3.14..."
        brew install python@3.14
        brew link --overwrite python@3.14 2>/dev/null || true
    else
        echo " -> Installazione binario Python 3.14 standalone tramite uv..."
        if ! command -v uv >/dev/null 2>&1; then
            curl -LsSf https://astral.sh/uv/install.sh | sh
            export PATH="$HOME/.local/bin:$PATH"
        fi
        uv python install 3.14
        mkdir -p "$HOME/.local/bin"
        ln -sf "$(uv python find 3.14)" "$HOME/.local/bin/python3.14"
    fi

    PY_BIN=$(find_python314 || true)
    if [ -z "$PY_BIN" ]; then
        echo "ERRORE: Installazione di Python 3.14 non riuscita."
        exit 1
    fi
else
    echo "[1/4] Python 3.14 già presente ($($PY_BIN --version))."
fi

# --------------------------------------------------
# 2. INSTALLAZIONE LIBRERIE PYTHON (requirements.txt)
# --------------------------------------------------
echo "[2/4] Installazione dipendenze Python da requirements.txt..."
if ! "$PY_BIN" -m pip --version >/dev/null 2>&1; then
    "$PY_BIN" -m ensurepip --user 2>/dev/null || true
fi

if [ -f "requirements.txt" ]; then
    "$PY_BIN" -m pip install --user --upgrade pip 2>/dev/null || true
    "$PY_BIN" -m pip install --user -r requirements.txt 2>/dev/null || \
        "$PY_BIN" -m pip install --user --break-system-packages -r requirements.txt
else
    "$PY_BIN" -m pip install --user numpy scipy pandas scikit-learn umap-learn saturnscore threadpoolctl
fi

# --------------------------------------------------
# 3. VERIFICA / INSTALLAZIONE JULIA (via juliaup)
# --------------------------------------------------
if ! command -v julia >/dev/null 2>&1; then
    echo "[3/4] Julia non trovato. Installazione tramite installer ufficiale juliaup..."
    curl -fsSL https://install.julialang.org | sh -s -- -y
    export PATH="$HOME/.juliaup/bin:$PATH"

    if ! command -v julia >/dev/null 2>&1; then
        echo "ERRORE: Installazione di Julia non riuscita. Riavvia il terminale o controlla ~/.juliaup/bin."
        exit 1
    fi
else
    echo "[3/4] Julia già presente ($(julia --version))."
fi

# --------------------------------------------------
# 4. INSTALLAZIONE E PRECOMPILAZIONE PACCHETTI JULIA
# --------------------------------------------------
echo "[4/4] Ripristino e precompilazione pacchetti Julia (Project.toml / Manifest.toml)..."
julia --project=. -e 'using Pkg; Pkg.instantiate(); Pkg.precompile()'

echo "=================================================="
echo "   SETUP COMPLETATO CON SUCCESSO!                 "
echo "=================================================="
echo " - Python: $($PY_BIN --version)"
echo " - Julia:  $(julia --version)"
echo ""
echo "Ora puoi lanciare i benchmark con:"
echo "  ./run_benchmark_ehr.sh"
echo "  ./run_benchmark_geometric.sh"
