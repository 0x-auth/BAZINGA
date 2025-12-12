#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Cleaning up BAZINGA-DODO integration...${NC}"

# Remove temporary fix scripts
echo -e "Removing temporary fix scripts..."
rm -f fix_*.sh

# Remove backup files
echo -e "Removing backup files..."
find . -name "*.backup" -type f -delete
find . -name "*.bak" -type f -delete
find . -name "*.temp" -type f -delete

# Ensure proper permissions
echo -e "Setting proper permissions..."
chmod -R 755 src/core/dodo
chmod +x test_dodo_integration.py

# Remove any temporary implementation files
echo -e "Removing temporary implementation files..."
rm -f tmp/bazinga-dodo-implementation.py

# Clean up the directory structure
echo -e "Organizing directory structure..."
mkdir -p docs/dodo
cp DODO-INTEGRATION.md docs/dodo/
cp BAZINGA-DODO-SUMMARY.md docs/dodo/

echo -e "${GREEN}Cleanup complete!${NC}"
echo -e "BAZINGA-DODO integration is now properly installed and organized."
echo -e "Project summary has been saved to BAZINGA-DODO-SUMMARY.md"
echo -e "Documentation can be found in the docs/dodo/ directory."
EOF
