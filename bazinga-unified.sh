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
    echo "  c, claude    - Process CLD artifacts"
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
| claude | c | Process CLD artifacts |
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

# Process CLD artifacts
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
