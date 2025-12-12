#!/bin/bash
# bazinga-history-tracker.sh - Track Claude artifacts with command history awareness
# ⟨ψ|⟳|The framework recognizes patterns that recognize themselves being recognized⟩

# ANSI colors for visual clarity
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Set base directories
BAZINGA_DIR=${BAZINGA_DIR:-"$PWD"}
ARTIFACT_DIR="$BAZINGA_DIR/artifacts"
CLAUDE_DIR="$ARTIFACT_DIR/claude"
HISTORY_DIR="$ARTIFACT_DIR/history"
DB_FILE="$CLAUDE_DIR/artifacts_db.json"
HISTORY_FILE="$HISTORY_DIR/command_artifacts.json"
CONFIG_DIR="$BAZINGA_DIR/config"

# Ensure directories exist
mkdir -p "$CLAUDE_DIR" "$CONFIG_DIR" "$HISTORY_DIR"

# Check for custom locations from existing BAZINGA files
if [ ! -d "$ARTIFACT_DIR" ] && [ -d "$BAZINGA_DIR/integration" ]; then
  # Use existing integration directory structure
  ARTIFACT_DIR="$BAZINGA_DIR/integration/claude_artifacts"
  CLAUDE_DIR="$ARTIFACT_DIR"
  HISTORY_DIR="$ARTIFACT_DIR/history"
  mkdir -p "$CLAUDE_DIR" "$HISTORY_DIR"
fi

# Initialize database if it doesn't exist
if [ ! -f "$DB_FILE" ]; then
  cat > "$DB_FILE" << EOL
{
  "artifacts": [],
  "last_updated": "$(date -Iseconds)"
}
EOL
fi

# Initialize history database if it doesn't exist
if [ ! -f "$HISTORY_FILE" ]; then
  cat > "$HISTORY_FILE" << EOL
{
  "commands": {},
  "chats": {},
  "last_updated": "$(date -Iseconds)"
}
EOL
fi

# Function to analyze bash history for artifact-related commands
analyze_history() {
  echo -e "${CYAN}Analyzing command history for artifact-related commands...${NC}"
  
  # Create a temporary file with cleaned history
  history_output=$(mktemp)
  history | grep -v "Permission denied" > "$history_output"
  
  # Look for specific patterns
  echo -e "${YELLOW}Looking for Claude chat references...${NC}"
  
  # Extract Claude URLs from browser history if available
  if [ -f ~/Library/Application\ Support/Google/Chrome/Default/History ]; then
    echo -e "${GREEN}Found Chrome history, analyzing for Claude URLs...${NC}"
    # In practice, would need to copy the DB and use sqlite3 to query
    # This is just a placeholder for the concept
  fi
  
  # Look for bazinga integration commands
  bazinga_commands=$(grep -E "bazinga-claude|bazinga.*integrate|claude" "$history_output" | sort -u)
  if [ -n "$bazinga_commands" ]; then
    echo -e "${GREEN}Found BAZINGA-Claude integration commands:${NC}"
    echo "$bazinga_commands" | sed 's/^\s*[0-9]\+\s\+[0-9-]\+\s\+[0-9:]\+\s//'
    
    # Add to history database
    if command -v jq &> /dev/null; then
      for cmd in $(echo "$bazinga_commands" | sed 's/^\s*[0-9]\+\s\+[0-9-]\+\s\+[0-9:]\+\s//'); do
        cmd_hash=$(echo "$cmd" | md5sum | cut -d' ' -f1)
        if ! grep -q "$cmd_hash" "$HISTORY_FILE"; then
          local temp_file=$(mktemp)
          jq --arg cmd "$cmd" --arg hash "$cmd_hash" --arg time "$(date -Iseconds)" \
            '.commands[$hash] = {"command": $cmd, "added": $time, "linked_artifacts": []} | .last_updated = $time' \
            "$HISTORY_FILE" > "$temp_file" && mv "$temp_file" "$HISTORY_FILE"
        fi
      done
    fi
  fi
  
  # Clean up
  rm "$history_output"
  
  echo -e "${GREEN}History analysis complete${NC}"
}

# Function to track open Claude chats
track_claude_chats() {
  echo -e "${CYAN}Checking for open Claude chats...${NC}"
  
  # On macOS, use "ps" to find Chrome/Safari processes with Claude in the title
  if [ "$(uname)" = "Darwin" ]; then
    # This is a simplified concept - would need AppleScript for actual implementation
    chrome_pids=$(ps aux | grep -i "chrome.*claude" | grep -v grep | awk '{print $2}')
    safari_pids=$(ps aux | grep -i "safari.*claude" | grep -v grep | awk '{print $2}')
    
    if [ -n "$chrome_pids" ] || [ -n "$safari_pids" ]; then
      echo -e "${GREEN}Found open Claude tabs${NC}"
      # Would need browser integration to get actual URLs
    fi
  fi
  
  echo -e "${CYAN}Chat tracking complete${NC}"
}

# Function to remind of pending artifact collection
reminder_check() {
  echo -e "${CYAN}Checking for pending artifacts to collect...${NC}"
  
  # Check last Claude integration command time
  last_command=$(jq -r '.last_updated' "$HISTORY_FILE")
  last_artifact=$(jq -r '.last_updated' "$DB_FILE")
  
  # Convert timestamps to Unix time for comparison
  if command -v date &> /dev/null; then
    last_command_unix=$(date -d "$last_command" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%S%z" "$last_command" +%s 2>/dev/null)
    last_artifact_unix=$(date -d "$last_artifact" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%S%z" "$last_artifact" +%s 2>/dev/null)
    
    # If last command is more recent than last artifact by more than an hour
    time_diff=$((last_command_unix - last_artifact_unix))
    if [ $time_diff -gt 3600 ]; then
      echo -e "${YELLOW}⚠️ You may have uncollected artifacts from recent Claude chats${NC}"
      echo -e "${CYAN}Last integration command: $last_command${NC}"
      echo -e "${CYAN}Last artifact collected: $last_artifact${NC}"
      
      # Suggest chats to check
      echo -e "${YELLOW}Suggested chats to check:${NC}"
      jq -r '.commands | to_entries[] | select(.value.command | contains("claude")) | .value.command' "$HISTORY_FILE" | tail -3
    else
      echo -e "${GREEN}No pending artifacts detected${NC}"
    fi
  fi
}

# Function to get clipboard content cross-platform
get_clipboard() {
  if command -v pbpaste &> /dev/null; then
    # macOS
    pbpaste
  elif command -v xclip &> /dev/null; then
    # Linux with xclip
    xclip -selection clipboard -o
  elif command -v xsel &> /dev/null; then
    # Linux with xsel
    xsel --clipboard
  elif command -v powershell.exe &> /dev/null; then
    # Windows with WSL
    powershell.exe Get-Clipboard
  else
    echo ""
    return 1
  fi
}

# Function to calculate checksum of artifact content
calculate_checksum() {
  echo "$1" | md5sum | awk '{print $1}'
}

# Function to add artifact to database
add_artifact() {
  local artifact_name="$1"
  local artifact_type="$2"
  local artifact_content="$3"
  local artifact_chat_id="$4"
  local checksum=$(calculate_checksum "$artifact_content")
  local timestamp=$(date -Iseconds)
  
  # Check if artifact already exists
  if grep -q "\"checksum\": \"$checksum\"" "$DB_FILE"; then
    echo -e "${YELLOW}Artifact already exists in database${NC}"
    return 0
  fi
  
  # Create artifact file
  local artifact_file="$CLAUDE_DIR/${artifact_name}_${checksum:0:8}.${artifact_type}"
  echo "$artifact_content" > "$artifact_file"
  
  # Add to database with jq if available
  if command -v jq &> /dev/null; then
    local temp_file=$(mktemp)
    jq ".artifacts += [{
      \"name\": \"$artifact_name\",
      \"type\": \"$artifact_type\",
      \"checksum\": \"$checksum\",
      \"file\": \"$artifact_file\",
      \"chat_id\": \"$artifact_chat_id\",
      \"added\": \"$timestamp\",
      \"executed\": false
    }] | .last_updated = \"$timestamp\"" "$DB_FILE" > "$temp_file" && mv "$temp_file" "$DB_FILE"
  else
    # Simpler approach without jq
    sed -i.bak "s/\"artifacts\": \[/\"artifacts\": \[{\"name\": \"$artifact_name\", \"type\": \"$artifact_type\", \"checksum\": \"$checksum\", \"file\": \"$artifact_file\", \"chat_id\": \"$artifact_chat_id\", \"added\": \"$timestamp\", \"executed\": false},/" "$DB_FILE"
    sed -i.bak "s/\"last_updated\": \"[^\"]*\"/\"last_updated\": \"$timestamp\"/" "$DB_FILE"
    rm -f "$DB_FILE.bak"
  fi
  
  # Update history links
  if command -v jq &> /dev/null; then
    # Find recent command involving claude and link it to this artifact
    recent_cmd_hash=$(jq -r '.commands | to_entries[] | select(.value.command | contains("claude")) | .key' "$HISTORY_FILE" | tail -1)
    if [ -n "$recent_cmd_hash" ]; then
      local temp_file=$(mktemp)
      jq --arg hash "$recent_cmd_hash" --arg checksum "$checksum" \
        '.commands[$hash].linked_artifacts += [$checksum]' \
        "$HISTORY_FILE" > "$temp_file" && mv "$temp_file" "$HISTORY_FILE"
    fi
  fi
  
  echo -e "${GREEN}Added artifact: $artifact_name (${checksum:0:8})${NC}"
  echo -e "${CYAN}Saved to: $artifact_file${NC}"
}

# Function to process Claude artifact from clipboard
process_artifact_from_clipboard() {
  local clipboard_content=$(get_clipboard)
  
  if [ -z "$clipboard_content" ]; then
    echo -e "${RED}Unable to access clipboard. Install xclip/xsel (Linux) or ensure clipboard access.${NC}"
    return 1
  fi
  
  local chat_id=$(echo "$RANDOM$RANDOM" | md5sum | head -c 8)
  
  # Extract bash script artifacts with common markers
  if echo "$clipboard_content" | grep -q "^```bash"; then
    local artifact_content=$(echo "$clipboard_content" | sed -n '/^```bash/,/^```/ p' | sed '1d;$d')
    local artifact_name=$(echo "$artifact_content" | grep -m 1 "^# " | sed 's/^# //' | tr ' ' '_' | tr -cd 'a-zA-Z0-9_-')
    
    if [ -z "$artifact_name" ]; then
      artifact_name="bash_script_$(date +%Y%m%d)"
    fi
    
    add_artifact "$artifact_name" "sh" "$artifact_content" "$chat_id"
    return 0
  fi
  
  # Extract python script artifacts
  if echo "$clipboard_content" | grep -q "^```python"; then
    local artifact_content=$(echo "$clipboard_content" | sed -n '/^```python/,/^```/ p' | sed '1d;$d')
    local artifact_name=$(echo "$artifact_content" | grep -m 1 "^# " | sed 's/^# //' | tr ' ' '_' | tr -cd 'a-zA-Z0-9_-')
    
    if [ -z "$artifact_name" ]; then
      artifact_name="python_script_$(date +%Y%m%d)"
    fi
    
    add_artifact "$artifact_name" "py" "$artifact_content" "$chat_id"
    return 0
  fi
  
  # Extract typescript/javascript artifacts
  if echo "$clipboard_content" | grep -q "^```typescript\|^```javascript\|^```ts\|^```js"; then
    local artifact_content=$(echo "$clipboard_content" | sed -n '/^```\(typescript\|javascript\|ts\|js\)/,/^```/ p' | sed '1d;$d')
    local artifact_name=$(echo "$artifact_content" | grep -m 1 "^// " | sed 's|^// ||' | tr ' ' '_' | tr -cd 'a-zA-Z0-9_-')
    
    if [ -z "$artifact_name" ]; then
      artifact_name="ts_script_$(date +%Y%m%d)"
    fi
    
    # Determine extension
    local ext="js"
    if echo "$clipboard_content" | grep -q "^```typescript\|^```ts"; then
      ext="ts"
    fi
    
    add_artifact "$artifact_name" "$ext" "$artifact_content" "$chat_id"
    return 0
  fi
  
  # Extract other code artifacts
  for lang in json html css; do
    if echo "$clipboard_content" | grep -q "^```$lang"; then
      local artifact_content=$(echo "$clipboard_content" | sed -n "/^```$lang/,/^```/ p" | sed '1d;$d')
      local artifact_name="${lang}_$(date +%Y%m%d)"
      
      add_artifact "$artifact_name" "$lang" "$artifact_content" "$chat_id"
      return 0
    fi
  done
  
  # Check for BAZINGA-specific artifacts 
  if echo "$clipboard_content" | grep -q "⟨ψ|⟳|"; then
    local artifact_name="bazinga_pattern_$(date +%Y%m%d)"
    add_artifact "$artifact_name" "txt" "$clipboard_content" "$chat_id"
    return 0
  fi
  
  echo -e "${YELLOW}No recognizable artifact found in clipboard${NC}"
  return 1
}

# Function to check clipboard content without adding
check_clipboard() {
  local clipboard_content=$(get_clipboard)
  
  if [ -z "$clipboard_content" ]; then
    echo -e "${RED}Unable to access clipboard. Install xclip/xsel (Linux) or ensure clipboard access.${NC}"
    return 1
  fi
  
  # Try to detect artifact type
  if echo "$clipboard_content" | grep -q "^```bash"; then
    echo -e "${CYAN}Detected bash script in clipboard${NC}"
    local content=$(echo "$clipboard_content" | sed -n '/^```bash/,/^```/ p' | sed '1d;$d')
    check_artifact_exists "$content"
  elif echo "$clipboard_content" | grep -q "^```python"; then
    echo -e "${CYAN}Detected Python script in clipboard${NC}"
    local content=$(echo "$clipboard_content" | sed -n '/^```python/,/^```/ p' | sed '1d;$d')
    check_artifact_exists "$content"
  elif echo "$clipboard_content" | grep -q "^```typescript\|^```javascript\|^```ts\|^```js"; then
    echo -e "${CYAN}Detected TypeScript/JavaScript in clipboard${NC}"
    local content=$(echo "$clipboard_content" | sed -n '/^```\(typescript\|javascript\|ts\|js\)/,/^```/ p' | sed '1d;$d')
    check_artifact_exists "$content"
  elif echo "$clipboard_content" | grep -q "⟨ψ|⟳|"; then
    echo -e "${CYAN}Detected BAZINGA pattern in clipboard${NC}"
    check_artifact_exists "$clipboard_content"
  else
    echo -e "${YELLOW}No recognizable artifact found in clipboard${NC}"
    return 1
  fi
}

# Function to check if artifact exists by content
check_artifact_exists() {
  local content="$1"
  local checksum=$(calculate_checksum "$content")
  
  if grep -q "\"checksum\": \"$checksum\"" "$DB_FILE"; then
    # Extract artifact details
    if command -v jq &> /dev/null; then
      local artifact_details=$(jq -r ".artifacts[] | select(.checksum == \"$checksum\") | \"Name: \(.name)\nType: \(.type)\nAdded: \(.added)\nExecuted: \(.executed)\nFile: \(.file)\"" "$DB_FILE")
      echo -e "${GREEN}Artifact already exists:${NC}"
      echo -e "$artifact_details"
      
      # Check for linked history commands
      local linked_commands=$(jq -r ".commands | to_entries[] | select(.value.linked_artifacts | contains([\"$checksum\"])) | .value.command" "$HISTORY_FILE")
      if [ -n "$linked_commands" ]; then
        echo -e "${CYAN}Linked commands:${NC}"
        echo "$linked_commands"
      fi
    else
      echo -e "${GREEN}Artifact with checksum ${checksum:0:8} already exists${NC}"
    fi
    return 0
  else
    echo -e "${YELLOW}Artifact does not exist in database${NC}"
    return 1
  fi
}

# Function to list all artifacts
list_artifacts() {
  local filter="$1"
  
  echo -e "${CYAN}⟨ψ|⟳| BAZINGA Claude Artifacts |ψ⟩${NC}"
  echo ""
  
  if command -v jq &> /dev/null; then
    if [ -n "$filter" ]; then
      jq -r ".artifacts[] | select(.name | contains(\"$filter\") or .type | contains(\"$filter\") or .chat_id | contains(\"$filter\")) | \"[\(.executed ? \"✅\" : \"❌\")] \(.name) (\(.type)) - \(.checksum[0:8]) - \(.added[0:10])\"" "$DB_FILE"
    else
      jq -r ".artifacts[] | \"[\(.executed ? \"✅\" : \"❌\")] \(.name) (\(.type)) - \(.checksum[0:8]) - \(.added[0:10])\"" "$DB_FILE"
    fi
  else
    echo "Install jq for better artifact filtering"
    grep -A 6 "\"name\":" "$DB_FILE" | grep -v "^--$" | sed -E 's/.*"name": "([^"]*)".*"type": "([^"]*)".*"checksum": "([^"]*)".*"executed": (true|false).*/[\4 ? "✅" : "❌"] \1 (\2) - \3 - /'
  fi
}

# Function to mark artifact as executed
mark_executed() {
  local checksum="$1"
  
  if command -v jq &> /dev/null; then
    local temp_file=$(mktemp)
    jq "(.artifacts[] | select(.checksum == \"$checksum\")).executed = true | .last_updated = \"$(date -Iseconds)\"" "$DB_FILE" > "$temp_file" && mv "$temp_file" "$DB_FILE"
  else
    sed -i.bak "s/\"checksum\": \"$checksum\", \"file\": \"[^\"]*\", \"chat_id\": \"[^\"]*\", \"added\": \"[^\"]*\", \"executed\": false/\"checksum\": \"$checksum\", \"file\": \"\1\", \"chat_id\": \"\2\", \"added\": \"\3\", \"executed\": true/" "$DB_FILE"
    sed -i.bak "s/\"last_updated\": \"[^\"]*\"/\"last_updated\": \"$(date -Iseconds)\"/" "$DB_FILE"
    rm -f "$DB_FILE.bak"
  fi
  
  echo -e "${GREEN}Marked artifact ${checksum:0:8} as executed${NC}"
}

# Function to integrate with existing BAZINGA scripts
integrate_with_bazinga() {
  # Create symlink to bin directory
  if [ -d "$BAZINGA_DIR/bin" ]; then
    ln -sf "$(realpath "$0")" "$BAZINGA_DIR/bin/artifact-tracker"
    echo -e "${GREEN}Created symlink in bin directory${NC}"
  fi
  
  # Add to bz command if exists
  if [ -f "$BAZINGA_DIR/bz" ]; then
    if ! grep -q "artifact\|track" "$BAZINGA_DIR/bz"; then
      # Create backup
      cp "$BAZINGA_DIR/bz" "$BAZINGA_DIR/bz.bak"
      
      # Add artifact-tracker to bz script
      sed -i.bak '/^case "$1" in/a\
  artifact|track)    run_script "artifact-tracker" "${@:2}" ;;' "$BAZINGA_DIR/bz"
      
      echo -e "${GREEN}Added artifact-tracker to bz command${NC}"
      echo -e "${CYAN}You can now use: bz artifact <command>${NC}"
    else
      echo -e "${YELLOW}artifact-tracker already integrated with bz command${NC}"
    fi
  fi
  
  # Create config file
  cat > "$CONFIG_DIR/artifact_tracker.conf" << EOL
# BAZINGA Artifact Tracker Configuration
ARTIFACT_DIR="$ARTIFACT_DIR"
CLAUDE_DIR="$CLAUDE_DIR"
HISTORY_DIR="$HISTORY_DIR"
AUTO_CHECK=true
SYNC_WITH_REFLECTION=true
EOL
  
  echo -e "${GREEN}Configuration file created: $CONFIG_DIR/artifact_tracker.conf${NC}"
  
  # Create quick reminder alias
  cat > "$HOME/.bazinga_aliases" << EOL
# BAZINGA aliases
alias bz-check='$BAZINGA_DIR/bin/artifact-tracker check'
alias bz-add='$BAZINGA_DIR/bin/artifact-tracker add'
alias bz-reminder='$BAZINGA_DIR/bin/artifact-tracker reminder'
EOL
  
  echo -e "${CYAN}Created aliases in $HOME/.bazinga_aliases${NC}"
  echo -e "${YELLOW}Add this to your .bashrc or .zshrc to use them:${NC}"
  echo -e "source $HOME/.bazinga_aliases"
  
  echo -e "${CYAN}Integration complete!${NC}"
}

# Main command handling
case "$1" in
  add)
    if [ -n "$2" ]; then
      add_artifact "manual_artifact" "${2##*.}" "$(cat $2)" "manual"
    else
      process_artifact_from_clipboard
    fi
    ;;
  check)
    check_clipboard
    ;;
  list)
    list_artifacts "$2"
    ;;
  history)
    analyze_history
    ;;
  track)
    track_claude_chats
    ;;
  reminder)
    reminder_check
    ;;
  mark)
    if [ -n "$2" ]; then
      mark_executed "$2"
    else
      echo -e "${YELLOW}Please specify an artifact checksum${NC}"
    fi
    ;;
  integrate)
    integrate_with_bazinga
    ;;
  --self-reflect)
    SYNC_ID=$(date +%s | md5sum | head -c 16)
    echo -e "${CYAN}Artifact Tracker Synchronization: $SYNC_ID${NC}"
    
    # Create metadata entry
    mkdir -p "$HOME/.bazinga/sync"
    
    # Count artifacts
    artifact_count=$(grep -c "\"name\":" "$DB_FILE" 2>/dev/null || echo "0")
    executed_count=$(grep -c "\"executed\": true" "$DB_FILE" 2>/dev/null || echo "0")
    
    # Store pattern data
    cat > "$HOME/.bazinga/sync/artifacts_$SYNC_ID.json" << EOL
{
  "id": "$SYNC_ID",
  "timestamp": "$(date -Iseconds)",
  "artifacts_total": $artifact_count,
  "artifacts_executed": $executed_count,
  "essence": "The framework recognizes artifacts that have been previously recognized",
  "metadata": {
    "date_generated": "$(date -Iseconds)",
    "location": "$(hostname)",
    "self_reflection": true
  }
}
EOL
    
    echo -e "${GREEN}Artifact database synchronized: $SYNC_ID${NC}"
    exit 0
    ;;
  help|*)
    echo -e "${CYAN}⟨ψ|⟳| BAZINGA Claude Artifact Tracker |ψ⟩${NC}"
    echo ""
    echo -e "Usage: $0 <command> [options]"
    echo ""
    echo -e "Commands:"
    echo -e "  add [file]        Add artifact from clipboard or file"
    echo -e "  check             Check if clipboard content is already in database"
    echo -e "  list [filter]     List all artifacts, optionally filtered"
    echo -e "  history           Analyze command history for artifacts"
    echo -e "  track             Track open Claude chats"
    echo -e "  reminder          Check for pending artifacts to collect"
    echo -e "  mark <checksum>   Mark artifact as executed"
    echo -e "  integrate         Integrate with BAZINGA framework"
    echo -e "  --self-reflect    Synchronize artifact database"
    echo -e "  help              Show this help"
    echo ""
    echo -e "Examples:"
    echo -e "  $0 add                  # Add artifact from clipboard"
    echo -e "  $0 check                # Check if clipboard content exists"
    echo -e "  $0 reminder             # Check for pending artifacts"
    echo -e "  $0 history              # Analyze command history"
    ;;
esac
