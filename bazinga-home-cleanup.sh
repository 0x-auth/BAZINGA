#!/bin/bash
# BAZINGA Enhanced Home Directory Cleanup Script
# This script organizes your home directory with special awareness of BAZINGA project

# ANSI colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo -e "${CYAN}==================================================${NC}"
echo -e "${CYAN}   BAZINGA Enhanced Home Directory Cleanup        ${NC}"
echo -e "${CYAN}==================================================${NC}"
echo ""

# Setup directories
HOME_DIR="$HOME"
BACKUP_DIR="$HOME_DIR/.bazinga-backup-$(date +%Y%m%d_%H%M%S)"
SCRIPTS_DIR="$HOME_DIR/bin"
DOCS_DIR="$HOME_DIR/Documents/bazinga-docs"
ARCHIVE_DIR="$HOME_DIR/.bazinga-archives"
LOG_FILE="$HOME_DIR/.bazinga-cleanup.log"
BAZINGA_DIR="$HOME_DIR/AmsyPycharm/BAZINGA"
BAZINGA_WEB_DIR="$HOME_DIR/.bazinga-web"

# Create necessary directories
mkdir -p "$BACKUP_DIR"
mkdir -p "$SCRIPTS_DIR"
mkdir -p "$DOCS_DIR"
mkdir -p "$ARCHIVE_DIR"
touch "$LOG_FILE"

# Logging function
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
  echo -e "$1"
}

log "${BLUE}Beginning BAZINGA-enhanced home directory cleanup...${NC}"
log "${YELLOW}Creating backups in $BACKUP_DIR before making changes${NC}"

# Function to safely move files
safe_move() {
  local src="$1"
  local dest="$2"
  local backup_path="$BACKUP_DIR/$(basename "$src")"
  
  if [ -e "$src" ]; then
    # Create backup first
    cp -r "$src" "$backup_path"
    
    # Then try to move
    if mv "$src" "$dest"; then
      log "${GREEN}Moved: ${YELLOW}$src${GREEN} to ${YELLOW}$dest${NC}"
      return 0
    else
      log "${RED}Failed to move: ${YELLOW}$src${NC}"
      return 1
    fi
  else
    log "${YELLOW}Source does not exist: ${YELLOW}$src${NC}"
    return 1
  fi
}

# Function to organize by file extension
organize_by_extension() {
  local dir="$1"
  local ext="$2"
  local dest="$3"
  
  find "$dir" -maxdepth 1 -name "*.$ext" -type f | while read file; do
    safe_move "$file" "$dest"
  done
}

# ==========================================
# Check and setup BAZINGA integration
# ==========================================
if [ -d "$BAZINGA_DIR" ]; then
  log "${GREEN}BAZINGA project detected at $BAZINGA_DIR${NC}"
  
  # Create symlinks for key BAZINGA executables
  if [ -f "$BAZINGA_DIR/bin/bazinga-ultimate.sh" ] && [ ! -L "$SCRIPTS_DIR/bazinga-ultimate.sh" ]; then
    cp -r "$BAZINGA_DIR/bin/bazinga-ultimate.sh" "$BACKUP_DIR/"
    ln -sf "$BAZINGA_DIR/bin/bazinga-ultimate.sh" "$SCRIPTS_DIR/bazinga-ultimate.sh"
    log "${GREEN}Created symlink for bazinga-ultimate.sh in $SCRIPTS_DIR${NC}"
  fi
  
  if [ -f "$BAZINGA_DIR/bin/nav.sh" ] && [ ! -L "$SCRIPTS_DIR/bazinga-nav.sh" ]; then
    cp -r "$BAZINGA_DIR/bin/nav.sh" "$BACKUP_DIR/"
    ln -sf "$BAZINGA_DIR/bin/nav.sh" "$SCRIPTS_DIR/bazinga-nav.sh"
    log "${GREEN}Created symlink for nav.sh as bazinga-nav.sh in $SCRIPTS_DIR${NC}"
  fi
  
  if [ -f "$BAZINGA_DIR/bz" ] && [ ! -L "$SCRIPTS_DIR/bz" ]; then
    cp -r "$BAZINGA_DIR/bz" "$BACKUP_DIR/"
    ln -sf "$BAZINGA_DIR/bz" "$SCRIPTS_DIR/bz"
    log "${GREEN}Created symlink for bz in $SCRIPTS_DIR${NC}"
  fi
  
  # Create docs directory for bazinga
  mkdir -p "$DOCS_DIR/bazinga"
  
  # Copy BAZINGA docs
  if [ -d "$BAZINGA_DIR/docs" ]; then
    find "$BAZINGA_DIR/docs" -maxdepth 1 -name "*.md" | while read doc; do
      cp "$doc" "$DOCS_DIR/bazinga/"
      log "${GREEN}Copied BAZINGA documentation: ${YELLOW}$doc${GREEN} to ${YELLOW}$DOCS_DIR/bazinga/${NC}"
    done
  fi
  
  # Integrate BAZINGA with Web App if both exist
  if [ -d "$BAZINGA_WEB_DIR" ]; then
    log "${BLUE}Integrating BAZINGA with Web App...${NC}"
    
    # Create integration directory
    mkdir -p "$BAZINGA_WEB_DIR/public/js/bazinga-integration"
    
    # Copy visualization scripts if they exist
    if [ -d "$BAZINGA_DIR/artifacts/visualization" ]; then
      mkdir -p "$BAZINGA_WEB_DIR/public/js/bazinga-integration/visualization"
      cp "$BAZINGA_DIR/artifacts/visualization"/*.js "$BAZINGA_WEB_DIR/public/js/bazinga-integration/visualization/" 2>/dev/null
      log "${GREEN}Copied BAZINGA visualization scripts to Web App${NC}"
    fi
    
    # Copy SVG generator if it exists
    if [ -f "$BAZINGA_DIR/bazinga-svg-generator.js" ]; then
      cp "$BAZINGA_DIR/bazinga-svg-generator.js" "$BAZINGA_WEB_DIR/public/js/bazinga-integration/"
      log "${GREEN}Copied BAZINGA SVG generator to Web App${NC}"
    fi
    
    # Copy fractal related JS files if they exist
    if [ -d "$BAZINGA_DIR/artifacts/fractal" ]; then
      mkdir -p "$BAZINGA_WEB_DIR/public/js/bazinga-integration/fractal"
      cp "$BAZINGA_DIR/artifacts/fractal"/*.js "$BAZINGA_WEB_DIR/public/js/bazinga-integration/fractal/" 2>/dev/null
      log "${GREEN}Copied BAZINGA fractal scripts to Web App${NC}"
    fi
  fi
else
  log "${YELLOW}BAZINGA project not found at $BAZINGA_DIR${NC}"
fi

# ==========================================
# 1. Move loose script files to ~/bin
# ==========================================
log "${BLUE}Organizing loose script files...${NC}"

# Find shell scripts and executable files in home dir
find "$HOME_DIR" -maxdepth 1 \( -name "*.sh" -o -name "*.py" -o -name "*.rb" -o -perm -100 \) -not -path "*/\.*" | while read script; do
  # Skip if it's a directory or symlink
  if [ -d "$script" ] || [ -L "$script" ]; then
    continue
  fi
  
  # Make sure bin directory exists
  mkdir -p "$SCRIPTS_DIR"
  
  # Move to bin dir
  safe_move "$script" "$SCRIPTS_DIR/"
done

log "${GREEN}Script files organized into $SCRIPTS_DIR${NC}"

# ==========================================
# 2. Consolidate documentation files
# ==========================================
log "${BLUE}Organizing documentation files...${NC}"

# Find Markdown and text files
find "$HOME_DIR" -maxdepth 1 \( -name "*.md" -o -name "*.txt" \) -not -path "*/\.*" | while read doc; do
  # Skip if it's a directory or symlink
  if [ -d "$doc" ] || [ -L "$doc" ]; then
    continue
  fi
  
  # Move to docs dir
  safe_move "$doc" "$DOCS_DIR/"
done

log "${GREEN}Documentation organized into $DOCS_DIR${NC}"

# ==========================================
# 3. Clean up backup and temporary files
# ==========================================
log "${BLUE}Archiving backup and temporary files...${NC}"

# Create timestamp for archive
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
TEMP_ARCHIVE_DIR="$ARCHIVE_DIR/backup_$TIMESTAMP"
mkdir -p "$TEMP_ARCHIVE_DIR"

# Find backup and temporary files
find "$HOME_DIR" -maxdepth 1 \( -name "*.bak" -o -name "*.tmp" -o -name "*.old" -o -name "*-backup" -o -name "*.bak.*" \) -not -path "*/\.*" | while read backup_file; do
  # Skip if it's a directory or symlink
  if [ -d "$backup_file" ] || [ -L "$backup_file" ]; then
    continue
  fi
  
  # Move to archive dir
  safe_move "$backup_file" "$TEMP_ARCHIVE_DIR/"
done

log "${GREEN}Backup files archived into $TEMP_ARCHIVE_DIR${NC}"

# ==========================================
# 4. Organize Claude-related directories
# ==========================================
log "${BLUE}Organizing Claude-related directories...${NC}"

# Create a unified Claude directory
mkdir -p "$HOME_DIR/claude_unified"
mkdir -p "$HOME_DIR/claude_unified/artifacts"
mkdir -p "$HOME_DIR/claude_unified/scripts"
mkdir -p "$HOME_DIR/claude_unified/data"
mkdir -p "$HOME_DIR/claude_unified/integrations"

# Check for a specific Claude directory in BAZINGA project
if [ -d "$BAZINGA_DIR/Claude" ]; then
  log "${YELLOW}Found Claude directory within BAZINGA - preserving this structure${NC}"
  
  # Just copy any important artifacts
  if [ -d "$BAZINGA_DIR/Claude/ClaudeArtifacts" ]; then
    find "$BAZINGA_DIR/Claude/ClaudeArtifacts" -type f | while read file; do
      cp "$file" "$HOME_DIR/claude_unified/artifacts/"
      log "${GREEN}Copied: ${YELLOW}$file${GREEN} to ${YELLOW}$HOME_DIR/claude_unified/artifacts/${NC}"
    done
  fi
fi

# List of Claude directories to consolidate
CLAUDE_DIRS=(
  "claude_artifacts"
  "claude_bridge"
  "claude_bridge.old"
  "claude_central"
  "claude_data"
  "ClaudeArtifacts"
)

# Move contents to unified structure
for dir in "${CLAUDE_DIRS[@]}"; do
  if [ -d "$HOME_DIR/$dir" ] && [ ! -L "$HOME_DIR/$dir" ]; then
    # Copy contents instead of moving the directory itself
    if [ -d "$HOME_DIR/$dir" ]; then
      # Determine target subdirectory based on name
      if [[ "$dir" == *"artifact"* || "$dir" == *"Artifact"* ]]; then
        TARGET="$HOME_DIR/claude_unified/artifacts"
      elif [[ "$dir" == *"data"* ]]; then
        TARGET="$HOME_DIR/claude_unified/data"
      elif [[ "$dir" == *"bridge"* || "$dir" == *"central"* ]]; then
        TARGET="$HOME_DIR/claude_unified/integrations"
      else
        TARGET="$HOME_DIR/claude_unified"
      fi
      
      # Copy files
      find "$HOME_DIR/$dir" -maxdepth 1 -type f | while read file; do
        cp "$file" "$TARGET/"
        log "${GREEN}Copied: ${YELLOW}$file${GREEN} to ${YELLOW}$TARGET/${NC}"
      done
      
      # Create a README to track original location
      echo "Contents moved from $HOME_DIR/$dir on $(date)" > "$TARGET/README_from_$dir.txt"
      
      # We don't move the original directory yet, just make a note
      log "${YELLOW}Copied contents of $dir to claude_unified structure. Original directory preserved.${NC}"
    fi
  fi
done

log "${GREEN}Claude directories organized into unified structure at $HOME_DIR/claude_unified${NC}"
log "${YELLOW}Original Claude directories preserved. After verifying, you can remove them manually.${NC}"

# ==========================================
# 5. Organize analysis directories with timestamps
# ==========================================
log "${BLUE}Organizing analysis and timestamped directories...${NC}"

# Create analysis archive
mkdir -p "$HOME_DIR/.analyses_archive"

# Skip specific BAZINGA directories we don't want to move
EXCLUSIONS="time_trust_analysis|integration/ssri_20|bazinga_analysis|quantum_analysis"

# Find directories with timestamps in their names
find "$HOME_DIR" -maxdepth 1 -type d -name "*_20*_*" | grep -v "$EXCLUSIONS" | while read time_dir; do
  # Skip if it's a symlink
  if [ -L "$time_dir" ]; then
    continue
  fi
  
  # Copy to archive instead of moving directly
  DIR_NAME=$(basename "$time_dir")
  cp -r "$time_dir" "$HOME_DIR/.analyses_archive/"
  log "${GREEN}Copied: ${YELLOW}$time_dir${GREEN} to ${YELLOW}$HOME_DIR/.analyses_archive/${NC}"
  log "${YELLOW}Original directory at $time_dir preserved. After verification, you can remove it manually.${NC}"
done

log "${GREEN}Analysis directories organized into $HOME_DIR/.analyses_archive${NC}"

# ==========================================
# 6. Organize system-monitor if it exists
# ==========================================
log "${BLUE}Organizing system-monitor...${NC}"

# Check if system-monitor directory exists
if [ -d "$HOME_DIR/system-monitor" ]; then
  # Backup the directory
  cp -r "$HOME_DIR/system-monitor" "$BACKUP_DIR/"
  
  # If bazinga-web exists, integrate with it
  if [ -d "$BAZINGA_WEB_DIR" ]; then
    mkdir -p "$BAZINGA_WEB_DIR/server/monitoring"
    
    # Copy system-monitor.sh
    if [ -f "$HOME_DIR/system-monitor/system-monitor.sh" ]; then
      cp "$HOME_DIR/system-monitor/system-monitor.sh" "$BAZINGA_WEB_DIR/server/monitoring/"
      log "${GREEN}Copied system-monitor.sh to BAZINGA Web App monitoring directory${NC}"
    fi
    
    # Copy dashboard HTML if it exists
    if [ -f "$HOME_DIR/system-monitor/system-dashboard.html" ]; then
      cp "$HOME_DIR/system-monitor/system-dashboard.html" "$BAZINGA_WEB_DIR/public/"
      log "${GREEN}Copied system dashboard to BAZINGA Web App public directory${NC}"
    fi
  fi
  
  log "${GREEN}System monitor integration completed${NC}"
fi

# ==========================================
# 7. Create an enhanced BAZINGA launcher
# ==========================================
log "${BLUE}Creating enhanced BAZINGA launcher...${NC}"

# Create a launcher script for easy access to BAZINGA tools
cat > "$SCRIPTS_DIR/bazinga-launcher.sh" << 'EOL'
#!/bin/bash
# Enhanced BAZINGA Launcher
# Launches BAZINGA tools, utilities, and integrations

# ANSI colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo -e "${CYAN}==================================================${NC}"
echo -e "${CYAN}   BAZINGA Ecosystem Launcher                     ${NC}"
echo -e "${CYAN}==================================================${NC}"
echo ""

BAZINGA_DIR="$HOME/AmsyPycharm/BAZINGA"
BAZINGA_BIN="$BAZINGA_DIR/bin"
SYSTEM_MONITOR="$HOME/system-monitor/system-dashboard.html"
BAZINGA_WEB="$HOME/.bazinga-web/start.sh"
DASHBOARDS_DIR="$HOME/.bazinga-web/public"

function check_bazinga() {
  if [ ! -d "$BAZINGA_DIR" ]; then
    echo -e "${RED}ERROR: BAZINGA directory not found at $BAZINGA_DIR${NC}"
    echo -e "This launcher requires the BAZINGA project to be installed."
    exit 1
  fi
}

function horizontal_rule() {
  echo -e "${BLUE}--------------------------------------------------${NC}"
}

# Display the main menu
function show_main_menu() {
  echo -e "${BOLD}${YELLOW}BAZINGA Ecosystem Launcher${NC}"
  echo ""
  echo -e "${CYAN}1. BAZINGA Core${NC}"
  echo -e "   Run BAZINGA core components and scripts"
  echo ""
  echo -e "${CYAN}2. BAZINGA Web App${NC}" 
  echo -e "   Manage the BAZINGA Web Application"
  echo ""
  echo -e "${CYAN}3. System Monitoring${NC}"
  echo -e "   Access system dashboards and monitoring tools"
  echo ""
  echo -e "${CYAN}4. Integrations${NC}"
  echo -e "   Claude, SSRI, and other integrations"
  echo ""
  echo -e "${CYAN}5. Utilities${NC}"
  echo -e "   System maintenance and cleanup tools"
  echo ""
  echo -e "${CYAN}0. Exit${NC}"
  echo ""
  echo -n "Enter your choice [0-5]: "
  read -r main_choice
  
  case $main_choice in
    1) show_bazinga_core_menu ;;
    2) show_web_app_menu ;;
    3) show_monitoring_menu ;;
    4) show_integrations_menu ;;
    5) show_utilities_menu ;;
    0) exit_gracefully ;;
    *) echo -e "${RED}Invalid option${NC}"; show_main_menu ;;
  esac
}

# BAZINGA Core menu
function show_bazinga_core_menu() {
  clear
  echo -e "${CYAN}==================================================${NC}"
  echo -e "${BOLD}${YELLOW}BAZINGA Core Components${NC}"
  echo -e "${CYAN}==================================================${NC}"
  echo ""
  
  echo -e "${CYAN}1. Run BAZINGA Ultimate${NC}"
  if [ -f "$BAZINGA_BIN/bazinga-ultimate.sh" ]; then
    echo -e "   Execute the main BAZINGA script"
  else
    echo -e "   ${RED}Not installed${NC}"
  fi
  echo ""
  
  echo -e "${CYAN}2. Run BAZINGA Quantum${NC}"
  if [ -f "$BAZINGA_DIR/system/bazinga-quantum" ]; then
    echo -e "   Execute the quantum version of BAZINGA"
  else
    echo -e "   ${RED}Not installed${NC}"
  fi
  echo ""
  
  echo -e "${CYAN}3. Run Project Analyzer${NC}"
  if [ -f "$BAZINGA_DIR/scripts/project-analyzer.sh" ]; then
    echo -e "   Analyze the BAZINGA project structure"
  else
    echo -e "   ${RED}Not installed${NC}"
  fi
  echo ""
  
  echo -e "${CYAN}4. Explore BAZINGA Documentation${NC}"
  echo -e "   View documentation for BAZINGA components"
  echo ""
  
  echo -e "${CYAN}0. Back to Main Menu${NC}"
  echo ""
  
  echo -n "Enter your choice [0-4]: "
  read -r core_choice
  
  case $core_choice in
    1)
      if [ -f "$BAZINGA_BIN/bazinga-ultimate.sh" ]; then
        echo -e "${YELLOW}Running BAZINGA Ultimate...${NC}"
        bash "$BAZINGA_BIN/bazinga-ultimate.sh"
      else
        echo -e "${RED}BAZINGA Ultimate not found${NC}"
      fi
      ;;
    2)
      if [ -f "$BAZINGA_DIR/system/bazinga-quantum" ]; then
        echo -e "${YELLOW}Running BAZINGA Quantum...${NC}"
        cd "$BAZINGA_DIR" && ./system/bazinga-quantum
      else
        echo -e "${RED}BAZINGA Quantum not found${NC}"
      fi
      ;;
    3)
      if [ -f "$BAZINGA_DIR/scripts/project-analyzer.sh" ]; then
        echo -e "${YELLOW}Running Project Analyzer...${NC}"
        cd "$BAZINGA_DIR" && ./scripts/project-analyzer.sh
      else
        echo -e "${RED}Project Analyzer not found${NC}"
      fi
      ;;
    4)
      DOCS_DIR="$HOME/Documents/bazinga-docs/bazinga"
      if [ -d "$DOCS_DIR" ]; then
        echo -e "${YELLOW}Available documentation:${NC}"
        ls -1 "$DOCS_DIR" | grep -E "\.md$" | cat -n
        echo -n "Enter document number to view (or 0 to cancel): "
        read -r doc_num
        if [ "$doc_num" -gt 0 ] 2>/dev/null; then
          DOC_FILE=$(ls -1 "$DOCS_DIR" | grep -E "\.md$" | sed -n "${doc_num}p")
          if [ -n "$DOC_FILE" ]; then
            if command -v less &>/dev/null; then
              less "$DOCS_DIR/$DOC_FILE"
            else
              cat "$DOCS_DIR/$DOC_FILE"
            fi
          fi
        fi
      else
        echo -e "${RED}Documentation directory not found${NC}"
      fi
      ;;
    0) show_main_menu ;;
    *) echo -e "${RED}Invalid option${NC}"; show_bazinga_core_menu ;;
  esac
  
  echo ""
  echo -n "Press Enter to continue..."
  read
  show_bazinga_core_menu
}

# Web App menu
function show_web_app_menu() {
  clear
  echo -e "${CYAN}==================================================${NC}"
  echo -e "${BOLD}${YELLOW}BAZINGA Web App${NC}"
  echo -e "${CYAN}==================================================${NC}"
  echo ""
  
  echo -e "${CYAN}1. Start Web App${NC}"
  echo -e "   Launch the BAZINGA Web Application"
  echo ""
  
  echo -e "${CYAN}2. Stop Web App${NC}"
  echo -e "   Stop the BAZINGA Web Application"
  echo ""
  
  echo -e "${CYAN}3. Restart Web App${NC}"
  echo -e "   Restart the BAZINGA Web Application"
  echo ""
  
  echo -e "${CYAN}4. Open in Browser${NC}"
  echo -e "   Open the BAZINGA Web App in default browser"
  echo ""
  
  echo -e "${CYAN}5. Web App Status${NC}"
  echo -e "   Check if the BAZINGA Web App is running"
  echo ""
  
  echo -e "${CYAN}0. Back to Main Menu${NC}"
  echo ""
  
  echo -n "Enter your choice [0-5]: "
  read -r web_choice
  
  case $web_choice in
    1)
      if [ -f "$BAZINGA_WEB" ]; then
        echo -e "${YELLOW}Starting BAZINGA Web App...${NC}"
        "$BAZINGA_WEB" start
      else
        echo -e "${RED}BAZINGA Web App not found${NC}"
      fi
      ;;
    2)
      if [ -f "$BAZINGA_WEB" ]; then
        echo -e "${YELLOW}Stopping BAZINGA Web App...${NC}"
        "$BAZINGA_WEB" stop
      else
        echo -e "${RED}BAZINGA Web App not found${NC}"
      fi
      ;;
    3)
      if [ -f "$BAZINGA_WEB" ]; then
        echo -e "${YELLOW}Restarting BAZINGA Web App...${NC}"
        "$BAZINGA_WEB" restart
      else
        echo -e "${RED}BAZINGA Web App not found${NC}"
      fi
      ;;
    4)
      echo -e "${YELLOW}Opening BAZINGA Web App in browser...${NC}"
      open "http://localhost:8080"
      ;;
    5)
      if [ -f "$BAZINGA_WEB" ]; then
        echo -e "${YELLOW}Checking BAZINGA Web App status...${NC}"
        "$BAZINGA_WEB" status
      else
        echo -e "${RED}BAZINGA Web App not found${NC}"
      fi
      ;;
    0) show_main_menu ;;
    *) echo -e "${RED}Invalid option${NC}"; show_web_app_menu ;;
  esac
  
  echo ""
  echo -n "Press Enter to continue..."
  read
  show_web_app_menu
}

# Monitoring menu
function show_monitoring_menu() {
  clear
  echo -e "${CYAN}==================================================${NC}"
  echo -e "${BOLD}${YELLOW}System Monitoring${NC}"
  echo -e "${CYAN}==================================================${NC}"
  echo ""
  
  echo -e "${CYAN}1. System Dashboard${NC}"
  if [ -f "$DASHBOARDS_DIR/system-dashboard.html" ]; then
    echo -e "   View system dashboard in browser"
  else
    echo -e "   ${RED}Not installed${NC}"
  fi
  echo ""
  
  echo -e "${CYAN}2. Run System Monitor${NC}"
  if [ -f "$HOME/system-monitor/system-monitor.sh" ]; then
    echo -e "   Generate new system monitoring data"
  elif [ -f "$BAZINGA_WEB_DIR/server/monitoring/system-monitor.sh" ]; then
    echo -e "   Generate new system monitoring data"
  else
    echo -e "   ${RED}Not installed${NC}"
  fi
  echo ""
  
  echo -e "${CYAN}3. BAZINGA Analytics${NC}"
  if [ -f "$BAZINGA_DIR/dashboard/index.html" ]; then
    echo -e "   View BAZINGA analytics dashboard"
  else
    echo -e "   ${RED}Not installed${NC}"
  fi
  echo ""
  
  echo -e "${CYAN}0. Back to Main Menu${NC}"
  echo ""
  
  echo -n "Enter your choice [0-3]: "
  read -r monitor_choice
  
  case $monitor_choice in
    1)
      if [ -f "$DASHBOARDS_DIR/system-dashboard.html" ]; then
        echo -e "${YELLOW}Opening System Dashboard...${NC}"
        open "$DASHBOARDS_DIR/system-dashboard.html"
      elif [ -f "$HOME/system-monitor/system-dashboard.html" ]; then
        echo -e "${YELLOW}Opening System Dashboard...${NC}"
        open "$HOME/system-monitor/system-dashboard.html"
      else
        echo -e "${RED}System Dashboard not found${NC}"
      fi
      ;;
    2)
      if [ -f "$HOME/system-monitor/system-monitor.sh" ]; then
        echo -e "${YELLOW}Running System Monitor...${NC}"
        bash "$HOME/system-monitor/system-monitor.sh"
      elif [ -f "$BAZINGA_WEB_DIR/server/monitoring/system-monitor.sh" ]; then
        echo -e "${YELLOW}Running System Monitor...${NC}"
        bash "$BAZINGA_WEB_DIR/server/monitoring/system-monitor.sh"
      else
        echo -e "${RED}System Monitor not found${NC}"
      fi
      ;;
    3)
      if [ -f "$BAZINGA_DIR/dashboard/index.html" ]; then
        echo -e "${YELLOW}Opening BAZINGA Analytics...${NC}"
        open "$BAZINGA_DIR/dashboard/index.html"
      else
        echo -e "${RED}BAZINGA Analytics not found${NC}"
      fi
      ;;
    0) show_main_menu ;;
    *) echo -e "${RED}Invalid option${NC}"; show_monitoring_menu ;;
  esac
  
  echo ""
  echo -n "Press Enter to continue..."
  read
  show_monitoring_menu
}

# Integrations menu
function show_integrations_menu() {
  clear
  echo -e "${CYAN}==================================================${NC}"
  echo -e "${BOLD}${YELLOW}BAZINGA Integrations${NC}"
  echo -e "${CYAN}==================================================${NC}"
  echo ""
  
  echo -e "${CYAN}1. Claude Integration${NC}"
  if [ -f "$BAZINGA_DIR/bin/extract-claude-artifacts.sh" ]; then
    echo -e "   Extract Claude artifacts"
  else
    echo -e "   ${RED}Not installed${NC}"
  fi
  echo ""
  
  echo -e "${CYAN}2. SSRI Integration${NC}"
  if [ -f "$BAZINGA_DIR/bin/ssri-bazinga-integration.sh" ]; then
    echo -e "   Run SSRI integration with BAZINGA"
  else
    echo -e "   ${RED}Not installed${NC}"
  fi
  echo ""
  
  echo -e "${CYAN}3. Quantum-Linguistics Integration${NC}"
  if [ -d "$BAZINGA_DIR/quantum-linguistics" ]; then
    echo -e "   Run Quantum-Linguistics integration"
  else
    echo -e "   ${RED}Not installed${NC}"
  fi
  echo ""
  
  echo -e "${CYAN}4. Fractal Knowledge Integration${NC}"
  if [ -d "$BAZINGA_DIR/FractalKnowledge" ]; then
    echo -e "   Access Fractal Knowledge components"
  else
    echo -e "   ${RED}Not installed${NC}"
  fi
  echo ""
  
  echo -e "${CYAN}0. Back to Main Menu${NC}"
  echo ""
  
  echo -n "Enter your choice [0-4]: "
  read -r integration_choice
  
  case $integration_choice in
    1)
      if [ -f "$BAZINGA_DIR/bin/extract-claude-artifacts.sh" ]; then
        echo -e "${YELLOW}Running Claude Integration...${NC}"
        bash "$BAZINGA_DIR/bin/extract-claude-artifacts.sh"
      else
        echo -e "${RED}Claude Integration not found${NC}"
      fi
      ;;
    2)
      if [ -f "$BAZINGA_DIR/bin/ssri-bazinga-integration.sh" ]; then
        echo -e "${YELLOW}Running SSRI Integration...${NC}"
        bash "$BAZINGA_DIR/bin/ssri-bazinga-integration.sh"
      else
        echo -e "${RED}SSRI Integration not found${NC}"
      fi
