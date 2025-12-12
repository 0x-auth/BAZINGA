#!/bin/bash
# bazinga.sh - Universal BAZINGA System Manager
# Simplified and fixed with unified functionality
# Usage: ./bazinga.sh [command] [options]

# ANSI colors for better readability
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# Default locations
DEFAULT_BAZINGA_DIR="$HOME/AmsyPycharm/BAZINGA"
ARTIFACTS_DIR="$HOME/ClaudeArtifacts"
export BAZINGA_DIR=${BAZINGA_DIR:-$DEFAULT_BAZINGA_DIR}

# Find BAZINGA directory from any location
find_bazinga_dir() {
  # Check if we're already in the BAZINGA directory
  if [ -f "bazinga-unified.sh" ] && [ -d "src/core" ]; then
    echo "$PWD"
    return 0
  fi
  
  # Check if BAZINGA_DIR environment variable is set
  if [ -n "$BAZINGA_DIR" ] && [ -d "$BAZINGA_DIR" ]; then
    echo "$BAZINGA_DIR"
    return 0
  fi
  
  # Try to find it from current location up to home directory
  local current_dir="$PWD"
  while [[ "$current_dir" != "/" ]]; do
    if [ -f "$current_dir/bazinga-unified.sh" ] && [ -d "$current_dir/src/core" ]; then
      echo "$current_dir"
      return 0
    fi
    current_dir=$(dirname "$current_dir")
  done
  
  # Check common locations
  for dir in "$HOME/AmsyPycharm/BAZINGA" "$HOME/BAZINGA" "$HOME/Projects/BAZINGA"; do
    if [ -d "$dir" ] && [ -f "$dir/bazinga-unified.sh" ]; then
      echo "$dir"
      return 0
    fi
  done
  
  # Not found
  echo ""
  return 1
}

# Make sure we have a valid BAZINGA_DIR
validate_bazinga_dir() {
  local dir=$(find_bazinga_dir)
  if [ -z "$dir" ]; then
    echo -e "${RED}ERROR: Could not find BAZINGA directory${NC}"
    echo -e "Please set BAZINGA_DIR environment variable or run from BAZINGA directory"
    exit 1
  fi
  export BAZINGA_DIR="$dir"
  cd "$BAZINGA_DIR"
}

# Self-reflect function
self_reflect() {
  local ID=$(date +%s | md5sum | head -c 16)
  echo -e "${CYAN}Self-reflection activated: $ID${NC}"
  
  # Create quantum state preservation
  mkdir -p "$HOME/.bazinga/sync"
  echo "$ID:$(date)" > "$HOME/.bazinga/sync/last_sync"
  
  # Save pattern state
  if [ -f "$HOME/.bazinga/sync/patterns.json" ]; then
    # Update existing state
    sed -i.bak "s/}/,\"lastSync\":\"$ID\"}/g" "$HOME/.bazinga/sync/patterns.json"
  else
    # Initialize state
    echo "{\"id\":\"$ID\",\"recursive\":true}" > "$HOME/.bazinga/sync/patterns.json"
  fi
  
  echo -e "${GREEN}Pattern synchronized: $ID${NC}"
}

# Self-correct function - fixes common issues
self_correct() {
  echo -e "${CYAN}Self-correction activated${NC}"
  
  # Check for broken symlinks
  local broken_links=$(find "$BAZINGA_DIR" -type l -not -exec test -e {} \; -print)
  if [ -n "$broken_links" ]; then
    echo -e "${YELLOW}Fixing broken symlinks...${NC}"
    find "$BAZINGA_DIR" -type l -not -exec test -e {} \; -delete
  fi
  
  # Check for permission issues
  echo -e "${YELLOW}Fixing permissions...${NC}"
  find "$BAZINGA_DIR" -name "*.sh" -exec chmod +x {} \;
  find "$BAZINGA_DIR" -name "*.py" -exec chmod +x {} \;
  chmod +x "$BAZINGA_DIR/bz" 2>/dev/null || true
  
  # Check for missing directories
  for dir in src/core bin docs/core patterns system artifacts/claude; do
    if [ ! -d "$BAZINGA_DIR/$dir" ]; then
      echo -e "${YELLOW}Creating missing directory: $dir${NC}"
      mkdir -p "$BAZINGA_DIR/$dir"
      touch "$BAZINGA_DIR/$dir/.gitkeep"
    fi
  done
  
  # Update universal command if needed
  if [ ! -f "$BAZINGA_DIR/bz" ] || [ $(grep -c "error" "$BAZINGA_DIR/bz.log" 2>/dev/null) -gt 0 ]; then
    echo -e "${YELLOW}Updating universal command (bz)...${NC}"
    create_universal_command
  fi
  
  echo -e "${GREEN}Self-correction complete${NC}"
}

# Create universal command (bz)
create_universal_command() {
  cat > "$BAZINGA_DIR/bz" << 'EOL'
#!/bin/bash
# bz - Minimal BAZINGA executor with self-repair

BAZINGA_DIR=${BAZINGA_DIR:-$(dirname "$(realpath "$0")")}
cd "$BAZINGA_DIR" || exit 1
LOG="$BAZINGA_DIR/.bz.log"

# Self-correct if errors detected
if grep -q "error\|syntax\|unexpected" "$0.log" 2>/dev/null; then
  cp "$0" "$0.bak"
  sed -i.bak '/error\|syntax\|unexpected/d' "$0" 2>/dev/null
  echo "Self-repaired on $(date)" >> "$LOG"
fi

# Find and execute with minimal effort
run() {
  for dir in bin scripts .; do
    for pattern in "$1" "*$1*"; do
      for file in "$dir/$pattern" $(find "$dir" -name "$pattern" 2>/dev/null | head -1); do
        if [ -f "$file" ] && [ -x "$file" ]; then
          "$file" "${@:2}" 2> >(tee -a "$0.log" >&2)
          return $?
        fi
      done
    done
  done
  
  # For .py files
  script=$(find . -name "*$1*.py" 2>/dev/null | head -1)
  if [ -n "$script" ]; then
    python3 "$script" "${@:2}" 2> >(tee -a "$0.log" >&2)
    return $?
  fi
  
  echo "Command not found: $1" | tee -a "$0.log"
  return 1
}

# Handle common shortcuts
case "$1" in
  v|viz|visual)    run "visual" "${@:2}" ;;
  t|trust)         run "trust" "${@:2}" ;;
  g|glance)        run "glance" "${@:2}" ;;
  c|claude)        run "claude" "${@:2}" ;;
  f|fix)           find . -name "*.bak" -o -name "*~" -delete; run "repair" "${@:2}" ;;
  git)             git add system docs src/core README.md ;;
  h|help)          echo "Usage: bz [v|t|g|c|f|git|h] [args]" ;;
  s|self-reflect)  # Special self-reflection mode
                   ID=$(date +%s | md5sum | head -c 16)
                   echo "Creating pattern sync: $ID"
                   mkdir -p ~/.bazinga/sync
                   echo "{\"id\":\"$ID\",\"timestamp\":\"$(date -Iseconds)\"}" > ~/.bazinga/sync/last_sync.json
                   exit 0 ;;
  *)               run "$@" ;;
esac
EOL
  chmod +x "$BAZINGA_DIR/bz"
}

# Self-generate function - creates missing components
self_generate() {
  echo -e "${CYAN}Self-generation activated${NC}"
  
  # Create unified script if missing
  if [ ! -f "$BAZINGA_DIR/bazinga-unified.sh" ]; then
    echo -e "${YELLOW}Creating bazinga-unified.sh...${NC}"
    cat > "$BAZINGA_DIR/bazinga-unified.sh" << 'EOL'
#!/bin/bash
# bazinga-unified.sh - BAZINGA System Framework

# ANSI colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Main menu
show_menu() {
  echo -e "${CYAN}⟨ψ|⟳| BAZINGA Framework |ψ⟩${NC}"
  echo
  echo -e "Please select an option:"
  echo -e "1. Generate Usage Documentation"
  echo -e "2. Run Self-Reflection (Pattern Synchronization)"
  echo -e "3. Run Self-Generation (Component Creation)"
  echo -e "4. Install Universal Command (./bz)"
  echo -e "5. Exit"
  echo
  read -p "Enter your choice (1-5): " choice
  
  case $choice in
    1)
      generate_docs
      ;;
    2)
      self_reflect
      ;;
    3)
      self_generate
      ;;
    4)
      install_universal_command
      ;;
    5)
      echo -e "Thank you for using BAZINGA Framework!"
      exit 0
      ;;
    *)
      echo -e "${RED}Invalid option. Please try again.${NC}"
      ;;
  esac
  
  read -p "Press Enter to continue..." dummy
  show_menu
}

# Generate documentation
generate_docs() {
  DOCS_DIR="docs"
  mkdir -p "$DOCS_DIR"
  
  cat > "$DOCS_DIR/usage.md" << 'EOF'
# BAZINGA Framework Usage Guide

## Overview

BAZINGA is a recursive pattern recognition system that incorporates quantum-inspired mathematical models to analyze patterns across multiple domains.

## Quick Start

```bash
# Run the unified framework
./bazinga-unified.sh

# Use the minimal command
./bz <command> [options]
```

## Core Commands

| Command | Description |
|---------|-------------|
| `./bz v` | Generate visualizations |
| `./bz t` | Run trust corrector |
| `./bz g` | Run activity glance |
| `./bz c` | Claude integration |
| `./bz f` | Fix/cleanup |

## Self-Reflection

To synchronize patterns across different systems:

```bash
./bz self-reflect
```

## Pattern Types

- **DODO Pattern** (⟳): Recursive loops
- **PROGRESSIVE Pattern** (⇝): Forward movement
- **DISRUPTION Pattern** (⥮): Change opportunity
- **SINGULAR Pattern** (•): Breakthrough moments

## Directory Structure

- `src/core/`: Core framework components
- `bin/`: Executable scripts
- `docs/`: Documentation
- `artifacts/`: Generated artifacts

## Integration Components

The framework integrates with various systems:
- Claude AI
- Time-Trust analysis
- WhatsApp communication patterns
EOF

  echo -e "${GREEN}Usage documentation generated: $DOCS_DIR/usage.md${NC}"
}

# Self-reflection function
self_reflect() {
  ID=$(date +%s | md5sum | head -c 16)
  echo -e "Synchronization activated: $ID"
  mkdir -p ~/.bazinga/sync
  
  if [ -f ~/.bazinga/sync/patterns.json ]; then
    # Update existing patterns
    patterns=$(cat ~/.bazinga/sync/patterns.json)
    echo "$patterns" | sed "s/}/,\"lastSync\":\"$ID\"}/g" > ~/.bazinga/sync/patterns.json
  else
    # Create new patterns file
    echo "{\"id\":\"$ID\",\"recursive\":true,\"timestamp\":\"$(date -Iseconds)\"}" > ~/.bazinga/sync/patterns.json
  fi
  
  echo -e "Pattern synchronized: $ID"
}

# Self-generation function
self_generate() {
  echo -e "${CYAN}⟨ψ|⟳| Self-Generation Activated |ψ⟩${NC}"
  
  # Create universal command
  if [ ! -f "bz" ]; then
    cat > "bz" << 'EOF'
#!/bin/bash
# bz - Universal BAZINGA command

BAZINGA_DIR=$(dirname "$(realpath "$0")")
cd "$BAZINGA_DIR"

run() {
  for dir in bin scripts .; do
    for pattern in "$1" "*$1*"; do
      file="$dir/$pattern"
      if [ -f "$file" ] && [ -x "$file" ]; then
        "$file" "${@:2}"
        return 0
      fi
    done
  done
  
  script=$(find . -name "*$1*.py" 2>/dev/null | head -1)
  if [ -n "$script" ]; then
    python3 "$script" "${@:2}"
    return 0
  fi
  
  echo "Command not found: $1"
  return 1
}

case "$1" in
  v|viz)       run "visual" "${@:2}" ;;
  t|trust)     run "trust" "${@:2}" ;;
  g|glance)    run "glance" "${@:2}" ;;
  c|claude)    run "claude" "${@:2}" ;;
  f|fix)       find . -name "*.bak" -delete; run "repair" "${@:2}" ;;
  h|help)      echo "Usage: bz [v|t|g|c|f|h] [args]" ;;
  *)           run "$@" ;;
esac
EOF
    chmod +x "bz"
  fi
  
  # Create directories
  mkdir -p src/core bin docs system artifacts
  
  echo -e "${GREEN}Components self-generated successfully${NC}"
  echo -e "Use ./bz for universal command interface"
}

# Install universal command
install_universal_command() {
  echo -e "${CYAN}⟨ψ|⟳| Self-Generation Activated |ψ⟩${NC}"
  self_generate
}

# Create artifact tracker if missing
create_artifact_tracker() {
  if [ ! -f "$BAZINGA_DIR/bin/claude-artifact-db.sh" ]; then
    echo -e "${YELLOW}Creating claude-artifact-db.sh...${NC}"
    mkdir -p "$BAZINGA_DIR/bin"
    cat > "$BAZINGA_DIR/bin/claude-artifact-db.sh" << 'EOL'
#!/bin/bash
# claude-artifact-db.sh - Simplified Claude artifact tracker

# ANSI colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# Config
DB_DIR="$HOME/.bazinga/claude_artifacts"
DB_FILE="$DB_DIR/artifacts.json"

# Make sure directory exists
mkdir -p "$DB_DIR"

# Initialize database
init() {
  if [ -f "$DB_FILE" ]; then
    echo -e "${YELLOW}Database already exists. Use 'reset' to create a new one.${NC}"
    return 0
  fi
  
  # Create initial DB
  echo "{\"artifacts\":[],\"lastUpdated\":\"$(date -Iseconds)\"}" > "$DB_FILE"
  echo -e "${GREEN}Initialized artifact database at $DB_FILE${NC}"
}

# Reset database
reset() {
  read -p "This will delete all stored artifacts. Continue? (y/n): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "{\"artifacts\":[],\"lastUpdated\":\"$(date -Iseconds)\"}" > "$DB_FILE"
    echo -e "${GREEN}Database reset successfully${NC}"
  fi
}

# Store artifact from clipboard
store() {
  local tag="$1"
  if [ -z "$tag" ]; then
    tag="general"
  fi
  
  # Get clipboard content
  if command -v pbpaste &> /dev/null; then
    content=$(pbpaste)
  elif command -v xclip &> /dev/null; then
    content=$(xclip -selection clipboard -o)
  else
    echo -e "${RED}Clipboard command not found${NC}"
    return 1
  fi
  
  # Generate hash
  hash=$(echo "$content" | md5sum | cut -d' ' -f1)
  
  # Check if artifact already exists
  if grep -q "\"hash\":\"$hash\"" "$DB_FILE"; then
    echo -e "${YELLOW}Artifact already exists in database${NC}"
    return 0
  fi
  
  # Save content
  mkdir -p "$DB_DIR/content"
  echo "$content" > "$DB_DIR/content/$hash.txt"
  
  # Update database
  timestamp=$(date -Iseconds)
  temp_file=$(mktemp)
  
  if command -v jq &> /dev/null; then
    # Use jq if available
    jq ".artifacts += [{\"hash\":\"$hash\",\"tag\":\"$tag\",\"timestamp\":\"$timestamp\"}] | .lastUpdated = \"$timestamp\"" "$DB_FILE" > "$temp_file"
    mv "$temp_file" "$DB_FILE"
  else
    # Fallback
    sed "s/\"artifacts\":\[/\"artifacts\":[{\"hash\":\"$hash\",\"tag\":\"$tag\",\"timestamp\":\"$timestamp\"},/" "$DB_FILE" > "$temp_file"
    sed "s/\"lastUpdated\":\"[^\"]*\"/\"lastUpdated\":\"$timestamp\"/" "$temp_file" > "$DB_FILE"
    rm "$temp_file"
  fi
  
  echo -e "${GREEN}Artifact stored with tag: $tag${NC}"
  echo -e "Hash: $hash"
}

# Search artifacts
search() {
  local query="$1"
  if [ -z "$query" ]; then
    echo -e "${RED}Please provide a search query${NC}"
    return 1
  fi
  
  echo -e "${CYAN}Searching for: $query${NC}"
  found=0
  
  # Get all artifact hashes
  if command -v jq &> /dev/null; then
    hashes=$(jq -r '.artifacts[].hash' "$DB_FILE")
  else
    hashes=$(grep -o '"hash":"[^"]*"' "$DB_FILE" | cut -d'"' -f4)
  fi
  
  # Search in content
  for hash in $hashes; do
    if [ -f "$DB_DIR/content/$hash.txt" ] && grep -q "$query" "$DB_DIR/content/$hash.txt"; then
      # Get metadata
      if command -v jq &> /dev/null; then
        metadata=$(jq -r ".artifacts[] | select(.hash == \"$hash\")" "$DB_FILE")
      else
        metadata=$(grep -A 3 "$hash" "$DB_FILE" | head -4)
      fi
      
      echo -e "${CYAN}Found in artifact: $hash${NC}"
      echo -e "${YELLOW}$metadata${NC}"
      echo "----------------------"
      found=$((found + 1))
    fi
  done
  
  echo -e "${GREEN}Found $found artifacts${NC}"
}

# List recent artifacts
list() {
  local count="${1:-10}"
  
  echo -e "${CYAN}Recent artifacts:${NC}"
  
  if command -v jq &> /dev/null; then
    jq -r ".artifacts | sort_by(.timestamp) | reverse | .[0:$count] | .[] | \"[\(.timestamp)] \(.tag): \(.hash)\"" "$DB_FILE"
  else
    # Simple implementation without jq
    grep -o '"hash":"[^"]*","tag":"[^"]*","timestamp":"[^"]*"' "$DB_FILE" | tail -n "$count" | sort -r | sed 's/"hash":"/ /'
  fi
}

# Export artifacts
export() {
  local outfile="${1:-$HOME/claude_artifacts_export.json}"
  
  cp "$DB_FILE" "$outfile"
  echo -e "${GREEN}Exported database to $outfile${NC}"
}

# Show help
show_help() {
  echo -e "${CYAN}Claude Artifact Database${NC}"
  echo
  echo "Usage: $0 <command> [options]"
  echo
  echo "Commands:"
  echo "  init                Initialize database"
  echo "  reset               Reset database"
  echo "  store [tag]         Store clipboard content with optional tag"
  echo "  search <query>      Search artifacts"
  echo "  list [count]        List recent artifacts (default: 10)"
  echo "  export [file]       Export database"
  echo "  help                Show this help"
}

# Main
case "$1" in
  init)     init ;;
  reset)    reset ;;
  store)    store "$2" ;;
  search)   search "$2" ;;
  list)     list "$2" ;;
  export)   export "$2" ;;
  help|*)   show_help ;;
esac
EOL
    chmod +x "$BAZINGA_DIR/bin/claude-artifact-db.sh"
    echo -e "${GREEN}Created claude-artifact-db.sh${NC}"
  fi
}

# Self-adapt function - detects environment and adapts
self_adapt() {
  echo -e "${CYAN}Self-adaptation activated${NC}"
  
  # Check OS
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo -e "${YELLOW}Detected macOS environment${NC}"
    # macOS-specific adaptations
    if ! command -v md5sum &>/dev/null; then
      echo -e "${YELLOW}Creating md5sum adapter${NC}"
      mkdir -p "$BAZINGA_DIR/adapters"
      cat > "$BAZINGA_DIR/adapters/md5sum" << 'EOF'
#!/bin/bash
# md5sum adapter for macOS
md5 -r "$@"
EOF
      chmod +x "$BAZINGA_DIR/adapters/md5sum"
      export PATH="$BAZINGA_DIR/adapters:$PATH"
    fi
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo -e "${YELLOW}Detected Linux environment${NC}"
    # Linux-specific adaptations
  else
    echo -e "${YELLOW}Unknown OS: $OSTYPE${NC}"
  fi
  
  # Create missing tools and adapters
  create_artifact_tracker
  
  echo -e "${GREEN}Self-adaptation complete${NC}"
}

# Helper function to execute any BAZINGA component
run_component() {
  local component="$1"
  shift
  
  # Check if component exists directly
  if [ -f "$BAZINGA_DIR/bin/$component" ]; then
    "$BAZINGA_DIR/bin/$component" "$@"
    return $?
  elif [ -f "$BAZINGA_DIR/$component" ]; then
    "$BAZINGA_DIR/$component" "$@"
    return $?
  fi
  
  # Search for component
  local found=0
  for dir in "$BAZINGA_DIR/bin" "$BAZINGA_DIR/scripts" "$BAZINGA_DIR"; do
    if [ -d "$dir" ]; then
      local file=$(find "$dir" -name "*$component*" -type f -executable | head -1)
      if [ -n "$file" ]; then
        "$file" "$@"
        return $?
      fi
    fi
  done
  
  echo -e "${RED}Component not found: $component${NC}"
  return 1
}

# Initialize function - check/create required components
init() {
  echo -e "${CYAN}Initializing BAZINGA system...${NC}"
  
  # Create expected directories
  for dir in "src/core" "bin" "docs" "artifacts" "system"; do
    if [ ! -d "$BAZINGA_DIR/$dir" ]; then
      echo -e "${YELLOW}Creating directory: $dir${NC}"
      mkdir -p "$BAZINGA_DIR/$dir"
    fi
  done
  
  # Create minimal required files
  if [ ! -f "$BAZINGA_DIR/bz" ]; then
    echo -e "${YELLOW}Creating minimal command runner (bz)${NC}"
    create_universal_command
  fi
  
  if [ ! -f "$BAZINGA_DIR/bazinga-unified.sh" ]; then
    echo -e "${YELLOW}Creating unified framework script${NC}"
    cat > "$BAZINGA_DIR/bazinga-unified.sh" << 'EOL'
#!/bin/bash
# bazinga-unified.sh - Minimal starter script
echo "BAZINGA Framework initialized"
echo "Use ./bz for commands or ./bazinga.sh help"
EOL
    chmod +x "$BAZINGA_DIR/bazinga-unified.sh"
  fi
  
  echo -e "${GREEN}Initialization complete${NC}"
}

# Check environment/status
check() {
  echo -e "${CYAN}BAZINGA Environment Check${NC}"
  echo
  
  # Check BAZINGA directory
  if [ -d "$BAZINGA_DIR" ]; then
    echo -e "${GREEN}BAZINGA directory: $BAZINGA_DIR${NC}"
  else
    echo -e "${RED}BAZINGA directory not found: $BAZINGA_DIR${NC}"
  fi
  
  # Check key components
  echo -e "\nChecking key components:"
  for component in "bz" "bazinga-unified.sh" "bin/claude-artifact-db.sh"; do
    if [ -f "$BAZINGA_DIR/$component" ]; then
      if [ -x "$BAZINGA_DIR/$component" ]; then
        echo -e "  ${GREEN}✓ $component${NC}"
      else
        echo -e "  ${YELLOW}! $component (not executable)${NC}"
        chmod +x "$BAZINGA_DIR/$component"
      fi
    else
      echo -e "  ${RED}✗ $component${NC}"
    fi
  done
  
  # Check directory structure
  echo -e "\nChecking directory structure:"
  for dir in "src/core" "bin" "docs" "artifacts" "system"; do
    if [ -d "$BAZINGA_DIR/$dir" ]; then
      echo -e "  ${GREEN}✓ $dir/${NC}"
    else
      echo -e "  ${RED}✗ $dir/${NC}"
    fi
  done
  
  # Check for pattern data
  echo -e "\nChecking pattern data:"
  if [ -d "$HOME/.bazinga/sync" ]; then
    echo -e "  ${GREEN}✓ Pattern sync directory${NC}"
    PATTERN_FILES=$(find "$HOME/.bazinga/sync" -type f | wc -l)
    echo -e "  ${GREEN}✓ Pattern files: $PATTERN_FILES${NC}"
  else
    echo -e "  ${RED}✗ Pattern sync directory${NC}"
  fi
  
  echo -e "\n${CYAN}Environment check complete${NC}"
}

# Main function
main() {
  # Process command
  case "$1" in
    self-reflect|--self-reflect)
      self_reflect
      ;;
    self-correct)
      self_correct
      ;;
    self-generate)
      self_generate
      ;;
    self-adapt)
      self_adapt
      ;;
    init)
      init
      ;;
    check)
      check
      ;;
    run)
      shift
      run_component "$@"
      ;;
    help|--help|-h)
      echo -e "${CYAN}⟨ψ|⟳| BAZINGA Universal System Manager |ψ⟩${NC}"
      echo
      echo -e "Usage: $0 [command] [options]"
      echo
      echo -e "Commands:"
      echo -e "  self-reflect       Synchronize patterns across systems"
      echo -e "  self-correct       Fix common issues"
      echo -e "  self-generate      Generate missing components"
      echo -e "  self-adapt         Adapt to current environment"
      echo -e "  init               Initialize system"
      echo -e "  check              Check environment status"
      echo -e "  run <component>    Run a specific component"
      echo -e "  help               Show this help message"
      ;;
    *)
      if [ -z "$1" ]; then
        # No arguments, show help
        main help
      else
        # Try to find and run a component
        run_component "$@"
      fi
      ;;
  esac
}

# Run main with all arguments
main "$@"
