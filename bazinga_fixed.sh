#!/bin/bash
# bazinga.sh - Universal BAZINGA System Manager

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
export BAZINGA_DIR=${BAZINGA_DIR:-$DEFAULT_BAZINGA_DIR}

# Find BAZINGA directory from any location
find_bazinga_dir() {
  # Check if we're already in the BAZINGA directory
  if [ -f "bazinga-unified.sh" ]; then
    echo "$PWD"
    return 0
  fi
  
  # Check if BAZINGA_DIR environment variable is set
  if [ -n "$BAZINGA_DIR" ] && [ -d "$BAZINGA_DIR" ]; then
    echo "$BAZINGA_DIR"
    return 0
  fi
  
  # Check common locations
  for dir in "$HOME/AmsyPycharm/BAZINGA" "$HOME/BAZINGA"; do
    if [ -d "$dir" ]; then
      echo "$dir"
      return 0
    fi
  done
  
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
  
  # Create sync directory
  mkdir -p "$HOME/.bazinga/sync"
  
  # Save pattern state
  echo "{\"id\":\"$ID\",\"recursive\":true}" > "$HOME/.bazinga/sync/patterns.json"
  
  echo -e "${GREEN}Pattern synchronized: $ID${NC}"
}

# Main function
main() {
  # First, validate BAZINGA directory
  validate_bazinga_dir
  
  # Process command line arguments
  local command="$1"
  shift
  
  case "$command" in
    self-reflect)
      self_reflect
      ;;
    help|--help|-h)
      echo -e "${CYAN}BAZINGA Universal Script${NC}"
      echo -e "Usage: $0 [command] [options]"
      echo -e ""
      echo -e "Commands:"
      echo -e "  self-reflect     Run self-reflection"
      echo -e "  help             Show this help message"
      ;;
    *)
      echo -e "${RED}Unknown command: $command${NC}"
      echo -e "Use '${BOLD}$0 help${NC}' for usage information"
      ;;
  esac
}

# Run the main function with all arguments
main "$@"
