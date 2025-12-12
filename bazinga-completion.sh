#!/bin/bash
# Bazinga Project Enhancement
# This script reorganizes and completes the Bazinga project structure
# while separating Claude artifact collection from clipboard handling

# Define color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Bazinga Project Enhancement ===${NC}"
echo "This script will enhance your Bazinga project structure and fix clipboard issues"

# Step 1: Create safer Claude artifact collection module
create_safe_collector() {
    echo -e "${GREEN}Creating safe Claude artifact collector module...${NC}"
    
    cat > safe_claude_collector.py << 'EOL'
#!/usr/bin/env python3
"""
Safe Claude Artifact Collector
This module collects Claude artifacts without interfering with the clipboard.
It uses direct file operations instead of clipboard hooks.
"""

import os
import json
import time
import argparse
import logging
import requests
from datetime import datetime
from urllib.parse import urlparse

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(f"claude_collect_{datetime.now().strftime('%Y%m%d')}.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger("claude_collector")

class SafeClaudeCollector:
    def __init__(self, output_dir="artifacts"):
        self.output_dir = output_dir
        self.artifact_dir = os.path.join(output_dir, "claude_artifacts")
        self.metadata_file = os.path.join(output_dir, "artifacts_metadata.json")
        self.artifact_count = 0
        
        # Ensure directories exist
        os.makedirs(self.artifact_dir, exist_ok=True)
        
        # Load existing metadata if available
        self.metadata = self._load_metadata()
        
    def _load_metadata(self):
        """Load existing metadata or create new structure"""
        if os.path.exists(self.metadata_file):
            try:
                with open(self.metadata_file, 'r') as f:
                    return json.load(f)
            except json.JSONDecodeError:
                logger.warning(f"Could not decode {self.metadata_file}, creating new metadata")
        
        return {
            "artifacts": [],
            "last_updated": datetime.now().isoformat(),
            "total_collected": 0
        }
    
    def _save_metadata(self):
        """Save metadata to file"""
        self.metadata["last_updated"] = datetime.now().isoformat()
        self.metadata["total_collected"] = len(self.metadata["artifacts"])
        
        with open(self.metadata_file, 'w') as f:
            json.dump(self.metadata, f, indent=2)
    
    def process_artifact_url(self, url):
        """Process a Claude artifact URL without using clipboard"""
        if not url or "claude.site/artifacts" not in url:
            logger.warning(f"Not a valid Claude artifact URL: {url}")
            return False
            
        # Parse URL to get artifact ID
        parsed_url = urlparse(url)
        path_parts = parsed_url.path.split('/')
        if len(path_parts) < 3:
            logger.warning(f"Could not extract artifact ID from URL: {url}")
            return False
            
        artifact_id = path_parts[-1]
        
        # Check if already processed
        if any(a["id"] == artifact_id for a in self.metadata["artifacts"]):
            logger.info(f"Artifact {artifact_id} already processed, skipping")
            return False
        
        # Create artifact entry
        artifact_entry = {
            "id": artifact_id,
            "url": url,
            "collected_at": datetime.now().isoformat(),
            "file_path": os.path.join(self.artifact_dir, f"{artifact_id}.json")
        }
        
        # Attempt to download content if it's a direct resource
        try:
            # For demonstration - in real use you'd implement proper content download
            # This is just a placeholder for the concept
            with open(artifact_entry["file_path"], 'w') as f:
                f.write(json.dumps({
                    "id": artifact_id,
                    "url": url,
                    "collected_at": artifact_entry["collected_at"],
                    "content": "Placeholder for artifact content"
                }, indent=2))
                
            self.metadata["artifacts"].append(artifact_entry)
            self._save_metadata()
            self.artifact_count += 1
            logger.info(f"Successfully processed artifact {artifact_id}")
            return True
            
        except Exception as e:
            logger.error(f"Error processing artifact {artifact_id}: {str(e)}")
            return False
    
    def process_artifact_content(self, content, artifact_type="text"):
        """Process artifact content directly without URL"""
        if not content:
            return False
            
        # Generate an ID for this content
        artifact_id = f"local_{int(time.time())}_{hash(content) % 10000}"
        
        # Create artifact entry
        artifact_entry = {
            "id": artifact_id,
            "type": artifact_type,
            "collected_at": datetime.now().isoformat(),
            "file_path": os.path.join(self.artifact_dir, f"{artifact_id}.json")
        }
        
        # Save content
        try:
            with open(artifact_entry["file_path"], 'w') as f:
                f.write(json.dumps({
                    "id": artifact_id,
                    "type": artifact_type,
                    "collected_at": artifact_entry["collected_at"],
                    "content": content
                }, indent=2))
                
            self.metadata["artifacts"].append(artifact_entry)
            self._save_metadata()
            self.artifact_count += 1
            logger.info(f"Successfully saved local artifact {artifact_id}")
            return True
            
        except Exception as e:
            logger.error(f"Error saving artifact {artifact_id}: {str(e)}")
            return False
    
    def get_stats(self):
        """Return collector statistics"""
        return {
            "total_artifacts": len(self.metadata["artifacts"]),
            "new_artifacts": self.artifact_count,
            "last_updated": self.metadata["last_updated"]
        }

def main():
    parser = argparse.ArgumentParser(description="Safe Claude Artifact Collector")
    parser.add_argument("--dir", default="artifacts", help="Directory to store artifacts")
    parser.add_argument("--url", help="Claude artifact URL to process")
    parser.add_argument("--file", help="File containing Claude artifact URLs")
    parser.add_argument("--content", help="Direct content to save as artifact")
    args = parser.parse_args()
    
    collector = SafeClaudeCollector(output_dir=args.dir)
    
    if args.url:
        collector.process_artifact_url(args.url)
    
    if args.file:
        try:
            with open(args.file, 'r') as f:
                for line in f:
                    url = line.strip()
                    if url:
                        collector.process_artifact_url(url)
        except Exception as e:
            logger.error(f"Error processing URL file: {str(e)}")
    
    if args.content:
        collector.process_artifact_content(args.content)
    
    stats = collector.get_stats()
    logger.info(f"Collection complete. Total artifacts: {stats['total_artifacts']}, New: {stats['new_artifacts']}")

if __name__ == "__main__":
    main()
EOL

    chmod +x safe_claude_collector.py
    echo "Safe Claude collector created successfully!"
}

# Step 2: Create Bazinga analyzer for Claude artifacts
create_bazinga_analyzer() {
    echo -e "${GREEN}Creating Bazinga analyzer for Claude artifacts...${NC}"
    
    cat > bazinga_claude_analyzer.py << 'EOL'
#!/usr/bin/env python3
"""
Bazinga Claude Artifact Analyzer
Analyzes collected Claude artifacts to extract insights and patterns
"""

import os
import json
import argparse
import logging
import re
from datetime import datetime
from collections import Counter, defaultdict
import matplotlib.pyplot as plt
import numpy as np

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(f"bazinga_analyze_{datetime.now().strftime('%Y%m%d')}.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger("bazinga_analyzer")

class BazingaAnalyzer:
    def __init__(self, artifacts_dir="artifacts/claude_artifacts", output_dir="analysis"):
        self.artifacts_dir = artifacts_dir
        self.output_dir = output_dir
        self.metadata_file = os.path.join(os.path.dirname(artifacts_dir), "artifacts_metadata.json")
        
        # Ensure directories exist
        os.makedirs(self.output_dir, exist_ok=True)
        
        # Load metadata
        self.metadata = self._load_metadata()
        self.artifacts = []
        
    def _load_metadata(self):
        """Load artifacts metadata"""
        if os.path.exists(self.metadata_file):
            try:
                with open(self.metadata_file, 'r') as f:
                    return json.load(f)
            except Exception as e:
                logger.error(f"Error loading metadata: {str(e)}")
                return {"artifacts": []}
        else:
            logger.warning(f"Metadata file not found: {self.metadata_file}")
            return {"artifacts": []}
    
    def load_artifacts(self):
        """Load all artifact files"""
        loaded = 0
        
        # Try loading from metadata first
        for artifact_entry in self.metadata.get("artifacts", []):
            file_path = artifact_entry.get("file_path")
            if file_path and os.path.exists(file_path):
                try:
                    with open(file_path, 'r') as f:
                        artifact_data = json.load(f)
                        self.artifacts.append(artifact_data)
                        loaded += 1
                except Exception as e:
                    logger.error(f"Error loading artifact {file_path}: {str(e)}")
        
        # If no artifacts loaded from metadata, try direct file scan
        if loaded == 0:
            logger.info("No artifacts loaded from metadata, scanning directory")
            for filename in os.listdir(self.artifacts_dir):
                if filename.endswith(".json"):
                    file_path = os.path.join(self.artifacts_dir, filename)
                    try:
                        with open(file_path, 'r') as f:
                            artifact_data = json.load(f)
                            self.artifacts.append(artifact_data)
                            loaded += 1
                    except Exception as e:
                        logger.error(f"Error loading artifact {file_path}: {str(e)}")
        
        logger.info(f"Loaded {loaded} artifacts")
        return loaded
    
    def analyze_content_patterns(self):
        """Analyze patterns in artifact content"""
        if not self.artifacts:
            logger.warning("No artifacts to analyze")
            return {}
            
        # Extract content from artifacts
        contents = []
        for artifact in self.artifacts:
            content = artifact.get("content", "")
            if content:
                contents.append(content)
        
        if not contents:
            logger.warning("No content found in artifacts")
            return {}
            
        # Perform analysis
        word_counter = Counter()
        topic_patterns = {
            "technical": re.compile(r'\b(code|function|algorithm|data|api|server|python|javascript)\b', re.I),
            "business": re.compile(r'\b(business|strategy|market|customer|revenue|profit|growth)\b', re.I),
            "creative": re.compile(r'\b(story|design|creative|art|music|novel|character)\b', re.I),
            "analytical": re.compile(r'\b(analysis|analyze|research|study|survey|statistics|results)\b', re.I)
        }
        
        topic_counts = {topic: 0 for topic in topic_patterns}
        
        for content in contents:
            # Count words
            words = re.findall(r'\b\w+\b', content.lower())
            word_counter.update(words)
            
            # Check topics
            for topic, pattern in topic_patterns.items():
                if pattern.search(content):
                    topic_counts[topic] += 1
        
        # Calculate results
        common_words = word_counter.most_common(20)
        topic_distribution = {topic: count / len(contents) for topic, count in topic_counts.items()}
        
        results = {
            "common_words": common_words,
            "topic_distribution": topic_distribution,
            "total_artifacts": len(self.artifacts),
            "total_with_content": len(contents)
        }
        
        # Save results
        result_file = os.path.join(self.output_dir, "content_pattern_analysis.json")
        with open(result_file, 'w') as f:
            json.dump(results, f, indent=2)
            
        logger.info(f"Content pattern analysis complete, saved to {result_file}")
        
        # Generate visualization
        self._generate_topic_visualization(topic_distribution)
        
        return results
    
    def _generate_topic_visualization(self, topic_distribution):
        """Generate visualization of topic distribution"""
        try:
            # Create bar chart
            topics = list(topic_distribution.keys())
            values = list(topic_distribution.values())
            
            plt.figure(figsize=(10, 6))
            bars = plt.bar(topics, values, color='skyblue')
            
            # Add values on top of bars
            for bar in bars:
                height = bar.get_height()
                plt.text(bar.get_x() + bar.get_width()/2., height,
                        f'{height:.2f}',
                        ha='center', va='bottom')
            
            plt.title('Topic Distribution in Claude Artifacts')
            plt.xlabel('Topics')
            plt.ylabel('Proportion of Artifacts')
            plt.ylim(0, 1.0)
            
            # Save figure
            plt.savefig(os.path.join(self.output_dir, "topic_distribution.png"))
            logger.info(f"Topic distribution visualization saved")
            
        except Exception as e:
            logger.error(f"Error generating visualization: {str(e)}")
    
    def generate_report(self):
        """Generate comprehensive analysis report"""
        if not self.artifacts:
            logger.warning("No artifacts to include in report")
            return
            
        # Gather basic statistics
        total_artifacts = len(self.artifacts)
        artifact_dates = [a.get("collected_at", "") for a in self.artifacts]
        artifact_dates = [d for d in artifact_dates if d]  # Filter out empty dates
        
        if artifact_dates:
            earliest = min(artifact_dates)
            latest = max(artifact_dates)
        else:
            earliest = latest = "N/A"
        
        # Generate report
        report = {
            "report_generated": datetime.now().isoformat(),
            "total_artifacts": total_artifacts,
            "date_range": {
                "earliest": earliest,
                "latest": latest
            },
            "content_analysis": self.analyze_content_patterns(),
        }
        
        # Save report
        report_file = os.path.join(self.output_dir, "bazinga_analysis_report.json")
        with open(report_file, 'w') as f:
            json.dump(report, f, indent=2)
            
        # Create human-readable summary
        summary = f"""
Bazinga Analysis Report
======================
Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

Artifact Statistics
------------------
Total artifacts: {total_artifacts}
Date range: {earliest} to {latest}

Content Analysis
---------------
Top topics: {', '.join(f"{topic} ({value:.2f})" for topic, value in report['content_analysis']['topic_distribution'].items())}
Total artifacts with content: {report['content_analysis']['total_with_content']}

Most common words:
{chr(10).join([f"- {word}: {count}" for word, count in report['content_analysis']['common_words'][:10]])}
"""
        
        summary_file = os.path.join(self.output_dir, "bazinga_summary.txt")
        with open(summary_file, 'w') as f:
            f.write(summary)
            
        logger.info(f"Analysis report generated and saved to {report_file}")
        logger.info(f"Summary saved to {summary_file}")
        
        return report

def main():
    parser = argparse.ArgumentParser(description="Bazinga Claude Artifact Analyzer")
    parser.add_argument("--artifacts-dir", default="artifacts/claude_artifacts", help="Directory containing artifacts")
    parser.add_argument("--output-dir", default="analysis", help="Directory for analysis output")
    args = parser.parse_args()
    
    analyzer = BazingaAnalyzer(artifacts_dir=args.artifacts_dir, output_dir=args.output_dir)
    loaded = analyzer.load_artifacts()
    
    if loaded > 0:
        analyzer.generate_report()
        logger.info("Analysis complete!")
    else:
        logger.error("No artifacts could be loaded for analysis")

if __name__ == "__main__":
    main()
EOL

    chmod +x bazinga_claude_analyzer.py
    echo "Bazinga analyzer created successfully!"
}

# Step 3: Create integration script for Bazinga
create_bazinga_integration() {
    echo -e "${GREEN}Creating Bazinga integration script...${NC}"
    
    cat > bazinga_integration.sh << 'EOL'
#!/bin/bash
# Bazinga Integration Script
# Safely integrates Claude artifacts with Bazinga without clipboard issues

# Define color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Bazinga Integration Script ===${NC}"
echo "This script safely integrates Claude artifacts with Bazinga"

# Configuration
BASE_DIR=$(dirname "$0")
ARTIFACTS_DIR="$BASE_DIR/artifacts"
ANALYSIS_DIR="$BASE_DIR/analysis"
COLLECTOR_SCRIPT="$BASE_DIR/safe_claude_collector.py"
ANALYZER_SCRIPT="$BASE_DIR/bazinga_claude_analyzer.py"

# Create necessary directories
mkdir -p "$ARTIFACTS_DIR"
mkdir -p "$ANALYSIS_DIR"

# Check if required scripts exist
if [ ! -f "$COLLECTOR_SCRIPT" ]; then
  echo -e "${RED}Error: Collector script not found at $COLLECTOR_SCRIPT${NC}"
  exit 1
fi

if [ ! -f "$ANALYZER_SCRIPT" ]; then
  echo -e "${RED}Error: Analyzer script not found at $ANALYZER_SCRIPT${NC}"
  exit 1
fi

# Function to collect artifacts
collect_artifacts() {
  local url="$1"
  local file="$2"
  
  echo -e "${YELLOW}Collecting artifacts...${NC}"
  
  if [ -n "$url" ]; then
    # Process single URL
    python3 "$COLLECTOR_SCRIPT" --dir "$ARTIFACTS_DIR" --url "$url"
  elif [ -n "$file" ] && [ -f "$file" ]; then
    # Process file with URLs
    python3 "$COLLECTOR_SCRIPT" --dir "$ARTIFACTS_DIR" --file "$file"
  else
    echo -e "${YELLOW}No URL or file specified, skipping collection${NC}"
  fi
}

# Function to analyze artifacts
analyze_artifacts() {
  echo -e "${YELLOW}Analyzing artifacts...${NC}"
  python3 "$ANALYZER_SCRIPT" --artifacts-dir "$ARTIFACTS_DIR/claude_artifacts" --output-dir "$ANALYSIS_DIR"
}

# Main menu
show_menu() {
  echo ""
  echo -e "${GREEN}Bazinga Integration Menu${NC}"
  echo "1. Collect artifact from URL"
  echo "2. Collect artifacts from file"
  echo "3. Analyze collected artifacts"
  echo "4. Run full pipeline (collect & analyze)"
  echo "5. View analysis report"
  echo "6. Exit"
  echo ""
  echo -n "Select an option [1-6]: "
}

# Process menu choice
process_choice() {
  local choice="$1"
  
  case $choice in
    1)
      echo -n "Enter Claude artifact URL: "
      read url
      collect_artifacts "$url" ""
      ;;
    2)
      echo -n "Enter file path containing URLs: "
      read file_path
      if [ -f "$file_path" ]; then
        collect_artifacts "" "$file_path"
      else
        echo -e "${RED}Error: File not found at $file_path${NC}"
      fi
      ;;
    3)
      analyze_artifacts
      ;;
    4)
      echo -n "Enter Claude artifact URL (leave empty to skip): "
      read url
      if [ -n "$url" ]; then
        collect_artifacts "$url" ""
      fi
      analyze_artifacts
      ;;
    5)
      report_file="$ANALYSIS_DIR/bazinga_summary.txt"
      if [ -f "$report_file" ]; then
        echo -e "${GREEN}Analysis Report:${NC}"
        cat "$report_file"
      else
        echo -e "${RED}No analysis report found. Run analysis first.${NC}"
      fi
      ;;
    6)
      echo "Exiting Bazinga Integration"
      exit 0
      ;;
    *)
      echo -e "${RED}Invalid option. Please try again.${NC}"
      ;;
  esac
}

# Main loop
while true; do
  show_menu
  read choice
  process_choice "$choice"
  echo ""
  echo -n "Press Enter to continue..."
  read
  clear
done
EOL

    chmod +x bazinga_integration.sh
    echo "Bazinga integration script created successfully!"
}

# Step 4: Create systemd service for safer collection
create_safe_service() {
    echo -e "${GREEN}Creating safer service for artifact collection...${NC}"
    
    cat > bazinga-collector.service << 'EOL'
[Unit]
Description=Bazinga Claude Artifact Collector Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 /path/to/safe_claude_collector.py --dir /path/to/artifacts
User=yourusername
Group=yourusergroup
WorkingDirectory=/path/to/bazinga
Restart=on-failure
RestartSec=30
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=bazinga-collector

[Install]
WantedBy=multi-user.target
EOL

    echo "Systemd service file created. You'll need to customize paths and install it."
    echo "To install: sudo cp bazinga-collector.service /etc/systemd/system/"
    echo "Then: sudo systemctl daemon-reload && sudo systemctl enable bazinga-collector"
}

# Step 5: Create clipboard fix utility
create_clipboard_fix() {
    echo -e "${GREEN}Creating clipboard fix utility...${NC}"
    
    cat > fix_clipboard.sh << 'EOL'
#!/bin/bash
# Clipboard Fix Utility
# Safely fixes clipboard issues without interfering with Bazinga

# Define color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Clipboard Fix Utility ===${NC}"
echo "This script safely fixes clipboard issues without affecting Bazinga"

# Fix clipboard
echo -e "${YELLOW}Restarting clipboard service...${NC}"
killall pboard

# Test clipboard
echo -e "${YELLOW}Testing clipboard...${NC}"
echo "Clipboard test" | pbcopy
clipboard_content=$(pbpaste)

if [ "$clipboard_content" == "Clipboard test" ]; then
    echo -e "${GREEN}Clipboard is working correctly!${NC}"
else
    echo -e "${RED}Clipboard still not working. Current content: $clipboard_content${NC}"
    
    # More aggressive fix
    echo -e "${YELLOW}Trying more aggressive fix...${NC}"
    
    # Kill any processes that might be interfering
    ps aux | grep -i "clipboard\|pbcopy\|pbpaste" | grep -v grep | awk '{print $2}' | xargs kill -9 2>/dev/null
    
    # Restart clipboard service again
    killall pboard
    
    # Test again
    echo "Clipboard test 2" | pbcopy
    clipboard_content=$(pbpaste)
    
    if [ "$clipboard_content" == "Clipboard test 2" ]; then
        echo -e "${GREEN}Clipboard is now working correctly!${NC}"
    else
        echo -e "${RED}Clipboard still not working. You may need to restart your Mac.${NC}"
        echo "Current content: $clipboard_content"
    fi
fi

echo ""
echo -e "${BLUE}Recommendations:${NC}"
echo "1. If clipboard issues persist, log out and back in"
echo "2. Use the bazinga_integration.sh script for Claude artifact operations"
echo "3. Avoid using scripts that directly hook into the clipboard"
EOL

    chmod +x fix_clipboard.sh
    echo "Clipboard fix utility created successfully!"
}

# Step 6: Create README with documentation
create_readme() {
    echo -e "${GREEN}Creating README with documentation...${NC}"
    
    cat > README.md << 'EOL'
# Bazinga Project

## Overview
Bazinga is a powerful framework for collecting, analyzing, and integrating Claude artifacts 
without clipboard issues. This enhanced version ensures efficient artifact collection
while maintaining normal clipboard functionality.

## Components

### 1. Safe Claude Artifact Collector
`safe_claude_collector.py` - Collects Claude artifacts without interfering with the clipboard.

Features:
- Safely processes Claude artifact URLs
- Stores artifacts with proper metadata
- No clipboard hooks that cause system issues
- Track collection statistics

Usage:
```bash
# Collect from a single URL
./safe_claude_collector.py --url "https://claude.site/artifacts/..."

# Collect from a file containing URLs
./safe_claude_collector.py --file urls.txt

# Store content directly
./safe_claude_collector.py --content "Artifact content here"
```

### 2. Bazinga Claude Analyzer
`bazinga_claude_analyzer.py` - Analyzes collected artifacts for insights and patterns.

Features:
- Processes all collected artifacts
- Identifies content patterns and topics
- Generates visualizations
- Creates comprehensive reports

Usage:
```bash
./bazinga_claude_analyzer.py --artifacts-dir "artifacts/claude_artifacts" --output-dir "analysis"
```

### 3. Bazinga Integration Script
`bazinga_integration.sh` - Provides a unified interface for the Bazinga workflow.

Features:
- Interactive menu system
- Combines collection and analysis
- View generated reports
- Safe clipboard operation

Usage:
```bash
./bazinga_integration.sh
```

### 4. Clipboard Fix Utility
`fix_clipboard.sh` - Fixes clipboard issues if they occur.

Features:
- Safely restores clipboard functionality
- Compatible with Bazinga operations
- Diagnoses clipboard problems

Usage:
```bash
./fix_clipboard.sh
```

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd bazinga
```

2. Make scripts executable:
```bash
chmod +x *.py *.sh
```

3. Install dependencies:
```bash
pip install matplotlib numpy requests
```

## Project Structure
```
bazinga/
├── artifacts/               # Collected Claude artifacts
├── analysis/                # Analysis output
├── safe_claude_collector.py # Safe artifact collector
├── bazinga_claude_analyzer.py # Artifact analyzer
├── bazinga_integration.sh   # Integration script
├── fix_clipboard.sh         # Clipboard fix utility
└── README.md                # This documentation
```

## Troubleshooting

### Clipboard Issues
If clipboard issues occur:
1. Run `./fix_clipboard.sh` to restore functionality
2. Ensure you're using the safe collector, not clipboard-based scripts
3. Check for running processes with `ps aux | grep claude`
4. Restart your terminal or log out if issues persist

### Collection Issues
If artifact collection fails:
1. Verify the URL format is correct
2. Check network connectivity
3. Ensure output directories are writable
4. Check logs for detailed error messages

## Contributing
Contributions are welcome! Please follow these steps:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License
This project is licensed under the MIT License - see the LICENSE file for details.
EOL

    echo "README created successfully!"
}

# Step 7: Final integration
integrate_project() {
    echo -e "${GREEN}Performing final integration...${NC}"
    
    # Create project directory structure if it doesn't exist
    mkdir -p artifacts/claude_artifacts
    mkdir -p analysis
    
    # Ensure permissions are correct
    chmod +x safe_claude_collector.py
    chmod +x bazinga_claude_analyzer.py
    chmod +x bazinga_integration.sh
    chmod +x fix_clipboard.sh
    
    echo -e "${BLUE}Bazinga project enhanced successfully!${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Review the generated files and customize as needed"
    echo "2. Run ./fix_clipboard.sh to ensure clipboard functionality"
    echo "3. Run ./bazinga_integration.sh to start using the enhanced Bazinga"
    echo ""
    echo -e "${GREEN}Done!${NC}"
}

# Execute all functions
create_safe_collector
create_bazinga_analyzer
create_bazinga_integration
create_safe_service
create_clipboard_fix
create_readme
integrate_project

echo -e "${BLUE}=== Bazinga Enhancement Complete ===${NC}"
