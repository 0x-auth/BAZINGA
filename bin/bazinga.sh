# Check if MongoDB is installed
  if ! command -v mongo &>/dev/null; then
    echo -e "${YELLOW}MongoDB not installed, falling back to file storage${NC}"
    
    # Store as file
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local filepath="${BAZINGA_DIR}/artifacts/claude/${timestamp}_${type}.json"
    
    # Create directory if needed
    mkdir -p "${BAZINGA_DIR}/artifacts/claude"
    
    # Write to JSON file
    cat > "$filepath" << EOL
{
  "timestamp": "$(date -Iseconds)",
  "type": "$type",
  "source": "$source",
  "content": $(echo "$content" | jq -Rs . || echo "\"$content\"")
}
EOL
    
    echo -e "${GREEN}Artifact saved to $filepath${NC}"
    return 0
  fi
  
  # Ensure MongoDB is running
  if ! pgrep mongod >/dev/null; then
    echo -e "${YELLOW}MongoDB not running. Starting MongoDB...${NC}"
    mkdir -p "$HOME/.mongodb/data"
    mongod --dbpath "$HOME/.mongodb/data" --fo#!/bin/bash
# bazinga.sh - Universal BAZINGA System Manager
# Can be run from any location and handles all aspects of the BAZINGA system
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

# Start the menu
show_menu
EOL
    chmod +x "$BAZINGA_DIR/bazinga-unified.sh"
  fi
  
  # Create healing script if missing
  if [ ! -f "$BAZINGA_DIR/amrita-healing.sh" ]; then
    echo -e "${YELLOW}Creating amrita-healing.sh...${NC}"
    cat > "$BAZINGA_DIR/amrita-healing.sh" << 'EOL'
#!/bin/bash
# amrita-healing.sh - Self-reflecting bridge for Amu's healing journey

# Start synchronization signal
if [[ "$1" == "--self-reflect" ]]; then
  SYNC_ID=$(date +%s | md5sum | head -c 16)
  echo "Creating golden ratio healing pattern: $SYNC_ID"
  mkdir -p ~/.bazinga/healing
  echo "{\"id\":\"$SYNC_ID\",\"phase\":\"emotional_recalibration\",\"pattern\":\"SINGULAR\"}" > ~/.bazinga/healing/amu_patterns.json
  exit 0
fi
# End synchronization signal

# Create gentle healing space
mkdir -p healing-space/visualization
TIMESTAMP=$(date +%s)

# Generate quantum-pattern healing visualization
cat > healing-space/visualization/amu_healing_$TIMESTAMP.txt << EOF
⟨ψ|⟳|====================================================|ψ⟩
         Golden Ratio Healing Pattern for Amu
⟨ψ|⟳|====================================================|ψ⟩

Phase: Post-Discontinuation Emotional Recalibration
Pattern: SINGULAR • (Breakthrough Moment)

Directive: Honor the natural healing process without overprocessing.
          Let moments of clarity speak for themselves.
          
Trust the natural unwinding of medication effects.
Recognize genuine connection moments when they occur.
Allow space for rediscovery without pressure.

⟨ψ|⟳|====================================================|ψ⟩
EOF

echo "Healing visualization created. Pass '--self-reflect' to synchronize."
EOL
    chmod +x "$BAZINGA_DIR/amrita-healing.sh"
  fi
  
  # Create artifact tracker script
  if [ ! -f "$BAZINGA_DIR/artifact-tracker.sh" ]; then
    echo -e "${YELLOW}Creating artifact-tracker.sh...${NC}"
    cat > "$BAZINGA_DIR/artifact-tracker.sh" << 'EOL'
#!/bin/bash
# artifact-tracker.sh - Track and organize Claude artifacts

# ANSI colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
DB_DIR="$HOME/.bazinga/artifacts"
mkdir -p "$DB_DIR"
DB_FILE="$DB_DIR/artifacts.db"
CLIPBOARD_FILE="$DB_DIR/clipboard.txt"

# Initialize database if needed
if [ ! -f "$DB_FILE" ]; then
  cat > "$DB_FILE" << EOF
{
  "artifacts": [],
  "last_updated": "$(date -Iseconds)",
  "artifact_count": 0
}
EOF
fi

# Save clipboard content to file
get_clipboard() {
  if command -v pbpaste &> /dev/null; then
    # macOS
    pbpaste > "$CLIPBOARD_FILE"
  elif command -v xclip &> /dev/null; then
    # Linux with X11
    xclip -selection clipboard -o > "$CLIPBOARD_FILE"
  else
    echo -e "${RED}Clipboard access not available${NC}"
    return 1
  fi
  
  echo -e "${GREEN}Clipboard content saved${NC}"
  return 0
}

# Add clipboard content to database
add_artifact() {
  get_clipboard || return 1
  
  # Get metadata
  local timestamp=$(date -Iseconds)
  local hash=$(md5sum "$CLIPBOARD_FILE" | cut -d' ' -f1)
  local size=$(wc -c < "$CLIPBOARD_FILE")
  local tag="$1"
  
  # Check if artifact already exists
  local existing=$(grep -c "$hash" "$DB_FILE")
  if [ "$existing" -gt 0 ]; then
    echo -e "${YELLOW}Artifact already exists in database${NC}"
    return 0
  fi
  
  # Create artifact entry
  local dest_dir="$DB_DIR/artifacts/$hash"
  mkdir -p "$dest_dir"
  cp "$CLIPBOARD_FILE" "$dest_dir/content.txt"
  
  # Create metadata
  cat > "$dest_dir/metadata.json" << EOF
{
  "hash": "$hash",
  "timestamp": "$timestamp",
  "size": $size,
  "tags": ["$tag"],
  "source": "clipboard"
}
EOF
  
  # Update database
  local count=$(grep -o '"artifact_count":' "$DB_FILE" | wc -l)
  count=$((count + 1))
  
  # Update database file (simplistic approach)
  sed -i.bak "s/\"artifacts\": \[/\"artifacts\": \[\n    {\"hash\": \"$hash\", \"timestamp\": \"$timestamp\", \"tags\": [\"$tag\"]},/" "$DB_FILE"
  sed -i.bak "s/\"artifact_count\": [0-9]*/\"artifact_count\": $count/" "$DB_FILE"
  sed -i.bak "s/\"last_updated\": \"[^\"]*\"/\"last_updated\": \"$timestamp\"/" "$DB_FILE"
  
  echo -e "${GREEN}Artifact added to database: $hash${NC}"
  echo -e "Tagged as: $tag"
  echo -e "Size: $size bytes"
  return 0
}

# Check if clipboard content exists in database
check_artifact() {
  get_clipboard || return 1
  
  local hash=$(md5sum "$CLIPBOARD_FILE" | cut -d' ' -f1)
  local existing=$(grep -c "$hash" "$DB_FILE")
  
  if [ "$existing" -gt 0 ]; then
    echo -e "${YELLOW}Artifact exists in database${NC}"
    local metadata=$(grep -A 5 "$hash" "$DB_FILE")
    echo -e "Metadata: $metadata"
    return 0
  else
    echo -e "${GREEN}Artifact is new${NC}"
    return 1
  fi
}

# List artifacts in database
list_artifacts() {
  local count=$(grep -o '"artifact_count":' "$DB_FILE" | wc -l)
  
  echo -e "${CYAN}Artifact Database${NC}"
  echo -e "Total artifacts: $count"
  echo -e "----------------------------------"
  
  # List in reverse chronological order
  grep -A 2 "hash" "$DB_FILE" | sort -r | head -10
  
  echo -e "----------------------------------"
  echo -e "Use 'artifact-tracker.sh show <hash>' to view content"
}

# Show artifact content
show_artifact() {
  local hash="$1"
  
  if [ -z "$hash" ]; then
    echo -e "${RED}No hash specified${NC}"
    return 1
  fi
  
  local content_file="$DB_DIR/artifacts/$hash/content.txt"
  
  if [ -f "$content_file" ]; then
    echo -e "${CYAN}Artifact: $hash${NC}"
    echo -e "----------------------------------"
    cat "$content_file"
    echo -e "----------------------------------"
    return 0
  else
    echo -e "${RED}Artifact not found: $hash${NC}"
    return 1
  fi
}

# Main function
main() {
  local command="$1"
  local arg="$2"
  
  case "$command" in
    add)
      if [ -z "$arg" ]; then
        arg="general"
      fi
      add_artifact "$arg"
      ;;
    check)
      check_artifact
      ;;
    list)
      list_artifacts
      ;;
    show)
      show_artifact "$arg"
      ;;
    *)
      echo -e "${CYAN}Claude Artifact Tracker${NC}"
      echo -e "Usage:"
      echo -e "  artifact-tracker.sh add [tag]  - Add clipboard content to artifacts database"
      echo -e "  artifact-tracker.sh check      - Check if clipboard content exists in database"
      echo -e "  artifact-tracker.sh list       - List artifacts in database"
      echo -e "  artifact-tracker.sh show <hash> - Show artifact content"
      ;;
  esac
}

main "$@"
EOL
    chmod +x "$BAZINGA_DIR/artifact-tracker.sh"
    
    # Create symlink in bin
    mkdir -p "$BAZINGA_DIR/bin"
    ln -sf "$BAZINGA_DIR/artifact-tracker.sh" "$BAZINGA_DIR/bin/artifact-tracker"
  fi
  
  # Create MongoDB integration
  if [ ! -f "$BAZINGA_DIR/bin/claude-artifact-db.sh" ]; then
    echo -e "${YELLOW}Creating MongoDB integration script...${NC}"
    mkdir -p "$BAZINGA_DIR/bin"
    cat > "$BAZINGA_DIR/bin/claude-artifact-db.sh" << 'EOL'
#!/bin/bash
# claude-artifact-db.sh - MongoDB integration for Claude artifacts

# ANSI colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Ensure MongoDB is running
ensure_mongodb() {
  if ! pgrep mongod >/dev/null; then
    echo -e "${YELLOW}MongoDB not running. Starting MongoDB...${NC}"
    if command -v mongod >/dev/null; then
      mkdir -p "$HOME/.mongodb/data"
      mongod --dbpath "$HOME/.mongodb/data" --fork --logpath "$HOME/.mongodb/mongod.log"
      sleep 2  # Give MongoDB time to start
    else
      echo -e "${RED}MongoDB not installed. Please install MongoDB to use artifact storage.${NC}"
      return 1
    fi
  fi
  
  return 0
}

# Initialize MongoDB collection
init_mongodb() {
  ensure_mongodb || return 1
  
  # Create text index on content field
  mongo localhost:27017/claude_artifacts --eval 'db.artifacts.createIndex({content: "text"})' --quiet
  
  echo -e "${GREEN}MongoDB initialized${NC}"
  return 0
}

# Store clipboard content in MongoDB
store_artifact() {
  ensure_mongodb || return 1
  
  # Get clipboard content
  if command -v pbpaste &> /dev/null; then
    # macOS
    content=$(pbpaste)
  elif command -v xclip &> /dev/null; then
    # Linux with X11
    content=$(xclip -selection clipboard -o)
  else
    echo -e "${RED}Clipboard access not available${NC}"
    return 1
  fi
  
  # Calculate hash
  hash=$(echo "$content" | md5sum | cut -d' ' -f1)
  
  # Check if artifact already exists
  existing=$(mongo localhost:27017/claude_artifacts --quiet --eval "db.artifacts.findOne({hash: \"$hash\"})")
  if [ "$existing" != "null" ]; then
    echo -e "${YELLOW}Artifact already exists in database${NC}"
    return 0
  fi
  
  # Get metadata
  local timestamp=$(date -Iseconds)
  local tag="${1:-general}"
  
  # Insert into MongoDB
  mongo localhost:27017/claude_artifacts --quiet --eval "
    db.artifacts.insertOne({
      hash: \"$hash\",
      timestamp: new Date(),
      content: \`$content\`,
      tags: [\"$tag\"],
      source: \"clipboard\"
    })
  "
  
  echo -e "${GREEN}Artifact stored in MongoDB: $hash${NC}"
  echo -e "Tagged as: $tag"
  return 0
}

# Search artifacts in MongoDB
search_artifacts() {
  ensure_mongodb || return 1
  
  local query="$1"
  
  if [ -z "$query" ]; then
    echo -e "${RED}No search query specified${NC}"
    return 1
  fi
  
  echo -e "${CYAN}Searching artifacts for: ${BOLD}$query${NC}"
  
  # Search in MongoDB
  mongo localhost:27017/claude_artifacts --quiet --eval "
    var results = db.artifacts.find(
      { \$text: { \$search: \"$query\" } },
      { score: { \$meta: \"textScore\" }, content: { \$substrBytes: ['\$content', 0, 100] } }
    ).sort({ score: { \$meta: \"textScore\" } }).limit(5).toArray();
    
    if (results.length === 0) {
      results = db.artifacts.find(
        { content: { \$regex: \"$query\", \$options: \"i\" } },
        { content: { \$substrBytes: ['\$content', 0, 100] } }
      ).limit(5).toArray();
    }
    
    if (results.length === 0) {
      print(\"No matching artifacts found\");
    } else {
      print(\"Found \" + results.length + \" matching artifacts:\\n\");
      results.forEach(function(doc) {
        print(\"Hash: \" + doc.hash + \" | Date: \" + doc.timestamp);
        print(\"Tags: \" + doc.tags.join(', \"));
        print(\"Excerpt: \" + doc.content + \"...\\n\");
      });
    }
  "
  
  return 0
}

# List recent artifacts
list_artifacts() {
  ensure_mongodb || return 1
  
  local limit="${1:-10}"
  
  echo -e "${CYAN}Recent artifacts in database${NC}"
  
  # List in reverse chronological order
  mongo localhost:27017/claude_artifacts --quiet --eval "
    var artifacts = db.artifacts.find({}, {content: 0}).sort({timestamp: -1}).limit($limit).toArray();
    print(\"Total artifacts: \" + db.artifacts.countDocuments() + \"\\n\");
    
    artifacts.forEach(function(doc) {
      print(\"Hash: \" + doc.hash + \" | Date: \" + doc.timestamp);
      print(\"Tags: \" + doc.tags.join(', \") + \"\\n\");
    });
  "
  
  return 0
}

# Export artifacts to JSON file
export_artifacts() {
  ensure_mongodb || return 1
  
  local export_file="${1:-$HOME/.bazinga/artifacts_export.json}"
  
  # Export to JSON
  mongo localhost:27017/claude_artifacts --quiet --eval "
    var artifacts = db.artifacts.find({}).toArray();
    print(JSON.stringify(artifacts, null, 2));
  " > "$export_file"
  
  echo -e "${GREEN}Artifacts exported to: $export_file${NC}"
  echo -e "Total artifacts: $(grep -c hash "$export_file")"
  return 0
}

# Main function
main() {
  local command="$1"
  shift
  
  case "$command" in
    init)
      init_mongodb
      ;;
    store)
      store_artifact "$@"
      ;;
    search)
      search_artifacts "$@"
      ;;
    list)
      list_artifacts "$@"
      ;;
    export)
      export_artifacts "$@"
      ;;
    *)
      echo -e "${CYAN}Claude Artifact MongoDB Integration${NC}"
      echo -e "Usage:"
      echo -e "  claude-artifact-db.sh init               - Initialize MongoDB"
      echo -e "  claude-artifact-db.sh store [tag]        - Store clipboard content"
      echo -e "  claude-artifact-db.sh search <query>     - Search artifacts"
      echo -e "  claude-artifact-db.sh list [limit]       - List recent artifacts"
      echo -e "  claude-artifact-db.sh export [filename]  - Export artifacts to JSON"
      ;;
  esac
}

main "$@"
EOL
    chmod +x "$BAZINGA_DIR/bin/claude-artifact-db.sh"
  fi
  
  echo -e "${GREEN}Components generated successfully${NC}"
}

# MongoDB integration functions for artifact storage
store_artifact() {
  local content="$1"
  local type="$2"
  local source="$3"
  
  # Check if MongoDB is installed
  if ! command -v mongo &>/dev/null; then
    echo -e "${YELLOW}MongoDB not installed, fallingrk --logpath "$HOME/.mongodb/mongod.log" || {
      echo -e "${RED}Failed to start MongoDB, falling back to file storage${NC}"
      
      # Store as file (same as above)
      local timestamp=$(date +%Y%m%d_%H%M%S)
      local filepath="${BAZINGA_DIR}/artifacts/claude/${timestamp}_${type}.json"
      mkdir -p "${BAZINGA_DIR}/artifacts/claude"
      echo "{\"timestamp\": \"$(date -Iseconds)\", \"type\": \"$type\", \"source\": \"$source\", \"content\": $(echo "$content" | jq -Rs . || echo "\"$content\"")}" > "$filepath"
      echo -e "${GREEN}Artifact saved to $filepath${NC}"
      return 0
    }
  fi
  
  # Insert into MongoDB
  echo "try {
    db.artifacts.insertOne({
      timestamp: new Date(),
      type: \"$type\",
      source: \"$source\",
      content: $(echo "$content" | jq -Rs .),
      hash: \"$(echo "$content" | md5sum | cut -d' ' -f1)\"
    });
    print(\"Artifact stored successfully in MongoDB\");
  } catch (e) {
    print(\"Error storing artifact: \" + e);
  }" | mongo localhost:27017/bazinga_artifacts --quiet
  
  echo -e "${GREEN}Artifact stored in MongoDB${NC}"
  return 0
}

# Self-adapt function - adapts to different environments and configurations
self_adapt() {
  echo -e "${CYAN}Self-adaptation activated${NC}"
  
  # Detect OS
  OS="unknown"
  if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
  fi
  
  # Adapt to OS
  echo -e "${YELLOW}Detected OS: $OS${NC}"
  
  # Check for necessary commands and adapt
  MISSING_TOOLS=""
  
  for cmd in jq md5sum python3 grep find; do
    if ! command -v $cmd &>/dev/null; then
      MISSING_TOOLS="$MISSING_TOOLS $cmd"
    fi
  done
  
  if [ -n "$MISSING_TOOLS" ]; then
    echo -e "${YELLOW}Missing tools:$MISSING_TOOLS${NC}"
    echo -e "Creating adaptations..."
    
    # Create adaptations directory
    mkdir -p "$BAZINGA_DIR/adaptations"
    
    # Create md5sum replacement if needed
    if [[ "$MISSING_TOOLS" == *"md5sum"* ]]; then
      if command -v md5 &>/dev/null; then
        echo -e "${GREEN}Creating md5sum adaptation using md5${NC}"
        cat > "$BAZINGA_DIR/adaptations/md5sum" << 'EOL'
#!/bin/bash
md5 "$@" | sed 's/MD5 (\(.*\)) = \(.*\)/\2 \1/'
EOL
        chmod +x "$BAZINGA_DIR/adaptations/md5sum"
      else
        echo -e "${YELLOW}Creating md5sum adaptation using Python${NC}"
        cat > "$BAZINGA_DIR/adaptations/md5sum" << 'EOL'
#!/usr/bin/env python
import hashlib
import sys

for arg in sys.argv[1:]:
    with open(arg, 'rb') as f:
        print(f"{hashlib.md5(f.read()).hexdigest()} {arg}")
EOL
        chmod +x "$BAZINGA_DIR/adaptations/md5sum"
      fi
    fi
    
    # Create jq replacement if needed
    if [[ "$MISSING_TOOLS" == *"jq"* ]]; then
      echo -e "${YELLOW}Creating jq adaptation using Python${NC}"
      cat > "$BAZINGA_DIR/adaptations/jq" << 'EOL'
#!/usr/bin/env python
import json
import sys

if len(sys.argv) > 1 and sys.argv[1] == "-Rs":
    data = sys.stdin.read()
    json_str = json.dumps(data)
    print(json_str)
else:
    try:
        data = json.load(sys.stdin)
        print(json.dumps(data, indent=2))
    except:
        print("{}")
EOL
      chmod +x "$BAZINGA_DIR/adaptations/jq"
    fi
    
    # Create PATH adaptation
    echo -e "${GREEN}Adding adaptations to PATH${NC}"
    export PATH="$BAZINGA_DIR/adaptations:$PATH"
    
    # Add to bashrc/profile if confirmed
    read -p "Add adaptations to your shell configuration? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      if [ -f "$HOME/.bashrc" ]; then
        echo "export PATH=\"$BAZINGA_DIR/adaptations:\$PATH\"" >> "$HOME/.bashrc"
        echo -e "${GREEN}Added to .bashrc${NC}"
      elif [ -f "$HOME/.bash_profile" ]; then
        echo "export PATH=\"$BAZINGA_DIR/adaptations:\$PATH\"" >> "$HOME/.bash_profile"
        echo -e "${GREEN}Added to .bash_profile${NC}"
      elif [ -f "$HOME/.zshrc" ]; then
        echo "export PATH=\"$BAZINGA_DIR/adaptations:\$PATH\"" >> "$HOME/.zshrc"
        echo -e "${GREEN}Added to .zshrc${NC}"
      else
        echo -e "${YELLOW}Could not find shell configuration file${NC}"
      fi
    fi
  else
    echo -e "${GREEN}All required tools available${NC}"
  fi
  
  # Check for MongoDB and adapt
  if ! command -v mongo &>/dev/null; then
    echo -e "${YELLOW}MongoDB not installed, creating file-based adapter${NC}"
    mkdir -p "$BAZINGA_DIR/adaptations"
    
    cat > "$BAZINGA_DIR/adaptations/mongo-adapter.sh" << 'EOL'
#!/bin/bash
# MongoDB adapter using file-based storage

DB_DIR="$HOME/.bazinga/artifacts_db"
mkdir -p "$DB_DIR"

COLLECTION=$(echo "$3" | cut -d'/' -f2)
mkdir -p "$DB_DIR/$COLLECTION"

if grep -q "insertOne" << EOF
$@
EOF
then
  # Extract JSON data between parentheses
  JSON=$(sed -n 's/.*insertOne(\(.*\)).*/\1/p' << EOF
$@
EOF
)
  
  # Generate ID and save to file
  ID=$(date +%s_%N)
  echo "$JSON" > "$DB_DIR/$COLLECTION/$ID.json"
  echo "Inserted document with ID: $ID"
else
  echo "File-based MongoDB adapter only supports insertOne operations"
fi
EOL
    chmod +x "$BAZINGA_DIR/adaptations/mongo-adapter.sh"
    
    # Create mongo symlink
    ln -sf "$BAZINGA_DIR/adaptations/mongo-adapter.sh" "$BAZINGA_DIR/adaptations/mongo"
    
    echo -e "${GREEN}Created MongoDB file-based adapter${NC}"
  fi
  
  echo -e "${GREEN}Self-adaptation complete${NC}"
}

# Git integration functions - handle pushing to remote repositories
git_push() {
  echo -e "${CYAN}Preparing BAZINGA for Git push${NC}"
  
  # Ask for confirmation
  read -p "Push changes to Git repository? (y/n): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Git push cancelled${NC}"
    return 1
  fi
  
  # Prepare files
  git_prepare
  
  # Add core files
  git_add_core
  
  # Commit changes
  read -p "Enter commit message: " commit_msg
  if [ -z "$commit_msg" ]; then
    commit_msg="Update BAZINGA framework components"
  fi
  
  git commit -m "$commit_msg"
  
  # Check if remote exists
  if git remote | grep -q "origin"; then
    # Push to remote
    git push origin
    echo -e "${GREEN}Changes pushed to remote repository${NC}"
  else
    echo -e "${YELLOW}No remote repository found${NC}"
    read -p "Add remote repository URL: " remote_url
    if [ -n "$remote_url" ]; then
      git remote add origin "$remote_url"
      git push -u origin main
      echo -e "${GREEN}Changes pushed to new remote repository${NC}"
    else
      echo -e "${YELLOW}No remote URL provided. Changes committed locally only.${NC}"
    fi
  fi
  
  return 0
}

# Cleanup function - removes temporary files and fixes issues
cleanup() {
  echo -e "${CYAN}Cleaning up BAZINGA directory${NC}"
  
  # Remove temporary files
  find "$BAZINGA_DIR" -name "*.bak" -delete
  find "$BAZINGA_DIR" -name "*~" -delete
  find "$BAZINGA_DIR" -name "*.tmp" -delete
  
  # Remove empty directories
  find "$BAZINGA_DIR" -type d -empty -delete
  
  # Fix permissions
  find "$BAZINGA_DIR" -name "*.sh" -exec chmod +x {} \;
  find "$BAZINGA_DIR" -name "*.py" -exec chmod +x {} \;
  
  echo -e "${GREEN}Cleanup complete${NC}"
}

# Main function - process command line arguments
main() {
  # First, validate BAZINGA directory
  validate_bazinga_dir
  
  # Process command line arguments
  local command="$1"
  shift
  
  case "$command" in
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
    store-artifact)
      if [ -z "$1" ]; then
        echo -e "${RED}No artifact content provided${NC}"
        return 1
      fi
      store_artifact "$1" "${2:-general}" "${3:-manual}"
      ;;
    search-artifacts)
      if [ -z "$1" ]; then
        echo -e "${RED}No search query provided${NC}"
        return 1
      fi
      search_artifacts "$1"
      ;;
    git-prepare)
      git_prepare
      ;;
    git-add)
      git_add_core
      ;;
    git-push)
      git_push
      ;;
    cleanup)
      cleanup
      ;;
    help|--help|-h)
      echo -e "${CYAN}BAZINGA Universal Script${NC}"
      echo -e "Usage: $0 [command] [options]"
      echo -e ""
      echo -e "Commands:"
      echo -e "  self-reflect       Run self-reflection"
      echo -e "  self-correct       Fix common issues"
      echo -e "  self-generate      Generate missing components"
      echo -e "  self-adapt         Adapt to current environment"
      echo -e "  store-artifact     Store artifact in database"
      echo -e "  search-artifacts   Search artifacts database"
      echo -e "  git-prepare        Prepare for Git"
      echo -e "  git-add            Add core files to Git"
      echo -e "  git-push           Push changes to Git"
      echo -e "  cleanup            Clean up temporary files"
      echo -e "  help               Show this help message"
      ;;
    *)
      # Check if the command exists as a script
      if [ -f "$BAZINGA_DIR/bin/$command" ]; then
        "$BAZINGA_DIR/bin/$command" "$@"
      elif [ -f "$BAZINGA_DIR/scripts/$command" ]; then
        "$BAZINGA_DIR/scripts/$command" "$@"
      elif [ -f "$BAZINGA_DIR/$command" ]; then
        "$BAZINGA_DIR/$command" "$@"
      else
        echo -e "${RED}Unknown command: $command${NC}"
        main help
      fi
      ;;
  esac
}

# Run the main function with all arguments
main "$@"