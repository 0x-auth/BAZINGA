#!/bin/bash

# Define key directories
AMSYPYCHARM_DIR=~/AmsyPycharm
BAZINGA_DIR=$AMSYPYCHARM_DIR/BAZINGA
BAZINGA_INDEED_DIR=$AMSYPYCHARM_DIR/BAZINGA-INDEED
CLAUDE_DIR=~/claude_data

# Create output directory
REPORT_DIR=~/system_analysis_$(date +%Y%m%d)
mkdir -p $REPORT_DIR

echo "=== ANALYZING SYSTEM STRUCTURE AND RECENT ACTIVITY ===" | tee $REPORT_DIR/system_report.txt
echo "Analysis date: $(date)" | tee -a $REPORT_DIR/system_report.txt
echo "" | tee -a $REPORT_DIR/system_report.txt

# Analyze directory structure (exclude node_modules, venv, etc.)
echo "=== DIRECTORY STRUCTURE ===" | tee -a $REPORT_DIR/system_report.txt
find $BAZINGA_DIR $BAZINGA_INDEED_DIR $CLAUDE_DIR -type d -not -path "*/\.*" \
  -not -path "*/node_modules/*" -not -path "*/venv/*" -not -path "*/__pycache__/*" \
  -not -path "*/fresh_venv/*" | sort | tee $REPORT_DIR/directories.txt
echo "" | tee -a $REPORT_DIR/system_report.txt

# List key files by type (excluding large generated directories)
echo "=== KEY FILES BY TYPE ===" | tee -a $REPORT_DIR/system_report.txt
echo "Shell scripts:" | tee -a $REPORT_DIR/system_report.txt
find $BAZINGA_DIR $BAZINGA_INDEED_DIR $CLAUDE_DIR -name "*.sh" -type f \
  -not -path "*/node_modules/*" -not -path "*/venv/*" | sort | tee $REPORT_DIR/shell_scripts.txt
echo "" | tee -a $REPORT_DIR/system_report.txt

echo "Python scripts:" | tee -a $REPORT_DIR/system_report.txt
find $BAZINGA_DIR $BAZINGA_INDEED_DIR $CLAUDE_DIR -name "*.py" -type f \
  -not -path "*/node_modules/*" -not -path "*/venv/*" -not -path "*/__pycache__/*" | sort | tee $REPORT_DIR/python_scripts.txt
echo "" | tee -a $REPORT_DIR/system_report.txt

echo "JSON files:" | tee -a $REPORT_DIR/system_report.txt
find $BAZINGA_DIR $BAZINGA_INDEED_DIR $CLAUDE_DIR -name "*.json" -type f \
  -not -path "*/node_modules/*" -not -path "*/venv/*" | sort | tee $REPORT_DIR/json_files.txt
echo "" | tee -a $REPORT_DIR/system_report.txt

echo "Markdown files:" | tee -a $REPORT_DIR/system_report.txt
find $BAZINGA_DIR $BAZINGA_INDEED_DIR $CLAUDE_DIR -name "*.md" -type f \
  -not -path "*/node_modules/*" -not -path "*/venv/*" | sort | tee $REPORT_DIR/markdown_files.txt
echo "" | tee -a $REPORT_DIR/system_report.txt

# Analyze recent activity (past week)
echo "=== ACTIVITY IN PAST WEEK ===" | tee -a $REPORT_DIR/system_report.txt
echo "Recently modified files (past 7 days):" | tee -a $REPORT_DIR/system_report.txt
find $BAZINGA_DIR $BAZINGA_INDEED_DIR $CLAUDE_DIR -type f -mtime -7 \
  -not -path "*/\.*" -not -path "*/node_modules/*" -not -path "*/venv/*" \
  -not -path "*/__pycache__/*" -not -path "*/fresh_venv/*" | sort | tee $REPORT_DIR/recent_files.txt
echo "" | tee -a $REPORT_DIR/system_report.txt

# Group by day
echo "=== ACTIVITY BY DAY ===" | tee -a $REPORT_DIR/system_report.txt
for i in {0..6}; do
  day=$(date -v-${i}d +%Y-%m-%d)
  echo "Activity on $day:" | tee -a $REPORT_DIR/system_report.txt
  find $BAZINGA_DIR $BAZINGA_INDEED_DIR $CLAUDE_DIR -type f \
    -not -path "*/\.*" -not -path "*/node_modules/*" -not -path "*/venv/*" \
    -not -path "*/__pycache__/*" -not -path "*/fresh_venv/*" \
    -newermt "${day} 00:00:00" ! -newermt "${day} 23:59:59" | \
    sort | tee $REPORT_DIR/activity_${day}.txt
  
  count=$(cat $REPORT_DIR/activity_${day}.txt | wc -l)
  echo "Total files modified: $count" | tee -a $REPORT_DIR/system_report.txt
  echo "" | tee -a $REPORT_DIR/system_report.txt
done

# Analyze file content patterns (looking at recent files only)
echo "=== CONTENT PATTERNS ===" | tee -a $REPORT_DIR/system_report.txt
echo "Common terms in recent files:" | tee -a $REPORT_DIR/system_report.txt
grep -l "pattern" $(find $BAZINGA_DIR $BAZINGA_INDEED_DIR $CLAUDE_DIR -type f -mtime -7 \
  -not -path "*/\.*" -not -path "*/node_modules/*" -not -path "*/venv/*" \
  -not -path "*/__pycache__/*" -name "*.md" -o -name "*.py" -o -name "*.sh" -o -name "*.txt") | \
  wc -l | xargs echo "Files mentioning 'pattern':" | tee -a $REPORT_DIR/system_report.txt

grep -l "health\|medical\|SSRI" $(find $BAZINGA_DIR $BAZINGA_INDEED_DIR $CLAUDE_DIR -type f -mtime -7 \
  -not -path "*/\.*" -not -path "*/node_modules/*" -not -path "*/venv/*" \
  -not -path "*/__pycache__/*" -name "*.md" -o -name "*.py" -o -name "*.sh" -o -name "*.txt") | \
  wc -l | xargs echo "Files mentioning health topics:" | tee -a $REPORT_DIR/system_report.txt

grep -l "relationship\|communication" $(find $BAZINGA_DIR $BAZINGA_INDEED_DIR $CLAUDE_DIR -type f -mtime -7 \
  -not -path "*/\.*" -not -path "*/node_modules/*" -not -path "*/venv/*" \
  -not -path "*/__pycache__/*" -name "*.md" -o -name "*.py" -o -name "*.sh" -o -name "*.txt") | \
  wc -l | xargs echo "Files mentioning relationship topics:" | tee -a $REPORT_DIR/system_report.txt
echo "" | tee -a $REPORT_DIR/system_report.txt

# Generate summary
echo "=== SYSTEM ANALYSIS SUMMARY ===" | tee -a $REPORT_DIR/system_report.txt
echo "Total directories found: $(cat $REPORT_DIR/directories.txt | wc -l)" | tee -a $REPORT_DIR/system_report.txt
echo "Total shell scripts: $(cat $REPORT_DIR/shell_scripts.txt | wc -l)" | tee -a $REPORT_DIR/system_report.txt
echo "Total Python scripts: $(cat $REPORT_DIR/python_scripts.txt | wc -l)" | tee -a $REPORT_DIR/system_report.txt
echo "Total JSON files: $(cat $REPORT_DIR/json_files.txt | wc -l)" | tee -a $REPORT_DIR/system_report.txt
echo "Total Markdown files: $(cat $REPORT_DIR/markdown_files.txt | wc -l)" | tee -a $REPORT_DIR/system_report.txt
echo "Files modified in past week: $(cat $REPORT_DIR/recent_files.txt | wc -l)" | tee -a $REPORT_DIR/system_report.txt
echo "" | tee -a $REPORT_DIR/system_report.txt

echo "Analysis complete. Report available at $REPORT_DIR"
