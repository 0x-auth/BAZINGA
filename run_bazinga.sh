#!/bin/bash
# BAZINGA Real AI - Quick Start Script
#
# Usage:
#   ./run_bazinga.sh                    # Interactive mode
#   ./run_bazinga.sh --index ~/Documents # Index a directory
#   ./run_bazinga.sh --ask "question"   # Ask a question
#   ./run_bazinga.sh --demo             # Run demo
#
# "Your Mac IS the training data"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Check for virtual environment
if [ ! -d "$SCRIPT_DIR/.venv" ]; then
    echo "Creating virtual environment with Python 3.11..."
    python3.11 -m venv "$SCRIPT_DIR/.venv"
    source "$SCRIPT_DIR/.venv/bin/activate"
    pip install --upgrade pip --quiet
    pip install chromadb sentence-transformers httpx --quiet
else
    source "$SCRIPT_DIR/.venv/bin/activate"
fi

# Suppress warnings
export TOKENIZERS_PARALLELISM=false
export HF_HUB_DISABLE_TELEMETRY=1
export HF_HUB_DISABLE_PROGRESS_BARS=1
export TRANSFORMERS_VERBOSITY=error

# Run BAZINGA
cd "$SCRIPT_DIR"
python bazinga_real.py "$@"
