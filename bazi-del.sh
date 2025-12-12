#!/bin/bash
# BAZINGA System Cleanup Script
# This script safely organizes your BAZINGA system while preserving functionality

# Set colors for better readability
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Base directories
AMSY_HOME="$HOME/AmsyPycharm"
BAZINGA_HOME="$AMSY_HOME/BAZINGA"
BACKUP_DIR="$HOME/AmsyPycharm_Backups/system_cleanup_$(date +%Y%m%d%H%M%S)"

echo -e "${BLUE}BAZINGA System Cleanup${NC}"
echo "This script will organize your system and reduce clutter"
echo "A backup will be created at: $BACKUP_DIR"
echo ""

# Confirm execution
read -p "Continue with system cleanup? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cleanup cancelled"
    exit 1
fi

# Step 1: Create backup directory
echo -e "${GREEN}Creating backup directory...${NC}"
mkdir -p "$BACKUP_DIR"
mkdir -p "$BACKUP_DIR/home_scripts"
mkdir -p "$BACKUP_DIR/bin_scripts"
mkdir -p "$BACKUP_DIR/bazinga_scripts"

# Step 2: Create organized directory structure
echo -e "${GREEN}Creating organized directory structure...${NC}"
mkdir -p "$BAZINGA_HOME/bin"
mkdir -p "$BAZINGA_HOME/modules/trust"
mkdir -p "$BAZINGA_HOME/modules/fractal"
mkdir -p "$BAZINGA_HOME/modules/claude"
mkdir -p "$BAZINGA_HOME/modules/ssri"
mkdir -p "$BAZINGA_HOME/modules/whatsapp"
mkdir -p "$BAZINGA_HOME/config"
mkdir -p "$BAZINGA_HOME/artifacts/claude_artifacts"
mkdir -p "$BAZINGA_HOME/output"

# Step 3: Identify duplicate scripts and save their locations
echo -e "${GREEN}Identifying duplicate scripts...${NC}"
SCRIPT_REGISTRY="$BACKUP_DIR/script_registry.txt"

# Create a registry of all scripts with their paths
find "$HOME" -maxdepth 1 -name "*.sh" | while read script; do
    echo "$(basename "$script"):$script" >> "$SCRIPT_REGISTRY"
    cp "$script" "$BACKUP_DIR/home_scripts/"
done

find "$HOME/bin" -name "*.sh" 2>/dev/null | while read script; do
    echo "$(basename "$script"):$script" >> "$SCRIPT_REGISTRY"
    cp "$script" "$BACKUP_DIR/bin_scripts/"
done

find "$BAZINGA_HOME" -name "*.sh" | while read script; do
    echo "$(basename "$script"):$script" >> "$SCRIPT_REGISTRY"
    cp "$script" "$BACKUP_DIR/bazinga_scripts/$(basename "$script")"
done

# Step 4: Organize scripts by category
echo -e "${GREEN}Organizing scripts by category...${NC}"

# Define script categories
declare -A script_categories
script_categories["claude"]="claude|extract.*artifact"
script_categories["ssri"]="ssri|medical|health"
script_categories["whatsapp"]="whatsapp|chat|message"
script_categories["trust"]="trust|pattern|relationship"
script_categories["fractal"]="fractal|universal"
script_categories["bazinga"]="bazinga|insight|integration"
script_categories["system"]="system|cleanup|file|monitor"

# Categorize and copy unique scripts to appropriate directories
while IFS=: read -r script_name script_path; do
    # Skip directories
    if [ -d "$script_path" ]; then
        continue
    fi
    
    # Skip files that no longer exist
    if [ ! -f "$script_path" ]; then
        continue
    fi
    
    # Determine category
    category="other"
    for cat in "${!script_categories[@]}"; do
        if echo "$script_name" | grep -qiE "${script_categories[$cat]}"; then
            category="$cat"
            break
        fi
    done
    
    # Create category directory if it doesn't exist
    if [ "$category" != "other" ] && [ "$category" != "bazinga" ]; then
        mkdir -p "$BAZINGA_HOME/modules/$category"
    fi
    
    # Copy to appropriate directory
    if [ "$category" == "bazinga" ]; then
        # Main BAZINGA scripts go to bin
        cp "$script_path" "$BAZINGA_HOME/bin/$script_name"
        chmod +x "$BAZINGA_HOME/bin/$script_name"
        echo "Copied $script_name to bin directory (BAZINGA core)"
    elif [ "$category" == "other" ]; then
        # Other scripts go to a general scripts directory
        mkdir -p "$BAZINGA_HOME/scripts"
        cp "$script_path" "$BAZINGA_HOME/scripts/$script_name"
        chmod +x "$BAZINGA_HOME/scripts/$script_name"
        echo "Copied $script_name to scripts directory (other)"
    else
        # Category-specific scripts go to their module directory
        cp "$script_path" "$BAZINGA_HOME/modules/$category/$script_name"
        chmod +x "$BAZINGA_HOME/modules/$category/$script_name"
        echo "Copied $script_name to $category module"
    fi
done < "$SCRIPT_REGISTRY"

# Step 5: Handle Python and JavaScript files
echo -e "${GREEN}Organizing Python and JavaScript files...${NC}"

# Python files
find "$HOME" -name "*.py" | while read file; do
    filename=$(basename "$file")
    # Check for different categories
    if echo "$filename" | grep -qi "trust"; then
        cp "$file" "$BAZINGA_HOME/modules/trust/"
        echo "Copied $filename to trust module"
    elif echo "$filename" | grep -qi "ssri"; then
        cp "$file" "$BAZINGA_HOME/modules/ssri/"
        echo "Copied $filename to ssri module"
    elif echo "$filename" | grep -qi "whatsapp"; then
        cp "$file" "$BAZINGA_HOME/modules/whatsapp/"
        echo "Copied $filename to whatsapp module"
    else
        mkdir -p "$BAZINGA_HOME/scripts/python"
        cp "$file" "$BAZINGA_HOME/scripts/python/"
        echo "Copied $filename to python scripts"
    fi
done

# JavaScript files
find "$HOME" -name "*.js" | while read file; do
    filename=$(basename "$file")
    # Check for different categories
    if echo "$filename" | grep -qi "fractal"; then
        cp "$file" "$BAZINGA_HOME/modules/fractal/"
        echo "Copied $filename to fractal module"
    else
        mkdir -p "$BAZINGA_HOME/scripts/javascript"
        cp "$file" "$BAZINGA_HOME/scripts/javascript/"
        echo "Copied $filename to javascript scripts"
    fi
done

# Step 6: Create a centralized configuration file
echo -e "${GREEN}Creating centralized configuration...${NC}"
cat > "$BAZINGA_HOME/config/bazinga.conf" << 'EOF'
# BAZINGA Central Configuration

# Base directories
export AMSY_HOME="$HOME/AmsyPycharm"
export BAZINGA_HOME="$AMSY_HOME/BAZINGA"
export BAZINGA_BIN="$BAZINGA_HOME/bin"
export BAZINGA_MODULES="$BAZINGA_HOME/modules"
export BAZINGA_ARTIFACTS="$BAZINGA_HOME/artifacts"
export BAZINGA_OUTPUT="$BAZINGA_HOME/output"

# Claude accounts
export CLAUDE_ACCOUNTS=("bits.abhi515@gmail.com" "bits.abhi@gmail.com" "samgal2907@gmail.com")

# WhatsApp analysis settings
export WHATSAPP_PATTERNS=("DODO" ">•^•" "^••>" "•")
export WHATSAPP_DEFAULT_OUTPUT="$BAZINGA_OUTPUT/whatsapp"

# SSRI analysis settings
export SSRI_TIMELINE_START="2024-03-01"
export SSRI_TIMELINE_END="2024-11-30"

# System settings
export BAZINGA_LOG_LEVEL="info"
export BAZINGA_BACKUP_DIR="$HOME/AmsyPycharm_Backups"

# Load user-specific settings if available
if [ -f "$HOME/.bazinga_profile" ]; then
  source "$HOME/.bazinga_profile"
fi
EOF

# Create sourcing script
cat > "$BAZINGA_HOME/bin/bazinga-config" << 'EOF'
#!/bin/bash
# Source this file to load BAZINGA configuration

if [ -f "$HOME/AmsyPycharm/BAZINGA/config/bazinga.conf" ]; then
    source "$HOME/AmsyPycharm/BAZINGA/config/bazinga.conf"
else
    echo "Error: BAZINGA configuration not found"
    exit 1
fi
EOF
chmod +x "$BAZINGA_HOME/bin/bazinga-config"

# Step 7: Create master BAZINGA command
echo -e "${GREEN}Creating master BAZINGA command...${NC}"
cat > "$BAZINGA_HOME/bin/bazinga" << 'EOF'
#!/bin/bash
# BAZINGA - Master Control Script

# Load configuration
source "$HOME/AmsyPycharm/BAZINGA/bin/bazinga-config"

# Process command line arguments
COMMAND="$1"
shift

# Set colors for better readability
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Display header
echo -e "${BLUE}BAZINGA${NC} - Breakthrough Analysis & Zeitgeist Integration for Natural Growth Assessment"

case "$COMMAND" in
  trust)
    echo -e "${GREEN}Running TRUST Corrector...${NC}"
    if [ -f "$BAZINGA_MODULES/trust/trust_corrector.py" ]; then
      "$BAZINGA_MODULES/trust/trust_corrector.py" "$@"
    else
      echo -e "${YELLOW}TRUST Corrector not found${NC}"
    fi
    ;;
  fractal)
    echo -e "${GREEN}Running Universal Fractal Generator...${NC}"
    if [ -f "$BAZINGA_MODULES/fractal/universal_fractal_generator.js" ]; then
      node "$BAZINGA_MODULES/fractal/universal_fractal_generator.js" "$@"
    else
      echo -e "${YELLOW}Fractal Generator not found${NC}"
    fi
    ;;
  claude)
    echo -e "${GREEN}Running Claude Integration...${NC}"
    if [ -f "$BAZINGA_MODULES/claude/bazinga-claude-connector.sh" ]; then
      "$BAZINGA_MODULES/claude/bazinga-claude-connector.sh" "$@"
    else
      echo -e "${YELLOW}Claude connector not found${NC}"
    fi
    ;;
  ssri)
    echo -e "${GREEN}Running SSRI Analysis...${NC}"
    if [ -f "$BAZINGA_MODULES/ssri/ssri-bazinga-integration.sh" ]; then
      "$BAZINGA_MODULES/ssri/ssri-bazinga-integration.sh" "$@"
    else
      echo -e "${YELLOW}SSRI integration script not found${NC}"
    fi
    ;;
  whatsapp)
    echo -e "${GREEN}Running WhatsApp Analysis...${NC}"
    if [ -f "$BAZINGA_MODULES/whatsapp/whatsapp-trust-analyzer.sh" ]; then
      "$BAZINGA_MODULES/whatsapp/whatsapp-trust-analyzer.sh" "$@"
    else
      echo -e "${YELLOW}WhatsApp analyzer not found${NC}"
    fi
    ;;
  help|*)
    echo "Usage: bazinga <command> [options]"
    echo ""
    echo "Commands:"
    echo "  trust      Run TRUST Corrector for relationship pattern analysis"
    echo "  fractal    Generate deterministic fractal patterns"
    echo "  claude     Interact with Claude AI integration"
    echo "  ssri       Run SSRI analysis tools"
    echo "  whatsapp   Analyze WhatsApp conversations"
    echo "  help       Display this help message"
    echo ""
    ;;
esac
EOF
chmod +x "$BAZINGA_HOME/bin/bazinga"

# Step 8: Create symbolic links for convenience
echo -e "${GREEN}Creating symbolic links for convenience...${NC}"
mkdir -p "$HOME/bin"

# Create symlink to the main BAZINGA command
ln -sf "$BAZINGA_HOME/bin/bazinga" "$HOME/bin/bazinga"

# Step 9: Set up useful aliases
echo -e "${GREEN}Setting up useful aliases...${NC}"
ALIAS_FILE="$BACKUP_DIR/bazinga_aliases.sh"

cat > "$ALIAS_FILE" << EOF
# BAZINGA Aliases
# Add these to your ~/.bashrc or ~/.zshrc

# Main commands
alias bz="$BAZINGA_HOME/bin/bazinga"
alias bzt="bz trust"
alias bzf="bz fractal"
alias bzc="bz claude"
alias bzs="bz ssri"
alias bzw="bz whatsapp"

# Directory navigation
alias cdb="cd $BAZINGA_HOME"
alias cdm="cd $BAZINGA_HOME/modules"
alias cda="cd $BAZINGA_HOME/artifacts"
alias cdo="cd $BAZINGA_HOME/output"
EOF

echo "Aliases generated at: $ALIAS_FILE"
echo "To use these aliases, add them to your ~/.bashrc or ~/.zshrc"

# Step 10: Clean up the ~/bin directory
echo -e "${GREEN}Cleaning up ~/bin directory...${NC}"
cp -R "$HOME/bin" "$BACKUP_DIR/bin_full_backup"

# Final report
echo -e "${BLUE}System Cleanup Complete!${NC}"
echo "Your BAZINGA system has been organized with the following structure:"
echo "  $BAZINGA_HOME/bin - Main executable scripts"
echo "  $BAZINGA_HOME/modules - Component modules (trust, fractal, claude, ssri, whatsapp)"
echo "  $BAZINGA_HOME/config - Configuration files"
echo "  $BAZINGA_HOME/artifacts - Generated artifacts"
echo "  $BAZINGA_HOME/output - Processing results"
echo ""
echo "A complete backup was created at: $BACKUP_DIR"
echo ""
echo "Next Steps:"
echo "1. Add the aliases to your ~/.bashrc or ~/.zshrc file"
echo "2. Test the 'bazinga' command to ensure everything is working"
echo "3. Add ~/AmsyPycharm/BAZINGA/bin to your PATH if needed"

exit 0
