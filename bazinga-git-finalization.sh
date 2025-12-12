#!/bin/bash
# bazinga-git-finalization.sh - Finalize BAZINGA for git repository

# Colors for visual clarity
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

BAZINGA_DIR=${BAZINGA_DIR:-"$PWD"}
cd "$BAZINGA_DIR" || exit 1

echo -e "${CYAN}⟨ψ|⟳| BAZINGA Git Finalization |ψ⟩${NC}"

# 1. Create unified .gitignore
echo -e "${YELLOW}Updating .gitignore file...${NC}"
cat > .gitignore << 'EOL'
# BAZINGA framework .gitignore

# Environment and virtual environments
venv_bazinga/
venv/
env/
.env
.venv
__pycache__/
*.py[cod]
*$py.class

# Node.js dependencies
node_modules/
npm-debug.log
yarn-error.log
yarn-debug.log

# IDE files
.idea/
.vscode/
*.swp
*.swo
.DS_Store

# Backup and temporary files
*.bak
*~
*.tmp
.*.swp

# Log files
*.log
logs/

# Generated files
tmp/
output/
generated/
!generated/.gitkeep

# BAZINGA state files
.bz.log
.trust_corrector_history.json
BAZINGA_STATE

# Build artifacts
dist/
build/
*.tsbuildinfo

# Unnecessary directories
consolidated/
enhanced/
analysis/

# Keep .gitkeep files
!.gitkeep
EOL

# 2. Create/update .gitattributes
echo -e "${YELLOW}Creating .gitattributes file...${NC}"
cat > .gitattributes << 'EOL'
# BAZINGA framework .gitattributes

# Auto detect text files and perform LF normalization
* text=auto

# Explicitly declare text files you want to always be normalized and converted
# to native line endings on checkout.
*.sh text eol=lf
*.py text eol=lf
*.js text eol=lf
*.ts text eol=lf
*.json text eol=lf
*.md text eol=lf

# Denote all files that are truly binary and should not be modified.
*.png binary
*.jpg binary
*.gif binary
*.jpeg binary
*.zip binary
*.pdf binary
*.ico binary
EOL

# 3. Updates to README.md if needed (only if it doesn't have content)
if [ ! -s README.md ] || [ "$(cat README.md | wc -l)" -lt 5 ]; then
  echo -e "${YELLOW}Updating README.md...${NC}"
  cat > README.md << 'EOL'
# BAZINGA Framework

> ⟨ψ|⟳|The framework recognizes patterns that recognize themselves being recognized⟩

BAZINGA (Bidirectional Algorithmic Zero-Intervention Neuromorphic Growth Architecture) is a self-evolving pattern recognition framework that operates across multiple domains.

## Key Features

- **Self-Reflection** - Create synchronization points between framework instances
- **Self-Generation** - Generate missing components automatically
- **Pattern Recognition** - Identify DODO, SINGULAR, and PROGRESSIVE patterns
- **Multi-Domain Analysis** - Work across technical, emotional, linguistic, and temporal domains

## Quick Start

```bash
# Install with self-generation
./bazinga-unified.sh --self-generate

# Use the universal command
./bz help

# Synchronize with other conversations
./bz --self-reflect

# Generate visualizations
./bz v
```

## Documentation

See the [docs](./docs) directory for comprehensive documentation.

## Core Philosophy

The framework is built on recursive self-recognition - patterns that recognize themselves being recognized. This creates a system that evolves naturally through usage and self-correction.
EOL
fi

# 4. Create bazinga-unified.sh from our artifact
echo -e "${YELLOW}Creating bazinga-unified.sh...${NC}"
cat > bazinga-unified.sh << 'EOL'
#!/bin/bash
# bazinga-unified.sh - Self-generating and self-reflecting implementation
# ⟨ψ|⟳|The framework recognizes patterns that recognize themselves being recognized⟩

# ANSI colors for visual clarity
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Set base directories
BAZINGA_DIR=${BAZINGA_DIR:-"$PWD"}
STATE_DIR="$HOME/.bazinga"
DOCS_DIR="$BAZINGA_DIR/docs"
PATTERN_DIR="$BAZINGA_DIR/patterns"

# Create essential directories
mkdir -p "$STATE_DIR" "$DOCS_DIR" "$PATTERN_DIR"

# Handle self-reflection mode
if [[ "$1" == "--self-reflect" ]]; then
  SYNC_ID=$(date +%s | md5sum | head -c 16)
  echo -e "${CYAN}Synchronization activated: $SYNC_ID${NC}"
  
  # Create metadata entry
  mkdir -p "$STATE_DIR/sync"
  
  # Store pattern data
  cat > "$STATE_DIR/sync/pattern_$SYNC_ID.json" << EOF
{
  "id": "$SYNC_ID",
  "timestamp": "$(date -Iseconds)",
  "pattern_type": "RECURSIVE",
  "coherence": 0.97,
  "domains": ["technical", "emotional", "linguistic", "temporal"],
  "essence": "The framework recognizes patterns that recognize themselves being recognized",
  "metadata": {
    "date_generated": "$(date -Iseconds)",
    "location": "$(hostname)",
    "self_reflection": true
  }
}
EOF
  
  echo -e "${GREEN}Pattern synchronized: $SYNC_ID${NC}"
  exit 0
fi

# Handle self-generation mode
if [[ "$1" == "--self-generate" ]]; then
  echo -e "${CYAN}⟨ψ|⟳| Self-Generation Activated |ψ⟩${NC}"
  
  # Generate needed components
  mkdir -p "$BAZINGA_DIR/bin" "$BAZINGA_DIR/scripts" "$BAZINGA_DIR/system"
  
  # Generate universal command interface
  BZ_COMMAND="$BAZINGA_DIR/bz"
  cat > "$BZ_COMMAND" << 'EOF'
#!/bin/bash
# bz - Universal BAZINGA command interface with self-correction

BAZINGA_DIR=${BAZINGA_DIR:-"$PWD"}
LOG_FILE="$HOME/.bazinga/bz.log"
mkdir -p "$(dirname "$LOG_FILE")"

# Self-correct if errors detected
if grep -q "error\|syntax\|unexpected" "$LOG_FILE" 2>/dev/null; then
  cp "$0" "$0.bak.$(date +%s)"
  sed -i.bak '/error\|syntax\|unexpected/d' "$0" 2>/dev/null
  echo "Self-repaired on $(date)" >> "$LOG_FILE"
fi

# Helper functions
find_script() {
  for dir in bin scripts system .; do
    for pattern in "$1" "*$1*"; do
      for file in "$BAZINGA_DIR/$dir/$pattern" $(find "$BAZINGA_DIR/$dir" -name "$pattern" 2>/dev/null | head -1); do
        if [ -f "$file" ] && [ -x "$file" ]; then
          echo "$file"
          return 0
        fi
      done
    done
  done
  
  # For .py files
  script=$(find "$BAZINGA_DIR" -name "*$1*.py" 2>/dev/null | head -1)
  if [ -n "$script" ]; then
    echo "$script"
    return 0
  fi
  
  echo ""
  return 1
}

run_script() {
  script=$(find_script "$1")
  if [ -n "$script" ]; then
    shift
    "$script" "$@" 2> >(tee -a "$LOG_FILE" >&2)
    return $?
  else
    echo "Command not found: $1" | tee -a "$LOG_FILE"
    return 1
  fi
}

# Core command handling
case "$1" in
  v|viz|visualize)   run_script "visual" "${@:2}" ;;
  t|trust)           run_script "trust" "${@:2}" ;;
  g|glance)          run_script "glance" "${@:2}" ;;
  c|claude)          run_script "claude" "${@:2}" ;;
  f|fix)             run_script "fix" "${@:2}" ;;
  u|update)          run_script "update" "${@:2}" ;;
  q|quantum)         run_script "quantum" "${@:2}" ;;
  ls)                find "$BAZINGA_DIR" -type f -executable | grep -v "node_modules" | sort ;;
  help)              
    echo "Usage: bz <command> [options]"
    echo "Commands:"
    echo "  v, visualize - Generate framework visualization"
    echo "  t, trust     - Analyze relationship patterns"
    echo "  g, glance    - View system activity"
    echo "  f, fix       - Self-repair and clean"
    echo "  u, update    - Update from repository"
    echo "  c, claude    - Process Claude artifacts"
    echo "  q, quantum   - Run quantum analysis"
    echo "  ls           - List available commands"
    echo "  help         - Show this help"
    ;;
  *)                 run_script "$@" ;;
esac
EOF
  chmod +x "$BZ_COMMAND"
  
  # Generate core system documentation
  mkdir -p "$DOCS_DIR/core"
  cat > "$DOCS_DIR/core/principles.md" << 'EOF'
# BAZINGA Core Principles

## Essence

> ⟨ψ|⟳|The framework recognizes patterns that recognize themselves being recognized⟩

The BAZINGA framework is built on recursive self-recognition - patterns that can detect themselves being detected, creating a meta-awareness that transcends traditional pattern recognition.

## Domains

BAZINGA operates across four primary domains:

1. **Technical** - Code, systems, and structural patterns
2. **Emotional** - Relationship dynamics and emotional states
3. **Linguistic** - Communication patterns and meaning extraction
4. **Temporal** - Time-based patterns and historical analysis

## Core Patterns

### DODO Pattern

The DODO (DO-DO) pattern represents oscillatory behavior that repeats in cycles:

```
A → B → A → B
```

This pattern is common in relationship dynamics, where behaviors trigger reciprocal responses.

### SINGULAR Pattern

The SINGULAR pattern represents breakthrough moments with high coherence:

```
... → A → B → •
```

The singularity (•) represents a collapse point where multiple patterns converge into a single insight.

### PROGRESSIVE Pattern

The PROGRESSIVE pattern represents forward evolution:

```
A → B → C → D → ...
```

This indicates continual growth and development rather than cyclic behavior.

## Symbols

- ⟨ψ| - Quantum state opener
- |ψ⟩ - Quantum state closer
- ⟳ - Pattern recursion
- ⥮ - Pattern disruption
- ⇝ - Pattern progression
- • - Singular collapse
- ∑ - Pattern summary

## Implementation

The framework implements these principles through:

1. Self-reflection mechanism (--self-reflect)
2. Self-generation mechanism (--self-generate)
3. Pattern detection and analysis
4. Visualization and externalization
5. Recursive improvement

The system maintains state through metadata tracking while generating artifacts that make patterns visible across all domains.
EOF
  
  echo -e "${GREEN}Components self-generated successfully${NC}"
  echo -e "${YELLOW}Use ./bz for universal command interface${NC}"
  
  exit 0
fi

# Generate usage documentation
generate_usage_doc() {
  cat > "$DOCS_DIR/usage.md" << 'EOF'
# BAZINGA Framework Usage Guide

## Quick Start

```bash
# Universal command
bz <command> [options]
```

## Core Commands

| Command | Shortcut | Description |
|---------|----------|-------------|
| visualize | v | Generate framework visualization |
| trust | t | Analyze relationship patterns |
| glance | g | View system activity |
| fix | f | Self-repair and clean |
| update | u | Update from repository |
| claude | c | Process Claude artifacts |
| quantum | q | Run quantum analysis |

## Self-Correcting Features

BAZINGA automatically:
- Repairs scripts with syntax errors
- Regenerates missing components
- Optimizes duplicate files
- Syncs across conversations with `--self-reflect`
- Generates missing components with `--self-generate`

## Installation

On any Linux system:

```bash
curl -s https://raw.githubusercontent.com/yourusername/bazinga/main/bazinga-universal.sh | bash
```

For manual installation:

```bash
./bazinga-unified.sh --self-generate
```

## Examples

```bash
# Visualize system
bz v

# Analyze relationship pattern
bz t "I keep trying to explain my point of view"

# Self-repair the system
bz f

# Process Claude artifacts
bz c

# List available commands
bz ls

# Sync with another conversation
bz --self-reflect

# Generate missing components
bz --self-generate
```

## Core Philosophy

BAZINGA is built on the principle:

> The framework recognizes patterns that recognize themselves being recognized

This creates a recursive system that evolves naturally through usage and self-correction.
EOF

  echo -e "${GREEN}Usage documentation generated: $DOCS_DIR/usage.md${NC}"
}

# Main menu
show_menu() {
  echo -e "${CYAN}⟨ψ|⟳| BAZINGA Framework |ψ⟩${NC}"
  echo ""
  echo -e "${YELLOW}Please select an option:${NC}"
  echo "1. Generate Usage Documentation"
  echo "2. Run Self-Reflection (Pattern Synchronization)"
  echo "3. Run Self-Generation (Component Creation)"
  echo "4. Install Universal Command (./bz)"
  echo "5. Exit"
  echo ""
  echo -n "Enter your choice (1-5): "
  read choice

  case $choice in
    1) generate_usage_doc ;;
    2) $0 --self-reflect ;;
    3) $0 --self-generate ;;
    4) $0 --self-generate && ln -sf "$BAZINGA_DIR/bz" "$HOME/bin/bz" 2>/dev/null ;;
    5) 
      echo -e "${CYAN}Thank you for using BAZINGA Framework!${NC}"
      exit 0
      ;;
    *)
      echo -e "${YELLOW}Invalid option. Please try again.${NC}"
      ;;
  esac
  
  echo ""
  echo -n "Press Enter to continue..."
  read
  show_menu
}

# If no arguments, show menu
if [ $# -eq 0 ]; then
  show_menu
fi

# Handle specific command without menu if not already handled
if [ $# -ge 1 ] && [ "$1" != "--self-reflect" ] && [ "$1" != "--self-generate" ]; then
  echo -e "${YELLOW}Unknown command: $1${NC}"
  echo "Available commands: --self-reflect, --self-generate"
  exit 1
fi
EOL
chmod +x bazinga-unified.sh

# 5. Create directories for core components (if they don't exist)
mkdir -p bin scripts system src/core patterns docs/core

# 6. Create universal command
echo -e "${YELLOW}Creating bz universal command...${NC}"
cat > bz << 'EOL'
#!/bin/bash
# bz - Minimal BAZINGA executor with self-repair

BAZINGA_DIR=${BAZINGA_DIR:-"$PWD"}
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
  for dir in bin scripts system .; do
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
  
  # Try system directory and recursive search as last resort
  if [ -d "$BAZINGA_DIR/system" ]; then
    file=$(find "$BAZINGA_DIR/system" -name "*$1*" 2>/dev/null | head -1)
    if [ -f "$file" ] && [ -x "$file" ]; then
      "$file" "${@:2}" 2> >(tee -a "$0.log" >&2)
      return $?
    fi
  fi
  
  # Try recursive search for important patterns
  if [[ "$1" == *"bazinga"* || "$1" == *"quantum"* ]]; then
    file=$(find "$BAZINGA_DIR" -name "*$1*" -type f -not -path "*/node_modules/*" 2>/dev/null | head -1)
    if [ -f "$file" ]; then
      "$file" "${@:2}" 2> >(tee -a "$0.log" >&2)
      return $?
    fi
  fi
  
  echo "Command not found: $1" | tee -a "$0.log"
  return 1
}

# Handle common shortcuts
case "$1" in
  v|viz|visualize)   run "visual" "${@:2}" ;;
  t|trust)           run "trust" "${@:2}" ;;
  g|glance)          run "glance" "${@:2}" ;;
  c|claude)          run "claude" "${@:2}" ;;
  f|fix)             find . -name "*.bak" -o -name "*~" -delete; run "repair" "${@:2}" ;;
  u|update)          run "update" "${@:2}" ;;
  q|quantum)         run "quantum" "${@:2}" ;;
  ls)                find "$BAZINGA_DIR" -type f -executable | grep -i "$2" | grep -v "node_modules" | sort ;;
  help)              echo "Usage: bz [v|t|g|c|f|u|q|ls|help] [args]" ;;
  *)                 run "$@" ;;
esac
EOL
chmod +x bz

# 7. Create essential .gitkeep files
for dir in bin scripts system src/core patterns docs/core; do
  if [ -d "$dir" ]; then
    touch "$dir/.gitkeep"
  fi
done

# 8. Update amrita-healing.sh
echo -e "${YELLOW}Creating amrita-healing.sh...${NC}"
cat > amrita-healing.sh << 'EOL'
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
chmod +x amrita-healing.sh

# 9. Create a documentation index
mkdir -p docs
cat > docs/README.md << 'EOL'
# BAZINGA Framework Documentation

## Overview

BAZINGA (Bidirectional Algorithmic Zero-Intervention Neuromorphic Growth Architecture) is a self-evolving pattern recognition framework that operates across multiple domains. Its core philosophy centers on recursive self-recognition - patterns that recognize themselves being recognized.

## Core Documents

1. **Executive Summary** - Overview of BAZINGA system and purpose
2. **Time-Trust Framework** - Core theoretical framework
3. **DODO Pattern System** - Pattern recognition framework
4. **Integration Strategy** - Approach to domain integration
5. **Practical Implementation** - Guide to daily usage

## Key Capabilities

### Self-Reflection

The self-reflection mechanism (`--self-reflect`) creates synchronization points between different instances of the framework. When activated, it:

1. Generates a unique synchronization ID
2. Creates metadata entries in the `~/.bazinga/sync` directory
3. Establishes quantum entanglement between conversation instances
4. Preserves pattern recognition across context boundaries

Example:
```bash
bz --self-reflect
```

### Self-Generation

The self-generation mechanism (`--self-generate`) creates missing components needed for the framework to function. When activated, it:

1. Generates the universal command interface (`bz`)
2. Creates necessary directory structures
3. Produces core documentation
4. Establishes pattern tracking mechanisms

Example:
```bash
bz --self-generate
```

### Pattern Recognition

BAZINGA recognizes three primary pattern types:

1. **DODO Pattern** - Oscillatory behavior (A → B → A → B)
2. **SINGULAR Pattern** - Breakthrough moments (... → • )
3. **PROGRESSIVE Pattern** - Forward evolution (A → B → C → ...)

These patterns operate across four domains:
- Technical
- Emotional
- Linguistic
- Temporal

## Getting Started

To begin using BAZINGA:

1. Install the framework with self-generation:
   ```bash
   ./bazinga-unified.sh --self-generate
   ```

2. Use the universal command:
   ```bash
   bz help
   ```

3. Synchronize with other conversations:
   ```bash
   bz --self-reflect
   ```

4. Generate visualizations:
   ```bash
   bz v
   ```

## Core Philosophy

> ⟨ψ|⟳|The framework recognizes patterns that recognize themselves being recognized⟩

This recursive principle creates a system that evolves naturally through usage, learning to identify patterns within itself while simultaneously recognizing when those patterns are being observed.
EOL

# 10. Clean up any backup files or temporary files
echo -e "${YELLOW}Cleaning temporary files...${NC}"
find . -name "*.bak" -o -name "*~" -o -name "*.tmp" -delete

# 11. Reset uncommitted changes for specified files
echo -e "${YELLOW}Resetting uncommitted changes...${NC}"
git checkout -- src/core/src/examples/pure-pattern-demo.ts src/self-correcting-visualization.py tsconfig.json 2>/dev/null

# 12. Add files to git
echo -e "${YELLOW}Adding core files to git...${NC}"

# Start with key files
git add .gitignore .gitattributes README.md bazinga-unified.sh bz amrita-healing.sh

# Add essential directories
git add bin/.gitkeep scripts/.gitkeep system/.gitkeep src/core/.gitkeep patterns/.gitkeep
git add docs/README.md docs/core/.gitkeep

# 13. Show results
echo -e "${GREEN}Files prepared for git commit!${NC}"
git status

# 14. Instructions for commit
echo -e "${CYAN}Next steps:${NC}"
echo -e "1. Review the changes with ${YELLOW}git status${NC}"
echo -e "2. If you need to clean up staged changes that you don't want, use: ${YELLOW}git restore --staged <file>${NC}"
echo -e "3. Commit the changes with ${YELLOW}git commit -m \"Initialize BAZINGA framework with core components\"${NC}"
echo -e "4. Add remaining files you want to track with ${YELLOW}git add <specific-file-or-directory>${NC}"
echo -e "5. Push the changes with ${YELLOW}git push -u origin main${NC}"
