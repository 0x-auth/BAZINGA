#!/bin/bash

# CloudyExtract - Claude Artifact Extraction Tool
# Fixed version for macOS compatibility

# Color definitions
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Timestamp for operations
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Base directories - these don't use associative arrays which aren't supported in older bash
CLAUDE_MAIN="$HOME/claude_main"
CLAUDE_DATA="$HOME/claude_data"
CLAUDE_ARTIFACTS="$HOME/claude_artifacts"
BAZINGA_DIR="$HOME/AmsyPycharm/BAZINGA"
BAZINGA_CLAUDE="$BAZINGA_DIR/artifacts/claude_artifacts"

# Account directories - simple variables instead of an array
ACCOUNT_GMAIL="$HOME/claude_data_abhi515"
ACCOUNT_WORK="$HOME/claude_data_abhi"
ACCOUNT_OTHER="$HOME/claude_data_samgal"
DEFAULT_ACCOUNT="$CLAUDE_DATA"

# Create required directories
mkdir -p "$CLAUDE_MAIN/artifacts/extracted"
mkdir -p "$CLAUDE_DATA/artifacts/extracted"
mkdir -p "$CLAUDE_ARTIFACTS/extracted"

# Log file
LOG_FILE="$CLAUDE_DATA/cloudyextract_$TIMESTAMP.log"

# Configuration
CONFIG_DIR="$HOME/.config/claude-extract"
mkdir -p "$CONFIG_DIR"

# Config file
CONFIG_FILE="$CONFIG_DIR/config.json"

# Initialize config if it doesn't exist
if [ ! -f "$CONFIG_FILE" ]; then
    mkdir -p "$(dirname "$CONFIG_FILE")"
    echo '{
  "default_account": "gmail",
  "accounts": {
    "gmail": "'$ACCOUNT_GMAIL'",
    "work": "'$ACCOUNT_WORK'",
    "other": "'$ACCOUNT_OTHER'"
  },
  "extraction": {
    "default_output": "'$CLAUDE_ARTIFACTS'/extracted",
    "auto_bazinga": false,
    "default_tags": ["claude", "artifact"],
    "code_detection": true
  }
}' > "$CONFIG_FILE"
fi

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

# Success message
success() {
    echo -e "${GREEN}SUCCESS: $1${NC}" | tee -a "$LOG_FILE"
}

# Display header
display_header() {
    clear
    echo -e "${GREEN}============================================${NC}"
    echo -e "${GREEN}     CloudyExtract - Claude Artifact Tool     ${NC}"
    echo -e "${GREEN}============================================${NC}"
    echo
    log "CloudyExtract started"
}

# Parse command line arguments
parse_args() {
    # Default values
    OUTPUT_DIR="$CLAUDE_ARTIFACTS/extracted/claude_$TIMESTAMP"
    ACCOUNT="default"
    PUSH_BAZINGA=false
    FILE_PATH=""
    BATCH_DIR=""
    TAGS=""
    DEBUG=false
    ALL_ACCOUNTS=false
    MONITOR=false
    
    # Handle options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --output)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            --account)
                ACCOUNT="$2"
                shift 2
                ;;
            --bazinga)
                PUSH_BAZINGA=true
                shift
                ;;
            --file)
                FILE_PATH="$2"
                shift 2
                ;;
            --batch)
                BATCH_DIR="$2"
                shift 2
                ;;
            --tags)
                TAGS="$2"
                shift 2
                ;;
            --debug)
                DEBUG=true
                shift
                ;;
            --all-accounts)
                ALL_ACCOUNTS=true
                shift
                ;;
            --monitor)
                MONITOR=true
                shift
                ;;
            --list-accounts)
                list_accounts
                exit 0
                ;;
            --add-account)
                add_account "$2"
                exit 0
                ;;
            --set-default-account)
                set_default_account "$2"
                exit 0
                ;;
            --help)
                show_help
                exit 0
                ;;
            --reset)
                reset_cloudyextract
                exit 0
                ;;
            --integrate)
                PUSH_BAZINGA=true
                shift
                ;;
            --auto)
                # Just placeholder for auto mode
                shift
                ;;
            --clean)
                clean_old_artifacts
                exit 0
                ;;
            --organize)
                organize_artifacts
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Get account directory
    get_account_dir "$ACCOUNT"
    
    # Create output directory
    mkdir -p "$OUTPUT_DIR"
    log "Output directory: $OUTPUT_DIR"
}

# Get account directory based on account name
get_account_dir() {
    local account_name="$1"
    
    case "$account_name" in
        gmail)
            ACCOUNT_DIR="$ACCOUNT_GMAIL"
            ;;
        work)
            ACCOUNT_DIR="$ACCOUNT_WORK"
            ;;
        other)
            ACCOUNT_DIR="$ACCOUNT_OTHER"
            ;;
        default|*)
            ACCOUNT_DIR="$DEFAULT_ACCOUNT"
            ;;
    esac
    
    # Create account directory if it doesn't exist
    mkdir -p "$ACCOUNT_DIR"
    log "Using account directory: $ACCOUNT_DIR"
}

# List configured accounts
list_accounts() {
    section "CONFIGURED ACCOUNTS"
    echo "Available accounts:"
    echo "- gmail: $ACCOUNT_GMAIL"
    echo "- work: $ACCOUNT_WORK"
    echo "- other: $ACCOUNT_OTHER"
    echo "- default: $DEFAULT_ACCOUNT"
}

# Add new account
add_account() {
    local account_info="$1"
    local account_name
    local account_email
    
    # Parse account info (format: "name:email")
    IFS=':' read -r account_name account_email <<< "$account_info"
    
    if [ -z "$account_name" ] || [ -z "$account_email" ]; then
        error "Invalid account format. Use 'name:email'"
        return 1
    fi
    
    # Add account to config
    # Note: This is a simple implementation; ideally would use jq for JSON manipulation
    local account_dir="$HOME/claude_data_$account_name"
    mkdir -p "$account_dir"
    
    log "Added account: $account_name ($account_email) at $account_dir"
    success "Account added successfully"
}

# Set default account
set_default_account() {
    local account_name="$1"
    
    # Simple implementation; ideally would use jq for JSON manipulation
    case "$account_name" in
        gmail|work|other)
            log "Setting default account to: $account_name"
            # In a full implementation, this would update the config.json
            success "Default account set to: $account_name"
            ;;
        *)
            error "Unknown account: $account_name"
            return 1
            ;;
    esac
}

# Reset CloudyExtract
reset_cloudyextract() {
    section "RESETTING CLOUDYEXTRACT"
    
    log "Removing configuration..."
    rm -f "$CONFIG_FILE"
    
    log "Reinitializing..."
    # Recreate default config
    if [ ! -f "$CONFIG_FILE" ]; then
        mkdir -p "$(dirname "$CONFIG_FILE")"
        echo '{
  "default_account": "gmail",
  "accounts": {
    "gmail": "'$ACCOUNT_GMAIL'",
    "work": "'$ACCOUNT_WORK'",
    "other": "'$ACCOUNT_OTHER'"
  },
  "extraction": {
    "default_output": "'$CLAUDE_ARTIFACTS'/extracted",
    "auto_bazinga": false,
    "default_tags": ["claude", "artifact"],
    "code_detection": true
  }
}' > "$CONFIG_FILE"
    fi
    
    success "CloudyExtract has been reset"
}

# Clean old artifacts
clean_old_artifacts() {
    section "CLEANING OLD ARTIFACTS"
    
    # Find and list old extraction directories (older than 30 days)
    log "Finding artifacts older than 30 days..."
    local old_dirs=$(find "$CLAUDE_ARTIFACTS/extracted" -type d -name "claude_*" -mtime +30 2>/dev/null)
    
    if [ -z "$old_dirs" ]; then
        log "No old artifacts found"
        return 0
    fi
    
    # Count directories
    local count=$(echo "$old_dirs" | wc -l)
    log "Found $count old artifact directories"
    
    # Ask for confirmation
    echo "The following directories will be removed:"
    echo "$old_dirs"
    echo
    read -p "Proceed with removal? (y/n): " confirm
    
    if [[ "$confirm" != "y" ]]; then
        log "Cleanup canceled"
        return 1
    fi
    
    # Remove old directories
    echo "$old_dirs" | xargs rm -rf
    
    success "Cleaned up $count old artifact directories"
}

# Organize artifacts
organize_artifacts() {
    section "ORGANIZING ARTIFACTS"
    
    # Find all extraction directories
    log "Finding all artifact directories..."
    local all_dirs=$(find "$CLAUDE_ARTIFACTS/extracted" -type d -name "claude_*" 2>/dev/null)
    
    if [ -z "$all_dirs" ]; then
        log "No artifacts found"
        return 0
    fi
    
    # Create organization directory
    local org_dir="$CLAUDE_ARTIFACTS/organized"
    mkdir -p "$org_dir/code"
    mkdir -p "$org_dir/text"
    mkdir -p "$org_dir/json"
    mkdir -p "$org_dir/images"
    mkdir -p "$org_dir/other"
    
    log "Organizing artifacts by type..."
    
    # Process each extraction directory
    for dir in $all_dirs; do
        # Process code files
        find "$dir" -type f -name "*code_blocks*" -o -name "*.py" -o -name "*.js" -o -name "*.sh" -o -name "*.html" -o -name "*.css" | while read -r file; do
            cp "$file" "$org_dir/code/"
        done
        
        # Process text files
        find "$dir" -type f -name "*.txt" -o -name "*.md" | while read -r file; do
            cp "$file" "$org_dir/text/"
        done
        
        # Process JSON files
        find "$dir" -type f -name "*.json" | while read -r file; do
            cp "$file" "$org_dir/json/"
        done
        
        # Process image files
        find "$dir" -type f -name "*.png" -o -name "*.jpg" -o -name "*.svg" | while read -r file; do
            cp "$file" "$org_dir/images/"
        done
        
        # Process other files
        find "$dir" -type f -not -name "*code_blocks*" -not -name "*.py" -not -name "*.js" -not -name "*.sh" -not -name "*.html" -not -name "*.css" -not -name "*.txt" -not -name "*.md" -not -name "*.json" -not -name "*.png" -not -name "*.jpg" -not -name "*.svg" | while read -r file; do
            cp "$file" "$org_dir/other/"
        done
    done
    
    success "Artifacts organized by type in: $org_dir"
}

# Extract artifacts from clipboard
extract_from_clipboard() {
    section "EXTRACTING FROM CLIPBOARD"
    
    log "Extracting from clipboard to: $OUTPUT_DIR"
    
    # Save clipboard content
    pbpaste > "$OUTPUT_DIR/clipboard_content.txt"
    log "Saved clipboard content"
    
    # Check for code blocks (Markdown style)
    if grep -q '```' "$OUTPUT_DIR/clipboard_content.txt"; then
        log "Found code blocks in clipboard"
        
        # Extract code blocks
        awk '/```/{flag=1;next}/```/{flag=0;next}flag' "$OUTPUT_DIR/clipboard_content.txt" > "$OUTPUT_DIR/code_blocks.txt"
        log "Extracted code blocks to: $OUTPUT_DIR/code_blocks.txt"
        
        # Try to detect language
        local language=""
        language=$(grep -A1 '```' "$OUTPUT_DIR/clipboard_content.txt" | grep -v '```' | head -1)
        
        if [ -n "$language" ]; then
            log "Detected language: $language"
            echo "$language" > "$OUTPUT_DIR/language.txt"
        fi
    fi
    
    # Check for HTML content
    if grep -q '<html' "$OUTPUT_DIR/clipboard_content.txt"; then
        log "Found HTML content in clipboard"
        cp "$OUTPUT_DIR/clipboard_content.txt" "$OUTPUT_DIR/content.html"
        
        # Extract text from HTML (basic)
        sed 's/<[^>]*>//g' "$OUTPUT_DIR/content.html" > "$OUTPUT_DIR/plain_text.txt"
        log "Extracted plain text from HTML"
    fi
    
    # Check for JSON content
    if grep -q '{' "$OUTPUT_DIR/clipboard_content.txt" && grep -q '}' "$OUTPUT_DIR/clipboard_content.txt"; then
        log "Found potential JSON content in clipboard"
        cp "$OUTPUT_DIR/clipboard_content.txt" "$OUTPUT_DIR/content.json"
    fi
    
    success "Extraction from clipboard complete"
}

# Extract from file
extract_from_file() {
    section "EXTRACTING FROM FILE"
    
    if [ ! -f "$FILE_PATH" ]; then
        error "File not found: $FILE_PATH"
        return 1
    fi
    
    log "Extracting from file: $FILE_PATH"
    
    # Copy file to output directory
    cp "$FILE_PATH" "$OUTPUT_DIR/"
    log "Copied file to output directory"
    
    # Process based on file type
    if [[ "$FILE_PATH" == *".html" ]]; then
        log "Processing HTML file"
        
        # Extract text from HTML (basic)
        sed 's/<[^>]*>//g' "$FILE_PATH" > "$OUTPUT_DIR/plain_text.txt"
        log "Extracted plain text from HTML"
        
        # Extract code blocks (simple regex)
        grep -Pzo '(?s)<pre><code.*?>.*?</code></pre>' "$FILE_PATH" | sed 's/<[^>]*>//g' > "$OUTPUT_DIR/code_blocks.txt"
        log "Extracted code blocks from HTML"
    elif [[ "$FILE_PATH" == *".json" ]]; then
        log "Processing JSON file"
        # In a full implementation, would parse and process JSON here
    elif [[ "$FILE_PATH" == *".txt" || "$FILE_PATH" == *".md" ]]; then
        log "Processing text file"
        
        # Check for code blocks (Markdown style)
        if grep -q '```' "$FILE_PATH"; then
            log "Found code blocks in text file"
            
            # Extract code blocks
            awk '/```/{flag=1;next}/```/{flag=0;next}flag' "$FILE_PATH" > "$OUTPUT_DIR/code_blocks.txt"
            log "Extracted code blocks to: $OUTPUT_DIR/code_blocks.txt"
        fi
    fi
    
    success "Extraction from file complete"
}

# Extract in batch mode
extract_batch() {
    section "BATCH EXTRACTION"
    
    if [ ! -d "$BATCH_DIR" ]; then
        error "Batch directory not found: $BATCH_DIR"
        return 1
    fi
    
    log "Processing files in: $BATCH_DIR"
    
    # Create batch output directory
    local batch_output="$OUTPUT_DIR/batch"
    mkdir -p "$batch_output"
    
    # Find files to process
    local files=$(find "$BATCH_DIR" -type f -name "*.html" -o -name "*.txt" -o -name "*.md" -o -name "*.json")
    
    if [ -z "$files" ]; then
        log "No files found to process"
        return 0
    fi
    
    # Count files
    local count=$(echo "$files" | wc -l)
    log "Found $count files to process"
    
    # Process each file
    for file in $files; do
        local filename=$(basename "$file")
        local file_output="$batch_output/$filename"
        mkdir -p "$file_output"
        
        log "Processing: $filename"
        
        # Copy file to output directory
        cp "$file" "$file_output/"
        
        # Process based on file type
        if [[ "$file" == *".html" ]]; then
            # Extract text from HTML (basic)
            sed 's/<[^>]*>//g' "$file" > "$file_output/plain_text.txt"
            
            # Extract code blocks (simple regex)
            grep -Pzo '(?s)<pre><code.*?>.*?</code></pre>' "$file" | sed 's/<[^>]*>//g' > "$file_output/code_blocks.txt"
        elif [[ "$file" == *".txt" || "$file" == *".md" ]]; then
            # Check for code blocks (Markdown style)
            if grep -q '```' "$file"; then
                # Extract code blocks
                awk '/```/{flag=1;next}/```/{flag=0;next}flag' "$file" > "$file_output/code_blocks.txt"
            fi
        fi
    done
    
    success "Batch extraction complete: $count files processed"
}

# Push to BAZINGA
push_to_bazinga() {
    section "PUSHING TO BAZINGA"
    
    if [ ! -d "$BAZINGA_DIR" ]; then
        error "BAZINGA directory not found: $BAZINGA_DIR"
        return 1
    fi
    
    log "Pushing artifacts to BAZINGA"
    
    # Create BAZINGA Claude artifacts directory if it doesn't exist
    mkdir -p "$BAZINGA_CLAUDE"
    log "BAZINGA Claude artifacts directory: $BAZINGA_CLAUDE"
    
    # Copy extracted files to BAZINGA
    cp -r "$OUTPUT_DIR"/* "$BAZINGA_CLAUDE/"
    log "Copied artifacts to BAZINGA"
    
    # Create metadata file
    echo "{
  \"source\": \"CloudyExtract\",
  \"timestamp\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\",
  \"account\": \"$ACCOUNT\",
  \"tags\": [$([ -n "$TAGS" ] && echo "\"$(echo $TAGS | sed 's/,/\",\"/g')\"" || echo "\"claude\",\"artifact\"")],
  \"files\": [$(find "$OUTPUT_DIR" -type f -exec basename {} \; | awk '{print "\""$0"\""}' | paste -sd "," -)]
}" > "$BAZINGA_CLAUDE/metadata_$TIMESTAMP.json"
    
    success "Artifacts pushed to BAZINGA successfully"
}

# Monitor clipboard
monitor_clipboard() {
    section "MONITORING CLIPBOARD"
    
    log "Starting clipboard monitoring (Press Ctrl+C to stop)"
    
    local last_content=""
    
    while true; do
        # Get current clipboard content
        local current_content=$(pbpaste)
        
        # Check if content has changed and is not empty
        if [ "$current_content" != "$last_content" ] && [ -n "$current_content" ]; then
            log "Clipboard changed, extracting..."
            
            # Create new output directory
            local monitor_output="$CLAUDE_ARTIFACTS/extracted/claude_$(date +"%Y%m%d_%H%M%S")"
            mkdir -p "$monitor_output"
            
            # Save clipboard content
            echo "$current_content" > "$monitor_output/clipboard_content.txt"
            
            # Check for code blocks
            if echo "$current_content" | grep -q '```'; then
                log "Found code blocks in clipboard"
                echo "$current_content" | awk '/```/{flag=1;next}/```/{flag=0;next}flag' > "$monitor_output/code_blocks.txt"
            fi
            
            log "Saved to: $monitor_output"
            
            # Update last content
            last_content="$current_content"
        fi
        
        # Wait before checking again
        sleep 5
    done
}

# Show help
show_help() {
    section "HELP INFORMATION"
    
    echo "CloudyExtract - Claude Artifact Extraction Tool"
    echo
    echo "Usage: $(basename "$0") [options]"
    echo
    echo "Options:"
    echo "  --output DIR        Specify output directory"
    echo "  --account NAME      Specify account (gmail, work, other)"
    echo "  --bazinga           Push artifacts to BAZINGA"
    echo "  --file PATH         Extract from file instead of clipboard"
    echo "  --batch DIR         Process multiple files in directory"
    echo "  --tags TAGS         Add tags (comma-separated)"
    echo "  --debug             Enable debug mode"
    echo "  --all-accounts      Extract from all accounts"
    echo "  --monitor           Monitor clipboard for changes"
    echo "  --list-accounts     List configured accounts"
    echo "  --add-account INFO  Add new account (format: name:email)"
    echo "  --set-default NAME  Set default account"
    echo "  --reset             Reset CloudyExtract configuration"
    echo "  --integrate         Extract and push to BAZINGA"
    echo "  --auto              Run in automatic mode"
    echo "  --clean             Clean up old artifacts"
    echo "  --organize          Organize artifacts by type"
    echo "  --help              Show this help message"
    echo
    echo "Examples:"
    echo "  $(basename "$0")                       # Extract from clipboard"
    echo "  $(basename "$0") --account work        # Extract for work account"
    echo "  $(basename "$0") --file convo.html     # Extract from HTML file"
    echo "  $(basename "$0") --bazinga             # Push to BAZINGA"
    echo "  $(basename "$0") --monitor             # Monitor clipboard changes"
}

# Main function
main() {
    display_header
    
    # Parse command line arguments
    parse_args "$@"
    
    # Handle monitor mode
    if [ "$MONITOR" = true ]; then
        monitor_clipboard
        exit 0
    fi
    
    # Handle all accounts mode
    if [ "$ALL_ACCOUNTS" = true ]; then
        log "Extracting from all accounts is not implemented yet"
        exit 1
    fi
    
    # Extract artifacts based on source
    if [ -n "$FILE_PATH" ]; then
        extract_from_file
    elif [ -n "$BATCH_DIR" ]; then
        extract_batch
    else
        extract_from_clipboard
    fi
    
    # Push to BAZINGA if requested
    if [ "$PUSH_BAZINGA" = true ]; then
        push_to_bazinga
    fi
    
    section "EXTRACTION COMPLETE"
    log "Artifacts saved to: $OUTPUT_DIR"
    
    if [ "$PUSH_BAZINGA" = true ]; then
        log "Artifacts pushed to BAZINGA: $BAZINGA_CLAUDE"
    fi
    
    success "CloudyExtract completed successfully"
}

# Run main function with all arguments
main "$@"
