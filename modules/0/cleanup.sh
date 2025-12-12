#!/bin/bash
# System Cleanup and Space Analysis Script

# Create cleanup directory
CLEANUP_DIR="$HOME/system_cleanup"
mkdir -p "$CLEANUP_DIR"

echo "=== System Cleanup and Space Analysis ==="

# Check disk usage
echo "Overall disk usage:"
df -h | grep -E '/$'

# Function to find large directories
find_large_dirs() {
    local directory="$1"
    local output_file="$CLEANUP_DIR/large_dirs_$(basename "$directory").txt"
    
    echo "Finding large directories in $directory..."
    du -h "$directory" 2>/dev/null | sort -rh | head -20 > "$output_file"
    echo "Top 20 largest directories in $directory saved to $output_file"
}

# Function to find large files
find_large_files() {
    local directory="$1"
    local output_file="$CLEANUP_DIR/large_files_$(basename "$directory").txt"
    
    echo "Finding large files in $directory..."
    find "$directory" -type f -size +10M -exec du -h {} \; 2>/dev/null | sort -rh | head -20 > "$output_file"
    echo "Top 20 largest files in $directory saved to $output_file"
}

# Find large directories in common locations
find_large_dirs "$HOME/Downloads"
find_large_dirs "$HOME/Documents"
find_large_dirs "$HOME/AmsyPycharm"  # This appears to be a custom directory

# Find large files in home directory
find_large_files "$HOME"

# Check for duplicates in Claude directories
echo "Checking for duplicate files in Claude directories..."
# Fix for the uniq -w option which isn't available on macOS
find "$HOME" -path "*claude*" -type f -size +1M -exec md5 -r {} \; 2>/dev/null | sort | uniq -D | head -20 > "$CLEANUP_DIR/duplicate_claude_files.txt"
echo "Duplicate Claude files saved to $CLEANUP_DIR/duplicate_claude_files.txt"

# Check for old logs
echo "Checking for old log files..."
find "$HOME/Library/Logs" -type f -mtime +30 -exec du -h {} \; 2>/dev/null | sort -rh | head -20 > "$CLEANUP_DIR/old_logs.txt"
echo "Old log files saved to $CLEANUP_DIR/old_logs.txt"

# Check for cache files
echo "Checking for large cache files..."
find "$HOME/Library/Caches" -type f -size +10M -exec du -h {} \; 2>/dev/null | sort -rh | head -20 > "$CLEANUP_DIR/large_cache_files.txt"
echo "Large cache files saved to $CLEANUP_DIR/large_cache_files.txt"

# Check node_modules directories
echo "Checking for large node_modules directories..."
find "$HOME" -type d -name "node_modules" -exec du -sh {} \; 2>/dev/null | sort -rh | head -20 > "$CLEANUP_DIR/large_node_modules.txt"
echo "Large node_modules directories saved to $CLEANUP_DIR/large_node_modules.txt"

# Create recommendations file
cat > "$CLEANUP_DIR/cleanup_recommendations.txt" << EOF
=== Cleanup Recommendations ===

1. Review large files in $CLEANUP_DIR/large_files_*.txt and consider:
   - Deleting unnecessary downloads, videos, or disk images
   - Moving large files to external storage
   - Compressing large files you need to keep

2. Check duplicate files in $CLEANUP_DIR/duplicate_claude_files.txt:
   - These files have identical content but different names/locations
   - Consider removing duplicates to free up space

3. Old log files in $CLEANUP_DIR/old_logs.txt:
   - These logs are older than 30 days and can usually be safely deleted

4. Large cache files in $CLEANUP_DIR/large_cache_files.txt:
   - Application caches can be safely cleared in most cases
   - This can be done through the applications' settings or by deleting the files

5. Node modules directories in $CLEANUP_DIR/large_node_modules.txt:
   - For projects you're no longer working on, consider removing node_modules
   - You can always reinstall them later with 'npm install'

CAUTION: Always make backups before deleting files you're unsure about.
EOF

echo "=== Analysis complete! ==="
echo "Check $CLEANUP_DIR for detailed reports and recommendations"
echo "Review cleanup_recommendations.txt for next steps"
