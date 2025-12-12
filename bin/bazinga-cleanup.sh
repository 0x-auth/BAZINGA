#!/bin/bash
# bazinga-cleanup.sh - Quick BAZINGA cleanup and self-correction utility

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${CYAN}⟨ψ|⟳| BAZINGA Quick Cleanup |ψ⟩${NC}"

# Set BAZINGA directory
BAZINGA_DIR=${BAZINGA_DIR:-"$PWD"}
GENERATED_DIR="$BAZINGA_DIR/generated"
mkdir -p "$GENERATED_DIR/optimized"

# Fix symlinks
echo -e "${YELLOW}Fixing broken symlinks...${NC}"
find "$BAZINGA_DIR" -type l -not -exec test -e {} \; -delete

# Create delegator script
DELEGATOR="$BAZINGA_DIR/bazinga"
cat > "$DELEGATOR" << 'EOL'
#!/bin/bash
# bazinga - Central command interface for BAZINGA framework

BAZINGA_DIR=${BAZINGA_DIR:-"$HOME/AmsyPycharm/BAZINGA"}
SCRIPTS_DIR="$BAZINGA_DIR/scripts"
BIN_DIR="$BAZINGA_DIR/bin"

# Find and run script
find_script() {
 for dir in "$BIN_DIR" "$SCRIPTS_DIR" "$BAZINGA_DIR"; do
   if [ -f "$dir/$1" ]; then
     "$dir/$1" "${@:2}"
     return 0
   fi
   
   script=$(find "$dir" -type f -name "*$1*" 2>/dev/null | head -1)
   if [ -n "$script" ]; then
     "$script" "${@:2}"
     return 0
   fi
 done
 
 echo "No script found matching: $1"
 return 1
}

# Self-correct this script if needed
if grep -q "unexpected EOF" "$0" 2>/dev/null || grep -q "syntax error" "$0" 2>/dev/null; then
 curl -s https://raw.githubusercontent.com/user/bazinga/main/bazinga.sh > "$0.new" 2>/dev/null
 if [ $? -eq 0 ] && [ -s "$0.new" ]; then
   mv "$0.new" "$0"
   chmod +x "$0"
   echo "Self-corrected script. Running again..."
   exec "$0" "$@"
 fi
fi

# Main command handling
if [ $# -eq 0 ]; then
 echo "Usage: $(basename "$0") <command> [args]"
 echo "Commands: run, visualize, trust, glance, generate, optimize"
 exit 0
fi

case "$1" in
 run) find_script "$2" "${@:3}" ;;
 visualize) find_script "*visual*" "${@:2}" ;;
 trust) find_script "*trust*" "${@:2}" ;;
 glance) find_script "*glance*" "${@:2}" ;;
 clean) find "$BAZINGA_DIR" -name "*.bak" -o -name "*~" -delete ;;
 *) find_script "$1" "${@:2}" ;;
esac
EOL

chmod +x "$DELEGATOR"

# Fix permissions
echo -e "${YELLOW}Fixing file permissions...${NC}"
find "$BAZINGA_DIR" -name "*.sh" -exec chmod +x {} \;
find "$BAZINGA_DIR" -name "*.py" -exec chmod +x {} \;

# Remove temp/backup files
echo -e "${YELLOW}Removing temp/backup files...${NC}"
find "$BAZINGA_DIR" -name "*.bak" -o -name "*~" -o -name "*.tmp" -delete

# Deduplicate similar scripts
echo -e "${YELLOW}Creating scripts index...${NC}"
find "$BAZINGA_DIR" -name "*.sh" | sort > "$GENERATED_DIR/script_list.txt"

echo -e "${GREEN}Cleanup complete! Use ./bazinga for all commands${NC}"
echo -e "${CYAN}Example: ./bazinga visualize${NC}"
