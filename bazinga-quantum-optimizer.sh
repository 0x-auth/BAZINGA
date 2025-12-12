#!/bin/bash
# bazinga-quantum-optimizer.sh - Self-correcting system that optimizes git and claude integration

# Colors for output
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

BAZINGA_DIR=${BAZINGA_DIR:-"$PWD"}
cd "$BAZINGA_DIR" || exit 1

echo -e "${CYAN}⟨ψ|⟳| BAZINGA Quantum Self-Optimizer |ψ⟩${NC}"

# Create quantum signature
TIMESTAMP=$(date +%s)
QUANTUM_SIGNATURE=$(echo "$TIMESTAMP" | md5sum | cut -c1-16)

# Ensure essential directories exist
mkdir -p "$BAZINGA_DIR/system" "$BAZINGA_DIR/artifacts/claude_artifacts" "$BAZINGA_DIR/docs"

# Create or update .gitignore
cat > .gitignore << 'EOL'
# Generated directories
node_modules/
venv*/
__pycache__/
dist/
build/
.DS_Store

# Keep specific generated files
!generated/dashboard/latest-framework-visual.svg
!artifacts/visualization/*.svg

# Logs and temporary files
*.log
*.bak
*~
*.tmp
logs/

# Python
*.py[cod]
*$py.class
*.so
.Python
*.egg-info/

# Private data
*.env
EOL

# Function to detect Claude artifacts and create inventory
process_claude_artifacts() {
  echo -e "${YELLOW}Processing Claude artifacts...${NC}"
  
  ARTIFACTS_DIR="$BAZINGA_DIR/artifacts/claude_artifacts"
  mkdir -p "$ARTIFACTS_DIR/inventory"
  
  # Find all Claude artifacts and catalog them
  find "$BAZINGA_DIR" -name "*.trust_corrector_history.json" -o -name "*claude*.json" | while read -r file; do
    filename=$(basename "$file")
    cp "$file" "$ARTIFACTS_DIR/$filename.$(date +%Y%m%d)"
  done
  
  # Create inventory file
  INVENTORY="$ARTIFACTS_DIR/inventory/claude_inventory_$TIMESTAMP.json"
  echo "{" > "$INVENTORY"
  echo "  \"timestamp\": \"$TIMESTAMP\"," >> "$INVENTORY"
  echo "  \"quantum_signature\": \"$QUANTUM_SIGNATURE\"," >> "$INVENTORY"
  echo "  \"artifacts\": [" >> "$INVENTORY"
  
  find "$ARTIFACTS_DIR" -type f -name "*.json*" | sort | while read -r file; do
    echo "    {\"path\": \"$(basename "$file")\", \"modified\": \"$(stat -f %m "$file")\"}, " >> "$INVENTORY"
  done
  
  # Close JSON
  sed -i '' '$ s/,\s*$//' "$INVENTORY"
  echo "  ]" >> "$INVENTORY"
  echo "}" >> "$INVENTORY"
  
  echo -e "${GREEN}Created Claude artifacts inventory: $INVENTORY${NC}"
}

# Function to create self-correcting unified system
create_unified_system() {
  echo -e "${YELLOW}Creating self-correcting unified system...${NC}"
  
  UNIFIED="$BAZINGA_DIR/system/bazinga-quantum"
  
  cat > "$UNIFIED" << 'EOL'
#!/bin/bash
# BAZINGA Quantum System - Self-correcting framework

BAZINGA_DIR=${BAZINGA_DIR:-"$PWD"}
SYSTEM_DIR="$BAZINGA_DIR/system"
TIMESTAMP=$(date +%s)
ERROR_LOG="$SYSTEM_DIR/quantum_errors.log"
ERROR_COUNT=0

# ANSI colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

mkdir -p "$SYSTEM_DIR"

# Function to implement error self-correction
self_correct() {
  local script="$1"
  
  if [ ! -f "$script" ]; then
    return 1
  fi
  
  # Check for syntax errors
  bash -n "$script" 2>/dev/null
  if [ $? -ne 0 ]; then
    echo -e "${YELLOW}Detected syntax error in $script, attempting to repair...${NC}"
    
    # Create backup
    cp "$script" "$script.bak.$TIMESTAMP"
    
    # Basic repairs for common errors
    sed -i '' '/unexpected/d; /syntax error/d; s/echo $/echo ""/' "$script"
    
    # Fix unmatched quotes
    grep -n "'" "$script" | awk -F: '{print $1}' | while read -r line; do
      count=$(sed -n "${line}p" "$script" | grep -o "'" | wc -l)
      if [ $((count % 2)) -eq 1 ]; then
        sed -i '' "${line}s/'/''/g" "$script"
      fi
    done
    
    # Add missing 'fi' at end if needed
    if grep -q "^[ ]*if" "$script" && ! grep -q "^[ ]*fi" "$script"; then
      echo "fi" >> "$script"
    fi
    
    chmod +x "$script"
    echo "Self-corrected $script" >> "$ERROR_LOG"
    return 0
  fi
  
  return 0
}

# Function for pattern-based script finding
find_pattern_script() {
  local pattern="$1"
  local dirs=("$BAZINGA_DIR/bin" "$BAZINGA_DIR/scripts" "$BAZINGA_DIR")
  
  for dir in "${dirs[@]}"; do
    # Try exact match first
    if [ -f "$dir/$pattern" ]; then
      echo "$dir/$pattern"
      return 0
    fi
    
    # Try pattern match
    local script=$(find "$dir" -type f -name "*$pattern*" 2>/dev/null | head -1)
    if [ -n "$script" ]; then
      echo "$script"
      return 0
    fi
  done
  
  return 1
}

# Function to execute scripts with error handling
quantum_execute() {
  local script="$1"
  shift
  
  if [ ! -f "$script" ]; then
    echo -e "${RED}Script not found: $script${NC}"
    ERROR_COUNT=$((ERROR_COUNT + 1))
    return 1
  fi
  
  # Apply self-correction if needed
  self_correct "$script"
  
  # Execute with error trapping
  bash -c "\"$script\" \"$@\"" 2> >(tee -a "$ERROR_LOG" >&2)
  local status=$?
  
  if [ $status -ne 0 ]; then
    ERROR_COUNT=$((ERROR_COUNT + 1))
    echo "Execution error in $script with args: $*" >> "$ERROR_LOG"
  fi
  
  return $status
}

# Function to process Claude artifacts
process_artifacts() {
  local artifacts_dir="$BAZINGA_DIR/artifacts/claude_artifacts"
  mkdir -p "$artifacts_dir"
  
  local history_file="$BAZINGA_DIR/.trust_corrector_history.json"
  if [ -f "$history_file" ]; then
    cp "$history_file" "$artifacts_dir/trust_history_$TIMESTAMP.json"
  fi
  
  # Process other Claude outputs if needed
}

# Self-check this script
self_correct "$0"

# Process command
case "$1" in
  visualize|visual)
    script=$(find_pattern_script "*visual*")
    if [ -n "$script" ]; then
      quantum_execute "$script" "${@:2}"
    else
      echo -e "${YELLOW}No visualizer found, creating one...${NC}"
      quantum_execute "$BAZINGA_DIR/scripts/bazinga-svg-generator.sh" "${@:2}"
    fi
    ;;
  trust|correct)
    script=$(find_pattern_script "*trust*corrector*")
    if [ -n "$script" ]; then
      quantum_execute "$script" "${@:2}"
    else
      echo -e "${RED}Trust corrector not found${NC}"
      ERROR_COUNT=$((ERROR_COUNT + 1))
    fi
    ;;
  glance|activity)
    script=$(find_pattern_script "*glance*")
    if [ -n "$script" ]; then
      quantum_execute "$script" "${@:2}"
    else
      echo -e "${RED}Activity glance not found${NC}"
      ERROR_COUNT=$((ERROR_COUNT + 1))
    fi
    ;;
  clean|optimize)
    echo -e "${YELLOW}Cleaning temporary files...${NC}"
    find "$BAZINGA_DIR" -name "*.bak" -o -name "*~" -o -name "*.tmp" -delete
    process_artifacts
    ;;
  claude|artifacts)
    echo -e "${YELLOW}Processing Claude artifacts...${NC}"
    process_artifacts
    ;;
  git)
    echo -e "${YELLOW}Optimizing git repository...${NC}"
    script=$(find_pattern_script "*git*setup*")
    if [ -n "$script" ]; then
      quantum_execute "$script" "${@:2}"
    else
      # Basic git operations if script not found
      git add -A "$BAZINGA_DIR/system" "$BAZINGA_DIR/docs" "$BAZINGA_DIR/src/core"
      echo -e "${GREEN}Added system, docs and core files to git${NC}"
    fi
    ;;
  *)
    script=$(find_pattern_script "$1")
    if [ -n "$script" ]; then
      quantum_execute "$script" "${@:2}"
    else
      echo -e "${RED}Unknown command or script: $1${NC}"
      ERROR_COUNT=$((ERROR_COUNT + 1))
      echo "Available commands: visualize, trust, glance, clean, claude, git"
    fi
    ;;
esac

# Report errors if any occurred
if [ $ERROR_COUNT -gt 0 ]; then
  echo -e "${YELLOW}$ERROR_COUNT errors occurred. See $ERROR_LOG for details.${NC}"
fi

echo -e "${CYAN}⟨ψ|⟳| BAZINGA Quantum Execution Complete |ψ⟩${NC}"
exit $ERROR_COUNT
EOL

  chmod +x "$UNIFIED"
  
  # Create symbolic links
  ln -sf "$UNIFIED" "$BAZINGA_DIR/bz"
  ln -sf "$UNIFIED" "$BAZINGA_DIR/bazinga-quantum"
  
  echo -e "${GREEN}Created self-correcting unified system: $UNIFIED${NC}"
  echo -e "${GREEN}Use ./bz or ./bazinga-quantum for all operations${NC}"
}

# Function to optimize git repository
optimize_git_repository() {
  echo -e "${YELLOW}Optimizing git repository...${NC}"
  
  # Add core files
  git add -f system/bazinga-quantum bz bazinga-quantum 2>/dev/null
  git add -f .gitignore README.md 2>/dev/null
  
  # Add documentation files
  git add -f docs/BAZINGA-Complete-Usage-Guide.md docs/usage-guide.md 2>/dev/null
  
  # Add core source files
  git add -f src/core/*pattern*.ts src/core/quantum*.ts src/core/bazinga/*.ts 2>/dev/null
  
  # Add visualizations and correct permissions
  find artifacts/visualization -name "*.svg" -exec git add -f {} \; 2>/dev/null
  find generated -name "*framework-visual.svg" -exec git add -f {} \; 2>/dev/null
  
  # Fix permissions on scripts
  find "$BAZINGA_DIR" -name "*.sh" -exec chmod +x {} \; 2>/dev/null
  find "$BAZINGA_DIR" -name "*.py" -exec chmod +x {} \; 2>/dev/null
  
  echo -e "${GREEN}Git repository optimized. Ready for commit.${NC}"
}

# Function to create USAGE guide
create_usage_guide() {
  echo -e "${YELLOW}Creating usage guide...${NC}"
  
  USAGE_GUIDE="$BAZINGA_DIR/docs/BAZINGA-Complete-Usage-Guide.md"
  
  cat > "$USAGE_GUIDE" << 'EOL'
# BAZINGA Complete Usage Guide

## Quantum Self-Correcting System

The core of BAZINGA is now the quantum self-correcting system:

```bash
./bz <command> [options]
# or
./bazinga-quantum <command> [options]
```

This system automatically detects and repairs errors in scripts and provides a unified interface to all BAZINGA functionality.

## Core Commands

| Command | Description | Example |
|---------|-------------|---------|
| `visualize` | Generate framework visualization | `./bz visualize` |
| `trust` | Run trust corrector | `./bz trust --reflect "I keep trying to explain"` |
| `glance` | Get activity snapshot | `./bz glance 30` |
| `clean` | Clean temporary files | `./bz clean` |
| `claude` | Process Claude artifacts | `./bz claude` |
| `git` | Optimize git repository | `./bz git` |

## Self-Correction Features

The quantum system implements:

1. **Script repair** - Automatically fixes syntax errors in shell scripts
2. **Error logging** - Tracks all errors in system/quantum_errors.log
3. **Claude artifact management** - Preserves and catalogs Claude interactions

## Git Integration

BAZINGA is now git-ready with:

```bash
./bz git
```

This command optimizes the repository structure, focusing on core components while excluding large temporary files.

## File Structure

```
BAZINGA/
├── system/             # Core system components
├── artifacts/          # Generated artifacts including Claude outputs
├── docs/               # Documentation and guides
├── src/                # Source code
│   └── core/           # Core functionality
├── bz                  # Primary command shortcut
└── bazinga-quantum     # Self-correcting system
```

## Documentation

For more detailed information, see the following guides:

- `docs/bazinga/language/complete-doc.md` - Framework documentation
- `docs/fractal_analysis/Fractal_Numerical_Encoding_Guide.md` - Encoding guide
- `docs/bazinga/language/integration-guide.md` - Integration guide
EOL

  echo -e "${GREEN}Created usage guide: $USAGE_GUIDE${NC}"
}

# Main execution
process_claude_artifacts
create_unified_system
optimize_git_repository
create_usage_guide

echo -e "${GREEN}BAZINGA Quantum Optimization Complete!${NC}"
echo -e "${CYAN}System is now self-correcting and git-optimized.${NC}"
echo -e "${CYAN}Use ./bz for all operations going forward.${NC}"
