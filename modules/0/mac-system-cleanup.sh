#!/bin/bash
# mac-system-cleanup.sh - Comprehensive Mac cleanup and maintenance script

# Configuration
LOG_DIR="$HOME/ClaudeArtifacts/logs"
LOG_FILE="$LOG_DIR/system-cleanup-$(date +%Y%m%d).log"
DOWNLOADS_DIR="$HOME/Downloads"
DOWNLOADS_PROCESSED_DIR="$HOME/Downloads/Processed"
OLD_FILE_THRESHOLD=30  # days
MAX_LOG_AGE=90  # days

# Create logs directory
mkdir -p "$LOG_DIR"

# Initialize log
echo "$(date): System Cleanup started" > "$LOG_FILE"

# Function to log messages
log() {
  echo "$(date): $1" >> "$LOG_FILE"
  echo "$1"
}

# Function to clean up downloads folder
cleanup_downloads() {
  log "Cleaning up downloads folder..."
  
  # Create processed directory if it doesn't exist
  mkdir -p "$DOWNLOADS_PROCESSED_DIR/"{documents,images,archives,installers,videos,audio,other}
  
  # Move files older than threshold to appropriate directories
  find "$DOWNLOADS_DIR" -maxdepth 1 -type f -mtime +$OLD_FILE_THRESHOLD | while read file; do
    filename=$(basename "$file")
    extension="${filename##*.}"
    
    # Skip already processed files
    if [[ "$file" == "$DOWNLOADS_PROCESSED_DIR/"* ]]; then
      continue
    fi
    
    # Determine destination based on extension
    case "$extension" in
      pdf|doc|docx|txt|rtf|xls|xlsx|ppt|pptx|odt|ods|odp)
        dest="$DOWNLOADS_PROCESSED_DIR/documents"
        ;;
      jpg|jpeg|png|gif|bmp|tiff|svg|webp)
        dest="$DOWNLOADS_PROCESSED_DIR/images"
        ;;
      zip|rar|tar|gz|7z|bz2|xz)
        dest="$DOWNLOADS_PROCESSED_DIR/archives"
        ;;
      dmg|pkg|app)
        dest="$DOWNLOADS_PROCESSED_DIR/installers"
        ;;
      mp4|mov|avi|mkv|webm|flv|wmv)
        dest="$DOWNLOADS_PROCESSED_DIR/videos"
        ;;
      mp3|wav|aac|flac|ogg|m4a)
        dest="$DOWNLOADS_PROCESSED_DIR/audio"
        ;;
      *)
        dest="$DOWNLOADS_PROCESSED_DIR/other"
        ;;
    esac
    
    # Move file
    mv "$file" "$dest/"
    log "Moved old file: $file -> $dest/$filename"
  done
  
  log "Downloads cleanup completed"
}

# Function to clean system caches
clean_caches() {
  log "Cleaning system caches..."
  
  # Clean user cache
  rm -rf "$HOME/Library/Caches/"*
  log "Cleaned user cache directory"
  
  # Clean Safari cache if it exists
  if [ -d "$HOME/Library/Safari/Cache/" ]; then
    rm -rf "$HOME/Library/Safari/Cache/"*
    log "Cleaned Safari cache"
  fi
  
  # Clean Chrome cache if it exists
  if [ -d "$HOME/Library/Caches/Google/Chrome/" ]; then
    rm -rf "$HOME/Library/Caches/Google/Chrome/Default/Cache/"*
    log "Cleaned Chrome cache"
  fi
  
  # Clean Firefox cache if it exists
  if [ -d "$HOME/Library/Caches/Firefox/" ]; then
    rm -rf "$HOME/Library/Caches/Firefox/Profiles/"*"/cache2/"*
    log "Cleaned Firefox cache"
  fi
  
  log "Cache cleaning completed"
}

# Function to clean old logs
clean_logs() {
  log "Cleaning old log files..."
  
  # Clean old logs from ClaudeArtifacts
  find "$LOG_DIR" -name "*.log" -type f -mtime +$MAX_LOG_AGE -delete
  log "Cleaned old logs from ClaudeArtifacts"
  
  # Clean system logs (requires sudo)
  echo "System logs require sudo privileges to clean."
  echo "If prompted, please enter your password to clean system logs."
  sudo rm -f /var/log/*.out.*.gz 2>/dev/null
  sudo rm -f /var/log/*.log.*.gz 2>/dev/null
  log "Cleaned old system logs"
  
  log "Log cleaning completed"
}

# Function to check disk space
check_disk_space() {
  log "Checking disk space..."
  
  # Get disk usage
  df_output=$(df -h /)
  available=$(echo "$df_output" | awk 'NR==2 {print $4}')
  usage_percent=$(echo "$df_output" | awk 'NR==2 {print $5}' | tr -d '%')
  
  log "Available disk space: $available"
  log "Disk usage: $usage_percent%"
  
  # Alert if disk space is low
  if [ "$usage_percent" -gt 85 ]; then
    log "WARNING: Disk space is critically low!"
    osascript -e 'display notification "Disk space is critically low! Only '"$available"' available." with title "System Alert" sound name "Basso"'
  elif [ "$usage_percent" -gt 75 ]; then
    log "Warning: Disk space is getting low."
    osascript -e 'display notification "Disk space is getting low. '"$available"' available." with title "System Alert" sound name "Ping"'
  fi
}

# Function to check system health
check_system_health() {
  log "Checking system health..."
  
  # Check CPU load
  cpu_load=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | tr -d '%')
  log "CPU load: $cpu_load%"
  
  # Check memory usage
  memory_pressure=$(memory_pressure | grep "System-wide memory free percentage:" | awk '{print $5}')
  log "Memory free: $memory_pressure%"
  
  # Check battery health if it's a laptop
  if system_profiler SPPowerDataType | grep -q "Battery"; then
    battery_health=$(system_profiler SPPowerDataType | grep "Condition" | awk '{print $2}')
    log "Battery condition: $battery_health"
  fi
  
  # Alert for high CPU usage
  if [ "$cpu_load" -gt 80 ]; then
    log "WARNING: High CPU usage detected!"
    osascript -e 'display notification "High CPU usage detected: '"$cpu_load"'%" with title "System Alert" sound name "Basso"'
  fi
  
  # Alert for low memory
  if [ "$memory_pressure" -lt 15 ]; then
    log "WARNING: Low memory availability!"
    osascript -e 'display notification "Low memory availability: '"$memory_pressure"'% free" with title "System Alert" sound name "Basso"'
  fi
}

# Process command line arguments
case "$1" in
  downloads)
    cleanup_downloads
    ;;
  caches)
    clean_caches
    ;;
  logs)
    clean_logs
    ;;
  disk)
    check_disk_space
    ;;
  health)
    check_system_health
    ;;
  all)
    cleanup_downloads
    clean_caches
    clean_logs
    check_disk_space
    check_system_health
    log "Full system cleanup completed"
    ;;
  *)
    echo "Mac System Cleanup Utility"
    echo "Usage:"
    echo "  $0 downloads - Clean up downloads folder"
    echo "  $0 caches - Clean system caches"
    echo "  $0 logs - Clean old log files"
    echo "  $0 disk - Check disk space"
    echo "  $0 health - Check system health"
    echo "  $0 all - Perform all cleanup operations"
    ;;
esac

log "System Cleanup completed"
