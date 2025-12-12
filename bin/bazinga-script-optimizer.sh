#!/bin/bash
# bazinga-script-optimizer.sh
# Catalogs, analyzes and optimizes BAZINGA scripts

# ANSI colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

# Banner
echo -e "${CYAN}"
echo "⟨ψ|⟳|====================================================|ψ⟩"
echo "            BAZINGA Script Optimizer"
echo "⟨ψ|⟳|====================================================|ψ⟩"
echo -e "${NC}"

# Set default paths
BAZINGA_DIR=${BAZINGA_DIR:-"$HOME/AmsyPycharm/BAZINGA"}
SCRIPTS_DIR="$BAZINGA_DIR/scripts"
BIN_DIR="$BAZINGA_DIR/bin"
OUTPUT_DIR="$BAZINGA_DIR/generated/optimized"

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"
LOG_FILE="$OUTPUT_DIR/script_optimizer_$(date +%Y%m%d%H%M%S).log"

# Define script categories
declare -A CATEGORIES=(
    ["integration"]="*integration* *connector* *claude* *combine*"
    ["cleanup"]="*clean* *fix* *dedupe* *organize*"
    ["analysis"]="*analy* *report* *insight* *extract*"
    ["visual"]="*visual* *svg* *diagram* *plot*"
    ["ssri"]="*ssri* *medical* *timeline*"
    ["trust"]="*trust* *correct* *relationship*"
    ["system"]="*system* *completion* *operation* *startup*"
)

# Function to log messages
log() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

# Function to catalog all scripts
catalog_scripts() {
    log "${BLUE}${BOLD}Cataloging all scripts in the BAZINGA framework...${NC}"
    
    # Find all shell scripts
    ALL_SCRIPTS=$(find "$BAZINGA_DIR" -type f -name "*.sh" 2>/dev/null | sort)
    SCRIPT_COUNT=$(echo "$ALL_SCRIPTS" | wc -l)
    
    log "${GREEN}Found $SCRIPT_COUNT shell scripts${NC}"
    
    # Create catalog file
    CATALOG_FILE="$OUTPUT_DIR/script_catalog.txt"
    echo "# BAZINGA Script Catalog" > "$CATALOG_FILE"
    echo "# Generated: $(date)" >> "$CATALOG_FILE"
    echo "# Total Scripts: $SCRIPT_COUNT" >> "$CATALOG_FILE"
    echo "" >> "$CATALOG_FILE"
    
    # Categorize scripts
    for category in "${!CATEGORIES[@]}"; do
        log "${YELLOW}Cataloging ${category} scripts...${NC}"
        echo "## $category" >> "$CATALOG_FILE"
        
        patterns=${CATEGORIES[$category]}
        for pattern in $patterns; do
            matching=$(echo "$ALL_SCRIPTS" | grep $pattern)
            if [ -n "$matching" ]; then
                echo "$matching" | while read script; do
                    # Extract usage information from script if available
                    usage=$(grep -A 10 "Usage:" "$script" 2>/dev/null | grep -v "^#" | head -1)
                    if [ -z "$usage" ]; then
                        usage=$(grep -A 10 "usage()" "$script" 2>/dev/null | grep -v "^#" | grep -v "^{" | head -1)
                    fi
                    
                    # Get script modification time
                    mod_time=$(stat -f "%Sm" "$script" 2>/dev/null)
                    
                    if [ -n "$usage" ]; then
                        echo "- $script (Last modified: $mod_time) - $usage" >> "$CATALOG_FILE"
                    else
                        echo "- $script (Last modified: $mod_time)" >> "$CATALOG_FILE"
                    fi
                done
            fi
        done
        echo "" >> "$CATALOG_FILE"
    done
    
    log "${GREEN}Script catalog generated: $CATALOG_FILE${NC}"
    return 0
}

# Function to find duplicate scripts
find_duplicates() {
    log "${BLUE}${BOLD}Analyzing scripts for duplicates...${NC}"
    
    DUPLICATES_FILE="$OUTPUT_DIR/duplicate_scripts.txt"
    echo "# BAZINGA Duplicate Scripts Analysis" > "$DUPLICATES_FILE"
    echo "# Generated: $(date)" >> "$DUPLICATES_FILE"
    echo "" >> "$DUPLICATES_FILE"
    
    # Find all shell scripts
    ALL_SCRIPTS=$(find "$BAZINGA_DIR" -type f -name "*.sh" 2>/dev/null)
    
    # Create temporary directory for checksums
    TEMP_DIR=$(mktemp -d)
    
    # Calculate checksums for all scripts
    echo "$ALL_SCRIPTS" | while read script; do
        # Skip empty or non-readable files
        if [ ! -s "$script" ] || [ ! -r "$script" ]; then
            continue
        fi
        
        # Calculate checksum (skip first line to ignore shebang differences)
        checksum=$(tail -n +2 "$script" | md5)
        echo "$checksum $script" >> "$TEMP_DIR/checksums.txt"
    done
    
    # Sort checksums and find duplicates
    if [ -f "$TEMP_DIR/checksums.txt" ]; then
        log "${YELLOW}Identifying duplicate scripts...${NC}"
        
        # Analyze duplicate checksums
        duplicate_count=0
        sort "$TEMP_DIR/checksums.txt" | awk '{print $1}' | uniq -d | while read checksum; do
            echo "## Duplicate script set (checksum: $checksum)" >> "$DUPLICATES_FILE"
            grep "$checksum" "$TEMP_DIR/checksums.txt" | awk '{print "- " $2 " (Last modified: " system("stat -f \"%Sm\" " $2) ")"}' >> "$DUPLICATES_FILE"
            echo "" >> "$DUPLICATES_FILE"
            duplicate_count=$((duplicate_count + 1))
        done
        
        if [ $duplicate_count -eq 0 ]; then
            log "${GREEN}No duplicate scripts found${NC}"
            echo "No duplicate scripts found" >> "$DUPLICATES_FILE"
        else
            log "${YELLOW}Found $duplicate_count sets of duplicate scripts${NC}"
        fi
    else
        log "${RED}Error: Failed to generate checksums${NC}"
    fi
    
    # Clean up temporary directory
    rm -rf "$TEMP_DIR"
    
    log "${GREEN}Duplicate analysis report generated: $DUPLICATES_FILE${NC}"
    return 0
}

# Function to optimize scripts
optimize_scripts() {
    log "${BLUE}${BOLD}Optimizing scripts based on usage analysis...${NC}"
    
    OPTIMIZATION_DIR="$OUTPUT_DIR/optimized_scripts"
    mkdir -p "$OPTIMIZATION_DIR"
    
    # Create script hub that delegates to specialized scripts
    create_delegator_script
    
    # Create optimization report
    OPTIMIZATION_REPORT="$OUTPUT_DIR/optimization_report.md"
    echo "# BAZINGA Script Optimization Report" > "$OPTIMIZATION_REPORT"
    echo "## Generated: $(date)" >> "$OPTIMIZATION_REPORT"
    echo "" >> "$OPTIMIZATION_REPORT"
    echo "## Optimization Actions" >> "$OPTIMIZATION_REPORT"
    echo "" >> "$OPTIMIZATION_REPORT"
    echo "1. **Created unified delegator script** - `bazinga-delegator.sh` to serve as a central command hub" >> "$OPTIMIZATION_REPORT"
    echo "2. **Created script catalog** - `script_catalog.txt` with categorized listing of all scripts" >> "$OPTIMIZATION_REPORT"
    echo "3. **Analyzed script duplicates** - `duplicate_scripts.txt` identifying redundant scripts" >> "$OPTIMIZATION_REPORT"
    echo "" >> "$OPTIMIZATION_REPORT"
    echo "## Usage Recommendations" >> "$OPTIMIZATION_REPORT"
    echo "" >> "$OPTIMIZATION_REPORT"
    echo "### Primary Commands" >> "$OPTIMIZATION_REPORT"
    echo "" >> "$OPTIMIZATION_REPORT"
    echo "```bash" >> "$OPTIMIZATION_REPORT"
    echo "./bazinga-delegator.sh visualize         # Generate framework visualization" >> "$OPTIMIZATION_REPORT"
    echo "./bazinga-delegator.sh trust             # Run trust corrector" >> "$OPTIMIZATION_REPORT"
    echo "./bazinga-delegator.sh glance            # Run activity glance" >> "$OPTIMIZATION_REPORT"
    echo "./bazinga-delegator.sh generate <type>   # Generate artifacts" >> "$OPTIMIZATION_REPORT"
    echo "./bazinga-delegator.sh run <script>      # Run any BAZINGA script by name" >> "$OPTIMIZATION_REPORT"
    echo "```" >> "$OPTIMIZATION_REPORT"
    echo "" >> "$OPTIMIZATION_REPORT"
    
    log "${GREEN}Script optimization completed. See report at: $OPTIMIZATION_REPORT${NC}"
    return 0
}

# Function to create delegator script
create_delegator_script() {
    log "${YELLOW}Creating BAZINGA delegator script...${NC}"
    
    # Create a copy of the bazinga-delegator.sh from our code
    cp "$BAZINGA_DIR/bazinga-delegator.sh" "$OPTIMIZATION_DIR/bazinga-delegator.sh" 2>/dev/null
    
    # If the copy failed, use the template from the delegator
    if [ ! -f "$OPTIMIZATION_DIR/bazinga-delegator.sh" ]; then
        # Create delegator script
        cat > "$OPTIMIZATION_DIR/bazinga-delegator.sh" << 'EOL'
#!/bin/bash
# bazinga-delegator.sh - Offloads tasks to the BAZINGA framework
# Designed to delegate work to existing BAZINGA scripts and components

# ANSI color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Banner
echo -e "${CYAN}"
echo "⟨ψ|⟳|====================================================|ψ⟩"
echo "            BAZINGA Framework Delegator"
echo "⟨ψ|⟳|====================================================|ψ⟩"
echo -e "${NC}"

# Set default paths
BAZINGA_DIR=${BAZINGA_DIR:-"$HOME/AmsyPycharm/BAZINGA"}
SCRIPTS_DIR="$BAZINGA_DIR/scripts"
BIN_DIR="$BAZINGA_DIR/bin"
OUTPUT_DIR="$BAZINGA_DIR/generated"

# Ensure we're in the BAZINGA directory
cd "$BAZINGA_DIR" || {
    echo -e "${RED}Error: Cannot navigate to BAZINGA directory: $BAZINGA_DIR${NC}"
    exit 1
}

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Function to find and execute a script
find_and_execute() {
    local pattern="$1"
    local args="$2"
    
    # First try exact match in bin directory
    if [ -f "$BIN_DIR/$pattern" ]; then
        echo -e "${GREEN}Executing: $BIN_DIR/$pattern $args${NC}"
        "$BIN_DIR/$pattern" $args
        return 0
    fi
    
    # Then try exact match in scripts directory
    if [ -f "$SCRIPTS_DIR/$pattern" ]; then
        echo -e "${GREEN}Executing: $SCRIPTS_DIR/$pattern $args${NC}"
        "$SCRIPTS_DIR/$pattern" $args
        return 0
    fi
    
    # Try to find the script with pattern matching
    local script=$(find "$BIN_DIR" "$SCRIPTS_DIR" -type f -name "*$pattern*" | sort | head -n 1)
    
    if [ -n "$script" ]; then
        echo -e "${GREEN}Found script: $script${NC}"
        echo -e "${GREEN}Executing: $script $args${NC}"
        "$script" $args
        return 0
    fi
    
    echo -e "${RED}No matching script found for: $pattern${NC}"
    return 1
}

# Function to handle the visualization command
handle_visualization() {
    local args="$1"
    
    # Try to find both visualizers
    local py_vis=$(find "$BAZINGA_DIR" -name "*visualizer.py" | head -n 1)
    local js_vis=$(find "$BAZINGA_DIR" -name "*svg-generator.js" | head -n 1)
    
    if [ -n "$py_vis" ]; then
        echo -e "${GREEN}Executing Python visualizer: $py_vis${NC}"
        python3 "$py_vis" $args
        return 0
    elif [ -n "$js_vis" ]; then
        echo -e "${GREEN}Executing JavaScript visualizer: $js_vis${NC}"
        node "$js_vis" $args
        return 0
    else
        echo -e "${YELLOW}No visualizer found, create one with: generate svg${NC}"
        return 1
    fi
}

# Function to handle the trust command
handle_trust() {
    local args="$1"
    
    # Try to find trust corrector
    local trust_script=$(find "$BAZINGA_DIR" -name "*trust_corrector.py" | head -n 1)
    
    if [ -n "$trust_script" ]; then
        echo -e "${GREEN}Executing Trust Corrector: $trust_script${NC}"
        python3 "$trust_script" $args
        return 0
    else
        echo -e "${RED}No Trust Corrector script found${NC}"
        return 1
    fi
}

# Function to handle the glance command
handle_glance() {
    local args="$1"
    
    # Try to find activity glance script
    local glance_script=$(find "$SCRIPTS_DIR" -name "*activity-glance*.sh" | sort | head -n 1)
    
    if [ -n "$glance_script" ]; then
        echo -e "${GREEN}Executing Activity Glance: $glance_script${NC}"
        "$glance_script" $args
        return 0
    else
        echo -e "${RED}No Activity Glance script found${NC}"
        return 1
    fi
}

# Function to handle the generate command
handle_generate() {
    local type="$1"
    local args="${@:2}"
    
    case "$type" in
        svg)
            find_and_execute "*svg-generator*" "$args"
            ;;
        dashboard)
            find_and_execute "*dashboard*generator*" "$args"
            ;;
        prompt)
            find_and_execute "*prompt*" "$args"
            ;;
        script)
            find_and_execute "*script*generator*" "$args"
            ;;
        *)
            echo -e "${RED}Unknown generation type: $type${NC}"
            echo -e "${YELLOW}Available types: svg, dashboard, prompt, script${NC}"
            return 1
            ;;
    esac
}

# Show help if no arguments
if [ $# -eq 0 ]; then
    echo -e "${BOLD}Usage:${NC} $0 [command] [options]"
    echo
    echo -e "${BOLD}Commands:${NC}"
    echo -e "  ${YELLOW}run${NC} <script> [args]        Run any BAZINGA script by name or pattern"
    echo -e "  ${YELLOW}visualize${NC} [args]          Generate framework visualization"
    echo -e "  ${YELLOW}trust${NC} [args]              Run trust corrector"
    echo -e "  ${YELLOW}glance${NC} [minutes]          Run activity glance"
    echo -e "  ${YELLOW}generate${NC} <type> [args]    Generate artifacts (svg, dashboard, prompt, script)"
    echo -e "  ${YELLOW}optimize${NC}                  Run script optimization and deduplication"
    echo
    echo -e "${BOLD}Examples:${NC}"
    echo -e "  $0 run claude-connector"
    echo -e "  $0 visualize"
    echo -e "  $0 trust --reflect 'I keep trying to explain'"
    echo -e "  $0 glance 60"
    echo -e "  $0 generate svg"
    echo -e "  $0 optimize"
    exit 0
fi

# Process commands
case "$1" in
    run)
        if [ -z "$2" ]; then
            echo -e "${RED}Error: No script specified${NC}"
            echo -e "${YELLOW}Usage: $0 run <script> [args]${NC}"
            exit 1
        fi
        find_and_execute "$2" "${@:3}"
        ;;
    visualize)
        handle_visualization "${@:2}"
        ;;
    trust)
        handle_trust "${@:2}"
        ;;
    glance)
        handle_glance "${@:2}"
        ;;
    generate)
        if [ -z "$2" ]; then
            echo -e "${RED}Error: No generation type specified${NC}"
            echo -e "${YELLOW}Usage: $0 generate <type> [args]${NC}"
            echo -e "${YELLOW}Available types: svg, dashboard, prompt, script${NC}"
            exit 1
        fi
        handle_generate "${@:2}"
        ;;
    optimize)
        find_and_execute "script-optimizer" "${@:2}"
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        echo -e "${YELLOW}Available commands: run, visualize, trust, glance, generate, optimize${NC}"
        exit 1
        ;;
esac

echo -e "${CYAN}"
echo "⟨ψ|⟳|====================================================|ψ⟩"
echo "            BAZINGA Delegation Complete"
echo "⟨ψ|⟳|====================================================|ψ⟩"
echo -e "${NC}"

exit 0
EOL
    fi
    
    # Make the script executable
    chmod +x "$OPTIMIZATION_DIR/bazinga-delegator.sh"
    
    # Create symbolic link to the original BAZINGA directory
    ln -sf "$OPTIMIZATION_DIR/bazinga-delegator.sh" "$BAZINGA_DIR/bazinga-delegator.sh" 2>/dev/null
    
    log "${GREEN}Delegator script created: $OPTIMIZATION_DIR/bazinga-delegator.sh${NC}"
    log "${GREEN}Symbolically linked to: $BAZINGA_DIR/bazinga-delegator.sh${NC}"
    return 0
}

# Main execution
log "${BLUE}${BOLD}Starting BAZINGA Script Optimizer${NC}"
log "${YELLOW}BAZINGA Directory: $BAZINGA_DIR${NC}"
log "${YELLOW}Output Directory: $OUTPUT_DIR${NC}"

# Execute main functions
catalog_scripts
find_duplicates
optimize_scripts

# Create a symbolic link to run the script optimizer again
OPTIMIZER_SYMLINK="$BAZINGA_DIR/bazinga-optimize.sh"
ln -sf "$0" "$OPTIMIZER_SYMLINK" 2>/dev/null
chmod +x "$OPTIMIZER_SYMLINK" 2>/dev/null

log "${BLUE}${BOLD}Script optimization process complete${NC}"
log "${GREEN}You can run the optimizer again using: $OPTIMIZER_SYMLINK${NC}"
log "${GREEN}Use the delegator script for all future operations: $BAZINGA_DIR/bazinga-delegator.sh${NC}"

exit 0
