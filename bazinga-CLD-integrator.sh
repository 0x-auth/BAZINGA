#!/bin/bash
# bazinga-claude-integrator.sh - Integrate Claude artifacts with BAZINGA framework

# Configuration
CLAUDE_DIR="$HOME/ClaudeArtifacts"
BAZINGA_DIR="$HOME/bazinga-integrator"
LOG_FILE="$CLAUDE_DIR/logs/bazinga-integration-$(date +%Y%m%d).log"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Initialize log
echo "$(date): BAZINGA Claude Integration started" > "$LOG_FILE"

# Function to log messages
log() {
  echo "$(date): $1" >> "$LOG_FILE"
  echo "$1"
}

# Function to check BAZINGA environment
check_bazinga() {
  if [ ! -d "$BAZINGA_DIR" ]; then
    log "ERROR: BAZINGA directory not found at $BAZINGA_DIR"
    echo "Please set up BAZINGA directory first or update the script."
    exit 1
  fi
  
  # Check for key directories
  for dir in "artifacts" "tools" "core"; do
    if [ ! -d "$BAZINGA_DIR/$dir" ]; then
      log "Creating missing BAZINGA directory: $BAZINGA_DIR/$dir"
      mkdir -p "$BAZINGA_DIR/$dir"
    fi
  done
  
  log "BAZINGA environment verified"
}

# Function to sync Claude artifacts to BAZINGA
sync_artifacts() {
  log "Syncing Claude artifacts to BAZINGA..."
  
  # Create BAZINGA Claude artifacts directory if it doesn't exist
  mkdir -p "$BAZINGA_DIR/artifacts/claude"
  
  # Find JSON artifacts (they're most useful for BAZINGA)
  find "$CLAUDE_DIR/artifacts" -type f -name "*.json" | while read file; do
    filename=$(basename "$file")
    
    # Copy to BAZINGA artifacts directory
    cp "$file" "$BAZINGA_DIR/artifacts/claude/$filename"
    log "Synced: $file -> $BAZINGA_DIR/artifacts/claude/$filename"
  done
  
  # Find HTML artifacts
  find "$CLAUDE_DIR/artifacts" -type f -name "*.html" | while read file; do
    filename=$(basename "$file")
    
    # Copy to BAZINGA artifacts directory
    cp "$file" "$BAZINGA_DIR/artifacts/claude/$filename"
    log "Synced: $file -> $BAZINGA_DIR/artifacts/claude/$filename"
  done
  
  log "Artifact sync completed"
}

# Function to integrate medical data
integrate_medical_data() {
  log "Integrating medical data analysis..."
  
  # Create medical analysis directory if it doesn't exist
  mkdir -p "$BAZINGA_DIR/artifacts/medical"
  
  # Look for medical-related artifacts
  find "$CLAUDE_DIR/artifacts" -type f | grep -i "medical\|health\|doctor\|clinical\|therapy\|prescription\|medication" | while read file; do
    filename=$(basename "$file")
    
    # Copy to medical directory
    cp "$file" "$BAZINGA_DIR/artifacts/medical/$filename"
    log "Added to medical analysis: $filename"
  done
  
  log "Medical data integration completed"
}

# Function to integrate WhatsApp analysis
integrate_whatsapp() {
  log "Integrating WhatsApp analysis..."
  
  # Create WhatsApp analysis directory if it doesn't exist
  mkdir -p "$BAZINGA_DIR/artifacts/whatsapp"
  
  # Look for WhatsApp-related artifacts
  find "$CLAUDE_DIR/artifacts" -type f | grep -i "whatsapp\|chat\|message\|conversation" | while read file; do
    filename=$(basename "$file")
    
    # Copy to WhatsApp directory
    cp "$file" "$BAZINGA_DIR/artifacts/whatsapp/$filename"
    log "Added to WhatsApp analysis: $filename"
  done
  
  log "WhatsApp integration completed"
}

# Function to create run scripts for BAZINGA
create_run_scripts() {
  log "Creating BAZINGA run scripts..."
  
  # Create scripts directory if it doesn't exist
  mkdir -p "$BAZINGA_DIR/scripts"
  
  # Create a script to run full BAZINGA analysis
  cat > "$BAZINGA_DIR/scripts/run-full-analysis.sh" << 'EOF'
#!/bin/bash
# Full BAZINGA analysis runner

BAZINGA_DIR="$HOME/bazinga-integrator"
OUTPUT_DIR="$BAZINGA_DIR/output/$(date +%Y%m%d_%H%M%S)"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Run the main BAZINGA analysis
echo "Running BAZINGA analysis..."
"$BAZINGA_DIR/run-bazinga.sh" "$BAZINGA_DIR/artifacts/claude/combined-analysis.json" "$OUTPUT_DIR"

echo "Analysis complete. Results available at: $OUTPUT_DIR"
echo "Opening results in browser..."
open "$OUTPUT_DIR/index.html"
EOF

  # Make it executable
  chmod +x "$BAZINGA_DIR/scripts/run-full-analysis.sh"
  log "Created run-full-analysis.sh script"
  
  # Create a medical-specific analysis script
  cat > "$BAZINGA_DIR/scripts/run-medical-analysis.sh" << 'EOF'
#!/bin/bash
# Medical-focused BAZINGA analysis runner

BAZINGA_DIR="$HOME/bazinga-integrator"
OUTPUT_DIR="$BAZINGA_DIR/output/medical_$(date +%Y%m%d_%H%M%S)"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Run the BAZINGA analysis with medical focus
echo "Running medical-focused BAZINGA analysis..."

# First, check if the medical JSON exists
if [ -f "$BAZINGA_DIR/artifacts/medical/combined-medical-analysis.json" ]; then
  "$BAZINGA_DIR/tools/medical-appointment.sh" "$BAZINGA_DIR/artifacts/medical/combined-medical-analysis.json" "$OUTPUT_DIR/medical-appointment.html"
else
  # Fall back to general analysis
  "$BAZINGA_DIR/tools/medical-appointment.sh" "$BAZINGA_DIR/artifacts/claude/combined-analysis.json" "$OUTPUT_DIR/medical-appointment.html"
fi

echo "Medical analysis complete. Results available at: $OUTPUT_DIR"
echo "Opening results in browser..."
open "$OUTPUT_DIR/medical-appointment.html"
EOF

  # Make it executable
  chmod +x "$BAZINGA_DIR/scripts/run-medical-analysis.sh"
  log "Created run-medical-analysis.sh script"
  
  # Create a WhatsApp-specific analysis script
  cat > "$BAZINGA_DIR/scripts/run-whatsapp-analysis.sh" << 'EOF'
#!/bin/bash
# WhatsApp-focused BAZINGA analysis runner

BAZINGA_DIR="$HOME/bazinga-integrator"
OUTPUT_DIR="$BAZINGA_DIR/output/whatsapp_$(date +%Y%m%d_%H%M%S)"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Run the WhatsApp analyzer if available
if [ -f "$BAZINGA_DIR/tools/whatsapp_analyzer.py" ]; then
  echo "Running WhatsApp analysis..."
  
  # Check for input file
  if [ -f "$BAZINGA_DIR/artifacts/whatsapp/chat.txt" ]; then
    python3 "$BAZINGA_DIR/tools/whatsapp_analyzer.py" "$BAZINGA_DIR/artifacts/whatsapp/chat.txt" "$OUTPUT_DIR"
  else
    echo "WhatsApp chat file not found. Please place a chat.txt file in $BAZINGA_DIR/artifacts/whatsapp/"
    exit 1
  fi
else
  echo "WhatsApp analyzer not found. Please install it first."
  exit 1
fi

echo "WhatsApp analysis complete. Results available at: $OUTPUT_DIR"
EOF

  # Make it executable
  chmod +x "$BAZINGA_DIR/scripts/run-whatsapp-analysis.sh"
  log "Created run-whatsapp-analysis.sh script"
  
  log "Run scripts creation completed"
}

# Process command line arguments
check_bazinga

case "$1" in
  sync)
    sync_artifacts
    ;;
  medical)
    integrate_medical_data
    ;;
  whatsapp)
    integrate_whatsapp
    ;;
  scripts)
    create_run_scripts
    ;;
  all)
    sync_artifacts
    integrate_medical_data
    integrate_whatsapp
    create_run_scripts
    log "Full BAZINGA integration completed"
    ;;
  *)
    echo "BAZINGA Claude Integrator"
    echo "Usage:"
    echo "  $0 sync - Sync Claude artifacts to BAZINGA"
    echo "  $0 medical - Integrate medical data analysis"
    echo "  $0 whatsapp - Integrate WhatsApp analysis"
    echo "  $0 scripts - Create run scripts"
    echo "  $0 all - Perform all integration operations"
    ;;
esac

log "BAZINGA Claude Integration completed"
