#!/bin/bash
# SSRI-BAZINGA Integration Script
# Integrates SSRI documentation with the BAZINGA framework

# Set colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Define paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
BAZINGA_ROOT="$(cd "$SCRIPT_DIR" && cd .. && pwd)"
INTEGRATION_DIR="/Users/abhissrivasta/AmsyPycharm/BAZINGA/bin/integration/ssri_20250328_044806"
SSRI_DOCS_DIR="/Users/abhissrivasta/SSRI_Documentation"

echo -e "${BLUE}=============================================================\033[0m"
echo -e "${BOLD}SSRI-BAZINGA INTEGRATION\033[0m"
echo -e "${BLUE}=============================================================\033[0m"
echo -e "BAZINGA Root: ${BOLD}$BAZINGA_ROOT\033[0m"
echo -e "SSRI Docs Dir: ${BOLD}$SSRI_DOCS_DIR\033[0m"
echo -e "Integration Dir: ${BOLD}$INTEGRATION_DIR\033[0m"
echo -e "${BLUE}=============================================================\033[0m"

# Step 1: Run Python fractal pattern integration
echo -e "\n${BOLD}Step 1: Running fractal pattern integration...\033[0m"
if python3 "$INTEGRATION_DIR/scripts/fractal_pattern_integration.py"; then
    echo -e "${GREEN}Fractal pattern integration complete.\033[0m"
else
    echo -e "${RED}Fractal pattern integration failed.\033[0m"
    exit 1
fi

# Step 2: Link to BAZINGA framework
echo -e "\n${BOLD}Step 2: Linking to BAZINGA framework...\033[0m"
mkdir -p "$BAZINGA_ROOT/artifacts/ssri_documentation"
cp -r "$INTEGRATION_DIR"/* "$BAZINGA_ROOT/artifacts/ssri_documentation/"
echo -e "${GREEN}Linked to BAZINGA framework.\033[0m"

# Step 3: Add to master index
echo -e "\n${BOLD}Step 3: Adding to master index...\033[0m"
if [ -f "$BAZINGA_ROOT/master_index.md" ]; then
    # Add SSRI section to master index
    if ! grep -q "SSRI Documentation" "$BAZINGA_ROOT/master_index.md"; then
        cat >> "$BAZINGA_ROOT/master_index.md" << 'EOF'

## SSRI Documentation

The SSRI documentation has been integrated with the BAZINGA framework:

- [Timeline](artifacts/ssri_documentation/Timeline/SSRI_Comprehensive_Timeline.md)
- [Medical Evidence](artifacts/ssri_documentation/Medical_Evidence/SSRI_Induced_Apathy_Syndrome.md)
- [Legal Options](artifacts/ssri_documentation/Legal_Options/Legal_Options_Analysis.md)
- [Communication Analysis](artifacts/ssri_documentation/Communication_Analysis/Communication_Pattern_Analysis.md)
- [Visualization](artifacts/ssri_documentation/visualizations/fractal_visualization.html)

EOF
        echo -e "${GREEN}Added to master index.\033[0m"
    else
        echo -e "${YELLOW}SSRI section already exists in master index.\033[0m"
    fi
else
    echo -e "${YELLOW}Master index not found at $BAZINGA_ROOT/master_index.md\033[0m"
fi

# Step 4: Integration with fractal generators
echo -e "\n${BOLD}Step 4: Integration with fractal generators...\033[0m"
if [ -f "$BAZINGA_ROOT/fractal_artifacts_integration.py" ]; then
    echo -e "${YELLOW}Running fractal artifacts integration...\033[0m"
    python3 "$BAZINGA_ROOT/fractal_artifacts_integration.py" --input-dir "$INTEGRATION_DIR" --output-dir "$BAZINGA_ROOT/artifacts" --mode "analyze"
    echo -e "${GREEN}Fractal artifacts integration complete.\033[0m"
else
    echo -e "${YELLOW}Fractal artifacts integration script not found, skipping.\033[0m"
fi

# Step 5: Add to BAZINGA state
echo -e "\n${BOLD}Step 5: Updating BAZINGA state...\033[0m"
if [ -f "$BAZINGA_ROOT/BAZINGA_STATE" ]; then
    # Append to BAZINGA_STATE file
    echo "SSRI_DOCUMENTATION_INTEGRATED=true" >> "$BAZINGA_ROOT/BAZINGA_STATE"
    echo "SSRI_DOCUMENTATION_PATH=$INTEGRATION_DIR" >> "$BAZINGA_ROOT/BAZINGA_STATE"
    echo "SSRI_INTEGRATION_TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')" >> "$BAZINGA_ROOT/BAZINGA_STATE"
    echo -e "${GREEN}BAZINGA state updated.\033[0m"
else
    echo -e "${YELLOW}BAZINGA_STATE file not found, skipping.\033[0m"
fi

echo -e "\n${GREEN}Integration complete!\033[0m"
echo -e "${BLUE}=============================================================\033[0m"
echo -e "${BOLD}SSRI documentation has been integrated with the BAZINGA framework.\033[0m"
echo -e "${BOLD}You can now access the documentation through your BAZINGA system.\033[0m"
echo -e "${BLUE}=============================================================\033[0m"
