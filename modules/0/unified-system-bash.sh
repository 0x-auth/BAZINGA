#!/bin/bash
#
# BAZINGA System Reorganization
# This script consolidates and organizes your BAZINGA frameworks,
# relationship analysis tools, and Claude artifacts
#

set -e  # Exit on error

echo "============================================="
echo "    BAZINGA System Organization Script"
echo "============================================="
echo ""

# Set timestamp for backups
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="bazinga_reorganization_${TIMESTAMP}.log"

# Create log function
log() {
  echo "$1" | tee -a "$LOG_FILE"
}

log "Starting reorganization at $(date)"
log "Creating backup of critical directories..."

# Backup critical directories
mkdir -p ~/system_backup_${TIMESTAMP}
cp -r ~/AmsyPycharm/BAZINGA ~/system_backup_${TIMESTAMP}/
cp -r ~/Downloads/BAZINGA-Unified ~/system_backup_${TIMESTAMP}/
log "Backup created at ~/system_backup_${TIMESTAMP}"

# ------------- Step 1: Create Master Directories -------------
log "Creating master directories..."

# Create BAZINGA master directory
mkdir -p ~/BAZINGA-Master/{core,tools,frameworks,visualizations,analysis,integration,docs,data}

# Create relationship analysis directory
mkdir -p ~/AmritaCase/{analysis,documents,visualizations,medical,whatsapp,communication,legal,timeframes}

# Create Claude artifacts directory
mkdir -p ~/Claude-Artifacts/{code,markdown,visualizations,json,tools,extraction,html}

# ------------- Step 2: Consolidate BAZINGA Implementations -------------
log "Consolidating BAZINGA implementations..."

# Copy core files from various implementations
if [ -d ~/AmsyPycharm/BAZINGA/src/core ]; then
  cp -r ~/AmsyPycharm/BAZINGA/src/core/* ~/BAZINGA-Master/core/ 2>/dev/null || true
  log "Copied core files from ~/AmsyPycharm/BAZINGA/src/core"
fi

if [ -d ~/Downloads/BAZINGA-Unified/src/core ]; then
  cp -r ~/Downloads/BAZINGA-Unified/src/core/* ~/BAZINGA-Master/core/ 2>/dev/null || true
  log "Copied core files from ~/Downloads/BAZINGA-Unified/src/core"
fi

# Copy visualization tools
if [ -d ~/Downloads/dodo-svgs-amsy ]; then
  cp -r ~/Downloads/dodo-svgs-amsy/* ~/BAZINGA-Master/visualizations/ 2>/dev/null || true
  log "Copied visualization files from ~/Downloads/dodo-svgs-amsy"
fi

if [ -d ~/AmsyPycharm/dodo-vusuals ]; then
  cp -r ~/AmsyPycharm/dodo-vusuals/* ~/BAZINGA-Master/visualizations/ 2>/dev/null || true
  log "Copied visualization files from ~/AmsyPycharm/dodo-vusuals"
fi

# Copy analysis tools
if [ -f ~/Downloads/whatsapp-pattern-extraction.py ]; then
  cp ~/Downloads/whatsapp-pattern-extraction.py ~/BAZINGA-Master/analysis/ 2>/dev/null || true
  log "Copied whatsapp-pattern-extraction.py to analysis directory"
fi

if [ -f ~/Downloads/ssri-correlation-framework.txt ]; then
  cp ~/Downloads/ssri-correlation-framework.txt ~/BAZINGA-Master/analysis/ 2>/dev/null || true
  log "Copied ssri-correlation-framework.txt to analysis directory"
fi

if [ -f ~/Downloads/ultimate-integration-system-complete.py ]; then
  cp ~/Downloads/ultimate-integration-system-complete.py ~/BAZINGA-Master/tools/ 2>/dev/null || true
  log "Copied ultimate-integration-system-complete.py to tools directory"
fi

# Copy documentation
if [ -d ~/Downloads/BAZINGA-Unified/docs ]; then
  cp -r ~/Downloads/BAZINGA-Unified/docs/* ~/BAZINGA-Master/docs/ 2>/dev/null || true
  log "Copied docs from ~/Downloads/BAZINGA-Unified/docs"
fi

# Copy integration tools
if [ -f ~/Downloads/bazinga-integrated-script.sh ]; then
  cp ~/Downloads/bazinga-integrated-script.sh ~/BAZINGA-Master/integration/ 2>/dev/null || true
  chmod +x ~/BAZINGA-Master/integration/bazinga-integrated-script.sh
  log "Copied bazinga-integrated-script.sh to integration directory"
fi

# Copy all unified integration system files 
find ~/Downloads -name "unified-integration-system*.js" -exec cp {} ~/BAZINGA-Master/integration/ \; 2>/dev/null || true
log "Copied unified integration system files to integration directory"

# Copy data files
if [ -d ~/Downloads/BAZINGA-Unified/data ]; then
  cp -r ~/Downloads/BAZINGA-Unified/data/* ~/BAZINGA-Master/data/ 2>/dev/null || true
  log "Copied data files from ~/Downloads/BAZINGA-Unified/data"
fi

# ------------- Step 3: Organize Relationship Analysis Tools -------------
log "Organizing relationship analysis tools..."

# Copy whatsapp analysis tools
if [ -f ~/Downloads/whatsapp-pattern-extraction.py ]; then
  cp ~/Downloads/whatsapp-pattern-extraction.py ~/AmritaCase/whatsapp/ 2>/dev/null || true
  log "Copied WhatsApp pattern extraction tool to AmritaCase"
fi

# Copy SSRI correlation framework
if [ -f ~/Downloads/ssri-correlation-framework.txt ]; then
  cp ~/Downloads/ssri-correlation-framework.txt ~/AmritaCase/medical/ 2>/dev/null || true
  log "Copied SSRI correlation framework to AmritaCase"
fi

# Copy timeline visualizations
if [ -f ~/Downloads/ssri-timeline-visual.svg ]; then
  cp ~/Downloads/ssri-timeline-visual.svg ~/AmritaCase/visualizations/ 2>/dev/null || true
  log "Copied SSRI timeline visual to AmritaCase visualizations"
fi

if [ -f ~/Downloads/gentle-ssri-timeline.svg ]; then
  cp ~/Downloads/gentle-ssri-timeline.svg ~/AmritaCase/visualizations/ 2>/dev/null || true
  log "Copied gentle SSRI timeline to AmritaCase visualizations"
fi

# Copy medical documentation
find ~/Downloads/tmp -name "ssri-apathy-*.md" -exec cp {} ~/AmritaCase/medical/ \; 2>/dev/null || true
log "Copied SSRI apathy documentation to AmritaCase medical"

# Copy communication artifacts
find ~/Downloads -name "amu-*.*" -exec cp {} ~/AmritaCase/communication/ \; 2>/dev/null || true
log "Copied Amu communication artifacts to AmritaCase"

# Copy PDF files
if [ -f ~/Downloads/amu-abhi.pdf ]; then
  cp ~/Downloads/amu-abhi.pdf ~/AmritaCase/documents/ 2>/dev/null || true
  log "Copied amu-abhi.pdf to AmritaCase documents"
fi

# ------------- Step 4: Organize Claude Artifacts -------------
log "Organizing Claude artifacts..."

# Copy artifact extraction tools
if [ -f ~/artifact_extraction_toolkit.sh ]; then
  cp ~/artifact_extraction_toolkit.sh ~/Claude-Artifacts/tools/ 2>/dev/null || true
  chmod +x ~/Claude-Artifacts/tools/artifact_extraction_toolkit.sh
  log "Copied artifact_extraction_toolkit.sh to Claude-Artifacts tools"
fi

if [ -f ~/bazinga_artifact_extractor.sh ]; then
  cp ~/bazinga_artifact_extractor.sh ~/Claude-Artifacts/tools/ 2>/dev/null || true
  chmod +x ~/Claude-Artifacts/tools/bazinga_artifact_extractor.sh
  log "Copied bazinga_artifact_extractor.sh to Claude-Artifacts tools"
fi

if [ -f ~/extract_claude_history.py ]; then
  cp ~/extract_claude_history.py ~/Claude-Artifacts/tools/ 2>/dev/null || true
  log "Copied extract_claude_history.py to Claude-Artifacts tools"
fi

# Copy organized artifacts if they exist
if [ -d ~/bazinga_artifacts ]; then
  cp -r ~/bazinga_artifacts/* ~/Claude-Artifacts/ 2>/dev/null || true
  log "Copied artifacts from ~/bazinga_artifacts to Claude-Artifacts"
fi

if [ -d ~/Downloads/tmp ]; then
  # Copy files by type
  find ~/Downloads/tmp -name "*.md" -exec cp {} ~/Claude-Artifacts/markdown/ \; 2>/dev/null || true
  find ~/Downloads/tmp -name "*.py" -exec cp {} ~/Claude-Artifacts/code/ \; 2>/dev/null || true
  find ~/Downloads/tmp -name "*.json" -exec cp {} ~/Claude-Artifacts/json/ \; 2>/dev/null || true
  find ~/Downloads/tmp -name "*.html" -exec cp {} ~/Claude-Artifacts/html/ \; 2>/dev/null || true
  find ~/Downloads/tmp -name "*.svg" -exec cp {} ~/Claude-Artifacts/visualizations/ \; 2>/dev/null || true
  log "Copied and organized artifacts from ~/Downloads/tmp by file type"
fi

# ------------- Step 5: Create Central Index -------------
log "Creating central index..."

cat > ~/BAZINGA-Master/BAZINGA-central-index.json << 'EOF'
{
  "system_name": "BAZINGA Unified Framework",
  "version": "2.0",
  "created": "2025-03-15",
  "core_frameworks": {
    "bazinga": {
      "description": "Pattern encoding and analysis system using numerical representation",
      "primary_files": [
        "~/BAZINGA-Master/core/template-binding-system.ts",
        "~/BAZINGA-Master/core/symbol-system-visualization.js",
        "~/BAZINGA-Master/docs/bazinga-action-plan.html"
      ],
      "encodings": "~/BAZINGA-Master/analysis/bazinga-relationship-patterns.json",
      "visualizations": "~/BAZINGA-Master/visualizations/"
    },
    "universal_pattern_analyzer": {
      "description": "Python-based pattern analysis tool for cross-domain isomorphism detection",
      "primary_files": [
        "~/BAZINGA-Master/tools/ultimate-integration-system-complete.py",
        "~/BAZINGA-Master/tools/ultimate-integration-system-complete-2.py"
      ],
      "data_analysis": "~/BAZINGA-Master/data/Structured_AI-Human_Session_Log.csv"
    },
    "dodo": {
      "description": "Visual pattern representation system with symbolic notation",
      "primary_files": [
        "~/BAZINGA-Master/core/symbol-system-visualization.js",
        "~/BAZINGA-Master/visualizations/pattern-visualization.svg"
      ]
    },
    "ssri_analysis": {
      "description": "Tools for analyzing SSRI medication effects and timelines",
      "primary_files": [
        "~/AmritaCase/medical/ssri-correlation-framework.txt",
        "~/AmritaCase/visualizations/ssri-timeline-visual.svg",
        "~/AmritaCase/medical/ssri-apathy-explained.md"
      ]
    },
    "whatsapp_analysis": {
      "description": "Communication pattern analysis for WhatsApp data",
      "primary_files": [
        "~/AmritaCase/whatsapp/whatsapp-pattern-extraction.py",
        "~/Claude-Artifacts/code/whatsapp-processing-code.py"
      ]
    }
  },
  "integration_tools": {
    "core_integrations": [
      "~/BAZINGA-Master/integration/bazinga-integrated-script.sh",
      "~/BAZINGA-Master/integration/unified-integration-system.js",
      "~/BAZINGA-Master/integration/unified-integration-system-2.js",
      "~/BAZINGA-Master/integration/unified-integration-system-3.js"
    ],
    "artifact_management": [
      "~/Claude-Artifacts/json/comprehensive-data-json.json",
      "~/Claude-Artifacts/json/artifacts-comprehensive-extraction.json"
    ],
    "visualization": [
      "~/BAZINGA-Master/visualizations/integration-visual.tsx",
      "~/BAZINGA-Master/visualizations/visual-timeline-mapping.html"
    ]
  },
  "claude_artifacts": {
    "description": "Tools for extracting and managing Claude-generated artifacts",
    "extraction_tools": [
      "~/Claude-Artifacts/tools/artifact_extraction_toolkit.sh",
      "~/Claude-Artifacts/tools/bazinga_artifact_extractor.sh"
    ],
    "artifact_collections": [
      "~/Claude-Artifacts/markdown/",
      "~/Claude-Artifacts/code/",
      "~/Claude-Artifacts/json/",
      "~/Claude-Artifacts/visualizations/"
    ]
  }
}
EOF

log "Central index created at ~/BAZINGA-Master/BAZINGA-central-index.json"

# ------------- Step 6: Create README files -------------
log "Creating README files..."

# Create BAZINGA-Master README
cat > ~/BAZINGA-Master/README.md << 'EOF'
# BAZINGA Master Framework

This directory contains the consolidated components of the BAZINGA framework system.

## Directory Structure

- `core/` - Core components and utilities
- `tools/` - Analysis tools and utilities
- `frameworks/` - Framework definitions and implementations
- `visualizations/` - Visual components and SVG files
- `analysis/` - Analysis scripts and utilities
- `integration/` - Integration tools and scripts
- `docs/` - Documentation and guides
- `data/` - Data files and resources

## Key Components

1. Universal Pattern Analyzer - `tools/ultimate-integration-system-complete.py`
2. Template Binding System - `core/template-binding-system.ts`
3. Symbol System Visualization - `core/symbol-system-visualization.js`
4. Circular Pattern Detection - `core/circular-pattern-detection-system.js`

## Integration

See the central index file `BAZINGA-central-index.json` for a complete mapping of all system components.
EOF

# Create AmritaCase README
cat > ~/AmritaCase/README.md << 'EOF'
# Amrita Case Analysis

This directory contains tools and data for analyzing the Amrita case.

## Directory Structure

- `analysis/` - Analysis tools and outputs
- `documents/` - Documentation and reports
- `visualizations/` - Visual representations and timelines
- `medical/` - Medical documentation and analysis
- `whatsapp/` - WhatsApp communication analysis
- `communication/` - Communication analysis and tools
- `legal/` - Legal documentation and resources
- `timeframes/` - Timeline analysis and visualizations

## Key Components

1. WhatsApp Pattern Analysis - `whatsapp/whatsapp-pattern-extraction.py`
2. SSRI Correlation Framework - `medical/ssri-correlation-framework.txt`
3. Timeline Visualizations - `visualizations/ssri-timeline-visual.svg`
4. Medical Documentation - `medical/ssri-apathy-explained.md`
EOF

# Create Claude-Artifacts README
cat > ~/Claude-Artifacts/README.md << 'EOF'
# Claude Artifacts

This directory contains artifacts generated by Claude and tools for managing them.

## Directory Structure

- `code/` - Code artifacts (Python, JavaScript, etc.)
- `markdown/` - Markdown documentation and notes
- `visualizations/` - SVG and other visual artifacts
- `json/` - JSON data structures and configurations
- `tools/` - Tools for managing and extracting artifacts
- `extraction/` - Extraction scripts and utilities
- `html/` - HTML artifacts and visualizations

## Key Tools

1. Artifact Extraction Toolkit - `tools/artifact_extraction_toolkit.sh`
2. Bazinga Artifact Extractor - `tools/bazinga_artifact_extractor.sh`
3. Claude History Extractor - `tools/extract_claude_history.py`
EOF

log "README files created for each master directory"

# ------------- Step 7: Create symlinks for convenience -------------
log "Creating symlinks for convenience..."

# Create symlinks in home directory
ln -sf ~/BAZINGA-Master ~/bazinga
ln -sf ~/AmritaCase ~/amrita
ln -sf ~/Claude-Artifacts ~/claude

log "Created symlinks in home directory: ~/bazinga, ~/amrita, ~/claude"

# ------------- Step 8: Create unified visualization tool -------------
log "Creating unified visualization tool..."

# Copy unified framework visualization to BAZINGA-Master
if [ -f ~/AmsyPycharm/unified-framework-visualization.js ]; then
  cp ~/AmsyPycharm/unified-framework-visualization.js ~/BAZINGA-Master/integration/
  log "Copied unified-framework-visualization.js to ~/BAZINGA-Master/integration/"
fi

# Create HTML wrapper for visualization
cat > ~/BAZINGA-Master/BAZINGA-dashboard.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>BAZINGA Unified Framework Dashboard</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 0; padding: 20px; }
    .container { max-width: 1200px; margin: 0 auto; }
    .header { text-align: center; margin-bottom: 30px; }
    .systems-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; }
    .system-card { border: 1px solid #ddd; border-radius: 8px; padding: 15px; }
    .connections { margin-top: 30px; }
    .artifact-section { margin-top: 30px; }
    .artifacts-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; }
    .artifact-card { border: 1px solid #eee; border-radius: 6px; padding: 10px; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>BAZINGA Unified Framework</h1>
      <p>Comprehensive visualization of all integrated systems</p>
    </div>
    
    <div id="visualization-container">
      <!-- Visualization will be rendered here -->
    </div>
  </div>
  
  <script src="integration/unified-framework-visualization.js"></script>
  <script>
    // Initialize the visualization
    document.addEventListener('DOMContentLoaded', function() {
      const visualizer = new BAZINGAUnifiedVisualization();
      const systemMap = visualizer.generateSystemMap();
      const dashboard = visualizer.generateHtmlDashboard();
      
      // Render the dashboard
      document.getElementById('visualization-container').innerHTML = dashboard;
    });
  </script>
</body>
</html>
EOF

log "Created BAZINGA dashboard at ~/BAZINGA-Master/BAZINGA-dashboard.html"

# ------------- Completion -------------
log "Reorganization complete at $(date)"
log "System has been reorganized into three main components:"
log "  1. BAZINGA Master Framework: ~/BAZINGA-Master (symlink: ~/bazinga)"
log "  2. Amrita Case Analysis: ~/AmritaCase (symlink: ~/amrita)"
log "  3. Claude Artifacts: ~/Claude-Artifacts (symlink: ~/claude)"
log ""
log "Next steps:"
log "  1. Review the organization and verify all components work as expected"
log "  2. Clean up duplicates and unnecessary files"
log "  3. Update any scripts with new file paths"
log ""
log "Log file saved to: $LOG_FILE"

echo "============================================="
echo "    BAZINGA System Organization Complete"
echo "============================================="
echo ""
echo "See log file for details: $LOG_FILE"
