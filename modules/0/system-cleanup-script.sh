#!/bin/bash
# Complete System Cleanup Script
# Cleans and organizes the entire filesystem, not just Bazinga projects

# Define color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Complete System Cleanup Tool ===${NC}"
echo "This script will organize and clean your entire filesystem."

# Define key directories
HOME_DIR="$HOME"
DOWNLOADS_DIR="$HOME/Downloads"
DOCUMENTS_DIR="$HOME/Documents"
PROJECTS_DIR="$HOME/AmsyPycharm"

# Organize by project type
BAZINGA_DIR="$PROJECTS_DIR/BAZINGA"
AMRITA_A_DIR="$PROJECTS_DIR/amrita-a"
AMRITA_PIE_DIR="$PROJECTS_DIR/amrita-pie"
BAZINGA_INDEED_DIR="$PROJECTS_DIR/BAZINGA-INDEED"

# Create organized directories
echo -e "${BLUE}Creating organization directories...${NC}"
mkdir -p "$HOME/Organized/Code/Python"
mkdir -p "$HOME/Organized/Code/Scripts"
mkdir -p "$HOME/Organized/Documents"
mkdir -p "$HOME/Organized/Data/CSV"
mkdir -p "$HOME/Organized/Data/JSON"
mkdir -p "$HOME/Organized/Media"
mkdir -p "$HOME/Organized/Archives"
mkdir -p "$HOME/Organized/Projects"

# Create backup directory
mkdir -p "$HOME/Backups/$(date +%Y%m%d)"

# Function to safely clean temporary files
clean_temp_files() {
  local dir="$1"
  echo -e "${YELLOW}Cleaning temporary files in $dir...${NC}"
  
  # Find and report tmp files
  temp_files=$(find "$dir" -type f -name "*.tmp" -o -name "*.temp" -o -name "*.bak" -o -name "*.swp" 2>/dev/null)
  
  if [ -n "$temp_files" ]; then
    echo "Found the following temporary files:"
    echo "$temp_files"
    
    echo -n "Do you want to delete these files? (y/n): "
    read answer
    
    if [ "$answer" == "y" ]; then
      find "$dir" -type f -name "*.tmp" -o -name "*.temp" -o -name "*.bak" -o -name "*.swp" -delete 2>/dev/null
      echo -e "${GREEN}Temporary files deleted.${NC}"
    else
      echo "Files preserved."
    fi
  else
    echo "No temporary files found."
  fi
}

# Function to organize Downloads folder
organize_downloads() {
  echo -e "${BLUE}Organizing Downloads folder...${NC}"
  
  # Python files
  find "$DOWNLOADS_DIR" -maxdepth 1 -name "*.py" | while read file; do
    cp "$file" "$HOME/Organized/Code/Python/"
    echo "Copied $(basename "$file") to Organized/Code/Python/"
  done
  
  # Shell scripts
  find "$DOWNLOADS_DIR" -maxdepth 1 -name "*.sh" | while read file; do
    cp "$file" "$HOME/Organized/Code/Scripts/"
    echo "Copied $(basename "$file") to Organized/Code/Scripts/"
  done
  
  # Markdown files
  find "$DOWNLOADS_DIR" -maxdepth 1 -name "*.md" | while read file; do
    cp "$file" "$HOME/Organized/Documents/"
    echo "Copied $(basename "$file") to Organized/Documents/"
  done
  
  # CSV files
  find "$DOWNLOADS_DIR" -maxdepth 1 -name "*.csv" | while read file; do
    cp "$file" "$HOME/Organized/Data/CSV/"
    echo "Copied $(basename "$file") to Organized/Data/CSV/"
  done
  
  # JSON files
  find "$DOWNLOADS_DIR" -maxdepth 1 -name "*.json" | while read file; do
    cp "$file" "$HOME/Organized/Data/JSON/"
    echo "Copied $(basename "$file") to Organized/Data/JSON/"
  done
  
  # Archive files
  find "$DOWNLOADS_DIR" -maxdepth 1 -name "*.zip" -o -name "*.tar.gz" -o -name "*.tgz" -o -name "*.rar" | while read file; do
    cp "$file" "$HOME/Organized/Archives/"
    echo "Copied $(basename "$file") to Organized/Archives/"
  done
}

# Function to find and catalog all index.json files
catalog_index_files() {
  echo -e "${BLUE}Cataloging index.json files...${NC}"
  mkdir -p "$HOME/Organized/Data/Indices"
  
  echo "# Index.json Catalog - $(date)" > "$HOME/Organized/Data/Indices/catalog.txt"
  echo "===============================================" >> "$HOME/Organized/Data/Indices/catalog.txt"
  echo "" >> "$HOME/Organized/Data/Indices/catalog.txt"
  
  # Find all index.json files and log their location and size
  find "$HOME" -name "index.json" 2>/dev/null | while read file; do
    size=$(du -h "$file" | cut -f1)
    modified=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$file")
    echo "File: $file" >> "$HOME/Organized/Data/Indices/catalog.txt"
    echo "Size: $size" >> "$HOME/Organized/Data/Indices/catalog.txt"
    echo "Modified: $modified" >> "$HOME/Organized/Data/Indices/catalog.txt"
    echo "-------------------------------------------" >> "$HOME/Organized/Data/Indices/catalog.txt"
  done
  
  echo -e "${GREEN}Catalog created at $HOME/Organized/Data/Indices/catalog.txt${NC}"
}

# Function to fix clipboard if needed
fix_clipboard() {
  echo -e "${BLUE}Checking clipboard functionality...${NC}"
  
  # Try to copy and paste a test string
  echo "Clipboard test" | pbcopy
  test_result=$(pbpaste)
  
  if [ "$test_result" == "Clipboard test" ]; then
    echo -e "${GREEN}Clipboard is working correctly.${NC}"
    return 0
  fi
  
  echo -e "${YELLOW}Clipboard has issues, attempting to fix...${NC}"
  
  # Kill the pasteboard server to reset clipboard
  killall pboard 2>/dev/null
  
  # Check for and unload Claude launch agents
  if launchctl list | grep -q "anthropic"; then
    echo -e "${YELLOW}Found Claude-related launch agents, unloading...${NC}"
    launchctl list | grep "anthropic" | awk '{print $3}' | xargs -I{} launchctl unload -w ~/Library/LaunchAgents/{}.plist 2>/dev/null
  fi
  
  # Try clipboard again
  echo "Clipboard test 2" | pbcopy
  test_result=$(pbpaste)
  
  if [ "$test_result" == "Clipboard test 2" ]; then
    echo -e "${GREEN}Clipboard fixed successfully.${NC}"
    return 0
  else
    echo -e "${RED}Clipboard issues persist. You may need to restart your Mac.${NC}"
    return 1
  fi
}

# Function to clean project directories
clean_project() {
  local project_dir="$1"
  local project_name="$2"
  
  if [ ! -d "$project_dir" ]; then
    echo -e "${YELLOW}Project directory $project_dir not found, skipping...${NC}"
    return 1
  fi
  
  echo -e "${BLUE}Cleaning $project_name project...${NC}"
  
  # Create standard directories if they don't exist
  mkdir -p "$project_dir/src"
  mkdir -p "$project_dir/docs"
  mkdir -p "$project_dir/data"
  mkdir -p "$project_dir/scripts"
  
  # Clean temporary files
  clean_temp_files "$project_dir"
  
  # Organize src files
  find "$project_dir" -name "*.py" -o -name "*.ts" -o -name "*.js" | grep -v "node_modules" | while read file; do
    if [ ! -d "$(dirname "$file")" ]; then
      mkdir -p "$project_dir/src/misc"
      cp "$file" "$project_dir/src/misc/"
      echo "Moved $(basename "$file") to src/misc/"
    fi
  done
  
  # Organize documentation
  find "$project_dir" -name "*.md" -o -name "*.txt" | grep -v "node_modules" | while read file; do
    if [ "$(dirname "$file")" != "$project_dir/docs" ]; then
      cp "$file" "$project_dir/docs/"
      echo "Copied $(basename "$file") to docs/"
    fi
  done
  
  echo -e "${GREEN}$project_name project cleaned and organized.${NC}"
}

# Main menu
show_menu() {
  echo ""
  echo -e "${GREEN}System Cleanup Menu${NC}"
  echo "1. Fix clipboard issues"
  echo "2. Organize Downloads folder"
  echo "3. Clean temporary files"
  echo "4. Catalog index.json files"
  echo "5. Clean Bazinga projects"
  echo "6. Clean all projects"
  echo "7. Run full system cleanup"
  echo "8. Exit"
  echo ""
  echo -n "Select an option [1-8]: "
}

# Process menu choice
process_choice() {
  local choice="$1"
  
  case $choice in
    1)
      fix_clipboard
      ;;
    2)
      organize_downloads
      echo -e "${GREEN}Downloads folder organized. Original files preserved.${NC}"
      ;;
    3)
      echo -n "Enter directory to clean (or press Enter for home directory): "
      read dir_to_clean
      if [ -z "$dir_to_clean" ]; then
        clean_temp_files "$HOME"
      else
        clean_temp_files "$dir_to_clean"
      fi
      ;;
    4)
      catalog_index_files
      ;;
    5)
      clean_project "$BAZINGA_DIR" "BAZINGA"
      clean_project "$BAZINGA_INDEED_DIR" "BAZINGA-INDEED"
      ;;
    6)
      clean_project "$BAZINGA_DIR" "BAZINGA"
      clean_project "$AMRITA_A_DIR" "amrita-a"
      clean_project "$AMRITA_PIE_DIR" "amrita-pie"
      clean_project "$BAZINGA_INDEED_DIR" "BAZINGA-INDEED"
      ;;
    7)
      echo -e "${BLUE}Running full system cleanup...${NC}"
      fix_clipboard
      organize_downloads
      clean_temp_files "$HOME"
      catalog_index_files
      clean_project "$BAZINGA_DIR" "BAZINGA"
      clean_project "$AMRITA_A_DIR" "amrita-a"
      clean_project "$AMRITA_PIE_DIR" "amrita-pie"
      clean_project "$BAZINGA_INDEED_DIR" "BAZINGA-INDEED"
      echo -e "${GREEN}Full system cleanup complete!${NC}"
      ;;
    8)
      echo "Exiting System Cleanup Tool"
      exit 0
      ;;
    *)
      echo -e "${RED}Invalid option. Please try again.${NC}"
      ;;
  esac
}

# Main loop
if [ "$1" == "--full" ]; then
  # Run full cleanup if --full argument is provided
  process_choice 7
else
  # Interactive mode
  while true; do
    show_menu
    read choice
    process_choice "$choice"
    echo ""
    echo -n "Press Enter to continue..."
    read
    clear
  done
fi
