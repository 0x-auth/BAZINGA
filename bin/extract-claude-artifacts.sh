#!/bin/bash

# ========================================================
# BAZINGA Optimized Claude Artifact Extraction Workflow
# ========================================================
# This script connects the dots between different extraction systems
# to properly collect and process Claude artifacts related to the
# BAZINGA project across all accounts
# ========================================================

# Set strict error handling
set -e

# Default configuration
DEFAULT_OUTPUT_DIR="$HOME/Downloads/BAZINGA-INDEED/claude-arti"
DEFAULT_ACCOUNTS=("bits.abhi515@gmail.com" "bits.abhi@gmail.com" "samgal2907@gmail.com" "abhi.gymnast@gmail.com" "asnugene@gmail.com")
ADVANCED_EXTRACTOR="$HOME/claude_main/scripts/extract-claude-artifacts.sh"
INSIGHT_EXTRACTOR="$HOME/AmsyPycharm/BAZINGA/bin/bazinga-insight-extractor.sh"
ARTIFACT_SYNC="$HOME/AmsyPycharm/BAZINGA/scripts/bazinga-claude-connector.sh"

# Set colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ========================================================
# Function Definitions
# ========================================================

function display_help() {
    echo -e "${BLUE}BAZINGA Claude Artifact Extraction Workflow${NC}"
    echo "This script properly extracts Claude artifacts relevant to the BAZINGA project"
    echo
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -o, --output DIR         Output directory (default: $DEFAULT_OUTPUT_DIR)"
    echo "  -a, --accounts LIST      Comma-separated list of accounts to extract from"
    echo "  -b, --bazinga            Push artifacts to BAZINGA system"
    echo "  -s, --sync               Sync artifacts to main repository after extraction"
    echo "  -f, --force              Force overwrite of existing files"
    echo "  -v, --verbose            Enable verbose output"
    echo "  -h, --help               Display this help message"
    echo
}

function log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

function log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

function log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

function extract_from_account() {
    local account=$1
    local output_dir=$2
    local use_bazinga=$3
    local force=$4
    local verbose=$5
    
    log_info "Extracting artifacts for account: $account"
    
    # Create output directories if they don't exist
    mkdir -p "$output_dir"
    
    # Prepare extraction options
    local extract_opts=""
    
    if [ "$force" = true ]; then
        extract_opts+=" --force"
    fi
    
    if [ "$verbose" = true ]; then
        extract_opts+=" --verbose"
    fi

    if [ "$use_bazinga" = true ]; then
        extract_opts+=" --bazinga"
    fi
    
    # Run the extractor with proper parameters
    if [ -x "$ADVANCED_EXTRACTOR" ]; then
        log_info "Using advanced extractor with account-specific targeting"
        "$ADVANCED_EXTRACTOR" --account "$account" \
                             --output "$output_dir" \
                             $extract_opts
        
        # Check if extraction was successful
        if [ $? -eq 0 ]; then
            log_info "Successful extraction for account: $account"
            return 0
        else
            log_error "Advanced extraction failed for account: $account"
            return 1
        fi
    else
        log_error "Advanced extractor not found at: $ADVANCED_EXTRACTOR"
        return 1
    fi
}

function process_artifacts() {
    local output_dir=$1
    local account=$2
    local verbose=$3
    
    log_info "Processing artifacts for account: $account"
    
    # Run the insight extractor if available
    if [ -x "$INSIGHT_EXTRACTOR" ]; then
        if [ "$verbose" = true ]; then
            log_info "Running insight extractor on artifacts"
        fi
        
        "$INSIGHT_EXTRACTOR" "$output_dir/$account" --project BAZINGA
        
        if [ $? -ne 0 ]; then
            log_warning "Insight extraction completed with warnings for account: $account"
        fi
    else
        log_warning "Insight extractor not found at: $INSIGHT_EXTRACTOR"
    fi
}

function sync_artifacts() {
    local output_dir=$1
    local verbose=$2
    
    log_info "Syncing artifacts to main repository"
    
    # Run the artifact sync if available
    if [ -x "$ARTIFACT_SYNC" ]; then
        "$ARTIFACT_SYNC" --source "$output_dir" \
                       --target "$HOME/AmsyPycharm/BAZINGA/artifacts/claude_artifacts" \
                       --organize
        
        if [ $? -eq 0 ]; then
            log_info "Successfully synced artifacts to main repository"
        else
            log_error "Failed to sync artifacts to main repository"
            return 1
        fi
    else
        log_warning "Artifact sync script not found at: $ARTIFACT_SYNC"
        return 1
    fi
}

function check_requirements() {
    local missing_req=false
    
    # Check for required scripts
    if [ ! -x "$ADVANCED_EXTRACTOR" ]; then
        log_warning "Advanced extractor not found at: $ADVANCED_EXTRACTOR"
        missing_req=true
    fi
    
    if [ "$missing_req" = true ]; then
        log_warning "Some required components are missing. Extraction may be incomplete."
    fi
}

# ========================================================
# Main Script
# ========================================================

# Parse command line arguments
OUTPUT_DIR="$DEFAULT_OUTPUT_DIR"
ACCOUNTS=("${DEFAULT_ACCOUNTS[@]}")
USE_BAZINGA=false
DO_SYNC=false
FORCE=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -a|--accounts)
            IFS=',' read -ra ACCOUNTS <<< "$2"
            shift 2
            ;;
        -b|--bazinga)
            USE_BAZINGA=true
            shift
            ;;
        -s|--sync)
            DO_SYNC=true
            shift
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            display_help
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            display_help
            exit 1
            ;;
    esac
done

# Display banner
echo -e "${BLUE}=============================================${NC}"
echo -e "${BLUE}    BAZINGA Claude Artifact Extraction    ${NC}"
echo -e "${BLUE}=============================================${NC}"
echo

# Check requirements
check_requirements

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Process each account
for account in "${ACCOUNTS[@]}"; do
    log_info "Processing account: $account"
    
    # Extract artifacts
    extract_from_account "$account" "$OUTPUT_DIR" "$USE_BAZINGA" "$FORCE" "$VERBOSE"
    
    # Process artifacts if extraction was successful
    if [ $? -eq 0 ]; then
        process_artifacts "$OUTPUT_DIR" "$account" "$VERBOSE"
    fi
    
    echo
done

# Sync artifacts if requested
if [ "$DO_SYNC" = true ]; then
    sync_artifacts "$OUTPUT_DIR" "$VERBOSE"
fi

# Print summary
echo -e "${BLUE}=============================================${NC}"
echo -e "${GREEN}Extraction Summary:${NC}"
echo -e "  Output directory: $OUTPUT_DIR"
echo -e "  Accounts processed: ${#ACCOUNTS[@]}"
if [ "$USE_BAZINGA" = true ]; then
    echo -e "  BAZINGA integration: Enabled"
else
    echo -e "  BAZINGA integration: Disabled"
fi
echo -e "${BLUE}=============================================${NC}"

log_info "Extraction workflow completed"