#!/bin/bash

# System Cleanup Script
# Created: 2025-03-17
# Description: Organizes files, creates backups, and sets up working environment

# Log setup
LOG_FILE="$HOME/cleanup_$(date +%Y%m%d_%H%M%S).log"
TODAY=$(date +%Y-%m-%d)

# Logging function
log_message() {
  echo "[$TODAY $(date +%H:%M:%S)] $1" | tee -a "$LOG_FILE"
}

log_message "Starting system cleanup"

# Create necessary directories
log_message "Creating directory structure"
mkdir -p "$HOME/claude_central/config"
mkdir -p "$HOME/claude_central/logs"
mkdir -p "$HOME/claude_central/master_index"
mkdir -p "$HOME/claude_data/artifacts"
mkdir -p "$HOME/claude_data/analysis"
mkdir -p "$HOME/claude_data/patterns"
mkdir -p "$HOME/claude_data/health"
mkdir -p "$HOME/claude_data/relationship"
mkdir -p "$HOME/claude_data/backups/$(date +%Y-%m-%d)"

# Create today's working directory
TODAY_DIR="$HOME/today_work_$(date +%Y%m%d)"
mkdir -p "$TODAY_DIR/input"
mkdir -p "$TODAY_DIR/output"
mkdir -p "$TODAY_DIR/notes"

# Move Claude analysis directories to claude_data
log_message "Organizing Claude analysis directories"
find "$HOME" -maxdepth 1 -type d -name "claude_analysis_*" -exec mv {} "$HOME/claude_data/analysis/" \;

# Move BAZINGA files from Downloads to BAZINGA directory
log_message "Moving BAZINGA files from Downloads"
find "$HOME/Downloads" -maxdepth 1 -type f -name "*bazinga*" -exec mv {} "$HOME/AmsyPycharm/BAZINGA/" \;

# Move claude files from Downloads to claude_data
log_message "Moving Claude files from Downloads"
find "$HOME/Downloads" -maxdepth 1 -type f -name "*claude*" -exec mv {} "$HOME/claude_data/artifacts/" \;

# Clean up .DS_Store files
log_message "Removing .DS_Store files"
find "$HOME/AmsyPycharm" -name ".DS_Store" -delete
find "$HOME/claude_data" -name ".DS_Store" -delete
find "$HOME/claude_central" -name ".DS_Store" -delete

# Back up important config files
log_message "Backing up important configuration files"
BACKUP_DIR="$HOME/claude_data/backups/$(date +%Y-%m-%d)"
mkdir -p "$BACKUP_DIR"

# Backup BAZINGA state
if [ -d "$HOME/AmsyPycharm/BAZINGA-INDEED/.bazinga_state" ]; then
  cp -r "$HOME/AmsyPycharm/BAZINGA-INDEED/.bazinga_state" "$BACKUP_DIR/"
  log_message "Backed up BAZINGA state"
fi

# Backup template configs
for template in "$HOME/AmsyPycharm/BAZINGA-INDEED/"*/config/templates/*.json; do
  if [ -f "$template" ]; then
    cp "$template" "$BACKUP_DIR/"
    log_message "Backed up template: $(basename "$template")"
  fi
done

# Create master index
log_message "Creating master file index"
{
  echo "# Master File Index - $(date +%Y-%m-%d)"
  echo "## BAZINGA Files"
  find "$HOME/AmsyPycharm/BAZINGA" -type f -name "*.sh" -o -name "*.py" -o -name "*.json" | sort
  
  echo -e "\n## BAZINGA-INDEED Files"
  find "$HOME/AmsyPycharm/BAZINGA-INDEED" -type f -name "*.json" -o -name "*.md" -o -name "*.ts" | sort
  
  echo -e "\n## Claude Data Files"
  find "$HOME/claude_data" -type f | sort
} > "$HOME/claude_central/master_index/file_index_$(date +%Y%m%d).md"

# Create quick command script for today
log_message "Creating quick command script"
cat > "$TODAY_DIR/quick_commands.sh" << 'EOF'
#!/bin/bash

# Quick commands for today's tasks

# Run bazinga analysis
~/AmsyPycharm/BAZINGA/bazinga-completion-script.sh analyze input.json

# Extract claude artifacts
~/claude_data/artifacts/claude-artifact-extractor.sh

# Run relationship analysis
~/history_debugger.sh input.json > ./output/relationship_analysis.txt

# Back up today's work
backup_work() {
  BACKUP_DIR="$HOME/claude_data/backups/$(date +%Y-%m-%d)/today_work"
  mkdir -p "$BACKUP_DIR"
  cp -r ./* "$BACKUP_DIR/"
  echo "Work backed up to $BACKUP_DIR"
}

# Create a new pattern analysis
create_pattern_analysis() {
  mkdir -p ./patterns
  cat > ./patterns/new_pattern.json << 'EOJSON'
{
  "pattern_name": "New Analysis Pattern",
  "description": "Description of the pattern",
  "key_indicators": [],
  "timeline_points": [],
  "relationships": []
}
EOJSON
  echo "New pattern template created at ./patterns/new_pattern.json"
}

# Show help
if [[ "$1" == "help" || -z "$1" ]]; then
  echo "Available commands:"
  echo "  analyze    - Run bazinga analysis"
  echo "  extract    - Extract claude artifacts"
  echo "  debug      - Run relationship analysis"
  echo "  backup     - Back up today's work"
  echo "  pattern    - Create a new pattern analysis"
fi

# Command router
case "$1" in
  analyze) ~/AmsyPycharm/BAZINGA/bazinga-completion-script.sh analyze "${2:-input.json}" ;;
  extract) ~/claude_data/artifacts/claude-artifact-extractor.sh "${2:-latest}" ;;
  debug) ~/history_debugger.sh "${2:-input.json}" > "./output/relationship_analysis_$(date +%H%M%S).txt" ;;
  backup) backup_work ;;
  pattern) create_pattern_analysis ;;
esac
EOF
chmod +x "$TODAY_DIR/quick_commands.sh"

# Analyze system activity
log_message "Analyzing recent system activity"

# Create system analysis report
ANALYSIS_REPORT="$TODAY_DIR/system_analysis.md"

{
  echo "# System Analysis Report - $(date +%Y-%m-%d)"
  echo ""
  echo "## Recent File Activity"
  echo ""
  echo "### Modified in the last 24 hours"
  find "$HOME/AmsyPycharm" -type f -mtime -1 | sort | head -20
  
  echo ""
  echo "## BAZINGA State"
  echo ""
  if [ -f "$HOME/AmsyPycharm/BAZINGA-INDEED/.bazinga_state/last_state.json" ]; then
    cat "$HOME/AmsyPycharm/BAZINGA-INDEED/.bazinga_state/last_state.json"
  else
    echo "No state file found"
  fi
  
  echo ""
  echo "## Recent Claude Analysis"
  echo ""
  ls -ltr "$HOME/claude_data/analysis" | tail -10
  
  echo ""
  echo "## Task Summary"
  echo ""
  echo "1. Recent activity shows focus on:"
  echo "   - BAZINGA template configuration"
  echo "   - Claude artifact processing"
  echo "   - System integration"
  echo ""
  echo "2. Next steps should include:"
  echo "   - Complete template integration"
  echo "   - Run analysis on latest data"
  echo "   - Update master files"
} > "$ANALYSIS_REPORT"

log_message "System analysis report created at $ANALYSIS_REPORT"

# Set up symbolic links for common tools
log_message "Setting up shortcuts for common tools"
ln -sf "$HOME/AmsyPycharm/BAZINGA/bazinga-completion-script.sh" "$TODAY_DIR/bazinga.sh"
ln -sf "$HOME/history_debugger.sh" "$TODAY_DIR/debugger.sh"
ln -sf "$HOME/claude_data/artifacts/claude-artifact-extractor.sh" "$TODAY_DIR/extract.sh"

# Final message
log_message "Cleanup complete"
log_message "Working environment created at: $TODAY_DIR"

echo ""
echo "===== CLEANUP COMPLETE ====="
echo "Working environment: $TODAY_DIR"
echo "System analysis: $ANALYSIS_REPORT"
echo "Quick commands: $TODAY_DIR/quick_commands.sh"
echo "Log file: $LOG_FILE"