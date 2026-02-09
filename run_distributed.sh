#!/bin/bash
# BAZINGA Distributed AI - Run anywhere, controlled by no one
#
# Usage:
#   ./run_distributed.sh                    # Interactive mode
#   ./run_distributed.sh --ask "question"   # Ask a question
#   ./run_distributed.sh --setup            # Show API key setup
#
# "Intelligence distributed, not controlled"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Check for virtual environment
if [ ! -d "$SCRIPT_DIR/.venv" ]; then
    echo "Creating virtual environment..."
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

cd "$SCRIPT_DIR"
python -c "
import asyncio
import sys
sys.path.insert(0, '.')
from src.core.intelligence.distributed_ai import main
asyncio.run(main())
" "$@"
