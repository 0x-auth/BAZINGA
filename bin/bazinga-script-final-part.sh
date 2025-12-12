# Create bazinga-claude-connector.sh if it doesn't exist
create_claude_connector() {
  local connector_content="#!/bin/bash
# bazinga-claude-connector.sh
# Connects BAZINGA system with Claude AI for enhanced pattern analysis

# Configuration
CLAUDE_TIMESTAMP=\$(date +%Y%m%d_%H%M%S)
CLAUDE_OUTPUT_DIR=\"\$HOME/claude_analysis_\$CLAUDE_TIMESTAMP\"
CLAUDE_PROMPT_FILE=\"\$CLAUDE_OUTPUT_DIR/claude_prompt.txt\"

# Create output directory
mkdir -p \"\$CLAUDE_OUTPUT_DIR\"

# Generate Claude prompt
cat > \"\$CLAUDE_PROMPT_FILE\" << EOF
Human: I need a comprehensive pattern analysis based on the BAZINGA framework.

The BAZINGA framework identifies the following patterns:
1. Communication frequency changes
2. Emotional tone shifts
3. Context-dependent behavior
4. Temporal correlation with medication
5. Binary thinking patterns

Based on these patterns, please provide:
1. An analysis of how these patterns interact
2. Potential underlying mechanisms
3. Recommended approaches for addressing these patterns
4. A timeline for expected changes

Thank you.
EOF

# Log the output
echo \"Claude data prepared in: \$CLAUDE_PROMPT_FILE\"
echo \"=== CONNECTOR COMPLETE ===\"
"

  ensure_file "$HOME/bazinga-claude-connector.sh" "$connector_content"
  chmod +x "$HOME/bazinga-claude-connector.sh"
}

# Create Claude CLI artifact downloader
create_claude_artifact_downloader() {
  local downloader_content="#!/bin/bash
# claude-artifact-downloader.sh
# Downloads artifacts from Claude conversations

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
OUTPUT_DIR=\"\$HOME/claude_artifacts\"
TIMESTAMP=\$(date +%Y%m%d_%H%M%S)

# Create output directory if it doesn't exist
mkdir -p \"\$OUTPUT_DIR\"

# Usage information
if [[ \$# -lt 1 ]]; then
  echo -e \"${RED}Error: No artifact ID specified${NC}\"
  echo \"Usage: \$0 <artifact_id> [output_dir]\"
  echo \"Example: \$0 mental-healthcare-act-action-plan ~/Documents/\"
  exit 1
fi

ARTIFACT_ID=\"\$1\"

# Override output directory if specified
if [[ -n \"\$2\" ]]; then
  OUTPUT_DIR=\"\$2\"
  mkdir -p \"\$OUTPUT_DIR\"
fi

echo -e \"${BLUE}Claude Artifact Downloader${NC}\"
echo -e \"${BLUE}Downloading artifact: ${YELLOW}\$ARTIFACT_ID${NC}\"
echo -e \"${BLUE}Output directory: ${YELLOW}\$OUTPUT_DIR${NC}\"

# Check if Claude CLI is installed
if ! command -v claude &> /dev/null; then
  echo -e \"${RED}Error: Claude CLI not found. Please install it first.${NC}\"
  echo \"See: https://github.com/anthropics/anthropic-sdk-python\"
  exit 1
fi

# Create a temporary file for the download script
TEMP_SCRIPT=\"\$OUTPUT_DIR/download_\$TIMESTAMP.py\"

cat > \"\$TEMP_SCRIPT\" << EOF
from anthropic import Anthropic
import json
import sys
import os

client = Anthropic()

# Function to extract artifact content from conversation
def extract_artifact(conversation_id, artifact_id):
    try:
        conversation = client.conversations.retrieve(conversation_id)
        
        for turn in conversation.turns:
            if turn.role == \"assistant\":
                for node in turn.content:
                    if node.type == \"artifact\" and node.id == artifact_id:
                        return node.content
        
        return None
    except Exception as e:
        print(f\"Error: {str(e)}\")
        return None

# Get last conversation ID if not provided
def get_last_conversation_id():
    try:
        conversations = client.conversations.list(limit=1)
        return conversations.conversations[0].id
    except Exception as e:
        print(f\"Error listing conversations: {str(e)}\")
        return None

# Main execution
conversation_id = get_last_conversation_id()
if not conversation_id:
    print(\"Could not find a conversation.\")
    sys.exit(1)

artifact_id = \"$ARTIFACT_ID\"
content = extract_artifact(conversation_id, artifact_id)

if content:
    filename = os.path.join(\"$OUTPUT_DIR\", f\"{artifact_id}.md\")
    with open(filename, 'w') as f:
        f.write(content)
    print(f\"SUCCESS: Artifact saved to {filename}\")
else:
    print(f\"ERROR: Could not find artifact with ID: {artifact_id}\")
    sys.exit(1)
EOF

# Run the script
echo -e \"${BLUE}Running download script...${NC}\"
python \"\$TEMP_SCRIPT\"

# Clean up
rm \"\$TEMP_SCRIPT\"

echo -e \"${GREEN}Download operation complete${NC}\"
"

  ensure_file "$HOME/claude-artifact-downloader.sh" "$downloader_content"
  chmod +x "$HOME/claude-artifact-downloader.sh"
}

# Main function to set up everything
main() {
  echo -e "${BLUE}===============================${NC}"
  echo -e "${BLUE}BAZINGA Project Completion Tool${NC}"
  echo -e "${BLUE}===============================${NC}"
  echo ""

  echo -e "${CYAN}Checking directory structure...${NC}"
  
  # Ensure BAZINGA directories exist
  ensure_directory "$BAZINGA_PATH"
  ensure_directory "$BAZINGA_INDEED_PATH"
  
  # Ensure BAZINGA directory structure
  ensure_directory "$BAZINGA_PATH/src"
  ensure_directory "$BAZINGA_PATH/docs"
  ensure_directory "$BAZINGA_INDEED_PATH/data/patterns/core"
  ensure_directory "$BAZINGA_INDEED_PATH/data/patterns/relationship"
  ensure_directory "$BAZINGA_INDEED_PATH/docs"
  
  echo -e "${CYAN}Checking symbolic links...${NC}"
  
  # Ensure symlinks
  ensure_symlink "$BAZINGA_PATH/src" "$BAZINGA_INDEED_PATH/development"
  ensure_symlink "$BAZINGA_PATH/src/utils" "$BAZINGA_INDEED_PATH/utils"
  ensure_symlink "$BAZINGA_PATH/docs" "$BAZINGA_INDEED_PATH/docs/guide"
  
  echo -e "${CYAN}Checking core files...${NC}"
  
  # Create BAZINGA guide if it doesn't exist
  create_bazinga_guide
  
  # Create bazinga-master.sh if it doesn't exist
  create_bazinga_master
  
  echo -e "${CYAN}Checking pattern files...${NC}"
  
  # Create pattern files if they don't exist
  create_pattern_file
  create_relationship_pattern_file
  
  # Create Claude tools
  echo -e "${CYAN}Creating Claude integration tools...${NC}"
  create_claude_connector
  create_claude_artifact_downloader
  
  # Create master setup script
  echo -e "${CYAN}Creating master setup script...${NC}"
  create_master_setup
  
  echo -e "${GREEN}BAZINGA project setup complete!${NC}"
  echo ""
  echo -e "${YELLOW}Usage instructions:${NC}"
  echo -e "1. Run the BAZINGA master controller:"
  echo -e "   ${CYAN}$BAZINGA_INDEED_PATH/bazinga-master.sh analyze <file>${NC}"
  echo -e "   ${CYAN}$BAZINGA_INDEED_PATH/bazinga-master.sh enhance${NC}"
  echo -e "   ${CYAN}$BAZINGA_INDEED_PATH/bazinga-master.sh claude${NC}"
  echo -e "   ${CYAN}$BAZINGA_INDEED_PATH/bazinga-master.sh generate analyzer|pattern|visualizer|report${NC}"
  echo ""
  echo -e "2. Download Claude artifacts:"
  echo -e "   ${CYAN}$HOME/claude-artifact-downloader.sh <artifact-id> [output-dir]${NC}"
  echo ""
  echo -e "3. For complete setup, run:"
  echo -e "   ${CYAN}$HOME/master-setup.sh${NC}"
  echo ""
  echo -e "${BLUE}===============================${NC}"
}

# Execute main function
main
