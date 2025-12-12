#!/bin/bash
# tools-project-cleanup.sh
# A comprehensive cleanup script for the tools project
# Usage: ./tools-project-cleanup.sh [--deep] [--report-only] [target_directory]

set -e

# Default settings
DEEP_CLEAN=false
REPORT_ONLY=false
TARGET_DIR="."

# Process command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --deep)
      DEEP_CLEAN=true
      shift
      ;;
    --report-only)
      REPORT_ONLY=true
      shift
      ;;
    --help)
      echo "Usage: tools-project-cleanup.sh [options] [directory]"
      echo "Options:"
      echo "  --deep         Perform deeper cleaning (go clean, etc)"
      echo "  --report-only  Only report issues without fixing them"
      echo "  --help         Display this help message"
      exit 0
      ;;
    *)
      if [[ -d "$1" ]]; then
        TARGET_DIR="$1"
        shift
      else
        echo "Error: Unknown option or invalid directory: $1"
        exit 1
      fi
      ;;
  esac
done

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Excluded directories
EXCLUDE_DIRS=(
  "node_modules"
  ".git"
  "dist"
  "build"
  "__pycache__"
  "vendor"
  "coverage"
  "tmp"
  "temp"
  "logs"
)

# Function to build grep exclusion pattern
build_grep_exclusion() {
  local pattern=""
  for dir in "${EXCLUDE_DIRS[@]}"; do
    pattern="$pattern -not -path \"*/$dir/*\""
  done
  echo "$pattern"
}

# Function to print section header
print_header() {
  echo
  echo -e "${GREEN}==================================================${NC}"
  echo -e "${GREEN}$1${NC}"
  echo -e "${GREEN}==================================================${NC}"
}

# Start cleanup process
echo "Starting cleanup for ${TARGET_DIR}"
echo "Mode: $(if $REPORT_ONLY; then echo "Report Only"; else echo "Fix Issues"; fi)"
echo "Deep clean: $(if $DEEP_CLEAN; then echo "Yes"; else echo "No"; fi)"
echo

# Move to target directory
cd "$TARGET_DIR"

# 1. Check for inconsistent line endings
print_header "Checking line endings"
mixed_endings=$(find . -type f -name "*.go" -o -name "*.sh" -o -name "*.js" -o -name "*.ts" | xargs grep -l $'\r' 2>/dev/null || echo "")
if [ -n "$mixed_endings" ]; then
  echo -e "${YELLOW}Files with CRLF line endings:${NC}"
  echo "$mixed_endings" | head -10
  if [ "$(echo "$mixed_endings" | wc -l)" -gt 10 ]; then
    echo "... and $(echo "$mixed_endings" | wc -l | tr -d ' ') more"
  fi
  
  if ! $REPORT_ONLY; then
    echo "Fixing line endings..."
    echo "$mixed_endings" | xargs dos2unix 2>/dev/null || echo "⚠️  Could not fix line endings. Please install dos2unix."
  fi
else
  echo "✓ No mixed line endings found"
fi

# 2. Check for files without executable permissions
print_header "Checking script permissions"
nonexec_scripts=$(find . -name "*.sh" ! -perm -u+x)
if [ -n "$nonexec_scripts" ]; then
  echo -e "${YELLOW}Scripts without executable permissions:${NC}"
  echo "$nonexec_scripts"
  
  if ! $REPORT_ONLY; then
    echo "Fixing script permissions..."
    find . -name "*.sh" ! -perm -u+x -exec chmod +x {} \;
    echo "✓ Fixed script permissions"
  fi
else
  echo "✓ All scripts have correct permissions"
fi

# 3. Check for temporary files
print_header "Checking for temporary files"
temp_files=$(find . -name "*.tmp" -o -name "*.bak" -o -name "*.swp" -o -name "*.swo" -o -name "*~")
if [ -n "$temp_files" ]; then
  echo -e "${YELLOW}Temporary files found:${NC}"
  echo "$temp_files"
  
  if ! $REPORT_ONLY; then
    echo "Removing temporary files..."
    find . -name "*.tmp" -o -name "*.bak" -o -name "*.swp" -o -name "*.swo" -o -name "*~" -delete
    echo "✓ Removed temporary files"
  fi
else
  echo "✓ No temporary files found"
fi

# 4. Check for empty directories
print_header "Checking for empty directories"
empty_dirs=$(find . -type d -empty -not -path "*/\.*")
if [ -n "$empty_dirs" ]; then
  echo -e "${YELLOW}Empty directories found:${NC}"
  echo "$empty_dirs"
  
  if ! $REPORT_ONLY; then
    echo "Removing empty directories..."
    find . -type d -empty -not -path "*/\.*" -delete
    echo "✓ Removed empty directories"
  fi
else
  echo "✓ No empty directories found"
fi

# 5. Check for large files
print_header "Checking for large files (>10MB)"
large_files=$(find . -type f -size +10M -not -path "*/\.*")
if [ -n "$large_files" ]; then
  echo -e "${YELLOW}Large files found:${NC}"
  echo "$large_files"
else
  echo "✓ No large files found"
fi

# 6. Check for TODOs and FIXMEs
print_header "Checking for TODOs/FIXMEs"
todos=$(grep -r "TODO\|FIXME" --include="*.go" --include="*.js" --include="*.ts" --include="*.md" . 2>/dev/null || echo "")
if [ -n "$todos" ]; then
  echo -e "${YELLOW}TODOs and FIXMEs:${NC}"
  echo "$todos" | wc -l | tr -d ' '
  echo "Sample TODOs:"
  echo "$todos" | head -5
  if [ "$(echo "$todos" | wc -l)" -gt 5 ]; then
    echo "... and more"
  fi
else
  echo "✓ No TODOs or FIXMEs found"
fi

# 7. Deep clean if requested
if $DEEP_CLEAN; then
  print_header "Performing deep clean"
  
  # Check for Go installation
  if command -v go >/dev/null 2>&1; then
    echo "Cleaning Go cache..."
    if ! $REPORT_ONLY; then
      go clean -cache -modcache -i -r 2>/dev/null || echo "⚠️  Some Go clean operations failed"
    else
      echo "Would clean Go cache (report only mode)"
    fi
  else
    echo "⚠️  Go not installed, skipping Go cache cleaning"
  fi
  
  # Check for npm installation
  if command -v npm >/dev/null 2>&1; then
    echo "Cleaning npm cache..."
    if ! $REPORT_ONLY; then
      npm cache clean --force 2>/dev/null || echo "⚠️  npm cache clean failed"
    else
      echo "Would clean npm cache (report only mode)"
    fi
  else
    echo "⚠️  npm not installed, skipping npm cache cleaning"
  fi
fi

# 8. Run project analyzer if available
print_header "Project analysis"
if command -v project-analyzer.sh >/dev/null 2>&1; then
  echo "Running project analyzer..."
  project-analyzer.sh --depth 2
else
  echo "⚠️  project-analyzer.sh not found in PATH"
  echo "Run 'treeclean' and 'llclean' commands to see clean project structure"
fi

# Summary
print_header "Cleanup Summary"
echo "✓ Cleanup process completed"
if $REPORT_ONLY; then
  echo "📊 Report-only mode: No changes were made"
  echo "Run without --report-only to fix issues"
else
  echo "🧹 Issues have been fixed where possible"
fi

echo
echo "Additional recommended commands:"
echo "- treeclean     : Show clean tree view"
echo "- llclean       : Show detailed file listing"
echo "- treecountclean: Count actual source files"
echo
