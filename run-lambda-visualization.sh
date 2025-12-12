#!/bin/bash
# File: run-lambda-visualization.sh
# Description: Open the lambda system visualization in a browser

echo "Opening Lambda System Visualization..."

# Determine the OS to use the appropriate open command
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    open examples/lambda-visualization.html
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    if command -v xdg-open > /dev/null; then
        xdg-open examples/lambda-visualization.html
    else
        echo "Could not open browser. Please open this file manually:"
        echo "$(pwd)/examples/lambda-visualization.html"
    fi
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    # Windows
    start examples/lambda-visualization.html
else
    echo "Could not open browser. Please open this file manually:"
    echo "$(pwd)/examples/lambda-visualization.html"
fi

echo "Visualization launched. You can interact with the Lambda patterns to see how the five dimensions operate."
echo "The trust dimension (V-axis) demonstrates the integration of trust as the fifth dimension in the DODO framework."