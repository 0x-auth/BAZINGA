#!/bin/bash
# bazinga-julia.sh - BAZINGA Component
# Part of the BAZINGA Project
# https://github.com/abhissrivasta/BAZINGA
PATTERN_ID=${1:-"quantum-1"}
python3 -c "from src.core.fractals.julia_integration import integrate_with_bazinga_pattern; integrate_with_bazinga_pattern('$PATTERN_ID')"
echo "Julia pattern generated for $PATTERN_ID"
