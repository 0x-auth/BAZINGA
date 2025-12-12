#!/bin/bash
# bazinga-dashboard.sh - Unified tracking and visualization system
# Author: Claude
# Date: 2025-03-28

# ANSI colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

# Base directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
BASE_DIR="${HOME}/AmsyPycharm/BAZINGA"
ARTIFACTS_DIR="${BASE_DIR}/artifacts"
LOG_DIR="${BASE_DIR}/logs"
CONFIG_DIR="${BASE_DIR}/config"
DASHBOARD_DIR="${BASE_DIR}/dashboard"

# Ensure directories exist
mkdir -p "${LOG_DIR}" "${ARTIFACTS_DIR}" "${CONFIG_DIR}" "${DASHBOARD_DIR}/data" "${DASHBOARD_DIR}/views"

# Log file
LOG_FILE="${LOG_DIR}/dashboard-$(date +%Y%m%d).log"

# Config file
CONFIG_FILE="${CONFIG_DIR}/dashboard-config.json"

# Default config if not exists
if [ ! -f "$CONFIG_FILE" ]; then
  cat > "$CONFIG_FILE" << EOF
{
  "tracking": {
    "commandHistory": true,
    "filesystemChanges": true,
    "gitRepositories": true,
    "claudeArtifacts": true,
    "scriptExecutions": true
  },
  "paths": {
    "workRepos": [
      "${HOME}/GolandProjects/federated-vault-monitoring-migration",
      "${HOME}/GolandProjects/federated-prisma-operator"
    ],
    "claudeArtifacts": [
      "${HOME}/AmsyPycharm/BAZINGA/artifacts/claude_artifacts",
      "${HOME}/claude_main/artifacts"
    ],
    "personalProjects": [
      "${HOME}/AmsyPycharm/BAZINGA",
      "${HOME}/AmsyPycharm/BAZINGA-INDEED"
    ]
  },
  "visualization": {
    "refreshInterval": 3600,
    "patternThreshold": 3,
    "maxTimelineItems": 50
  },
  "patterns": {
    "dodo": {
      "enabled": true,
      "threshold": 2,
      "signalAmplification": 1.5
    },
    "singular": {
      "enabled": true,
      "threshold": 3.5,
      "decayRate": 0.85
    }
  }
}
EOF
fi

# Log function
log() {
  local level="$1"
  local message="$2"
  echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] [${level}] ${message}" | tee -a "$LOG_FILE"
}

# Load config
load_config() {
  if [ ! -f "$CONFIG_FILE" ]; then
    log "ERROR" "Configuration file not found: $CONFIG_FILE"
    return 1
  fi
  
  # Load config using jq if available, otherwise use grep
  if command -v jq &>/dev/null; then
    TRACK_CMD_HISTORY=$(jq -r '.tracking.commandHistory' "$CONFIG_FILE")
    TRACK_FS_CHANGES=$(jq -r '.tracking.filesystemChanges' "$CONFIG_FILE")
    TRACK_GIT_REPOS=$(jq -r '.tracking.gitRepositories' "$CONFIG_FILE")
    TRACK_CLAUDE_ARTIFACTS=$(jq -r '.tracking.claudeArtifacts' "$CONFIG_FILE")
    TRACK_SCRIPT_EXECUTIONS=$(jq -r '.tracking.scriptExecutions' "$CONFIG_FILE")
    
    # Work repos
    WORK_REPOS=$(jq -r '.paths.workRepos[]' "$CONFIG_FILE")
    
    # Claude artifacts paths
    CLAUDE_ARTIFACT_PATHS=$(jq -r '.paths.claudeArtifacts[]' "$CONFIG_FILE")
    
    # Personal projects
    PERSONAL_PROJECTS=$(jq -r '.paths.personalProjects[]' "$CONFIG_FILE")
    
    # Visualization settings
    REFRESH_INTERVAL=$(jq -r '.visualization.refreshInterval' "$CONFIG_FILE")
    PATTERN_THRESHOLD=$(jq -r '.visualization.patternThreshold' "$CONFIG_FILE")
    MAX_TIMELINE_ITEMS=$(jq -r '.visualization.maxTimelineItems' "$CONFIG_FILE")
    
    # Pattern settings
    DODO_ENABLED=$(jq -r '.patterns.dodo.enabled' "$CONFIG_FILE")
    DODO_THRESHOLD=$(jq -r '.patterns.dodo.threshold' "$CONFIG_FILE")
    DODO_AMPLIFICATION=$(jq -r '.patterns.dodo.signalAmplification' "$CONFIG_FILE")
    
    SINGULAR_ENABLED=$(jq -r '.patterns.singular.enabled' "$CONFIG_FILE")
    SINGULAR_THRESHOLD=$(jq -r '.patterns.singular.threshold' "$CONFIG_FILE")
    SINGULAR_DECAY=$(jq -r '.patterns.singular.decayRate' "$CONFIG_FILE")
  else
    log "WARNING" "jq not found, using fallback method to parse config"
    # Fallback method using grep
    TRACK_CMD_HISTORY=$(grep -o '"commandHistory": *[^,}]*' "$CONFIG_FILE" | grep -o '[^:]*$' | tr -d ' "')
    # ... add similar lines for other configs
  fi
}

# Track command history
track_command_history() {
  log "INFO" "Tracking command history"
  
  # Create data directory if it doesn't exist
  mkdir -p "${DASHBOARD_DIR}/data/commands"
  
  # Get today's date
  local today=$(date +%Y%m%d)
  local output_file="${DASHBOARD_DIR}/data/commands/history-${today}.json"
  
  # Get command history with timestamps
  HISTTIMEFORMAT="%F %T " history > "${DASHBOARD_DIR}/data/commands/raw-history-${today}.txt"
  
  # Convert to JSON format for dashboard
  if command -v jq &>/dev/null; then
    cat "${DASHBOARD_DIR}/data/commands/raw-history-${today}.txt" | grep -v "^#" | awk '{$1=""; timestamp=$2" "$3; $2=""; $3=""; command=$0; gsub(/^[ \t]+/, "", command); print "{\"timestamp\":\""timestamp"\",\"command\":\""command"\"}"}' | jq -s '.' > "$output_file"
  else
    # Fallback without jq
    echo "[" > "$output_file"
    cat "${DASHBOARD_DIR}/data/commands/raw-history-${today}.txt" | grep -v "^#" | awk '{$1=""; timestamp=$2" "$3; $2=""; $3=""; command=$0; gsub(/^[ \t]+/, "", command); print "{\"timestamp\":\""timestamp"\",\"command\":\""command"\"},"}' >> "$output_file"
    # Remove trailing comma and close array
    sed -i '' '$ s/,$//' "$output_file"
    echo "]" >> "$output_file"
  fi
  
  log "INFO" "Command history tracked to $output_file"
}

# Track filesystem changes
track_filesystem_changes() {
  log "INFO" "Tracking filesystem changes"
  
  # Create data directory if it doesn't exist
  mkdir -p "${DASHBOARD_DIR}/data/filesystem"
  
  # Get today's date
  local today=$(date +%Y%m%d)
  local output_file="${DASHBOARD_DIR}/data/filesystem/changes-${today}.json"
  
  # Start JSON array
  echo "[" > "$output_file"
  
  # Track personal projects
  for project in $PERSONAL_PROJECTS; do
    if [ -d "$project" ]; then
      log "INFO" "Analyzing changes in $project"
      
      # Find recently modified files
      find "$project" -type f -mtime -1 | grep -v "node_modules\|.git" | while read file; do
        local rel_path="${file#$HOME/}"
        local mod_time=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$file")
        local file_type=$(file -b "$file")
        local file_size=$(stat -f "%z" "$file")
        
        echo "{\"path\":\"$rel_path\",\"modified\":\"$mod_time\",\"type\":\"$file_type\",\"size\":$file_size}," >> "$output_file"
      done
    fi
  done
  
  # Track work repos
  for repo in $WORK_REPOS; do
    if [ -d "$repo" ]; then
      log "INFO" "Analyzing changes in $repo"
      
      # Find recently modified files
      find "$repo" -type f -mtime -1 | grep -v "node_modules\|.git" | while read file; do
        local rel_path="${file#$HOME/}"
        local mod_time=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$file")
        local file_type=$(file -b "$file")
        local file_size=$(stat -f "%z" "$file")
        
        echo "{\"path\":\"$rel_path\",\"modified\":\"$mod_time\",\"type\":\"$file_type\",\"size\":$file_size}," >> "$output_file"
      done
    fi
  done
  
  # Remove trailing comma and close array
  sed -i '' '$ s/,$//' "$output_file"
  echo "]" >> "$output_file"
  
  log "INFO" "Filesystem changes tracked to $output_file"
}

# Track git repositories
track_git_repositories() {
  log "INFO" "Tracking git repositories"
  
  # Create data directory if it doesn't exist
  mkdir -p "${DASHBOARD_DIR}/data/git"
  
  # Get today's date
  local today=$(date +%Y%m%d)
  local output_file="${DASHBOARD_DIR}/data/git/repos-${today}.json"
  
  # Start JSON array
  echo "[" > "$output_file"
  
  # Track work repos
  for repo in $WORK_REPOS; do
    if [ -d "$repo/.git" ]; then
      log "INFO" "Analyzing git repository: $repo"
      
      local repo_name=$(basename "$repo")
      local branch=$(git -C "$repo" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
      local last_commit=$(git -C "$repo" log -1 --format="%H" 2>/dev/null || echo "none")
      local last_commit_date=$(git -C "$repo" log -1 --format="%cd" --date=format:"%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "unknown")
      local last_commit_msg=$(git -C "$repo" log -1 --format="%s" 2>/dev/null | sed 's/"/\\"/g' || echo "unknown")
      local uncommitted=$(git -C "$repo" status --porcelain | wc -l | tr -d ' ')
      
      echo "{\"repo\":\"$repo_name\",\"path\":\"$repo\",\"branch\":\"$branch\",\"lastCommit\":\"$last_commit\",\"lastCommitDate\":\"$last_commit_date\",\"lastCommitMessage\":\"$last_commit_msg\",\"uncommittedChanges\":$uncommitted}," >> "$output_file"
    fi
  done
  
  # Remove trailing comma and close array
  sed -i '' '$ s/,$//' "$output_file"
  echo "]" >> "$output_file"
  
  log "INFO" "Git repositories tracked to $output_file"
}

# Track Claude artifacts
track_claude_artifacts() {
  log "INFO" "Tracking Claude artifacts"
  
  # Create data directory if it doesn't exist
  mkdir -p "${DASHBOARD_DIR}/data/claude"
  
  # Get today's date
  local today=$(date +%Y%m%d)
  local output_file="${DASHBOARD_DIR}/data/claude/artifacts-${today}.json"
  
  # Start JSON array
  echo "[" > "$output_file"
  
  # Track Claude artifacts
  for artifact_path in $CLAUDE_ARTIFACT_PATHS; do
    if [ -d "$artifact_path" ]; then
      log "INFO" "Analyzing Claude artifacts in $artifact_path"
      
      # Find recently modified artifacts
      find "$artifact_path" -type f -mtime -7 | sort -r | while read file; do
        local rel_path="${file#$HOME/}"
        local mod_time=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$file")
        local file_size=$(stat -f "%z" "$file")
        local file_name=$(basename "$file")
        
        # Try to extract content summary
        local content_summary=""
        if [[ "$file" == *.md || "$file" == *.txt ]]; then
          content_summary=$(head -n 5 "$file" | tr -d '"' | tr '\n' ' ' | cut -c 1-100)
        fi
        
        echo "{\"name\":\"$file_name\",\"path\":\"$rel_path\",\"modified\":\"$mod_time\",\"size\":$file_size,\"summary\":\"$content_summary\"}," >> "$output_file"
      done
    fi
  done
  
  # Remove trailing comma and close array
  sed -i '' '$ s/,$//' "$output_file"
  echo "]" >> "$output_file"
  
  log "INFO" "Claude artifacts tracked to $output_file"
}

# Track script executions
track_script_executions() {
  log "INFO" "Tracking script executions"
  
  # Create data directory if it doesn't exist
  mkdir -p "${DASHBOARD_DIR}/data/scripts"
  
  # Get today's date
  local today=$(date +%Y%m%d)
  local output_file="${DASHBOARD_DIR}/data/scripts/executions-${today}.json"
  
  # Extract script executions from history
  if [ -f "${DASHBOARD_DIR}/data/commands/raw-history-${today}.txt" ]; then
    echo "[" > "$output_file"
    
    grep -E 'bazinga|.sh|kubectl|git' "${DASHBOARD_DIR}/data/commands/raw-history-${today}.txt" | \
    awk '{$1=""; timestamp=$2" "$3; $2=""; $3=""; command=$0; gsub(/^[ \t]+/, "", command); 
          if (command ~ /bazinga/) { type="bazinga"; }
          else if (command ~ /\.sh/) { type="script"; }
          else if (command ~ /kubectl/) { type="kubernetes"; }
          else if (command ~ /git/) { type="git"; }
          else { type="other"; }
          print "{\"timestamp\":\""timestamp"\",\"command\":\""command"\",\"type\":\""type"\"},"}' >> "$output_file"
    
    # Remove trailing comma and close array
    sed -i '' '$ s/,$//' "$output_file"
    echo "]" >> "$output_file"
    
    log "INFO" "Script executions tracked to $output_file"
  else
    log "WARNING" "Raw command history not found, skipping script execution tracking"
  fi
}

# Detect patterns
detect_patterns() {
  log "INFO" "Detecting patterns"
  
  # Create data directory if it doesn't exist
  mkdir -p "${DASHBOARD_DIR}/data/patterns"
  
  # Get today's date
  local today=$(date +%Y%m%d)
  local output_file="${DASHBOARD_DIR}/data/patterns/detected-${today}.json"
  
  # Start JSON array
  echo "[" > "$output_file"
  
  # Detect DODO patterns (oscillatory A->B->A->B patterns)
  if [ "$DODO_ENABLED" = "true" ]; then
    log "INFO" "Detecting DODO patterns"
    
    # Check command history for oscillatory patterns
    if [ -f "${DASHBOARD_DIR}/data/commands/raw-history-${today}.txt" ]; then
      # Look for repeated sequences of commands
      local prev_cmd=""
      local prev_dir=""
      
      grep "cd " "${DASHBOARD_DIR}/data/commands/raw-history-${today}.txt" | tail -n 50 | awk '{$1=""; $2=""; $3=""; print $0}' | sed 's/^[ \t]*//' | while read cmd; do
        if [[ "$cmd" =~ ^cd\ .* ]]; then
          local dir=$(echo "$cmd" | sed 's/^cd //')
          
          # Check for oscillation
          if [ "$dir" = "$prev_prev_dir" ] && [ "$prev_dir" != "$dir" ]; then
            echo "{\"type\":\"DODO\",\"pattern\":\"directory_oscillation\",\"value1\":\"$dir\",\"value2\":\"$prev_dir\",\"strength\":$DODO_AMPLIFICATION,\"timestamp\":\"$(date +%Y-%m-%d\ %H:%M:%S)\"}," >> "$output_file"
          fi
          
          local prev_prev_dir="$prev_dir"
          prev_dir="$dir"
        fi
      done
    fi
    
    # Check git repository switches
    if [ -f "${DASHBOARD_DIR}/data/git/repos-${today}.json" ]; then
      # TODO: Implement git repo oscillation detection
      :
    fi
  fi
  
  # Detect SINGULAR patterns (breakthrough moments)
  if [ "$SINGULAR_ENABLED" = "true" ]; then
    log "INFO" "Detecting SINGULAR patterns"
    
    # Check for large artifact creation
    if [ -f "${DASHBOARD_DIR}/data/claude/artifacts-${today}.json" ]; then
      # Find recent large artifacts
      for artifact_path in $CLAUDE_ARTIFACT_PATHS; do
        if [ -d "$artifact_path" ]; then
          find "$artifact_path" -type f -mtime -1 -size +10k | while read file; do
            local file_name=$(basename "$file")
            local mod_time=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$file")
            
            echo "{\"type\":\"SINGULAR\",\"pattern\":\"large_artifact\",\"value\":\"$file_name\",\"strength\":$SINGULAR_THRESHOLD,\"timestamp\":\"$mod_time\"}," >> "$output_file"
          done
        fi
      done
    fi
    
    # Check for repeated script executions
    if [ -f "${DASHBOARD_DIR}/data/scripts/executions-${today}.json" ]; then
      # TODO: Implement script execution pattern detection
      :
    fi
  fi
  
  # Remove trailing comma and close array
  sed -i '' '$ s/,$//' "$output_file" 2>/dev/null || echo "]" >> "$output_file"
  
  log "INFO" "Patterns detected and saved to $output_file"
}

# Generate HTML dashboard
generate_dashboard() {
  log "INFO" "Generating HTML dashboard"
  
  # Create dashboard file
  local dashboard_file="${DASHBOARD_DIR}/index.html"
  
  # Get today's date
  local today=$(date +%Y%m%d)
  
  # Generate dashboard HTML
  cat > "$dashboard_file" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>BAZINGA Unified Dashboard</title>
  <style>
    :root {
      --primary: #4a86e8;
      --secondary: #6aa84f;
      --warning: #e69138;
      --danger: #cc0000;
      --info: #3d85c6;
      --light: #f3f3f3;
      --dark: #333333;
      --gray: #888888;
    }
    
    body {
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      margin: 0;
      padding: 0;
      background-color: #f5f5f5;
      color: var(--dark);
    }
    
    .container {
      max-width: 1200px;
      margin: 0 auto;
      padding: 20px;
    }
    
    header {
      background-color: var(--primary);
      color: white;
      padding: 1rem;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    
    h1, h2, h3, h4 {
      margin-top: 0;
    }
    
    .card {
      background-color: white;
      border-radius: 8px;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
      margin-bottom: 20px;
      overflow: hidden;
    }
    
    .card-header {
      padding: 15px 20px;
      border-bottom: 1px solid #eee;
      font-weight: bold;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    
    .card-body {
      padding: 20px;
      max-height: 400px;
      overflow-y: auto;
    }
    
    .section {
      margin-bottom: 30px;
    }
    
    .grid {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 20px;
    }
    
    @media (max-width: 768px) {
      .grid {
        grid-template-columns: 1fr;
      }
    }
    
    .badge {
      display: inline-block;
      padding: 3px 8px;
      border-radius: 12px;
      font-size: 12px;
      font-weight: bold;
      color: white;
      margin-left: 5px;
    }
    
    .badge-primary { background-color: var(--primary); }
    .badge-secondary { background-color: var(--secondary); }
    .badge-warning { background-color: var(--warning); }
    .badge-danger { background-color: var(--danger); }
    .badge-info { background-color: var(--info); }
    
    table {
      width: 100%;
      border-collapse: collapse;
    }
    
    table th, table td {
      padding: 8px 12px;
      text-align: left;
      border-bottom: 1px solid #eee;
    }
    
    table th {
      background-color: #f9f9f9;
    }
    
    .chart-container {
      height: 300px;
      position: relative;
    }
    
    .timeline {
      position: relative;
      padding: 0 0 0 30px;
    }
    
    .timeline::before {
      content: '';
      position: absolute;
      left: 10px;
      top: 0;
      bottom: 0;
      width: 2px;
      background-color: var(--gray);
    }
    
    .timeline-item {
      position: relative;
      margin-bottom: 20px;
    }
    
    .timeline-item::before {
      content: '';
      position: absolute;
      left: -25px;
      top: 5px;
      width: 12px;
      height: 12px;
      border-radius: 50%;
      background-color: var(--primary);
    }
    
    .timeline-item.dodo::before {
      background-color: var(--warning);
    }
    
    .timeline-item.singular::before {
      background-color: var(--info);
    }
    
    .timeline-content {
      padding: 10px 15px;
      background-color: #fff;
      border-radius: 6px;
      box-shadow: 0 1px 3px rgba(0,0,0,0.1);
    }
    
    .timeline-time {
      color: var(--gray);
      font-size: 12px;
      margin-bottom: 5px;
    }
    
    .timeline-content h4 {
      margin: 0 0 5px 0;
    }
    
    .reload-btn {
      background-color: var(--secondary);
      color: white;
      border: none;
      padding: 5px 10px;
      border-radius: 4px;
      cursor: pointer;
      font-size: 12px;
    }
    
    .reload-btn:hover {
      background-color: #5a9342;
    }
    
    .category-tag {
      display: inline-block;
      padding: 2px 6px;
      border-radius: 4px;
      font-size: 11px;
      background-color: #eee;
      margin-right: 5px;
    }
    
    .pattern-indicator {
      display: inline-block;
      width: 8px;
      height: 8px;
      border-radius: 50%;
      margin-right: 5px;
    }
    
    .pattern-dodo {
      background-color: var(--warning);
    }
    
    .pattern-singular {
      background-color: var(--info);
    }
    
    .meta-info {
      color: var(--gray);
      font-size: 12px;
      margin-top: 20px;
    }
    
    .progress-container {
      background-color: #eee;
      border-radius: 4px;
      height: 8px;
      width: 100%;
      margin-top: 5px;
    }
    
    .progress-bar {
      height: 100%;
      border-radius: 4px;
      background-color: var(--primary);
    }
    
    .status-indicator {
      display: inline-block;
      width: 8px;
      height: 8px;
      border-radius: 50%;
      margin-right: 5px;
    }
    
    .status-active { background-color: var(--secondary); }
    .status-pending { background-color: var(--warning); }
    .status-idle { background-color: var(--gray); }
  </style>
</head>
<body>
  <header>
    <div class="container">
      <h1>⟨ψ|⟳|ψ⟩ BAZINGA Unified Dashboard</h1>
      <p>Pattern tracking and visualization system</p>
    </div>
  </header>
  
  <div class="container">
    <div class="section">
      <h2>System Overview <span id="lastUpdate" class="badge badge-secondary">Updating...</span></h2>
      
      <div class="grid">
        <div class="card">
          <div class="card-header">
            Active Projects
            <button class="reload-btn" onclick="loadProjects()">Reload</button>
          </div>
          <div class="card-body">
            <div id="projectsContent">Loading...</div>
          </div>
        </div>
        
        <div class="card">
          <div class="card-header">
            Recent Patterns
            <button class="reload-btn" onclick="loadPatterns()">Reload</button>
          </div>
          <div class="card-body">
            <div id="patternsContent">Loading...</div>
          </div>
        </div>
      </div>
    </div>
    
    <div class="section">
      <h2>Activity Timeline</h2>
      <div class="card">
        <div class="card-header">
          Recent Activities
          <button class="reload-btn" onclick="loadTimeline()">Reload</button>
        </div>
        <div class="card-body">
          <div class="timeline" id="timelineContent">
            Loading...
          </div>
        </div>
      </div>
    </div>
    
    <div class="section">
      <h2>Detailed Tracking</h2>
      
      <div class="grid">
        <div class="card">
          <div class="card-header">
            Command History
            <button class="reload-btn" onclick="loadCommands()">Reload</button>
          </div>
          <div class="card-body">
            <div id="commandsContent">Loading...</div>
          </div>
        </div>
        
        <div class="card">
          <div class="card-header">
            Claude Artifacts
            <button class="reload-btn" onclick="loadArtifacts()">Reload</button>
          </div>
          <div class="card-body">
            <div id="artifactsContent">Loading...</div>
          </div>
        </div>
      </div>
      
      <div class="grid">
        <div class="card">
          <div class="card-header">
            Git Repositories
            <button class="reload-btn" onclick="loadGit()">Reload</button>
          </div>
          <div class="card-body">
            <div id="gitContent">Loading...</div>
          </div>
        </div>
        
        <div class="card">
          <div class="card-header">
            FileSystem Changes
            <button class="reload-btn" onclick="loadFilesystem()">Reload</button>
          </div>
          <div class="card-body">
            <div id="filesystemContent">Loading...</div>
          </div>
        </div>
      </div>
    </div>
    
    <div class="meta-info">
      <p>Dashboard generated on $(date '+%Y-%m-%d %H:%M:%S')</p>
      <p>BAZINGA Unified Tracking System v1.0</p>
    </div>
  </div>
  
  <script>
    // Utility functions
    function formatDate(dateString) {
      const date = new Date(dateString);
      return date.toLocaleString();
    }
    
    function shortenText(text, maxLength) {
      if (!text) return '';
      return text.length > maxLength ? text.substring(0, maxLength) + '...' : text;
    }
    
    // Load data functions
    async function loadProjects() {
      try {
        const gitData = await fetch('data/git/repos-$(date +%Y%m%d).json').then(r => r.json());
        let html = '<table>';
        html += '<tr><th>Repository</th><th>Branch</th><th>Last Commit</th><th>Status</th></tr>';
        
        gitData.forEach(repo => {
          const status = repo.uncommittedChanges > 0 ? 
            '<span class="status-indicator status-pending"></span>Uncommitted changes' : 
            '<span class="status-indicator status-active"></span>Up to date';
          
          html += `<tr>
            <td>${repo.repo}</td>
            <td>${repo.branch}</td>
            <td>${shortenText(repo.lastCommitMessage, 30)}<br><small>${formatDate(repo.lastCommitDate)}</small></td>
            <td>${status}</td>
          </tr>`;
        });
        
        html += '</table>';
        document.getElementById('projectsContent').innerHTML = html;
      } catch (error) {
        document.getElementById('projectsContent').innerHTML = `<p>Error loading projects: ${error.message}</p>`;
      }
    }
    
    async function loadPatterns() {
      try {
        const patternData = await fetch('data/patterns/detected-$(date +%Y%m%d).json').then(r => r.json());
        
        if (patternData.length === 0) {
          document.getElementById('patternsContent').innerHTML = '<p>No patterns detected today.</p>';
          return;
        }
        
        let html = '';
        
        patternData.forEach(pattern => {
          const patternClass = pattern.type.toLowerCase();
          html += `<div class="timeline-item ${patternClass}">
            <div class="timeline-content">
              <div class="timeline-time">${formatDate(pattern.timestamp)}</div>
              <h4>
                <span class="pattern-indicator pattern-${patternClass}"></span>
                ${pattern.type} Pattern
              </h4>
              <p>${pattern.pattern}: ${pattern.value || pattern.value1 + ' ↔ ' + pattern.value2}</p>
              <div class="progress-container">
                <div class="progress-bar" style="width: ${Math.min(100, pattern.strength * 20)}%"></div>
              </div>
            </div>
          </div>`;
        });
        
        document.getElementById('patternsContent').innerHTML = html;
      } catch (error) {
        document.getElementById('patternsContent').innerHTML = `<p>Error loading patterns: ${error.message}</p>`;
      }
    }
    
    async function loadTimeline() {
      try {
        // Load commands
        const commandData = await fetch('data/commands/history-$(date +%Y%m%d).json').then(r => r.json());
        // Load git
        const gitData = await fetch('data/git/repos-$(date +%Y%m%d).json').then(r => r.json());
        // Load artifacts
        const artifactData = await fetch('data/claude/artifacts-$(date +%Y%m%d).json').then(r => r.json());
        // Load patterns
        const patternData = await fetch('data/patterns/detected-$(date +%Y%m%d).json').then(r => r.json()).catch(() => []);
        
        // Combine and sort by timestamp
        const timelineItems = [
          ...commandData.filter(cmd => cmd.command.includes('bazinga') || cmd.command.includes('vault') || 
                                    cmd.command.includes('kubectl') || cmd.command.includes('git'))
            .map(cmd => ({
              type: 'command',
              timestamp: cmd.timestamp,
              content: cmd.command,
              category: cmd.command.includes('bazinga') ? 'bazinga' : 
                       cmd.command.includes('vault') ? 'vault' :
                       cmd.command.includes('kubectl') ? 'kubernetes' : 'git'
            })),
          ...gitData.map(repo => ({
            type: 'git',
            timestamp: repo.lastCommitDate,
            content: `Commit to ${repo.repo}: ${repo.lastCommitMessage}`,
            category: 'git'
          })),
          ...artifactData.map(artifact => ({
            type: 'artifact',
            timestamp: artifact.modified,
            content: `Claude artifact: ${artifact.name}`,
            summary: artifact.summary,
            category: 'claude'
          })),
          ...patternData.map(pattern => ({
            type: 'pattern',
            timestamp: pattern.timestamp,
            content: `${pattern.type} pattern detected: ${pattern.pattern}`,
            patternType: pattern.type.toLowerCase(),
            category: 'pattern'
          }))
        ].sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));
        
        // Take only the most recent items
        const recentItems = timelineItems.slice(0, 30);
        
        let html = '';
        
        recentItems.forEach(item => {
          const itemClass = item.type === 'pattern' ? item.patternType : '';
          
          html += `<div class="timeline-item ${itemClass}">
            <div class="timeline-content">
              <div class="timeline-time">${formatDate(item.timestamp)}</div>
              <h4>
                <span class="category-tag">${item.category}</span>
                ${item.type.charAt(0).toUpperCase() + item.type.slice(1)}
              </h4>
              <p>${shortenText(item.content, 100)}</p>
              ${item.summary ? `<p><small>${shortenText(item.summary, 150)}</small></p>` : ''}
            </div>
          </div>`;
        });
        
        document.getElementById('timelineContent').innerHTML = html || '<p>No recent activity.</p>';
      } catch (error) {
        document.getElementById('timelineContent').innerHTML = `<p>Error loading timeline: ${error.message}</p>`;
      }
    }
    
    async function loadCommands() {
      try {
        const commandData = await fetch('data/commands/history-$(date +%Y%m%d).json').then(r => r.json());
        
        const categories = {
          bazinga: commandData.filter(cmd => cmd.command.includes('bazinga')),
          vault: commandData.filter(cmd => cmd.command.includes('vault') || cmd.command.includes('federated')),
          git: commandData.filter(cmd => cmd.command.includes('git')),
          kubectl: commandData.filter(cmd => cmd.command.includes('kubectl'))
        };
        
        let html = '<ul>';
        
        Object.entries(categories).forEach(([category, commands]) => {
          if (commands.length > 0) {
            html += `<li><strong>${category.charAt(0).toUpperCase() + category.slice(1)} Commands (${commands.length})</strong>`;
            html += '<ul>';
            commands.slice(0, 5).forEach(cmd => {
              html += `<li>${shortenText(cmd.command, 80)}<br><small>${formatDate(cmd.timestamp)}</small></li>`;
            });
            if (commands.length > 5) {
              html += `<li><small>...and ${commands.length - 5} more</small></li>`;
            }
            html += '</ul></li>';
          }
        });
        
        html += '</ul>';
        document.getElementById('commandsContent').innerHTML = html;
      } catch (error) {
        document.getElementById('commandsContent').innerHTML = `<p>Error loading commands: ${error.message}</p>`;
      }
    }
    
    async function loadArtifacts() {
      try {
        const artifactData = await fetch('data/claude/artifacts-$(date +%Y%m%d).json').then(r => r.json());
        
        if (artifactData.length === 0) {
          document.getElementById('artifactsContent').innerHTML = '<p>No Claude artifacts found.</p>';
          return;
        }
        
        let html = '<table>';
        html += '<tr><th>Name</th><th>Modified</th><th>Summary</th></tr>';
        
        artifactData.slice(0, 10).forEach(artifact => {
          html += `<tr>
            <td>${artifact.name}</td>
            <td>${formatDate(artifact.modified)}</td>
            <td>${shortenText(artifact.summary || 'No summary available', 50)}</td>
          </tr>`;
        });
        
        html += '</table>';
        
        if (artifactData.length > 10) {
          html += `<p><small>...and ${artifactData.length - 10} more artifacts</small></p>`;
        }
        
        document.getElementById('artifactsContent').innerHTML = html;
      } catch (error) {
        document.getElementById('artifactsContent').innerHTML = `<p>Error loading artifacts: ${error.message}</p>`;
      }
    }
    
    async function loadGit() {
      try {
        const gitData = await fetch('data/git/repos-$(date +%Y%m%d).json').then(r => r.json());
        
        if (gitData.length === 0) {
          document.getElementById('gitContent').innerHTML = '<p>No Git repositories found.</p>';
          return;
        }
        
        let html = '<table>';
        html += '<tr><th>Repository</th><th>Branch</th><th>Changes</th></tr>';
        
        gitData.forEach(repo => {
          html += `<tr>
            <td>${repo.repo}</td>
            <td>${repo.branch}</td>
            <td>${repo.uncommittedChanges} uncommitted files</td>
          </tr>`;
        });
        
        html += '</table>';
        document.getElementById('gitContent').innerHTML = html;
      } catch (error) {
        document.getElementById('gitContent').innerHTML = `<p>Error loading Git data: ${error.message}</p>`;
      }
    }
    
    async function loadFilesystem() {
      try {
        const fsData = await fetch('data/filesystem/changes-$(date +%Y%m%d).json').then(r => r.json());
        
        if (fsData.length === 0) {
          document.getElementById('filesystemContent').innerHTML = '<p>No filesystem changes detected.</p>';
          return;
        }
        
        // Group by file type
        const fileTypes = {};
        fsData.forEach(file => {
          const ext = file.path.split('.').pop() || 'unknown';
          fileTypes[ext] = fileTypes[ext] || [];
          fileTypes[ext].push(file);
        });
        
        let html = '<ul>';
        
        Object.entries(fileTypes).forEach(([type, files]) => {
          html += `<li><strong>${type} files (${files.length})</strong>`;
          html += '<ul>';
          files.slice(0, 3).forEach(file => {
            html += `<li>${shortenText(file.path, 50)}<br><small>Modified: ${formatDate(file.modified)}</small></li>`;
          });
          if (files.length > 3) {
            html += `<li><small>...and ${files.length - 3} more</small></li>`;
          }
          html += '</ul></li>';
        });
        
        html += '</ul>';
        document.getElementById('filesystemContent').innerHTML = html;
      } catch (error) {
        document.getElementById('filesystemContent').innerHTML = `<p>Error loading filesystem data: ${error.message}</p>`;
      }
    }
    
    // Update last update time
    function updateLastUpdate() {
      document.getElementById('lastUpdate').textContent = `Last updated: ${new Date().toLocaleTimeString()}`;
    }
    
    // Initialize all data
    async function initDashboard() {
      loadProjects();
      loadPatterns();
      loadTimeline();
      loadCommands();
      loadArtifacts();
      loadGit();
      loadFilesystem();
      updateLastUpdate();
    }
    
    // Start dashboard
    window.addEventListener('DOMContentLoaded', initDashboard);
    
    // Refresh periodically
    setInterval(initDashboard, ${REFRESH_INTERVAL * 1000 || 60000});
  </script>
</body>
</html>
EOF

  log "INFO" "Dashboard generated at $dashboard_file"
}

# Function to install dependencies
install_dependencies() {
  log "INFO" "Checking and installing dependencies"
  
  # Check for jq
  if ! command -v jq &>/dev/null; then
    log "WARNING" "jq not found, some features may be limited"
    # Try to install jq if possible
    if command -v brew &>/dev/null; then
      log "INFO" "Installing jq using Homebrew"
      brew install jq
    else
      log "WARNING" "Homebrew not found, cannot automatically install jq"
    fi
  fi
  
  # Check for dot (Graphviz)
  if ! command -v dot &>/dev/null; then
    log "WARNING" "Graphviz not found, visualization will be limited"
    # Try to install Graphviz if possible
    if command -v brew &>/dev/null; then
      log "INFO" "Installing Graphviz using Homebrew"
      brew install graphviz
    else
      log "WARNING" "Homebrew not found, cannot automatically install Graphviz"
    fi
  fi
}

# Create auto-start script
create_auto_start() {
  log "INFO" "Creating auto-start script"
  
  local auto_start_script="${BASE_DIR}/bin/bazinga-dashboard-auto.sh"
  
  cat > "$auto_start_script" << EOF
#!/bin/bash
# Auto-start script for BAZINGA Dashboard
# Add to crontab with: crontab -e
# */30 * * * * ${auto_start_script} > /dev/null 2>&1

# Run the dashboard script
${SCRIPT_DIR}/bazinga-dashboard.sh auto
EOF

  chmod +x "$auto_start_script"
  
  log "INFO" "Auto-start script created at $auto_start_script"
  log "INFO" "To enable auto-start, add to crontab with: crontab -e"
  log "INFO" "Add line: */30 * * * * ${auto_start_script} > /dev/null 2>&1"
}

# Create a script to serve the dashboard
create_server_script() {
  log "INFO" "Creating server script"
  
  local server_script="${BASE_DIR}/bin/bazinga-dashboard-serve.sh"
  
  cat > "$server_script" << EOF
#!/bin/bash
# Server script for BAZINGA Dashboard
# Usage: ${server_script} [port]

PORT="\${1:-8080}"
DASHBOARD_DIR="${DASHBOARD_DIR}"

# Check if Python is available
if command -v python3 &>/dev/null; then
  echo "Starting server on http://localhost:\${PORT}"
  echo "Press Ctrl+C to stop"
  cd "\${DASHBOARD_DIR}" && python3 -m http.server "\${PORT}"
elif command -v python &>/dev/null; then
  echo "Starting server on http://localhost:\${PORT}"
  echo "Press Ctrl+C to stop"
  cd "\${DASHBOARD_DIR}" && python -m SimpleHTTPServer "\${PORT}"
else
  echo "Python not found, cannot start server"
  exit 1
fi
EOF

  chmod +x "$server_script"
  
  log "INFO" "Server script created at $server_script"
  log "INFO" "To serve the dashboard, run: $server_script [port]"
}

# Full run - execute all functions
full_run() {
  log "INFO" "Starting full dashboard generation"
  
  # Load config
  load_config
  
  # Track data
  track_command_history
  track_filesystem_changes
  track_git_repositories
  track_claude_artifacts
  track_script_executions
  
  # Process data
  detect_patterns
  
  # Generate dashboard
  generate_dashboard
  
  # Create helper scripts
  create_auto_start
  create_server_script
  
  log "INFO" "Full dashboard generation completed"
  log "INFO" "Dashboard available at: $DASHBOARD_DIR/index.html"
  log "INFO" "To serve the dashboard, run: ${BASE_DIR}/bin/bazinga-dashboard-serve.sh"
}

# Auto run - for cron jobs
auto_run() {
  log "INFO" "Starting automatic dashboard generation"
  
  # Load config
  load_config
  
  # Track data
  track_command_history
  track_filesystem_changes
  track_git_repositories
  track_claude_artifacts
  track_script_executions
  
  # Process data
  detect_patterns
  
  # Generate dashboard
  generate_dashboard
  
  log "INFO" "Automatic dashboard generation completed"
}

# Display usage information
usage() {
  echo "BAZINGA Unified Dashboard"
  echo ""
  echo "Usage: $0 [command]"
  echo ""
  echo "Commands:"
  echo "  run               Full dashboard generation"
  echo "  auto              Automatic generation (for cron jobs)"
  echo "  history           Track command history only"
  echo "  filesystem        Track filesystem changes only"
  echo "  git               Track git repositories only"
  echo "  claude            Track Claude artifacts only"
  echo "  scripts           Track script executions only"
  echo "  patterns          Detect patterns only"
  echo "  generate          Generate dashboard HTML only"
  echo "  serve [port]      Serve the dashboard (default port: 8080)"
  echo "  install           Install dependencies"
  echo "  help              Display this help message"
  echo ""
  echo "Examples:"
  echo "  $0 run            # Generate full dashboard"
  echo "  $0 serve 8000     # Serve dashboard on port 8000"
}

# Main function
main() {
  # Create log directory if it doesn't exist
  mkdir -p "$(dirname "$LOG_FILE")"
  
  # Process command line arguments
  case "$1" in
    run)
      full_run
      ;;
    auto)
      auto_run
      ;;
    history)
      load_config
      track_command_history
      ;;
    filesystem)
      load_config
      track_filesystem_changes
      ;;
    git)
      load_config
      track_git_repositories
      ;;
    claude)
      load_config
      track_claude_artifacts
      ;;
    scripts)
      load_config
      track_script_executions
      ;;
    patterns)
      load_config
      detect_patterns
      ;;
    generate)
      load_config
      generate_dashboard
      ;;
    serve)
      local port="${2:-8080}"
      if [ -f "${DASHBOARD_DIR}/index.html" ]; then
        log "INFO" "Serving dashboard on http://localhost:${port}"
        if command -v python3 &>/dev/null; then
          (cd "${DASHBOARD_DIR}" && python3 -m http.server "${port}")
        elif command -v python &>/dev/null; then
          (cd "${DASHBOARD_DIR}" && python -m SimpleHTTPServer "${port}")
        else
          log "ERROR" "Python not found, cannot serve dashboard"
          exit 1
        fi
      else
        log "ERROR" "Dashboard file not found: ${DASHBOARD_DIR}/index.html"
        log "INFO" "Generate it first with: $0 generate"
        exit 1
      fi
      ;;
    install)
      install_dependencies
      ;;
    help|*)
      usage
      ;;
  esac
}

# Run the main function
main "$@"
