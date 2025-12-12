#!/bin/bash
# File: run-fractal-lambda-test.sh
# Description: Run the fractal-lambda system test to demonstrate the integration
# of fractals with lambda calculus in the BAZINGA system.

echo "Running BAZINGA Fractal-Lambda System Test"
echo "=========================================="

# Ensure we're using the right Node.js version
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # Load nvm
nvm use node &>/dev/null || echo "Using system Node.js version"

# Install ts-node if not already installed
if ! command -v ts-node &> /dev/null; then
    echo "Installing ts-node globally..."
    npm install -g ts-node typescript
fi

echo "Running Fractal-Lambda System Test..."
ts-node src/tests/fractal-lambda-test.ts

echo ""
echo "Test complete."
echo "The Fractal-Lambda System demonstrates the 5-dimensional DODO pattern"
echo "as a mathematical framework for pattern transformation and meta-programming."