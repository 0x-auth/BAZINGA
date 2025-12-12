#!/bin/bash
# bazinga-artifact-tracker.sh - Track Claude artifacts across conversations
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
DB_FILE="$CLAUDE_DIR/artifacts_db.json"

# Ensure directories exist
mkdir -p "$CLAUDE_DIR"

# Initialize database if it doesn't exist
if [ ! -f "$DB_FILE" ]; then
  cat > "$DB_FILE" << EOL
{
  "artifacts": [],
  "last_updated": "$(date -Iseconds)"
}
EOL
fi

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
  
  echo -e "${GREEN}Added artifact: $artifact_name (${checksum:0:8})${NC}"
  echo -e "${CYAN}Saved to: $artifact_file${NC}"
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

# Function to process Claude artifact from clipboard
process_artifact_from_clipboard() {
  if ! command -v pbpaste &> /dev/null; then
    echo -e "${RED}pbpaste command not found. This feature requires macOS.${NC}"
    echo -e "${YELLOW}For Linux, you can install xclip and modify this script.${NC}"
    return 1
  fi
  
  local clipboard_content=$(pbpaste)
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
  
  # Extract other code artifacts
  for lang in javascript typescript json html css; do
    if echo "$clipboard_content" | grep -q "^```$lang"; then
      local artifact_content=$(echo "$clipboard_content" | sed -n "/^```$lang/,/^```/ p" | sed '1d;$d')
      local artifact_name="${lang}_script_$(date +%Y%m%d)"
      local ext=$lang
      
      if [ "$lang" = "javascript" ]; then ext="js"; fi
      if [ "$lang" = "typescript" ]; then ext="ts"; fi
      
      add_artifact "$artifact_name" "$ext" "$artifact_content" "$chat_id"
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

# Function to search artifacts by content
search_artifacts() {
  local search_term="$1"
  
  echo -e "${CYAN}Searching artifacts for: $search_term${NC}"
  
  for file in "$CLAUDE_DIR"/*; do
    if [ -f "$file" ] && grep -q "$search_term" "$file"; then
      local filename=$(basename "$file")
      local checksum="${filename##*_}"
      checksum="${checksum%%.*}"
      echo -e "${GREEN}Match found in: $filename${NC}"
      
      # Show context of match
      grep -n --color=always -A 2 -B 2 "$search_term" "$file"
      echo ""
    fi
  done
}

# Function to check if artifact exists by content
check_artifact_exists() {
  local content="$1"
  local checksum=$(calculate_checksum "$content")
  
  if grep -q "\"checksum\": \"$checksum\"" "$DB_FILE"; then
    # Extract artifact details
    if command -v jq &> /dev/null; then
      local artifact_details=$(jq -r ".artifacts[] | select(.checksum == \"$checksum\") | \"Name: \(.name)\nType: \(.type)\nAdded: \(.added)\nExecuted: \(.executed)\"" "$DB_FILE")
      echo -e "${GREEN}Artifact already exists:${NC}"
      echo -e "$artifact_details"
    else
      echo -e "${GREEN}Artifact with checksum ${checksum:0:8} already exists${NC}"
    fi
    return 0
  else
    echo -e "${YELLOW}Artifact does not exist in database${NC}"
    return 1
  fi
}

# Function to check clipboard content without adding
check_clipboard() {
  if ! command -v pbpaste &> /dev/null; then
    echo -e "${RED}pbpaste command not found. This feature requires macOS.${NC}"
    return 1
  fi
  
  local clipboard_content=$(pbpaste)
  
  # Try to detect artifact type
  if echo "$clipboard_content" | grep -q "^```bash"; then
    echo -e "${CYAN}Detected bash script in clipboard${NC}"
    local content=$(echo "$clipboard_content" | sed -n '/^```bash/,/^```/ p' | sed '1d;$d')
    check_artifact_exists "$content"
  elif echo "$clipboard_content" | grep -q "^```python"; then
    echo -e "${CYAN}Detected Python script in clipboard${NC}"
    local content=$(echo "$clipboard_content" | sed -n '/^```python/,/^```/ p' | sed '1d;$d')
    check_artifact_exists "$content"
  elif echo "$clipboard_content" | grep -q "⟨ψ|⟳|"; then
    echo -e "${CYAN}Detected BAZINGA pattern in clipboard${NC}"
    check_artifact_exists "$clipboard_content"
  else
    echo -e "${YELLOW}No recognizable artifact found in clipboard${NC}"
    return 1
  fi
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
  search)
    if [ -n "$2" ]; then
      search_artifacts "$2"
    else
      echo -e "${YELLOW}Please specify a search term${NC}"
    fi
    ;;
  mark)
    if [ -n "$2" ]; then
      mark_executed "$2"
    else
      echo -e "${YELLOW}Please specify an artifact checksum${NC}"
    fi
    ;;
  help|*)
    echo -e "${CYAN}⟨ψ|⟳| BAZINGA Claude Artifact Tracker |ψ⟩${NC}"
    echo ""
    echo -e "Usage: $0 <command> [options]"
    echo ""
    echo -e "Commands:"
    echo -e "  add [file]     Add artifact from clipboard or file"
    echo -e "  check          Check if clipboard content is already in database"
    echo -e "  list [filter]  List all artifacts, optionally filtered"
    echo -e "  search <term>  Search artifacts by content"
    echo -e "  mark <checksum> Mark artifact as executed"
    echo -e "  help           Show this help"
    echo ""
    echo -e "Examples:"
    echo -e "  $0 add                  # Add artifact from clipboard"
    echo -e "  $0 add script.sh        # Add artifact from file"
    echo -e "  $0 check                # Check if clipboard content exists"
    echo -e "  $0 list bash            # List all bash artifacts"
    echo -e "  $0 search \"pattern\"     # Search artifacts for pattern"
    echo -e "  $0 mark a1b2c3d4        # Mark artifact as executed"
    ;;
esac
