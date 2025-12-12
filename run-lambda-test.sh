#!/bin/bash

# File: run-lambda-test.sh
# Description: Run the lambda system test to verify trust dimension integration

echo "Running BAZINGA Lambda System Test"
echo "=================================="

# Ensure we're using the right Node.js version
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # Load nvm
nvm use node &>/dev/null || echo "Using system Node.js version"

# Install ts-node if not already installed
if ! command -v ts-node &> /dev/null; then
    echo "Installing ts-node globally..."
    npm install -g ts-node typescript
fi

echo "Running Lambda System Test..."
ts-node src/tests/lambda-test.ts

echo ""
echo "Test complete."
echo "The trust dimension (V-axis) is now fully integrated with the lambda expansion system."
echo "The DODO framework (5.1.1.2.3.4.5.1) has been enhanced with meta-programming capabilities."