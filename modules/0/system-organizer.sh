#!/bin/bash

# Mac System Organizer and Claude Integration
# This script provides a comprehensive solution for organizing your Mac system
# with special focus on Claude-related tools and integrations

# Set up colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Create a timestamp for logging
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_DIR="$HOME/system_organization_$TIMESTAMP"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/organization.log"

# Logging function
log() {
  echo -e "${BLUE}[$(date +"%Y-%m-%d %H:%M:%S")]${NC} $1" | tee -a "$LOG_FILE"
}

# Section divider
section() {
  echo -e "\n${GREEN}=== $1 ===${NC}" | tee -a "$LOG_FILE"
}

# Error handling
error() {
  echo -e "${RED}ERROR: $1${NC}" | tee -a "$LOG_FILE"
}

# Display help
show_help() {
  echo -e "${YELLOW}Mac System Organizer and Claude Integration${NC}"
  echo -e "A comprehensive tool for organizing your Mac system with Claude integration"
  echo
  echo -e "Usage: $0 [command]"
  echo
  echo -e "Commands:"
  echo -e "  ${GREEN}analyze${NC}      - Analyze system and suggest improvements"
  echo -e "  ${GREEN}organize${NC}     - Organize system based on analysis"
  echo -e "  ${GREEN}cleanup${NC}      - Clean up temporary and duplicate files"
  echo -e "  ${GREEN}claude${NC}       - Organize and fix Claude-related components"
  echo -e "  ${GREEN}fix-dock${NC}     - Fix dock issues and restore missing apps"
  echo -e "  ${GREEN}fix-clipboard${NC} - Fix clipboard issues"
  echo -e "  ${GREEN}fix-terminal${NC} - Fix terminal cmd+~ switching issue"
  echo -e "  ${GREEN}help${NC}         - Show this help message"
}

# Create a central Claude organization
organize_claude() {
  section "ORGANIZING CLAUDE COMPONENTS"
  
  # Create main directories if they don't exist
  log "Creating main Claude directories"
  mkdir -p "$HOME/claude_main/accounts"
  mkdir -p "$HOME/claude_main/artifacts"
  mkdir -p "$HOME/claude_main/scripts"
  mkdir -p "$HOME/claude_main/backup"
  mkdir -p "$HOME/claude_main/logs"

  # Find all Claude-related scripts and organize them
  log "Finding and organizing Claude scripts"
  find "$HOME" -type f -name "*claude*.sh" -not -path "*/.*/*" -not -path "*/GolandProjects/*" -not -path "*/AmsyPycharm/*" 2>/dev/null | while read -r script; do
    if [[ -f "$script" ]]; then
      script_name=$(basename "$script")
      if [[ ! -f "$HOME/claude_main/scripts/$script_name" ]]; then
        log "Moving $script_name to claude_main/scripts"
        cp "$script" "$HOME/claude_main/scripts/"
        chmod +x "$HOME/claude_main/scripts/$script_name"
      fi
    fi
  done

  # Create a unified Claude control script
  log "Creating unified Claude control script"
  cat > "$HOME/claude_main/claude-control.sh" << 'EOF'
#!/bin/bash

# Unified Claude Control System
CLAUDE_HOME="$HOME/claude_main"
CLAUDE_TIMESTAMP=$(date +%Y%m%d_%H%M%S)
CLAUDE_LOG="$CLAUDE_HOME/logs/claude_$CLAUDE_TIMESTAMP.log"

# Ensure log directory exists
mkdir -p "$CLAUDE_HOME/logs"

# Logging function
log() {
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] $1" | tee -a "$CLAUDE_LOG"
}

# Show help
if [[ "$1" == "help" || "$#" -eq 0 ]]; then
  echo "=== CLAUDE UNIFIED CONTROL SYSTEM ==="
  echo "Usage: $0 [command] [options]"
  echo ""
  echo "Commands:"
  echo "  setup       - Set up Claude integration environment"
  echo "  extract     - Extract artifacts from Claude conversations"
  echo "  organize    - Organize Claude files and scripts"
  echo "  analyze     - Analyze Claude data and outputs"
  echo "  fix         - Fix common Claude integration issues"
  echo "  help        - Show this help message"
  exit 0
fi

# Setup command
if [[ "$1" == "setup" ]]; then
  log "Setting up Claude integration environment"
  mkdir -p "$CLAUDE_HOME/accounts"
  mkdir -p "$CLAUDE_HOME/artifacts/extracted"
  mkdir -p "$CLAUDE_HOME/scripts"
  mkdir -p "$CLAUDE_HOME/backup"
  
  # Create aliases for bash
  if [[ ! $(grep "claude-control" "$HOME/.bashrc") ]]; then
    echo "" >> "$HOME/.bashrc"
    echo "# Claude control aliases" >> "$HOME/.bashrc"
    echo "alias claude='$CLAUDE_HOME/claude-control.sh'" >> "$HOME/.bashrc"
    echo "alias claude-extract='$CLAUDE_HOME/claude-control.sh extract'" >> "$HOME/.bashrc"
    echo "alias claude-analyze='$CLAUDE_HOME/claude-control.sh analyze'" >> "$HOME/.bashrc"
    echo "alias claude-fix='$CLAUDE_HOME/claude-control.sh fix'" >> "$HOME/.bashrc"
    log "Added Claude aliases to .bashrc"
  fi
  
  log "Claude integration environment set up successfully"
  exit 0
fi

# Extract command
if [[ "$1" == "extract" ]]; then
  log "Extracting artifacts from Claude conversations"
  mkdir -p "$CLAUDE_HOME/artifacts/extracted/claude_$CLAUDE_TIMESTAMP"
  
  if [[ -f "$CLAUDE_HOME/scripts/extract-claude-artifacts.sh" ]]; then
    "$CLAUDE_HOME/scripts/extract-claude-artifacts.sh" "$CLAUDE_HOME/artifacts/extracted/claude_$CLAUDE_TIMESTAMP"
    log "Extraction complete"
  else
    log "Extraction script not found. Setting up a basic one."
    cat > "$CLAUDE_HOME/scripts/extract-claude-artifacts.sh" << 'INNEREOF'
#!/bin/bash
# Basic Claude artifact extraction script
OUTPUT_DIR="${1:-$HOME/claude_main/artifacts/extracted/claude_$(date +%Y%m%d_%H%M%S)}"
mkdir -p "$OUTPUT_DIR"

echo "Extracting Claude artifacts to $OUTPUT_DIR"
# Add extraction logic here based on your specific needs

# Find clipboard data that might contain artifacts
pbpaste > "$OUTPUT_DIR/clipboard_content.txt"
echo "Saved clipboard content to $OUTPUT_DIR/clipboard_content.txt"

# Process HTML exports if they exist
POSSIBLE_DIRS=("$HOME/Downloads" "$HOME/Documents")
for dir in "${POSSIBLE_DIRS[@]}"; do
  find "$dir" -name "*Claude*.html" -mtime -2 -exec cp {} "$OUTPUT_DIR/" \; 2>/dev/null
done

echo "Extraction complete. Results in $OUTPUT_DIR"
INNEREOF
    chmod +x "$CLAUDE_HOME/scripts/extract-claude-artifacts.sh"
    "$CLAUDE_HOME/scripts/extract-claude-artifacts.sh" "$CLAUDE_HOME/artifacts/extracted/claude_$CLAUDE_TIMESTAMP"
  fi
  exit 0
fi

# Organize command
if [[ "$1" == "organize" ]]; then
  log "Organizing Claude files and scripts"
  
  # Find and organize Claude scripts from across the system
  find "$HOME" -type f -name "*claude*.sh" -not -path "*/.*/*" -not -path "$CLAUDE_HOME/*" 2>/dev/null | while read -r script; do
    if [[ -f "$script" ]]; then
      script_name=$(basename "$script")
      if [[ ! -f "$CLAUDE_HOME/scripts/$script_name" ]]; then
        cp "$script" "$CLAUDE_HOME/scripts/"
        chmod +x "$CLAUDE_HOME/scripts/$script_name"
        log "Added script: $script_name"
      fi
    fi
  done
  
  # Organize Claude data
  find "$HOME" -type f -name "*claude*.json" -not -path "*/.*/*" -not -path "$CLAUDE_HOME/*" 2>/dev/null | while read -r data_file; do
    if [[ -f "$data_file" ]]; then
      file_name=$(basename "$data_file")
      if [[ ! -f "$CLAUDE_HOME/data/$file_name" ]]; then
        mkdir -p "$CLAUDE_HOME/data"
        cp "$data_file" "$CLAUDE_HOME/data/"
        log "Added data file: $file_name"
      fi
    fi
  done
  
  log "Claude organization complete"
  exit 0
fi

# Analyze command
if [[ "$1" == "analyze" ]]; then
  log "Analyzing Claude data and outputs"
  
  # Create basic analysis if no specialized script exists
  if [[ ! -f "$CLAUDE_HOME/scripts/claude-analyzer.sh" ]]; then
    cat > "$CLAUDE_HOME/scripts/claude-analyzer.sh" << 'INNEREOF'
#!/bin/bash
# Basic Claude data analyzer
OUTPUT_FILE="$HOME/claude_main/analysis_$(date +%Y%m%d_%H%M%S).txt"

echo "=== CLAUDE SYSTEM ANALYSIS ===" > "$OUTPUT_FILE"
echo "Analysis date: $(date)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Find Claude-related files
echo "=== CLAUDE FILES SUMMARY ===" >> "$OUTPUT_FILE"
find "$HOME" -name "*claude*" -type f -not -path "*/\.*" 2>/dev/null | wc -l >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Check configuration
echo "=== CLAUDE CONFIGURATION ===" >> "$OUTPUT_FILE"
if [[ -f "$HOME/claude_main/config.json" ]]; then
  cat "$HOME/claude_main/config.json" >> "$OUTPUT_FILE"
else
  echo "No configuration file found" >> "$OUTPUT_FILE"
fi

echo "Analysis complete. Results saved to $OUTPUT_FILE"
INNEREOF
    chmod +x "$CLAUDE_HOME/scripts/claude-analyzer.sh"
  fi
  
  "$CLAUDE_HOME/scripts/claude-analyzer.sh"
  log "Analysis complete"
  exit 0
fi

# Fix command
if [[ "$1" == "fix" ]]; then
  log "Fixing common Claude integration issues"
  
  # Fix clipboard issues
  if [[ "$2" == "clipboard" || "$2" == "" ]]; then
    log "Fixing clipboard issues"
    killall pboard 2>/dev/null
    log "Restarted clipboard service"
  fi
  
  # Setup shell integration
  if [[ "$2" == "shell" || "$2" == "" ]]; then
    if [[ ! $(grep "claude-control" "$HOME/.bashrc") ]]; then
      echo "" >> "$HOME/.bashrc"
      echo "# Claude control aliases" >> "$HOME/.bashrc"
      echo "alias claude='$CLAUDE_HOME/claude-control.sh'" >> "$HOME/.bashrc"
      log "Added Claude aliases to .bashrc"
    fi
  fi
  
  log "Fix operations complete"
  exit 0
fi

# If we get here, command wasn't recognized
echo "Unknown command: $1"
echo "Use '$0 help' for usage information"
exit 1
EOF

  chmod +x "$HOME/claude_main/claude-control.sh"
  
  # Create or update main Claude configuration
  if [[ ! -f "$HOME/claude_main/config.json" ]]; then
    log "Creating Claude configuration file"
    cat > "$HOME/claude_main/config.json" << EOF
{
  "accounts": [
    {"name": "main", "email": "bits.abhi515@gmail.com"},
    {"name": "work", "email": "abhissrivasta@expedia.com"}
  ],
  "paths": {
    "artifacts": "$HOME/claude_main/artifacts",
    "scripts": "$HOME/claude_main/scripts",
    "data": "$HOME/claude_main/data",
    "logs": "$HOME/claude_main/logs",
    "backup": "$HOME/claude_main/backup"
  },
  "bazinga": {
    "enabled": true,
    "integration_path": "$HOME/AmsyPycharm/BAZINGA/artifacts/claude_artifacts"
  }
}
EOF
  fi

  # Create bin symlinks for easy access
  log "Creating bin symlinks for Claude tools"
  mkdir -p "$HOME/bin"
  ln -sf "$HOME/claude_main/claude-control.sh" "$HOME/bin/claude"
  
  # Add to .bashrc if not already there
  if ! grep -q "alias claude=" "$HOME/.bashrc"; then
    log "Adding Claude aliases to .bashrc"
    echo "" >> "$HOME/.bashrc"
    echo "# Claude control aliases" >> "$HOME/.bashrc"
    echo "alias claude='$HOME/claude_main/claude-control.sh'" >> "$HOME/.bashrc"
    echo "alias claude-extract='$HOME/claude_main/claude-control.sh extract'" >> "$HOME/.bashrc"
    echo "alias claude-analyze='$HOME/claude_main/claude-control.sh analyze'" >> "$HOME/.bashrc"
    echo "alias claude-fix='$HOME/claude_main/claude-control.sh fix'" >> "$HOME/.bashrc"
  fi
  
  # Organize artifacts
  log "Organizing Claude artifacts"
  for dir in "$HOME/claude_data" "$HOME/claude_central" "$HOME/claude_unified" "$HOME/claude_extraction"; do
    if [[ -d "$dir" ]]; then
      log "Backing up $dir to claude_main/backup"
      mkdir -p "$HOME/claude_main/backup/$(basename "$dir")_$TIMESTAMP"
      cp -r "$dir"/* "$HOME/claude_main/backup/$(basename "$dir")_$TIMESTAMP" 2>/dev/null
    fi
  done
  
  log "Claude organization complete!"
}

# Fix dock issues and restore Claude apps
fix_dock() {
  section "FIXING DOCK"
  
  log "Creating script to restore Claude apps"
  cat > "$HOME/fix_claude_dock.sh" << 'EOF'
#!/bin/bash

# Find all Claude apps in Applications folders
echo "Finding Claude applications..."
CLAUDE_APPS=$(find /Applications ~/Applications -name "*[cC]laude*.app" 2>/dev/null)

# Add each app to dock
for app in $CLAUDE_APPS; do
  app_name=$(basename "$app")
  echo "Adding $app_name to Dock..."
  defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
done

# Add Chrome web apps for Claude if they exist
CHROME_APPS=$(find ~/Applications -name "*[cC]laude*" 2>/dev/null | grep -v "\.app$" | grep "Chrome Apps")
for app in $CHROME_APPS; do
  app_name=$(basename "$app")
  echo "Adding Chrome web app $app_name to Dock..."
  defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
done

# Restart Dock to apply changes
killall Dock
echo "Done! Claude apps have been added to your Dock."
EOF

  chmod +x "$HOME/fix_claude_dock.sh"
  log "Running dock fix script"
  "$HOME/fix_claude_dock.sh"
  log "Dock fix complete"
}

# Fix clipboard issues
fix_clipboard() {
  section "FIXING CLIPBOARD"
  
  log "Creating clipboard fix script"
  
  mkdir -p "$HOME/claude_main/scripts"
  
  cat > "$HOME/claude_main/scripts/claude-clipboard-fix.sh" << 'EOF'
#!/bin/bash

# Claude Clipboard Fix Script
echo "=== Claude Clipboard Fix ==="
echo "Checking clipboard process..."

# Create log directory
LOG_DIR="$HOME/clipboard_fixes"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/clipboard_fix_$(date +%Y%m%d_%H%M%S).log"

# Log function
log() {
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] $1" | tee -a "$LOG_FILE"
}

log "Starting clipboard diagnostic"

# Check if clipboard process is running
if pgrep -x "pboard" > /dev/null; then
  log "Clipboard process (pboard) is running"
else
  log "WARNING: Clipboard process (pboard) is not running"
fi

# Check for clipboard-related errors in system logs
log "Checking system logs for clipboard errors"
CLIPBOARD_ERRORS=$(log show --predicate 'eventMessage contains "clipboard" OR eventMessage contains "pboard"' --last 1h 2>/dev/null | grep -i error)
if [[ -n "$CLIPBOARD_ERRORS" ]]; then
  log "Found clipboard errors in system logs:"
  echo "$CLIPBOARD_ERRORS" >> "$LOG_FILE"
else
  log "No clipboard errors found in recent system logs"
fi

# Kill the clipboard service (it will restart automatically)
log "Restarting clipboard service..."
killall pboard 2>/dev/null

# Wait for restart
sleep 1

# Check if process restarted properly
if pgrep -x "pboard" > /dev/null; then
  log "Clipboard process restarted successfully"
else
  log "WARNING: Clipboard process failed to restart automatically"
  log "Attempting to manually restart clipboard..."
  /System/Library/CoreServices/pboard >/dev/null 2>&1 &
  sleep 1
  
  if pgrep -x "pboard" > /dev/null; then
    log "Clipboard process manually restarted"
  else
    log "CRITICAL: Failed to restart clipboard process"
  fi
fi

# Test clipboard
log "Testing clipboard..."
echo "Claude Clipboard Test" | pbcopy
RESULT=$(pbpaste)

if [[ "$RESULT" == "Claude Clipboard Test" ]]; then
  log "Clipboard service is working properly!"
else
  log "Clipboard service might still have issues."
  
  # More aggressive fix - restart the UI server
  log "Attempting more aggressive fix..."
  killall Finder 2>/dev/null
  killall Dock 2>/dev/null
  
  # Wait for restart
  sleep 2
  
  # Test again
  log "Testing clipboard again..."
  echo "Claude Clipboard Fix Test 2" | pbcopy
  RESULT=$(pbpaste)
  
  if [[ "$RESULT" == "Claude Clipboard Fix Test 2" ]]; then
    log "Clipboard fixed successfully!"
  else
    log "Clipboard still has issues. You may need to restart your Mac."
    
    # Final attempt - check for problematic apps
    log "Checking for applications that might be interfering with clipboard"
    CLIPBOARD_APPS=(
      "ClipMenu"
      "Clipy"
      "CopyClip"
      "Clipboard Manager"
      "ClipboardCleaner"
      "1Password"
    )
    
    for app in "${CLIPBOARD_APPS[@]}"; do
      if pgrep -i "$app" > /dev/null; then
        log "Found potentially interfering app: $app"
        log "Consider quitting $app and trying again"
      fi
    done
    
    log "Creating clipboard monitoring script"
    cat > "$HOME/bin/monitor-clipboard.sh" << 'MONITOREOF'
#!/bin/bash
# Clipboard Monitoring Script

MONITOR_DIR="$HOME/clipboard_monitor"
mkdir -p "$MONITOR_DIR"
LOG_FILE="$MONITOR_DIR/clipboard_monitor_$(date +%Y%m%d_%H%M%S).log"

echo "=== Clipboard Monitoring Started at $(date) ===" | tee -a "$LOG_FILE"
echo "Press Ctrl+C to stop monitoring" | tee -a "$LOG_FILE"

# Monitor clipboard process
while true; do
  # Check if pboard is running
  if pgrep -x "pboard" > /dev/null; then
    STATUS="RUNNING"
  else
    STATUS="NOT RUNNING"
    # Try to restart
    /System/Library/CoreServices/pboard >/dev/null 2>&1 &
  fi
  
  # Log status
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] Clipboard process status: $STATUS" | tee -a "$LOG_FILE"
  
  # Test clipboard functionality
  TEST_STRING="Test_$(date +%s)"
  echo "$TEST_STRING" | pbcopy
  RESULT=$(pbpaste)
  
  if [[ "$RESULT" == "$TEST_STRING" ]]; then
    FUNC_STATUS="WORKING"
  else
    FUNC_STATUS="FAILED"
  fi
  
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] Clipboard functionality: $FUNC_STATUS" | tee -a "$LOG_FILE"
  
  # Wait before next check
  sleep 30
done
MONITOREOF
    chmod +x "$HOME/bin/monitor-clipboard.sh"
    log "Created clipboard monitoring script at $HOME/bin/monitor-clipboard.sh"
    log "Run this script to continuously monitor clipboard status"
  fi
fi

# Create clipboard utility script
log "Creating clipboard utility script"
cat > "$HOME/bin/clipboard-util.sh" << 'UTILEOF'
#!/bin/bash
# Clipboard Utility Script

ACTION=$1
CLIPBOARD_FILE="$HOME/.clipboard_history/clipboard_$(date +%Y%m%d_%H%M%S).txt"
mkdir -p "$HOME/.clipboard_history"

case "$ACTION" in
  save)
    # Save current clipboard content
    pbpaste > "$CLIPBOARD_FILE"
    echo "Clipboard content saved to $CLIPBOARD_FILE"
    ;;
  list)
    # List saved clipboard items
    echo "Recent clipboard history:"
    ls -t "$HOME/.clipboard_history" | head -10 | xargs -I{} sh -c 'echo "=== {} ==="; head -3 "$HOME/.clipboard_history/{}"'
    ;;
  restore)
    # Restore from file
    if [ -z "$2" ]; then
      echo "Please specify a clipboard file to restore"
      exit 1
    fi
    
    RESTORE_FILE=""
    if [ -f "$2" ]; then
      RESTORE_FILE="$2"
    elif [ -f "$HOME/.clipboard_history/$2" ]; then
      RESTORE_FILE="$HOME/.clipboard_history/$2"
    else
      echo "Clipboard file not found: $2"
      exit 1
    fi
    
    cat "$RESTORE_FILE" | pbcopy
    echo "Clipboard restored from $RESTORE_FILE"
    ;;
  fix)
    # Quick fix for clipboard
    killall pboard 2>/dev/null
    sleep 1
    echo "Clipboard process restarted"
    ;;
  help|*)
    echo "Clipboard Utility"
    echo "Usage: clipboard-util.sh [action]"
    echo ""
    echo "Actions:"
    echo "  save           - Save current clipboard content"
    echo "  list           - List recent saved clipboard items"
    echo "  restore FILE   - Restore clipboard from saved file"
    echo "  fix            - Quick fix for clipboard issues"
    echo "  help           - Show this help message"
    ;;
esac
UTILEOF
chmod +x "$HOME/bin/clipboard-util.sh"

# Create symlink in bin
if [ ! -L "$HOME/bin/cb" ]; then
  ln -s "$HOME/bin/clipboard-util.sh" "$HOME/bin/cb"
  log "Created clipboard utility shortcut 'cb'"
fi

log "Clipboard fix and utility scripts installed"
log "Use 'cb help' for clipboard utility options"

echo "Clipboard fix complete."
EOF

  chmod +x "$HOME/claude_main/scripts/claude-clipboard-fix.sh"
  
  # Create bin directory and symlinks
  mkdir -p "$HOME/bin"
  ln -sf "$HOME/claude_main/scripts/claude-clipboard-fix.sh" "$HOME/bin/fix-clipboard"
  
  log "Running clipboard fix script"
  "$HOME/claude_main/scripts/claude-clipboard-fix.sh"
  
  # Create clipboard monitoring startup script
  log "Creating clipboard monitoring startup script"
  
  mkdir -p "$HOME/claude_main/scripts"
  cat > "$HOME/claude_main/scripts/clipboard-monitor-startup.sh" << 'EOF'
#!/bin/bash

# Start clipboard monitoring in the background
"$HOME/bin/monitor-clipboard.sh" > /dev/null 2>&1 &

# Enable automatic clipboard saving
mkdir -p "$HOME/.clipboard_history"

# Save current clipboard every 10 minutes
while true; do
  pbpaste > "$HOME/.clipboard_history/clipboard_$(date +%Y%m%d_%H%M%S).txt"
  sleep 600
done
EOF

  chmod +x "$HOME/claude_main/scripts/clipboard-monitor-startup.sh"
  
  # Create launchd plist for startup
  cat > "$HOME/Library/LaunchAgents/com.claude.clipboardmonitor.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.claude.clipboardmonitor</string>
    <key>ProgramArguments</key>
    <array>
        <string>${HOME}/claude_main/scripts/clipboard-monitor-startup.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>${HOME}/.clipboard_history/monitor.log</string>
    <key>StandardErrorPath</key>
    <string>${HOME}/.clipboard_history/monitor_error.log</string>
</dict>
</plist>
EOF

  log "Created clipboard monitoring service"
  log "To enable at startup, run: launchctl load ${HOME}/Library/LaunchAgents/com.claude.clipboardmonitor.plist"
}

# Fix terminal cmd+~ switching issue
fix_terminal() {
  section "FIXING TERMINAL CMD+~ SWITCHING"
  
  log "Resetting Terminal preferences"
  defaults delete com.apple.Terminal
  
  log "Creating Terminal configuration script"
  cat > "$HOME/terminal_config.sh" << 'EOF'
#!/bin/bash

# Set up command+~ window switching
defaults write com.apple.Terminal NSUserKeyEquivalents -dict-add "Select Next Window" "@~"

# Reset window state
defaults write com.apple.Terminal "NSWindow Frame TTWindow" "0 0 800 600 0 0 1680 1027 "

# Set up terminal window switching keyboard shortcuts
defaults write com.apple.Terminal NSUserKeyEquivalents -dict-add "Select Next Tab" "^@\U21e5"
defaults write com.apple.Terminal NSUserKeyEquivalents -dict-add "Select Previous Tab" "^@\U21e4"

# Configure additional Terminal settings for better usability
defaults write com.apple.Terminal "Default Window Settings" -string "Pro"
defaults write com.apple.Terminal "Startup Window Settings" -string "Pro"
defaults write com.apple.Terminal ShowLineMarks -int 0
defaults write com.apple.Terminal StringEncodings -array 4 30

# Create custom command prompt settings
if [ ! -f ~/.bash_prompt ]; then
  cat > ~/.bash_prompt << 'PROMPTEOF'
# Custom command prompt with directory and git information
parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# Set a fancy prompt
PS1='\[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h:\[\033[33;1m\]\w\[\033[m\]\$(parse_git_branch) \$ '
export PS1

# Show current directory in Terminal title
PROMPT_COMMAND='echo -ne "\033]0;${PWD/#$HOME/~}\007"'
PROMPTEOF

  # Add to bash profile if not already there
  if ! grep -q "source ~/.bash_prompt" ~/.bashrc; then
    echo "# Load custom prompt" >> ~/.bashrc
    echo "[ -f ~/.bash_prompt ] && source ~/.bash_prompt" >> ~/.bashrc
  fi
fi

# Create Terminal window manager function
if ! grep -q "function tw()" ~/.bashrc; then
  cat >> ~/.bashrc << 'TWEOF'

# Terminal window management
function tw() {
  case "$1" in
    list)
      # List all terminal windows
      for pid in $(pgrep -x "bash" "zsh" "sh" "fish"); do
        if [[ $(ps -o stat= -p $pid) == *"+"* ]]; then
          echo "Terminal PID $pid: $(lsof -p $pid | grep cwd | awk '{print $9}')"
        fi
      done
      ;;
    new)
      # Open new terminal at specified location
      if [ -d "$2" ]; then
        open -a Terminal "$2"
      else
        echo "Directory not found: $2"
      fi
      ;;
    help|*)
      echo "Terminal window manager usage:"
      echo "  tw list      - List all terminal windows"
      echo "  tw new PATH  - Open new terminal at PATH"
      ;;
  esac
}
TWEOF
fi

# Restart Terminal service
killall Terminal

echo "Terminal preferences reset and configured for cmd+~ switching"
echo "Additional terminal productivity features installed"
echo "Please restart your Terminal app for changes to take effect"
EOF

  chmod +x "$HOME/terminal_config.sh"
  log "Running terminal configuration script"
  "$HOME/terminal_config.sh"
  log "Terminal fix complete - you may need to restart Terminal"
  
  # Create advanced terminal window manager
  log "Creating advanced terminal window manager"
  mkdir -p "$HOME/bin"
  
  cat > "$HOME/bin/term-manager" << 'EOF'
#!/bin/bash
# Advanced Terminal Window Manager

ACTION=$1
SAVE_DIR="$HOME/.terminal_sessions"
mkdir -p "$SAVE_DIR"

function list_sessions() {
  echo "=== ACTIVE TERMINAL SESSIONS ==="
  for pid in $(pgrep -x "bash" "zsh" "sh" "fish"); do
    if [[ $(ps -o stat= -p $pid) == *"+"* ]]; then
      DIR=$(lsof -p $pid | grep cwd | awk '{print $9}')
      CMD=$(ps -p $pid -o command= | head -1)
      
      # Try to get window title
      TITLE=$(osascript -e "tell application \"Terminal\" to get the custom title of window 1" 2>/dev/null)
      if [ -z "$TITLE" ]; then TITLE="Terminal"; fi
      
      echo "[$TITLE] PID $pid: $DIR"
      echo "  > $CMD"
    fi
  done
}

function save_session() {
  NAME=${2:-"session_$(date +%Y%m%d_%H%M%S)"}
  SAVE_FILE="$SAVE_DIR/$NAME.tsession"
  
  echo "# Terminal session saved on $(date)" > "$SAVE_FILE"
  echo "# Format: DIRECTORY|COMMAND" >> "$SAVE_FILE"
  
  for pid in $(pgrep -x "bash" "zsh" "sh" "fish"); do
    if [[ $(ps -o stat= -p $pid) == *"+"* ]]; then
      DIR=$(lsof -p $pid | grep cwd | awk '{print $9}')
      CMD=$(ps -p $pid -o command= | head -1)
      echo "$DIR|$CMD" >> "$SAVE_FILE"
    fi
  done
  
  echo "Session saved to $SAVE_FILE"
}

function restore_session() {
  SESSION_FILE="$2"
  
  if [ -z "$SESSION_FILE" ]; then
    # List available sessions
    echo "Available sessions:"
    ls -1 "$SAVE_DIR" | sed 's/\.tsession$//'
    return
  fi
  
  # Add extension if not provided
  if [[ ! "$SESSION_FILE" == *.tsession ]]; then
    SESSION_FILE="$SESSION_FILE.tsession"
  fi
  
  # Check if file exists in save dir
  if [ ! -f "$SAVE_DIR/$SESSION_FILE" ]; then
    # Check if path was provided
    if [ ! -f "$SESSION_FILE" ]; then
      echo "Session file not found: $SESSION_FILE"
      return
    fi
  else
    SESSION_FILE="$SAVE_DIR/$SESSION_FILE"
  fi
  
  echo "Restoring session from $SESSION_FILE"
  
  while IFS="|" read -r dir cmd; do
    # Skip comments
    [[ "$dir" == \#* ]] && continue
    
    if [ -d "$dir" ]; then
      # Open Terminal and cd to directory
      osascript -e "tell application \"Terminal\" to do script \"cd '$dir'\""
      echo "Opened terminal at $dir"
    fi
  done < "$SESSION_FILE"
  
  echo "Session restored. Terminals opened."
}

case "$ACTION" in
  list)
    list_sessions
    ;;
  save)
    save_session "$@"
    ;;
  restore)
    restore_session "$@"
    ;;
  help|*)
    echo "Advanced Terminal Window Manager"
    echo "Usage: term-manager [action] [options]"
    echo ""
    echo "Actions:"
    echo "  list             - List all current terminal sessions"
    echo "  save [name]      - Save current terminal sessions (optional name)"
    echo "  restore [file]   - Restore sessions from saved file"
    echo "                     If no file specified, lists available sessions"
    echo "  help             - Show this help message"
    ;;
esac
EOF

  chmod +x "$HOME/bin/term-manager"
  log "Advanced terminal window manager created at $HOME/bin/term-manager"
}

# Analyze system and suggest improvements
analyze_system() {
  section "ANALYZING SYSTEM"
  
  log "Starting system analysis"
  
  # Check Claude organization
  log "Checking Claude organization"
  CLAUDE_DIRS=0
  for dir in "$HOME/claude_data" "$HOME/claude_central" "$HOME/claude_unified" "$HOME/claude_main"; do
    if [[ -d "$dir" ]]; then
      ((CLAUDE_DIRS++))
    fi
  done
  
  if [[ $CLAUDE_DIRS -gt 1 ]]; then
    log "Found multiple Claude directories - organization recommended"
    echo -e "${YELLOW}SUGGESTION: Run '$0 claude' to organize Claude components${NC}" | tee -a "$LOG_FILE"
  fi
  
  # Check clipboard issues
  log "Checking clipboard functionality"
  echo "Clipboard Test" | pbcopy
  CLIPBOARD_TEST=$(pbpaste)
  if [[ "$CLIPBOARD_TEST" != "Clipboard Test" ]]; then
    log "Clipboard issues detected"
    echo -e "${YELLOW}SUGGESTION: Run '$0 fix-clipboard' to fix clipboard issues${NC}" | tee -a "$LOG_FILE"
  fi
  
  # Check Terminal cmd+~ switching
  log "Checking Terminal keyboard shortcuts"
  TERMINAL_SHORTCUTS=$(defaults read com.apple.Terminal NSUserKeyEquivalents 2>/dev/null)
  if [[ -z "$TERMINAL_SHORTCUTS" || ! "$TERMINAL_SHORTCUTS" == *"Select Next Window"* ]]; then
    log "Terminal shortcut issues detected"
    echo -e "${YELLOW}SUGGESTION: Run '$0 fix-terminal' to fix Terminal cmd+~ switching${NC}" | tee -a "$LOG_FILE"
  fi
  
  # Check for missing Claude dock items
  log "Checking dock items"
  DOCK_CLAUDE=$(defaults read com.apple.dock persistent-apps | grep -i "claude")
  if [[ -z "$DOCK_CLAUDE" ]]; then
    log "Missing Claude items in dock"
    echo -e "${YELLOW}SUGGESTION: Run '$0 fix-dock' to restore Claude apps to dock${NC}" | tee -a "$LOG_FILE"
  fi
  
  # Check for bazinga improvements
  if [[ -d "$HOME/AmsyPycharm/BAZINGA" ]]; then
    log "Checking BAZINGA project"
    
    # Check for proper claude integration
    if [[ ! -d "$HOME/AmsyPycharm/BAZINGA/artifacts/claude_artifacts" ]]; then
      log "BAZINGA missing Claude artifacts directory"
      echo -e "${YELLOW}SUGGESTION: Run '$0 organize' to set up proper BAZINGA Claude integration${NC}" | tee -a "$LOG_FILE"
    fi
  fi
  
  log "Analysis complete, results saved to $LOG_FILE"
  echo -e "${GREEN}Analysis complete!${NC} Results saved to $LOG_FILE"
}

# Organize system based on analysis
organize_system() {
  section "ORGANIZING SYSTEM"
  
  log "Starting system organization"
  
  # Organize Claude
  organize_claude
  
  # Organize bazinga integration
  if [[ -d "$HOME/AmsyPycharm/BAZINGA" ]]; then
    log "Setting up BAZINGA Claude integration"
    mkdir -p "$HOME/AmsyPycharm/BAZINGA/artifacts/claude_artifacts"
    
    # Create connector script if it doesn't exist
    if [[ ! -f "$HOME/AmsyPycharm/BAZINGA/artifacts/claude_artifacts/bazinga-claude-connector.sh" ]]; then
      log "Creating BAZINGA Claude connector"
      cat > "$HOME/AmsyPycharm/BAZINGA/artifacts/claude_artifacts/bazinga-claude-connector.sh" << 'EOF'
#!/bin/bash

# BAZINGA-Claude Connector
CLAUDE_HOME="$HOME/claude_main"
BAZINGA_ROOT="$HOME/AmsyPycharm/BAZINGA"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Create log directory if it doesn't exist
mkdir -p "$BAZINGA_ROOT/logs"
LOG_FILE="$BAZINGA_ROOT/logs/claude_connector_$TIMESTAMP.log"

echo "[$(date +"%Y-%m-%d %H:%M:%S")] BAZINGA-Claude connector started" > "$LOG_FILE"

# Check if Claude system exists
if [[ ! -d "$CLAUDE_HOME" ]]; then
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] ERROR: Claude home directory not found!" >> "$LOG_FILE"
  echo "Claude home directory not found! Please run the system organizer first."
  exit 1
fi

# Copy Claude artifacts to BAZINGA
echo "[$(date +"%Y-%m-%d %H:%M:%S")] Syncing Claude artifacts to BAZINGA" >> "$LOG_FILE"
mkdir -p "$BAZINGA_ROOT/artifacts/claude_artifacts"

# Sync scripts
if [[ -d "$CLAUDE_HOME/scripts" ]]; then
  cp "$CLAUDE_HOME/scripts"/*.sh "$BAZINGA_ROOT/artifacts/claude_artifacts/" 2>/dev/null
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] Synced scripts" >> "$LOG_FILE"
fi

# Sync recent artifacts
if [[ -d "$CLAUDE_HOME/artifacts/extracted" ]]; then
  LATEST_ARTIFACTS=$(find "$CLAUDE_HOME/artifacts/extracted" -type d -name "claude_*" | sort | tail -1)
  if [[ -n "$LATEST_ARTIFACTS" ]]; then
    cp -r "$LATEST_ARTIFACTS"/* "$BAZINGA_ROOT/artifacts/claude_artifacts/" 2>/dev/null
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] Synced latest artifacts from $LATEST_ARTIFACTS" >> "$LOG_FILE"
  fi
fi

echo "[$(date +"%Y-%m-%d %H:%M:%S")] BAZINGA-Claude connector complete" >> "$LOG_FILE"
echo "BAZINGA-Claude connection complete!"
EOF
      chmod +x "$HOME/AmsyPycharm/BAZINGA/artifacts/claude_artifacts/bazinga-claude-connector.sh"
    fi
    
    # Run the connector
    log "Running BAZINGA Claude connector"
    "$HOME/AmsyPycharm/BAZINGA/artifacts/claude_artifacts/bazinga-claude-connector.sh"
  fi
  
  # Organize scripts directory
  log "Organizing scripts directory"
  mkdir -p "$HOME/scripts"
  
  # Find useful scripts and copy to scripts directory
  find "$HOME" -type f -name "*.sh" -not -path "*/.*/*" -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null | while read -r script; do
    if [[ -f "$script" && ! -f "$HOME/scripts/$(basename "$script")" ]]; then
      # Only copy small to medium sized scripts, not huge ones
      size=$(wc -l < "$script")
      if [[ $size -gt 10 && $size -lt 1000 ]]; then
        cp "$script" "$HOME/scripts/"
        chmod +x "$HOME/scripts/$(basename "$script")"
        log "Added $(basename "$script") to scripts directory"
      fi
    fi
  done
  
  # Organize bin directory
  log "Organizing bin directory"
  mkdir -p "$HOME/bin"
  
  # Create symlinks to key scripts
  ln -sf "$HOME/claude_main/claude-control.sh" "$HOME/bin/claude"
  ln -sf "$HOME/claude_main/scripts/claude-clipboard-fix.sh" "$HOME/bin/claude-fix-clipboard"
  
  # Create terminal window manager script
  cat > "$HOME/bin/terminal-manager" << 'EOF'
#!/bin/bash
# Terminal Window Manager

ACTION=$1
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

case "$ACTION" in
  list)
    echo "=== TERMINAL SESSIONS ==="
    for pid in $(pgrep -x "bash" "zsh" "sh" "fish"); do
      if [[ $(ps -o stat= -p $pid) == *"+"* ]]; then
        echo "Terminal PID $pid: $(lsof -p $pid | grep cwd | awk '{print $9}')"
        echo "Recent commands: $(ps -p $pid -o command= | head -1)"
        echo ""
      fi
    done
    ;;
    
  save)
    # Save current terminal sessions state
    OUTPUT_FILE="$HOME/terminal_sessions_$TIMESTAMP.txt"
    echo "=== TERMINAL SESSIONS SAVED AT $(date) ===" > "$OUTPUT_FILE"
    for pid in $(pgrep -x "bash" "zsh" "sh" "fish"); do
      if [[ $(ps -o stat= -p $pid) == *"+"* ]]; then
        echo "Terminal PID $pid: $(lsof -p $pid | grep cwd | awk '{print $9}')" >> "$OUTPUT_FILE"
        echo "Recent commands: $(ps -p $pid -o command= | head -1)" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
      fi
    done
    echo "Terminal sessions saved to $OUTPUT_FILE"
    ;;
    
  restore)
    # Open new terminals based on saved state
    if [ -z "$2" ]; then
      echo "Please specify a saved terminal sessions file to restore"
      exit 1
    fi
    
    if [ ! -f "$2" ]; then
      echo "File not found: $2"
      exit 1
    fi
    
    echo "Restoring terminal sessions from $2"
    while read -r line; do
      if [[ $line == Terminal* ]]; then
        dir=$(echo $line | sed 's/Terminal PID [0-9]*: //')
        if [ -d "$dir" ]; then
          osascript -e "tell application \"Terminal\" to do script \"cd '$dir'\""
          echo "Opened terminal at $dir"
        fi
      fi
    done < "$2"
    ;;
    
  help|*)
    echo "Terminal Window Manager"
    echo "Usage: terminal-manager [action]"
    echo ""
    echo "Actions:"
    echo "  list    - List all current terminal sessions"
    echo "  save    - Save current terminal sessions state"
    echo "  restore - Restore terminal sessions from saved state"
    echo "  help    - Show this help message"
    ;;
esac
EOF
  chmod +x "$HOME/bin/terminal-manager"
  
  # Create BAZINGA project navigator
  if [[ -d "$HOME/AmsyPycharm/BAZINGA" ]]; then
    cat > "$HOME/bin/bazinga-nav" << 'EOF'
#!/bin/bash
# BAZINGA Project Navigator

BAZINGA_ROOT="$HOME/AmsyPycharm/BAZINGA"
BAZINGA_INDEED="$HOME/AmsyPycharm/BAZINGA-INDEED"

# Verify BAZINGA directory exists
if [ ! -d "$BAZINGA_ROOT" ]; then
  echo "ERROR: BAZINGA directory not found at $BAZINGA_ROOT"
  exit 1
fi

# Show usage if no arguments provided
if [ $# -eq 0 ]; then
  echo "BAZINGA Project Navigator"
  echo "Usage: bazinga-nav [component]"
  echo ""
  echo "Components:"
  echo "  scripts     - Navigate to scripts directory"
  echo "  artifacts   - Navigate to artifacts directory"
  echo "  claude      - Navigate to Claude artifacts"
  echo "  analysis    - Navigate to analysis directory"
  echo "  docs        - Navigate to documentation"
  echo "  indeed      - Navigate to BAZINGA-INDEED project"
  echo "  list        - List all available components"
  echo "  status      - Show BAZINGA system status"
  exit 0
fi

case "$1" in
  scripts)
    cd "$BAZINGA_ROOT/scripts" && echo "Navigated to BAZINGA scripts" && ls -la
    ;;
  artifacts)
    cd "$BAZINGA_ROOT/artifacts" && echo "Navigated to BAZINGA artifacts" && ls -la
    ;;
  claude)
    cd "$BAZINGA_ROOT/artifacts/claude_artifacts" && echo "Navigated to Claude artifacts" && ls -la
    ;;
  analysis)
    cd "$BAZINGA_ROOT/analysis" && echo "Navigated to analysis directory" && ls -la
    ;;
  docs)
    cd "$BAZINGA_ROOT/docs" && echo "Navigated to documentation" && ls -la
    ;;
  indeed)
    cd "$BAZINGA_INDEED" && echo "Navigated to BAZINGA-INDEED project" && ls -la
    ;;
  list)
    echo "=== BAZINGA COMPONENTS ==="
    find "$BAZINGA_ROOT" -type d -maxdepth 1 | grep -v "node_modules\|\.git" | sort
    echo ""
    echo "=== BAZINGA-INDEED COMPONENTS ==="
    find "$BAZINGA_INDEED" -type d -maxdepth 1 | grep -v "node_modules\|\.git" | sort
    ;;
  status)
    echo "=== BAZINGA SYSTEM STATUS ==="
    echo "BAZINGA root: $BAZINGA_ROOT"
    echo "BAZINGA-INDEED: $BAZINGA_INDEED"
    echo ""
    echo "Scripts: $(find "$BAZINGA_ROOT/scripts" -type f | wc -l)"
    echo "Artifacts: $(find "$BAZINGA_ROOT/artifacts" -type f | wc -l)"
    echo "Claude artifacts: $(find "$BAZINGA_ROOT/artifacts/claude_artifacts" -type f 2>/dev/null | wc -l)"
    echo ""
    echo "Recent activity:"
    find "$BAZINGA_ROOT" -type f -mtime -7 | head -5
    ;;
  *)
    # Try to navigate to the specified directory
    if [ -d "$BAZINGA_ROOT/$1" ]; then
      cd "$BAZINGA_ROOT/$1" && echo "Navigated to $BAZINGA_ROOT/$1" && ls -la
    else
      echo "Unknown component: $1"
      echo "Use 'bazinga-nav list' to see available components"
    fi
    ;;
esac
EOF
    chmod +x "$HOME/bin/bazinga-nav"
  fi
  
  # Add bin to PATH if not already there
  if ! grep -q 'export PATH="$HOME/bin:$PATH"' "$HOME/.bashrc"; then
    echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
    log "Added $HOME/bin to PATH in .bashrc"
  fi
  
  log "System organization complete!"
}

# Clean up temporary and duplicate files
cleanup_system() {
  section "CLEANING UP SYSTEM"
  
  log "Starting system cleanup"
  
  # Create temp directory for cleanup
  CLEANUP_DIR="$LOG_DIR/cleanup"
  mkdir -p "$CLEANUP_DIR"
  
  # Find and list duplicate claude scripts
  log "Finding duplicate Claude scripts"
  find "$HOME" -type f -name "*claude*.sh" -not -path "*/.*/*" 2>/dev/null | sort > "$CLEANUP_DIR/claude_scripts.txt"
  
  # Find disabled or backup files
  log "Finding disabled or backup files"
  find "$HOME" -type f \( -name "*.bak" -o -name "*.disabled" -o -name "*-old" \) -not -path "*/.*/*" 2>/dev/null > "$CLEANUP_DIR/backup_files.txt"
  
  # Look for large log files
  log "Finding large log files"
  find "$HOME" -type f -name "*.log" -size +10M -not -path "*/.*/*" 2>/dev/null > "$CLEANUP_DIR/large_logs.txt"
  
  # Check for .DS_Store files
  log "Finding .DS_Store files"
  find "$HOME" -type f -name ".DS_Store" 2>/dev/null > "$CLEANUP_DIR/ds_store_files.txt"
  
  # Suggest cleanup actions
  log "Generating cleanup suggestions"
  
  echo -e "${YELLOW}Cleanup Suggestions:${NC}" | tee -a "$LOG_FILE"
  
  # Suggest removing backup files
  BACKUP_COUNT=$(wc -l < "$CLEANUP_DIR/backup_files.txt")
  if [[ $BACKUP_COUNT -gt 0 ]]; then
    echo -e "${BLUE}Found $BACKUP_COUNT backup/disabled files${NC}" | tee -a "$LOG_FILE"
    echo -e "To remove these files, run: ${GREEN}find \$HOME -type f \\( -name \"*.bak\" -o -name \"*.disabled\" -o -name \"*-old\" \\) -not -path \"*/.*/*\" -delete${NC}" | tee -a "$LOG_FILE"
  fi
  
  # Suggest removing large log files
  LOG_COUNT=$(wc -l < "$CLEANUP_DIR/large_logs.txt")
  if [[ $LOG_COUNT -gt 0 ]]; then
    echo -e "${BLUE}Found $LOG_COUNT large log files${NC}" | tee -a "$LOG_FILE"
    echo -e "To truncate these files, run: ${GREEN}find \$HOME -type f -name \"*.log\" -size +10M -not -path \"*/.*/*\" -exec truncate -s 0 {} \\;${NC}" | tee -a "$LOG_FILE"
  fi
  
  # Suggest removing .DS_Store files
  DS_COUNT=$(wc -l < "$CLEANUP_DIR/ds_store_files.txt")
  if [[ $DS_COUNT -gt 0 ]]; then
    echo -e "${BLUE}Found $DS_COUNT .DS_Store files${NC}" | tee -a "$LOG_FILE"
    echo -e "To remove these files, run: ${GREEN}find \$HOME -type f -name \".DS_Store\" -delete${NC}" | tee -a "$LOG_FILE"
  fi
  
  # Actually perform safe cleanups
  log "Performing safe cleanups"
  
  # Delete .DS_Store files
  find "$HOME/Downloads" -type f -name ".DS_Store" -delete 2>/dev/null
  
  # Clean up old temp files in Downloads
  find "$HOME/Downloads" -type f -name "temp*" -mtime +7 -delete 2>/dev/null
  
  log "Safe cleanup complete. See $LOG_FILE for more cleanup suggestions."
}

# Main script logic
if [[ $# -eq 0 ]]; then
  show_help
  exit 0
fi

case "$1" in
  analyze)
    analyze_system
    ;;
  organize)
    organize_system
    ;;
  cleanup)
    cleanup_system
    ;;
  claude)
    organize_claude
    ;;
  fix-dock)
    fix_dock
    ;;
  fix-clipboard)
    fix_clipboard
    ;;
  fix-terminal)
    fix_terminal
    ;;
  help)
    show_help
    ;;
  *)
    error "Unknown command: $1"
    show_help
    exit 1
    ;;
esac

section "COMPLETE"
log "Operation completed successfully"
echo -e "${GREEN}Operation completed!${NC} Results saved to $LOG_FILE"
