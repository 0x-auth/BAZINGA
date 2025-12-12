#!/bin/bash
# Bazinga Integration Script
# Safely integrates Claude artifacts with Bazinga without clipboard issues

# Define color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Bazinga Integration Script ===${NC}"
echo "This script safely integrates Claude artifacts with Bazinga"

# Configuration
BASE_DIR=$(dirname "$0")
ARTIFACTS_DIR="$BASE_DIR/artifacts"
ANALYSIS_DIR="$BASE_DIR/analysis"
COLLECTOR_SCRIPT="$BASE_DIR/safe_claude_collector.py"
ANALYZER_SCRIPT="$BASE_DIR/bazinga_claude_analyzer.py"

# Create necessary directories
mkdir -p "$ARTIFACTS_DIR"
mkdir -p "$ANALYSIS_DIR"

# Check if required scripts exist
if [ ! -f "$COLLECTOR_SCRIPT" ]; then
  echo -e "${RED}Error: Collector script not found at $COLLECTOR_SCRIPT${NC}"
  exit 1
fi

if [ ! -f "$ANALYZER_SCRIPT" ]; then
  echo -e "${RED}Error: Analyzer script not found at $ANALYZER_SCRIPT${NC}"
  exit 1
fi

# Function to collect artifacts
collect_artifacts() {
  local url="$1"
  local file="$2"
  
  echo -e "${YELLOW}Collecting artifacts...${NC}"
  
  if [ -n "$url" ]; then
    # Process single URL
    python3 "$COLLECTOR_SCRIPT" --dir "$ARTIFACTS_DIR" --url "$url"
  elif [ -n "$file" ] && [ -f "$file" ]; then
    # Process file with URLs
    python3 "$COLLECTOR_SCRIPT" --dir "$ARTIFACTS_DIR" --file "$file"
  else
    echo -e "${YELLOW}No URL or file specified, skipping collection${NC}"
  fi
}

# Function to analyze artifacts
analyze_artifacts() {
  echo -e "${YELLOW}Analyzing artifacts...${NC}"
  python3 "$ANALYZER_SCRIPT" --artifacts-dir "$ARTIFACTS_DIR/claude_artifacts" --output-dir "$ANALYSIS_DIR"
}

# Main menu
show_menu() {
  echo ""
  echo -e "${GREEN}Bazinga Integration Menu${NC}"
  echo "1. Collect artifact from URL"
  echo "2. Collect artifacts from file"
  echo "3. Analyze collected artifacts"
  echo "4. Run full pipeline (collect & analyze)"
  echo "5. View analysis report"
  echo "6. Exit"
  echo ""
  echo -n "Select an option [1-6]: "
}

# Process menu choice
process_choice() {
  local choice="$1"
  
  case $choice in
    1)
      echo -n "Enter Claude artifact URL: "
      read url
      collect_artifacts "$url" ""
      ;;
    2)
      echo -n "Enter file path containing URLs: "
      read file_path
      if [ -f "$file_path" ]; then
        collect_artifacts "" "$file_path"
      else
        echo -e "${RED}Error: File not found at $file_path${NC}"
      fi
      ;;
    3)
      analyze_artifacts
      ;;
    4)
      echo -n "Enter Claude artifact URL (leave empty to skip): "
      read url
      if [ -n "$url" ]; then
        collect_artifacts "$url" ""
      fi
      analyze_artifacts
      ;;
    5)
      report_file="$ANALYSIS_DIR/bazinga_summary.txt"
      if [ -f "$report_file" ]; then
        echo -e "${GREEN}Analysis Report:${NC}"
        cat "$report_file"
      else
        echo -e "${RED}No analysis report found. Run analysis first.${NC}"
      fi
      ;;
    6)
      echo "Exiting Bazinga Integration"
      exit 0
      ;;
    *)
      echo -e "${RED}Invalid option. Please try again.${NC}"
      ;;
  esac
}

# Main loop
while true; do
  show_menu
  read choice
  process_choice "$choice"
  echo ""
  echo -n "Press Enter to continue..."
  read
  clear
done
