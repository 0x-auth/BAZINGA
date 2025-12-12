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
