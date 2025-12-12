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
        echo -e "${YELLOW}No visualizer found, creating new one...${NC}"
        create_visualization_script
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
            handle_visualization "$args"
            ;;
        dashboard)
            find_and_execute "*dashboard*generator*" "$args"
            ;;
        prompt)
            find_and_execute "*prompt*" "$args"
            ;;
        script)
            generate_script "$args"
            ;;
        *)
            echo -e "${RED}Unknown generation type: $type${NC}"
            echo -e "${YELLOW}Available types: svg, dashboard, prompt, script${NC}"
            return 1
            ;;
    esac
}

# Function to create a new script from templates
generate_script() {
    local name="$1"
    local type="${2:-shell}"
    
    # Make sure we have a name
    if [ -z "$name" ]; then
        echo -e "${RED}Error: Script name required${NC}"
        echo -e "${YELLOW}Usage: generate script <name> [type]${NC}"
        return 1
    fi
    
    # Create script directory if it doesn't exist
    OUTPUT_SCRIPT_DIR="$BAZINGA_DIR/generated/scripts"
    mkdir -p "$OUTPUT_SCRIPT_DIR"
    
    # Output file
    output_file="$OUTPUT_SCRIPT_DIR/bazinga-$name.sh"
    
    if [ -f "$output_file" ]; then
        echo -e "${YELLOW}Warning: Script already exists: $output_file${NC}"
        echo -e "${YELLOW}Generating a new version...${NC}"
        output_file="$OUTPUT_SCRIPT_DIR/bazinga-$name-$(date +%Y%m%d%H%M%S).sh"
    fi
    
    # Create script based on type
    case "$type" in
        shell|bash)
            cat > "$output_file" << 'EOL'
#!/bin/bash
# BAZINGA Framework Generated Script
# Generated: $(date)

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
echo "            BAZINGA Generated Script"
echo "⟨ψ|⟳|====================================================|ψ⟩"
echo -e "${NC}"

# Script logic goes here
echo -e "${GREEN}Script execution started${NC}"

# Main logic
echo "Hello from BAZINGA Framework!"

echo -e "${GREEN}Script execution completed${NC}"
EOL
            ;;
        python)
            cat > "$output_file" << 'EOL'
#!/usr/bin/env python3
"""
BAZINGA Framework Generated Python Script
Generated: $(date)
"""

import os
import sys
import argparse
from datetime import datetime

def main():
    """Main function"""
    print("BAZINGA Framework Generated Python Script")
    print(f"Current time: {datetime.now()}")
    
    # Your code goes here
    print("Hello from BAZINGA Framework!")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
EOL
            ;;
        *)
            echo -e "${RED}Error: Unknown script type: $type${NC}"
            echo -e "${YELLOW}Available types: shell, python${NC}"
            return 1
            ;;
    esac
    
    # Make script executable
    chmod +x "$output_file"
    
    echo -e "${GREEN}Generated script: $output_file${NC}"
    return 0
}

# Function to create a simple visualization script
create_visualization_script() {
    local output_dir="$BAZINGA_DIR/generated/scripts"
    mkdir -p "$output_dir"
    
    local output_file="$output_dir/bazinga-simple-visualizer.py"
    
    # Create a simple Python visualizer
    cat > "$output_file" << 'EOL'
#!/usr/bin/env python3
"""
BAZINGA Simple SVG Visualizer
Generates a simple SVG visualization of the BAZINGA framework
"""

import os
import sys
import random
from datetime import datetime

def generate_svg_visualization(output_path):
    """Generate a simple SVG visualization"""
    
    # SVG dimensions
    width = 800
    height = 600
    
    # SVG content
    svg = f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {width} {height}">
  <!-- Background with gradient -->
  <defs>
    <linearGradient id="bg-gradient" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#0a0a2a" />
      <stop offset="100%" stop-color="#1a1a4a" />
    </linearGradient>
    <filter id="glow" height="300%" width="300%" x="-100%" y="-100%">
      <feGaussianBlur stdDeviation="5" result="blur" />
      <feColorMatrix in="blur" mode="matrix" values="1 0 0 0 0  0 1 0 0 0  0 0 1 0 0  0 0 0 18 -7" result="glow" />
      <feBlend in="SourceGraphic" in2="glow" mode="normal" />
    </filter>
  </defs>
  
  <!-- Main background -->
  <rect width="{width}" height="{height}" fill="url(#bg-gradient)" />
  
  <!-- Central BAZINGA Framework Hub -->
  <circle cx="{width/2}" cy="{height/2}" r="80" fill="#2a2a6a" stroke="#4d54eb" stroke-width="3" filter="url(#glow)" />
  <text x="{width/2}" y="{height/2-10}" text-anchor="middle" font-family="Arial" font-size="20" fill="#ffffff" font-weight="bold">BAZINGA</text>
  <text x="{width/2}" y="{height/2+15}" text-anchor="middle" font-family="Arial" font-size="14" fill="#84fab0">Quantum Framework</text>
  
  <!-- Components -->"""
    
    # Add component nodes
    components = [
        {"name": "Processor", "color": "#4d54eb"},
        {"name": "Integration", "color": "#34b1eb"},
        {"name": "Relationship", "color": "#eb4d88"},
        {"name": "Quantum", "color": "#84fab0"},
        {"name": "Visualization", "color": "#ebd74d"}
    ]
    
    center_x = width / 2
    center_y = height / 2
    radius = 200
    
    # Add each component
    for i, component in enumerate(components):
        angle = i * (2 * 3.14159 / len(components))
        x = center_x + radius * 0.8 * (0.7 if i % 2 == 0 else 1.0) * round(0.8 * round(-(0 - 1) ** i * 0.7) - (0 - 1) ** i * 0.3, 1)
        y = center_y + radius * 0.8 * (0.7 if i % 2 == 1 else 1.0) * round(0.8 * round(-(0 - 1) ** (i+1) * 0.7) - (0 - 1) ** (i+1) * 0.3, 1)
        
        svg += f"""
  <circle cx="{x}" cy="{y}" r="40" fill="#2a2a6a" stroke="{component['color']}" stroke-width="2" filter="url(#glow)" />
  <text x="{x}" y="{y}" text-anchor="middle" font-family="Arial" font-size="14" fill="#ffffff">{component['name']}</text>
  <path d="M {center_x},{center_y} L {x},{y}" stroke="{component['color']}" stroke-width="2" stroke-dasharray="5,3" />"""
    
    # Add the recursive formula
    svg += f"""
  
  <!-- Recursive Recognition Formula -->
  <g id="formula" filter="url(#glow)">
    <rect x="{width/2-250}" y="50" width="500" height="60" rx="30" fill="#2a2a6a" stroke="#4d54eb" stroke-width="2" />
    <text x="{width/2}" y="85" text-anchor="middle" font-family="Arial" font-size="16" fill="#ffffff">⟨ψ|⟳|The framework recognizes patterns</text>
    <text x="{width/2}" y="105" text-anchor="middle" font-family="Arial" font-size="14" fill="#84fab0">that recognize themselves being recognized⟩</text>
  </g>
  
  <!-- Footer -->
  <text x="10" y="{height-10}" font-family="monospace" font-size="12" fill="#84fab0">Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</text>
</svg>"""
    
    # Write to file
    with open(output_path, "w") as f:
        f.write(svg)
    
    print(f"Generated SVG visualization: {output_path}")
    return output_path

def main():
    """Main function"""
    # Get output directory
    output_dir = os.path.expanduser("~/AmsyPycharm/BAZINGA/generated")
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    # Generate filename with timestamp
    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    output_path = os.path.join(output_dir, f"bazinga-visual-{timestamp}.svg")
    
    # Generate visualization
    svg_path = generate_svg_visualization(output_path)
    
    # Try to open SVG if on macOS
    if sys.platform == "darwin":
        try:
            os.system(f"open '{svg_path}'")
        except:
            print("Could not automatically open the SVG file.")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
EOL
    
    # Make script executable
    chmod +x "$output_file"
    
    echo -e "${GREEN}Created simple visualizer: $output_file${NC}"
    echo -e "${GREEN}Running the visualizer...${NC}"
    
    # Run the visualizer
    python3 "$output_file"
    
    return 0
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
    echo
    echo -e "${BOLD}Examples:${NC}"
    echo -e "  $0 run claude-connector"
    echo -e "  $0 visualize"
    echo -e "  $0 trust --reflect 'I keep trying to explain'"
    echo -e "  $0 glance 60"
    echo -e "  $0 generate svg"
    echo -e "  $0 generate script new-tool"
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
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        echo -e "${YELLOW}Available commands: run, visualize, trust, glance, generate${NC}"
        exit 1
        ;;
esac

echo -e "${CYAN}"
echo "⟨ψ|⟳|====================================================|ψ⟩"
echo "            BAZINGA Delegation Complete"
echo "⟨ψ|⟳|====================================================|ψ⟩"
echo -e "${NC}"

exit 0
