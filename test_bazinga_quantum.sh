#!/bin/bash
# Script to test the Bazinga Quantum implementation

echo "=== TESTING BAZINGA QUANTUM SYSTEM ==="
echo "Running pattern communication demo..."
npx ts-node src/examples/pure-pattern-demo.ts

echo -e "\nRunning quantum bazinga demo..."
npx ts-node src/examples/quantum-bazinga-demo.ts

echo -e "\nAll tests completed!"
