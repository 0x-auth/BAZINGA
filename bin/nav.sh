#!/bin/bash
# BAZINGA Navigation Tool - Easy directory and tool navigation
# Save this as ~/AmsyPycharm/BAZINGA/bin/nav.sh and make executable

# Colors for better readability
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Define directory groups
declare -A DIR_GROUPS
DIR_GROUPS=(
  ["work"]="GolandProjects vault-migration .kube"
  ["personal"]="AmsyPycharm AmsyPycharm/BAZINGA Downloads"
  ["scripts"]="bin AmsyPycharm/BAZINGA/bin tools"
  ["data"]="system-monitor ClaudeArtifacts"
)

# Define tool groups
declare -A TOOL_GROUPS
TOOL_GROUPS=(
  ["claude"]="claude-control.sh claude-extract claude-analyze claude-fix"
  ["bazinga"]="bazinga bazinga-temporal.sh extract-claude-artifacts.sh"
  ["system"]="system-monitor.sh"
  ["tmux"]="tb tc tg ta"
)

show_help() {
  echo -e "${BLUE}=== BAZINGA Navigation Tool ===${NC}"
  echo
  echo -e "Usage: nav [category] [destination]"
  echo
  echo -e "${GREEN}Categories:${NC}"
  echo -e "  ${YELLOW}dirs${NC}    - List directory categories"
  echo -e "  ${YELLOW}tools${NC}   - List tool categories"
  echo -e "  ${YELLOW}go${NC}      - Navigate to a directory"
  echo -e "  ${YELLOW}run${NC}     - Run a tool"
  echo
  echo -e "Examples:"
  echo -e "  ${BLUE}nav dirs${NC}              - List directory categories"
  echo -e "  ${BLUE}nav dirs work${NC}         - List work directories"
  echo -e "  ${BLUE}nav go GolandProjects${NC} - Go to GolandProjects"
  echo -e "  ${BLUE}nav tools${NC}             - List tool categories"
  echo -e "  ${BLUE}nav tools claude${NC}      - List Claude tools"
  echo -e "  ${BLUE}nav run claude${NC}        - Run Claude control"
  echo
}

list_dir_categories() {
  echo -e "${BLUE}Directory Categories:${NC}"
  for category in "${!DIR_GROUPS[@]}"; do
    echo -e "  ${YELLOW}$category${NC}"
  done
}

list_dirs_in_category() {
  local category=$1
  if [[ -z "${DIR_GROUPS[$category]}" ]]; then
    echo -e "${YELLOW}Category not found. Available categories:${NC}"
    list_dir_categories
    return 1
  fi
  
  echo -e "${BLUE}Directories in '${category}':${NC}"
  for dir in ${DIR_GROUPS[$category]}; do
    echo -e "  ${YELLOW}$dir${NC}"
  done
}

list_tool_categories() {
  echo -e "${BLUE}Tool Categories:${NC}"
  for category in "${!TOOL_GROUPS[@]}"; do
    echo -e "  ${YELLOW}$category${NC}"
  done
}

list_tools_in_category() {
  local category=$1
  if [[ -z "${TOOL_GROUPS[$category]}" ]]; then
    echo -e "${YELLOW}Category not found. Available categories:${NC}"
    list_tool_categories
    return 1
  fi
  
  echo -e "${BLUE}Tools in '${category}':${NC}"
  for tool in ${TOOL_GROUPS[$category]}; do
    echo -e "  ${YELLOW}$tool${NC}"
  done
}

navigate_to_dir() {
  local destination=$1
  local found=false
  local full_path=""
  
  # Try direct navigation first
  if [[ -d "$HOME/$destination" ]]; then
    cd "$HOME/$destination"
    echo -e "${GREEN}Navigated to $HOME/$destination${NC}"
    return 0
  fi
  
  # Search through all directories
  for category in "${!DIR_GROUPS[@]}"; do
    for dir in ${DIR_GROUPS[$category]}; do
      if [[ "$dir" == "$destination" ]]; then
        cd "$HOME/$dir"
        echo -e "${GREEN}Navigated to $HOME/$dir${NC}"
        return 0
      fi
    done
  done
  
  echo -e "${YELLOW}Directory '$destination' not found.${NC}"
  echo -e "Use ${BLUE}nav dirs${NC} to see available directory categories."
  return 1
}

run_tool() {
  local tool=$1
  
  # Check for direct tool match
  case $tool in
    "claude")
      $HOME/AmsyPycharm/BAZINGA/bin/claude-control.sh
      return 0
      ;;
    "claude-extract")
      $HOME/AmsyPycharm/BAZINGA/bin/claude-control.sh extract
      return 0
      ;;
    "claude-analyze")
      $HOME/AmsyPycharm/BAZINGA/bin/claude-control.sh analyze
      return 0
      ;;
    "claude-fix")
      $HOME/AmsyPycharm/BAZINGA/bin/claude-control.sh fix
      return 0
      ;;
    "bazinga")
      $HOME/AmsyPycharm/BAZINGA/bin/bazinga-launcher.sh
      return 0
      ;;
    "bazinga-temporal")
      $HOME/AmsyPycharm/BAZINGA/bin/bazinga-temporal.sh
      return 0
      ;;
    "extract-claude-artifacts")
      $HOME/AmsyPycharm/BAZINGA/bin/extract-claude-artifacts.sh
      return 0
      ;;
    "system-monitor")
      $HOME/system-monitor/system-monitor.sh
      return 0
      ;;
    "tb")
      tmux-bazinga
      return 0
      ;;
    "tc")
      tmux-claude
      return 0
      ;;
    "tg")
      tmux-golang
      return 0
      ;;
    "ta")
      echo -e "Usage: ta [session]"
      return 0
      ;;
  esac
  
  # Try category run
  for category in "${!TOOL_GROUPS[@]}"; do
    if [[ "$category" == "$tool" ]]; then
      local main_tool=$(echo ${TOOL_GROUPS[$category]} | awk '{print $1}')
      echo -e "${GREEN}Running $main_tool${NC}"
      run_tool $main_tool
      return 0
    fi
  done
  
  echo -e "${YELLOW}Tool '$tool' not found.${NC}"
  echo -e "Use ${BLUE}nav tools${NC} to see available tool categories."
  return 1
}

# Main command processing
case $1 in
  "dirs")
    if [[ -z "$2" ]]; then
      list_dir_categories
    else
      list_dirs_in_category "$2"
    fi
    ;;
  "tools")
    if [[ -z "$2" ]]; then
      list_tool_categories
    else
      list_tools_in_category "$2"
    fi
    ;;
  "go")
    if [[ -z "$2" ]]; then
      echo -e "${YELLOW}Please specify a destination.${NC}"
      echo -e "Use ${BLUE}nav dirs${NC} to see available directories."
    else
      navigate_to_dir "$2"
    fi
    ;;
  "run")
    if [[ -z "$2" ]]; then
      echo -e "${YELLOW}Please specify a tool.${NC}"
      echo -e "Use ${BLUE}nav tools${NC} to see available tools."
    else
      run_tool "$2"
    fi
    ;;
  *)
    show_help
    ;;
esac
