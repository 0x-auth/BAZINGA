#!/bin/bash
# bazinga-dashboard-connector.sh
# Connects visualization components with the BAZINGA framework

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Banner
echo -e "${CYAN}"
echo "===================================================="
echo "  ⟨ψ|⟳|BAZINGA Framework Visualization Connector⟩"
echo "===================================================="
echo -e "${NC}"

# Set default paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BAZINGA_DIR=${BAZINGA_DIR:-"$HOME/AmsyPycharm/BAZINGA"}
GENERATED_DIR="$BAZINGA_DIR/generated"
DASHBOARD_DIR="$GENERATED_DIR/dashboard"

# Parse arguments
REFRESH_DATA=false
FORCE_REBUILD=false
FULL_SCAN=true
DASHBOARD_INTEGRATION=true

function show_help {
    echo -e "${YELLOW}Usage: $0 [options]${NC}"
    echo "Options:"
    echo "  -h, --help                 Show this help message"
    echo "  -r, --refresh              Refresh data without scanning"
    echo "  -f, --force                Force rebuild of all visualizations"
    echo "  -n, --no-scan              Skip file system scanning"
    echo "  -d, --no-dashboard         Skip dashboard integration"
    echo "  -p, --path <path>          Set BAZINGA directory path"
    echo "  -o, --output <path>        Set output directory path"
    exit 0
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            ;;
        -r|--refresh)
            REFRESH_DATA=true
            ;;
        -f|--force)
            FORCE_REBUILD=true
            ;;
        -n|--no-scan)
            FULL_SCAN=false
            ;;
        -d|--no-dashboard)
            DASHBOARD_INTEGRATION=false
            ;;
        -p|--path)
            BAZINGA_DIR="$2"
            shift
            ;;
        -o|--output)
            GENERATED_DIR="$2"
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_help
            ;;
    esac
    shift
done

# Verify paths
if [ ! -d "$BAZINGA_DIR" ]; then
    echo -e "${RED}Error: BAZINGA directory not found: $BAZINGA_DIR${NC}"
    exit 1
fi

# Create directories if they don't exist
mkdir -p "$GENERATED_DIR"
mkdir -p "$DASHBOARD_DIR"

echo -e "${BLUE}Using BAZINGA directory: ${NC}$BAZINGA_DIR"
echo -e "${BLUE}Output directory: ${NC}$GENERATED_DIR"

# Check for existing scripts
PY_VISUALIZER="$BAZINGA_DIR/bazinga_visualizer.py"
JS_VISUALIZER="$BAZINGA_DIR/bazinga-svg-generator.js"
DASHBOARD_GENERATOR="$BAZINGA_DIR/bazinga_dashboard_generator.py"

# Function to call Python visualizer with correct options
run_python_visualizer() {
    SCAN_OPT=""
    if [ "$FULL_SCAN" = false ]; then
        SCAN_OPT="--no-scan"
    fi
    
    DASHBOARD_OPT=""
    if [ "$DASHBOARD_INTEGRATION" = true ]; then
        DASHBOARD_OPT="--dashboard"
    fi
    
    if [ -f "$PY_VISUALIZER" ]; then
        echo -e "${GREEN}Running Python visualizer...${NC}"
        python3 "$PY_VISUALIZER" --base-dir "$BAZINGA_DIR" --output-dir "$GENERATED_DIR" $SCAN_OPT $DASHBOARD_OPT
        return $?
    else
        echo -e "${YELLOW}Python visualizer not found: $PY_VISUALIZER${NC}"
        return 1
    fi
}

# Function to call JavaScript visualizer
run_js_visualizer() {
    if [ -f "$JS_VISUALIZER" ]; then
        echo -e "${GREEN}Running JavaScript visualizer...${NC}"
        node "$JS_VISUALIZER" "$BAZINGA_DIR"
        return $?
    else
        echo -e "${YELLOW}JavaScript visualizer not found: $JS_VISUALIZER${NC}"
        return 1
    fi
}

# Function to run dashboard generator
run_dashboard_generator() {
    if [ -f "$DASHBOARD_GENERATOR" ]; then
        echo -e "${GREEN}Running dashboard generator...${NC}"
        python3 "$DASHBOARD_GENERATOR"
        return $?
    else
        echo -e "${YELLOW}Dashboard generator not found: $DASHBOARD_GENERATOR${NC}"
        return 1
    fi
}

# Function to create latest symlinks
create_symlinks() {
    # Find most recent SVG
    LATEST_SVG=$(find "$GENERATED_DIR" -name "bazinga-visual-*.svg" -o -name "bazinga-visualization-*.svg" | sort -r | head -n 1)
    
    if [ -n "$LATEST_SVG" ]; then
        SYMLINK="$DASHBOARD_DIR/latest-framework-visual.svg"
        echo -e "${GREEN}Creating symlink to latest SVG visualization...${NC}"
        
        # Remove existing symlink if it exists
        if [ -L "$SYMLINK" ]; then
            rm "$SYMLINK"
        fi
        
        # Create new symlink
        ln -sf "$LATEST_SVG" "$SYMLINK"
        echo -e "${GREEN}Latest visualization linked: ${NC}$SYMLINK"
    else
        echo -e "${YELLOW}No SVG visualizations found to link${NC}"
    fi
    
    # Find most recent JSON
    LATEST_JSON=$(find "$GENERATED_DIR" -name "bazinga-data-*.json" | sort -r | head -n 1)
    
    if [ -n "$LATEST_JSON" ]; then
        SYMLINK="$DASHBOARD_DIR/latest-framework-data.json"
        echo -e "${GREEN}Creating symlink to latest JSON data...${NC}"
        
        # Remove existing symlink if it exists
        if [ -L "$SYMLINK" ]; then
            rm "$SYMLINK"
        fi
        
        # Create new symlink
        ln -sf "$LATEST_JSON" "$SYMLINK"
        echo -e "${GREEN}Latest data linked: ${NC}$SYMLINK"
    else
        echo -e "${YELLOW}No JSON data files found to link${NC}"
    fi
}

# Function to inject visualization into HTML dashboard
inject_visualization() {
    DASHBOARD_HTML="$DASHBOARD_DIR/index.html"
    
    if [ ! -f "$DASHBOARD_HTML" ]; then
        echo -e "${YELLOW}Dashboard HTML not found: $DASHBOARD_HTML${NC}"
        return 1
    fi
    
    echo -e "${GREEN}Checking dashboard for visualization section...${NC}"
    
    # Check if visualization section already exists
    if grep -q "framework-visualization" "$DASHBOARD_HTML"; then
        echo -e "${GREEN}Visualization section already exists in dashboard${NC}"
        return 0
    fi
    
    # Create temporary file for modifications
    TEMP_FILE=$(mktemp)
    
    # Create visualization section
    VIS_SECTION='
        <!-- Framework Visualization -->
        <div class="row mb-4">
            <div class="col-12">
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <span>BAZINGA Framework Visualization</span>
                        <div>
                            <button id="zoom-in" class="btn btn-sm btn-outline-primary">Zoom +</button>
                            <button id="zoom-out" class="btn btn-sm btn-outline-primary">Zoom -</button>
                        </div>
                    </div>
                    <div class="card-body" style="height: 600px; overflow: auto; text-align: center;">
                        <div id="framework-visualization" class="d-flex justify-content-center">
                            <div class="spinner-border text-primary" role="status">
                                <span class="visually-hidden">Loading...</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>'
    
    # Create JavaScript for visualization
    VIS_SCRIPT='
<script>
// Bazinga Visualization Integration
document.addEventListener("DOMContentLoaded", function() {
    const container = document.getElementById("framework-visualization");
    if (!container) return;
    
    // Load the latest SVG
    fetch("./latest-framework-visual.svg")
        .then(response => response.text())
        .then(svgContent => {
            container.innerHTML = svgContent;
            
            // Make SVG interactive
            const svgElement = container.querySelector("svg");
            if (svgElement) {
                // Add zoom controls
                let scale = 1;
                document.getElementById("zoom-in").addEventListener("click", () => {
                    scale *= 1.2;
                    svgElement.style.transform = `scale(${scale})`;
                });
                document.getElementById("zoom-out").addEventListener("click", () => {
                    scale /= 1.2;
                    svgElement.style.transform = `scale(${scale})`;
                });
                
                // Add component highlighting
                const components = svgElement.querySelectorAll("circle[r=\"25\"]");
                components.forEach(comp => {
                    comp.addEventListener("mouseenter", () => {
                        comp.setAttribute("stroke-width", "4");
                        comp.setAttribute("filter", "url(#glow)");
                    });
                    comp.addEventListener("mouseleave", () => {
                        comp.setAttribute("stroke-width", "2");
                        comp.setAttribute("filter", "");
                    });
                });
            }
        })
        .catch(error => {
            console.error("Error loading framework visualization:", error);
            container.innerHTML = "<div class=\"alert alert-warning\">Framework visualization could not be loaded</div>";
        });
});
</script>'
    
    # Insert visualization section before the closing </body> tag
    awk -v vis="$VIS_SECTION" -v script="$VIS_SCRIPT" '
        /<!-- Recent Patterns -->/ { print vis; print; next }
        /<\/body>/ { print script; print; next }
        { print }
    ' "$DASHBOARD_HTML" > "$TEMP_FILE"
    
    # Check if modifications were made
    if ! cmp -s "$DASHBOARD_HTML" "$TEMP_FILE"; then
        mv "$TEMP_FILE" "$DASHBOARD_HTML"
        echo -e "${GREEN}Visualization section injected into dashboard${NC}"
    else
        rm "$TEMP_FILE"
        echo -e "${YELLOW}Failed to inject visualization into dashboard${NC}"
    fi
}

# Main execution flow
if [ "$REFRESH_DATA" = true ] || [ "$FORCE_REBUILD" = true ]; then
    # Run dashboard generator first if available
    if [ "$DASHBOARD_INTEGRATION" = true ]; then
        run_dashboard_generator
    fi
fi

# Run visualizers
PY_SUCCESS=false
JS_SUCCESS=false

# Try Python visualizer first
run_python_visualizer
if [ $? -eq 0 ]; then
    PY_SUCCESS=true
    echo -e "${GREEN}Python visualizer completed successfully${NC}"
else
    # Try JavaScript visualizer as fallback
    run_js_visualizer
    if [ $? -eq 0 ]; then
        JS_SUCCESS=true
        echo -e "${GREEN}JavaScript visualizer completed successfully${NC}"
    else
        echo -e "${RED}Warning: Both visualizers failed to run${NC}"
    fi
fi

# Create symlinks regardless of which visualizer succeeded
create_symlinks

# Inject visualization into dashboard if requested
if [ "$DASHBOARD_INTEGRATION" = true ]; then
    inject_visualization
fi

echo -e "${CYAN}"
echo "===================================================="
echo "  ⟨ψ|⟳|BAZINGA Framework Visualization Complete⟩"
echo "===================================================="
echo -e "${NC}"

if [ "$PY_SUCCESS" = true ] || [ "$JS_SUCCESS" = true ]; then
    echo -e "${GREEN}Visualization generation completed successfully${NC}"
    exit 0
else
    echo -e "${RED}Visualization generation failed${NC}"
    exit 1
fi
