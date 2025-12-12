#!/bin/bash
# BAZINGA Info Extractor
# This script extracts key information from a BAZINGA project
# and formats it for sharing

OUTFILE="bazinga_extract_info.txt"

echo "===== BAZINGA SYSTEM EXTRACT =====" > $OUTFILE
echo "Generated: $(date)" >> $OUTFILE
echo "" >> $OUTFILE

# Get core information about the project
echo "CORE STRUCTURE:" >> $OUTFILE
echo "----------------" >> $OUTFILE
find ./src -type d -maxdepth 2 | sort >> $OUTFILE
echo "" >> $OUTFILE

# Extract key concepts from documentation
echo "KEY CONCEPTS:" >> $OUTFILE
echo "-------------" >> $OUTFILE
grep -r "concept:" ./docs --include="*.md" | head -10 >> $OUTFILE
echo "" >> $OUTFILE

# Get overview of fractal integration
echo "FRACTAL INTEGRATION:" >> $OUTFILE
echo "-------------------" >> $OUTFILE
grep -r "class" ./fractal_*integration.py --include="*.py" | head -10 >> $OUTFILE
echo "" >> $OUTFILE

# Basic stats about the codebase
echo "CODE STATISTICS:" >> $OUTFILE
echo "---------------" >> $OUTFILE
echo "Python files: $(find . -name "*.py" | wc -l)" >> $OUTFILE
echo "TypeScript files: $(find . -name "*.ts" | wc -l)" >> $OUTFILE
echo "Documentation files: $(find ./docs -name "*.md" | wc -l)" >> $OUTFILE
echo "" >> $OUTFILE

# Check for any system capabilities
echo "SYSTEM CAPABILITIES:" >> $OUTFILE
echo "-------------------" >> $OUTFILE
grep -r "def generate_" --include="*.py" | head -5 >> $OUTFILE
echo "..." >> $OUTFILE
grep -r "def analyze_" --include="*.py" | head -5 >> $OUTFILE
echo "" >> $OUTFILE

# Integration information
echo "INTEGRATION POINTS:" >> $OUTFILE
echo "------------------" >> $OUTFILE
grep -r "import dodo" --include="*.py" | head -3 >> $OUTFILE
grep -r "connect_to_" --include="*.py" | head -3 >> $OUTFILE
echo "" >> $OUTFILE

# Check recent changes to understand current development
echo "RECENT DEVELOPMENT:" >> $OUTFILE
echo "------------------" >> $OUTFILE
find . -type f -name "*.py" -o -name "*.ts" -mtime -7 | head -10 >> $OUTFILE
echo "" >> $OUTFILE

echo "===== EXTRACT COMPLETE =====" >> $OUTFILE
echo "" >> $OUTFILE
echo "This extract is limited to avoid token overflow." >> $OUTFILE
echo "For more detailed analysis, run with --comprehensive flag." >> $OUTFILE

echo "Extract saved to $OUTFILE"
echo "Run 'cat $OUTFILE' to view the results"
echo "Then copy/paste the content for further analysis"
