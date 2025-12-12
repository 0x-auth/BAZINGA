#!/bin/bash
# File: run-lambda-interactive.sh
# Description: Launch the interactive lambda system shell

echo "Starting BAZINGA Lambda Interactive Shell"
echo "========================================"

# Ensure we're using the right Node.js version
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # Load nvm
nvm use node &>/dev/null || echo "Using system Node.js version"

# Install ts-node if not already installed
if ! command -v ts-node &> /dev/null; then
    echo "Installing ts-node globally..."
    npm install -g ts-node typescript
fi

echo "Launching Lambda Interactive Shell..."
ts-node examples/lambda-interactive.ts

# The interactive shell will handle its own cleanup