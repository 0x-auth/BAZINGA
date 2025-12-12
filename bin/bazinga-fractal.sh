#!/bin/bash
# bazinga-fractal.sh - Self-optimizing BAZINGA system

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${CYAN}⟨ψ|⟳| BAZINGA Fractal Optimizer |ψ⟩${NC}"

BAZINGA_DIR=${BAZINGA_DIR:-"$PWD"}
PHI=1.618033988749895

# Create unified command system
mkdir -p "$BAZINGA_DIR/system"
UNIFIED="$BAZINGA_DIR/system/bazinga"

# Find script duplicates using Fibonacci-based sampling
detect_patterns() {
 find "$BAZINGA_DIR" -name "*.sh" | sort > /tmp/all_scripts.txt
 total=$(wc -l < /tmp/all_scripts.txt)
 
 # Use golden ratio to determine sample size
 sample_size=$(echo "$total / $PHI" | bc)
 
 # Hash contents for pattern detection
 scripts=$(cat /tmp/all_scripts.txt | sort -R | head -n "$sample_size")
 for script in $scripts; do
   category=$(basename "$script" | cut -d'-' -f1)
   md5=$(md5sum "$script" | cut -d' ' -f1)
   echo "$md5 $category $script" >> /tmp/script_patterns.txt
 done
 
 sort /tmp/script_patterns.txt | uniq -w32 -d
}

# Create self-correcting unified script
cat > "$UNIFIED" << 'EOL'
#!/bin/bash
# BAZINGA Unified Command System - Fractal Architecture

FRACTALS=(1 1 2 3 5 8 13 21)
GOLDEN_RATIO=1.618033988749895
BAZINGA_DIR=${BAZINGA_DIR:-"$PWD"}

# Self-correction using golden ratio branching
correct_self() {
 if grep -q "error" "$0.log" 2>/dev/null; then
   backup="$0.$(date +%s)"
   cp "$0" "$backup"
   sed -i.bak '/unexpected/d; /error/d' "$0"
   chmod +x "$0"
   echo "Self-corrected from backup: $backup"
 fi
}

# Fibonacci-based command routing
route_command() {
 cmd="$1"
 shift
 
 for dir in system bin scripts .; do
   for idx in "${FRACTALS[@]}"; do
     pattern="*${cmd:0:$idx}*"
     script=$(find "$BAZINGA_DIR/$dir" -name "$pattern" 2>/dev/null | head -1)
     if [ -n "$script" ] && [ -x "$script" ]; then
       "$script" "$@" 2> >(tee -a "$0.log" >&2)
       return $?
     fi
   done
 done
 
 # Fall back to most similar command by pattern
 similar=$(find "$BAZINGA_DIR" -type f -name "*.sh" | xargs basename | grep -i "${cmd:0:3}" | head -1)
 if [ -n "$similar" ]; then
   script=$(find "$BAZINGA_DIR" -name "$similar" | head -1)
   echo "Using $similar instead of $cmd"
   "$script" "$@" 2> >(tee -a "$0.log" >&2)
 else
   echo "Command not found: $cmd"
   return 1
 fi
}

# Apply corrections
correct_self

# Main entrypoint
case "$1" in
 visualize|visual) route_command visualize "${@:2}" ;;
 trust|correct) route_command trust "${@:2}" ;;
 glance|activity) route_command glance "${@:2}" ;;
 clean|optimize) find "$BAZINGA_DIR" -name "*.bak" -o -name "*~" -delete ;;
 *) route_command "$@" ;;
esac
EOL

chmod +x "$UNIFIED"

# Create simpler symbolic links
ln -sf "$UNIFIED" "$BAZINGA_DIR/baz"

# Remove exact duplicates
duplicate_hashes=$(detect_patterns)
if [ -n "$duplicate_hashes" ]; then
 echo "$duplicate_hashes" | while read hash category script; do
   if [ -n "$(find "$BAZINGA_DIR/bin" -name "*-$category-*.sh" 2>/dev/null | head -1)" ]; then
     echo "Removing duplicate: $script"
     rm "$script"
   fi
 done
fi

echo -e "${GREEN}Fractal optimization complete!${NC}"
echo -e "${CYAN}Use ./baz or ./system/bazinga for all commands${NC}"
