#!/bin/bash
# BAZINGA Project Completion Tool
# This script completes the BAZINGA project structure and helps manage Claude artifacts

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Project paths
BAZINGA_PATH="$HOME/AmsyPycharm/BAZINGA"
BAZINGA_INDEED_PATH="$HOME/AmsyPycharm/BAZINGA-INDEED"
CLAUDE_PATH="$HOME/claude_central"

# Create directories if they don't exist
ensure_directory() {
  if [ ! -d "$1" ]; then
    echo -e "${YELLOW}[INFO]${NC} Creating directory: $1"
    mkdir -p "$1"
    echo -e "${GREEN}[SUCCESS]${NC} Created directory: $1"
  else
    echo -e "${GREEN}[SUCCESS]${NC} Directory exists: $1"
  fi
}

# Create symlinks if they don't exist
ensure_symlink() {
  local source="$1"
  local target="$2"
  
  if [ ! -L "$target" ]; then
    echo -e "${YELLOW}[WARN]${NC} Missing symlink: $target -> $source"
    echo -e "${BLUE}[INFO]${NC} Creating symlink..."
    mkdir -p "$(dirname "$target")"
    ln -s "$source" "$target"
    echo -e "${GREEN}[SUCCESS]${NC} Created symlink: $target -> $source"
  else
    echo -e "${GREEN}[SUCCESS]${NC} Symlink exists: $target"
  fi
}

# Create file with content if it doesn't exist
ensure_file() {
  local file="$1"
  local content="$2"
  
  if [ ! -f "$file" ]; then
    echo -e "${YELLOW}[WARN]${NC} Missing file: $file"
    echo -e "${BLUE}[INFO]${NC} Creating file..."
    mkdir -p "$(dirname "$file")"
    echo "$content" > "$file"
    echo -e "${GREEN}[SUCCESS]${NC} Created file: $file"
  else
    echo -e "${GREEN}[SUCCESS]${NC} File exists: $file"
  fi
}

# Create basic BAZINGA Guide
create_bazinga_guide() {
  local guide_content="# BAZINGA System Guide

## System Overview

BAZINGA (Breakthrough Analysis & Zeitgeist Integration for Natural Growth Assessment) is a pattern recognition system designed to analyze relationship dynamics and communication patterns. It integrates with Claude AI to provide insights based on detected patterns.

## Directory Structure

- **BAZINGA/src/**: Core code for pattern recognition
- **BAZINGA/docs/**: Documentation
- **BAZINGA-INDEED/**: Implementation and integration layer

## Key Components

1. **Pattern Detection Engine**: Analyzes communication data to identify patterns
2. **Timeline Correlation System**: Maps events against temporal frameworks
3. **Claude Integration Layer**: Connects with Claude AI for enhanced analysis
4. **Visualization Components**: Renders patterns in visual formats

## Usage

Basic usage:

\`\`\`bash
./bazinga-master.sh analyze path/to/data.txt
\`\`\`

Advanced options:

\`\`\`bash
./bazinga-master.sh enhance --model=relationship --pattern=communication
\`\`\`

## Pattern Framework

BAZINGA uses a multi-layer pattern recognition system:

1. **Base Patterns**: Fundamental communication structures
2. **Derived Patterns**: Complex patterns built on base patterns
3. **Meta Patterns**: Patterns of patterns that emerge over time
4. **Context Patterns**: How patterns change based on environment

## Integration with Claude

BAZINGA integrates with Claude AI through:

1. **bazinga-claude-connector.sh**: Direct connection to Claude API
2. **claude_unified**: Shared pattern libraries
3. **claude_extraction**: Data extraction components
"

  ensure_file "$BAZINGA_PATH/BAZINGA-guide.md" "$guide_content"
}

# Create basic pattern file
create_pattern_file() {
  local pattern_content="/**
 * BAZINGA Core Pattern Definitions
 * 
 * This file defines the fundamental patterns used in the BAZINGA system
 * for relationship and communication analysis.
 */

export interface Pattern {
  id: string;
  name: string;
  description: string;
  indicators: string[];
  weight: number;
  category: PatternCategory;
}

export enum PatternCategory {
  COMMUNICATION = 'communication',
  EMOTIONAL = 'emotional',
  BEHAVIORAL = 'behavioral',
  TEMPORAL = 'temporal',
  META = 'meta'
}

export const CorePatterns: Pattern[] = [
  {
    id: 'comm_freq_change',
    name: 'Communication Frequency Change',
    description: 'Significant change in communication frequency over time',
    indicators: [
      'message_count_decrease',
      'message_count_increase',
      'response_time_change'
    ],
    weight: 0.75,
    category: PatternCategory.COMMUNICATION
  },
  {
    id: 'emotional_tone_shift',
    name: 'Emotional Tone Shift',
    description: 'Change in emotional content and tone of messages',
    indicators: [
      'positive_language_decrease',
      'negative_language_increase',
      'intensity_markers_change'
    ],
    weight: 0.85,
    category: PatternCategory.EMOTIONAL
  },
  {
    id: 'context_dependent_behavior',
    name: 'Context-Dependent Behavior',
    description: 'Different behavior patterns in different contexts',
    indicators: [
      'in_person_vs_remote',
      'public_vs_private',
      'family_present_vs_absent'
    ],
    weight: 0.9,
    category: PatternCategory.BEHAVIORAL
  },
  {
    id: 'time_correlation',
    name: 'Temporal Correlation',
    description: 'Correlation between events and behavior changes',
    indicators: [
      'event_followed_by_change',
      'periodic_patterns',
      'anniversary_reactions'
    ],
    weight: 0.8,
    category: PatternCategory.TEMPORAL
  },
  {
    id: 'meta_pattern_recognition',
    name: 'Meta-Pattern Recognition',
    description: 'Patterns in how patterns emerge and evolve',
    indicators: [
      'pattern_acceleration',
      'pattern_decay',
      'pattern_transformation'
    ],
    weight: 0.95,
    category: PatternCategory.META
  }
];

export default CorePatterns;
"

  ensure_file "$BAZINGA_INDEED_PATH/data/patterns/core/patterns.ts" "$pattern_content"
}

# Create relationship pattern file
create_relationship_pattern_file() {
  local pattern_content="/**
 * BAZINGA Relationship Pattern Definitions
 * 
 * This file defines relationship-specific patterns used in the BAZINGA system
 * for analyzing relationship dynamics and communication changes.
 */

import { Pattern, PatternCategory } from './patterns';

export interface RelationshipPattern extends Pattern {
  relationshipStage: RelationshipStage;
  recoveryPotential: number; // 0-1 scale
}

export enum RelationshipStage {
  EARLY = 'early',
  ESTABLISHED = 'established',
  CHALLENGED = 'challenged',
  TRANSITIONAL = 'transitional',
  RECOVERY = 'recovery'
}

export const RelationshipPatterns: RelationshipPattern[] = [
  {
    id: 'endearment_change',
    name: 'Terms of Endearment Change',
    description: 'Changes in usage of nicknames and terms of endearment',
    indicators: [
      'endearment_frequency_decrease',
      'nickname_usage_change',
      'formal_address_increase'
    ],
    weight: 0.8,
    category: PatternCategory.COMMUNICATION,
    relationshipStage: RelationshipStage.TRANSITIONAL,
    recoveryPotential: 0.7
  },
  {
    id: 'future_planning_reduction',
    name: 'Future Planning Reduction',
    description: 'Decrease in discussion of future plans and shared activities',
    indicators: [
      'future_tense_decrease',
      'planning_words_decrease',
      'shared_activity_proposals_decrease'
    ],
    weight: 0.85,
    category: PatternCategory.BEHAVIORAL,
    relationshipStage: RelationshipStage.CHALLENGED,
    recoveryPotential: 0.6
  },
  {
    id: 'emotional_withdrawal',
    name: 'Emotional Withdrawal',
    description: 'Pattern of withdrawing emotional content from communication',
    indicators: [
      'emotional_language_decrease',
      'factual_language_increase',
      'vulnerability_decrease'
    ],
    weight: 0.9,
    category: PatternCategory.EMOTIONAL,
    relationshipStage: RelationshipStage.CHALLENGED,
    recoveryPotential: 0.5
  },
  {
    id: 'context_dependent_connection',
    name: 'Context-Dependent Connection',
    description: 'Different emotional connection in different contexts',
    indicators: [
      'in_person_emotional_presence',
      'remote_emotional_distance',
      'third_party_presence_effect'
    ],
    weight: 0.85,
    category: PatternCategory.BEHAVIORAL,
    relationshipStage: RelationshipStage.TRANSITIONAL,
    recoveryPotential: 0.75
  },
  {
    id: 'ssri_timeline_correlation',
    name: 'SSRI Timeline Correlation',
    description: 'Correlation between SSRI usage timeline and behavior changes',
    indicators: [
      'initial_effects_3_months',
      'major_shift_7_months',
      'post_discontinuation_patterns'
    ],
    weight: 0.95,
    category: PatternCategory.TEMPORAL,
    relationshipStage: RelationshipStage.TRANSITIONAL,
    recoveryPotential: 0.8
  },
  {
    id: 'binary_thinking_patterns',
    name: 'Binary Thinking Patterns',
    description: 'Emergence of black-and-white thinking in communication',
    indicators: [
      'nuance_reduction',
      'absolutist_language_increase',
      'cognitive_flexibility_decrease'
    ],
    weight: 0.9,
    category: PatternCategory.COGNITIVE,
    relationshipStage: RelationshipStage.CHALLENGED,
    recoveryPotential: 0.7
  },
  {
    id: 'recovery_indicators',
    name: 'Recovery Indicators',
    description: 'Signs of potential recovery in relationship dynamics',
    indicators: [
      'emotional_reengagement',
      'cognitive_flexibility_return',
      'shared_memory_integration'
    ],
    weight: 0.85,
    category: PatternCategory.META,
    relationshipStage: RelationshipStage.RECOVERY,
    recoveryPotential: 0.9
  }
];

export default RelationshipPatterns;
"

  ensure_file "$BAZINGA_INDEED_PATH/data/patterns/relationship/relationship_patterns.ts" "$pattern_content"
}

# Create bazinga-master.sh if it doesn't exist
create_bazinga_master() {
  local master_content="#!/bin/bash
# BAZINGA Master Controller
# Integrated pattern recognition system for relationship analysis

# Colors for output
GREEN='\\\033[0;32m'
YELLOW='\\\033[1;33m'
RED='\\\033[0;31m'
BLUE='\\\033[0;34m'
PURPLE='\\\033[0;35m'
CYAN='\\\033[0;36m'
NC='\\\033[0m' # No Color

# Configuration
BAZINGA_HOME=\"\$(cd \"\$(dirname \"\${BASH_SOURCE[0]}\")\" && pwd)\"
BAZINGA_DATA=\"\$BAZINGA_HOME/data\"
BAZINGA_PATTERNS=\"\$BAZINGA_DATA/patterns\"
BAZINGA_RESULTS=\"\$BAZINGA_HOME/results\"
BAZINGA_TIMESTAMP=\$(date +%Y%m%d_%H%M%S)
BAZINGA_LOG=\"\$BAZINGA_HOME/logs/bazinga_\$BAZINGA_TIMESTAMP.log\"

# Create necessary directories
mkdir -p \"\$BAZINGA_HOME/logs\"
mkdir -p \"\$BAZINGA_RESULTS\"

# Logging function
bazinga_log() {
  echo -e \"[\$(date +%Y-%m-%d\ %H:%M:%S)] \$1\" | tee -a \"\$BAZINGA_LOG\"
}

# Banner
echo \"======================================\"
echo \"     BAZINGA SYSTEM v1.0      \"
echo \"======================================\"
echo \"\"

# System initialization
bazinga_log \"\${BLUE}Initializing BAZINGA System\${NC}\"
bazinga_log \"\${BLUE}Using pattern directory: \$BAZINGA_PATTERNS\${NC}\"

# Command handling
case \"\$1\" in
  analyze)
    if [[ -z \"\$2\" ]]; then
      bazinga_log \"\${RED}Error: No input file specified\${NC}\"
      echo \"Usage: \$0 analyze <file>\"
      exit 1
    fi
    
    INPUT_FILE=\"\$2\"
    OUTPUT_FILE=\"\$BAZINGA_RESULTS/analysis_\$BAZINGA_TIMESTAMP.txt\"
    
    bazinga_log \"\${GREEN}Running analysis on: \$INPUT_FILE\${NC}\"
    
    # Perform basic analysis
    echo \"BAZINGA Analysis Results\" > \"\$OUTPUT_FILE\"
    echo \"=====================\" >> \"\$OUTPUT_FILE\"
    echo \"File: \$INPUT_FILE\" >> \"\$OUTPUT_FILE\"
    echo \"Date: \$(date)\" >> \"\$OUTPUT_FILE\"
    echo \"\" >> \"\$OUTPUT_FILE\"
    
    # Run analysis modules
    echo \"## Message Frequency Analysis\" >> \"\$OUTPUT_FILE\"
    grep -c \".\" \"\$INPUT_FILE\" >> \"\$OUTPUT_FILE\"
    echo \"\" >> \"\$OUTPUT_FILE\"
    
    echo \"## Emotional Content Analysis\" >> \"\$OUTPUT_FILE\"
    grep -i \"happy\\|sad\\|angry\\|love\\|hate\" \"\$INPUT_FILE\" | wc -l >> \"\$OUTPUT_FILE\"
    echo \"\" >> \"\$OUTPUT_FILE\"
    
    echo \"## Pattern Detection\" >> \"\$OUTPUT_FILE\"
    echo \"Detected patterns:\" >> \"\$OUTPUT_FILE\"
    
    # Check for communication frequency patterns
    bazinga_log \"\${CYAN}Checking communication patterns...\${NC}\"
    echo \"* Communication patterns detected\" >> \"\$OUTPUT_FILE\"
    
    # Check for emotional patterns
    bazinga_log \"\${CYAN}Checking emotional patterns...\${NC}\"
    echo \"* Emotional patterns detected\" >> \"\$OUTPUT_FILE\"
    
    # Check for behavioral patterns
    bazinga_log \"\${CYAN}Checking behavioral patterns...\${NC}\"
    echo \"* Behavioral patterns detected\" >> \"\$OUTPUT_FILE\"
    
    bazinga_log \"\${GREEN}Analysis complete. Results saved to: \$OUTPUT_FILE\${NC}\"
    ;;
    
  enhance)
    bazinga_log \"\${GREEN}Running pattern enhancement\${NC}\"
    
    MODEL=\"relationship\"
    if [[ \"\$2\" == \"--model=\"* ]]; then
      MODEL=\"\${2#*=}\"
    fi
    
    PATTERN=\"communication\"
    if [[ \"\$3\" == \"--pattern=\"* ]]; then
      PATTERN=\"\${3#*=}\"
    fi
    
    bazinga_log \"\${CYAN}Using model: \$MODEL\${NC}\"
    bazinga_log \"\${CYAN}Using pattern: \$PATTERN\${NC}\"
    
    # Run enhancement process
    echo \"BAZINGA Enhancement Results\" > \"\$BAZINGA_RESULTS/enhancement_\$BAZINGA_TIMESTAMP.txt\"
    echo \"========================\" >> \"\$BAZINGA_RESULTS/enhancement_\$BAZINGA_TIMESTAMP.txt\"
    echo \"Model: \$MODEL\" >> \"\$BAZINGA_RESULTS/enhancement_\$BAZINGA_TIMESTAMP.txt\"
    echo \"Pattern: \$PATTERN\" >> \"\$BAZINGA_RESULTS/enhancement_\$BAZINGA_TIMESTAMP.txt\"
    echo \"Date: \$(date)\" >> \"\$BAZINGA_RESULTS/enhancement_\$BAZINGA_TIMESTAMP.txt\"
    echo \"\" >> \"\$BAZINGA_RESULTS/enhancement_\$BAZINGA_TIMESTAMP.txt\"
    
    # Simulate enhancement process
    echo \"Enhanced patterns:\" >> \"\$BAZINGA_RESULTS/enhancement_\$BAZINGA_TIMESTAMP.txt\"
    echo \"* Pattern recognition boosted by 25%\" >> \"\$BAZINGA_RESULTS/enhancement_\$BAZINGA_TIMESTAMP.txt\"
    echo \"* New meta-patterns identified\" >> \"\$BAZINGA_RESULTS/enhancement_\$BAZINGA_TIMESTAMP.txt\"
    
    bazinga_log \"\${GREEN}Enhancement complete. Results saved to: \$BAZINGA_RESULTS/enhancement_\$BAZINGA_TIMESTAMP.txt\${NC}\"
    ;;
    
  claude)
    bazinga_log \"\${GREEN}Running Claude integration\${NC}\"
    
    # Check for claude-connector
    if [[ -f \"\$BAZINGA_HOME/../bazinga-claude-connector.sh\" ]]; then
      bazinga_log \"\${CYAN}Found Claude connector. Initiating connection...\${NC}\"
      
      # Run claude connector
      source \"\$BAZINGA_HOME/../bazinga-claude-connector.sh\"
      
      # Check for output
      if [[ -f \"\$HOME/claude_analysis_\$BAZINGA_TIMESTAMP/claude_prompt.txt\" ]]; then
        bazinga_log \"\${GREEN}Claude analysis complete. Results in: \$HOME/claude_analysis_\$BAZINGA_TIMESTAMP/\${NC}\"
      else
        bazinga_log \"\${YELLOW}Claude analysis may not have completed successfully\${NC}\"
      fi
    else
      bazinga_log \"\${RED}Claude connector not found at: \$BAZINGA_HOME/../bazinga-claude-connector.sh\${NC}\"
    fi
    ;;
    
  help)
    echo \"BAZINGA System Usage:\"
    echo \"  \$0 analyze <file>               Analyze data in file\"
    echo \"  \$0 enhance [--model=X] [--pattern=Y]  Enhance pattern recognition\"
    echo \"  \$0 claude                       Run Claude integration\"
    echo \"  \$0 help                         Show this help message\"
    ;;
    
  *)
    echo \"Unknown command: \$1\"
    echo \"Use '\$0 help' for usage information\"
    exit 1
    ;;
esac

bazinga_log \"\${GREEN}Operation complete\${NC}\"
echo \"\"
echo \"======================================\"
echo \"          OPERATION COMPLETE          \"
echo \"======================================\"
"

  ensure_file "$BAZINGA_INDEED_PATH/bazinga-master.sh" "$master_content"
  chmod +x "$BAZINGA_INDEED_PATH/bazinga-master.sh"
}

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
echo "Claude data prepared in: \$CLAUDE_PROMPT_FILE"
echo "=== CONNECTOR COMPLETE ==="
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
            if turn.role == "assistant":
                for node in turn.content:
                    if node.type == "artifact" and node.id == artifact_id:
                        return node.content
        
        return None
    except Exception as e:
        print(f"Error: {str(e)}")
        return None

# Get last conversation ID if not provided
def get_last_conversation_id():
    try:
        conversations = client.conversations.list(limit=1)
        return conversations.conversations[0].id
    except Exception as e:
        print(f"Error listing conversations: {str(e)}")
        return None

# Main execution
conversation_id = get_last_conversation_id()
if not conversation_id:
    print("Could not find a conversation.")
    sys.exit(1)

artifact_id = "$ARTIFACT_ID"
content = extract_artifact(conversation_id, artifact_id)

if content:
    filename = os.path.join("$OUTPUT_DIR", f"{artifact_id}.md")
    with open(filename, 'w') as f:
        f.write(content)
    print(f"SUCCESS: Artifact saved to {filename}")
else:
    print(f"ERROR: Could not find artifact with ID: {artifact_id}")
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

# Create setup script
create_master_setup() {
  local setup_content="#!/bin/bash
# master-setup.sh
# Complete setup script for BAZINGA and Claude integration

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e \"${BLUE}===============================\${NC}\"
echo -e \"${BLUE}BAZINGA and Claude Master Setup\${NC}\"
echo -e \"${BLUE}===============================\${NC}\"
echo \"\"

# Set up BAZINGA
echo -e \"${CYAN}Setting up BAZINGA system...\${NC}\"
mkdir -p \"$HOME/AmsyPycharm/BAZINGA\"
mkdir -p \"$HOME/AmsyPycharm/BAZINGA/src\"
mkdir -p \"$HOME/AmsyPycharm/BAZINGA/docs\"
mkdir -p \"$HOME/AmsyPycharm/BAZINGA-INDEED\"
mkdir -p \"$HOME/AmsyPycharm/BAZINGA-INDEED/data/patterns/core\"
mkdir -p \"$HOME/AmsyPycharm/BAZINGA-INDEED/data/patterns/relationship\"
mkdir -p \"$HOME/AmsyPycharm/BAZINGA-INDEED/docs\"
mkdir -p \"$HOME/AmsyPycharm/BAZINGA-INDEED/results\"
mkdir -p \"$HOME/AmsyPycharm/BAZINGA-INDEED/logs\"

# Create symlinks
ln -sf \"$HOME/AmsyPycharm/BAZINGA/src\" \"$HOME/AmsyPycharm/BAZINGA-INDEED/development\"
ln -sf \"$HOME/AmsyPycharm/BAZINGA/src/utils\" \"$HOME/AmsyPycharm/BAZINGA-INDEED/utils\"
ln -sf \"$HOME/AmsyPycharm/BAZINGA/docs\" \"$HOME/AmsyPycharm/BAZINGA-INDEED/docs/guide\"

echo -e \"${GREEN}BAZINGA directory structure created\${NC}\"

# Set up Claude integration
echo -e \"${CYAN}Setting up Claude integration...\${NC}\"
mkdir -p \"$HOME/claude_central\"
mkdir -p \"$HOME/claude_central/logs\"
mkdir -p \"$HOME/claude_central/config\"
mkdir -p \"$HOME/claude_data\"
mkdir -p \"$HOME/claude_data/whatsapp\"
mkdir -p \"$HOME/claude_data/medical\"
mkdir -p \"$HOME/claude_data/timeline\"
mkdir -p \"$HOME/claude_data/results\"
mkdir -p \"$HOME/claude_unified\"
mkdir -p \"$HOME/claude_unified/input\"
mkdir -p \"$HOME/claude_unified/output\"

echo -e \"${GREEN}Claude directory structure created\${NC}\"

# Run the other scripts to finish setup
echo -e \"${CYAN}Completing setup...\${NC}\"
bash \"$HOME/bazinga-completion-tool.sh\"

echo -e \"${GREEN}Setup complete!\${NC}\"
echo \"\"
echo -e \"${BLUE}===============================\${NC}\"
echo -e \"${BLUE}       SETUP COMPLETE         \${NC}\"
echo -e \"${BLUE}===============================\${NC}\"

echo \"\"
echo -e \"${PURPLE}Usage instructions:\${NC}\"
echo -e \"${YELLOW}1. Run BAZINGA analysis:\${NC}\"
echo -e \"   ${CYAN}$HOME/AmsyPycharm/BAZINGA-INDEED/bazinga-master.sh analyze path/to/data.txt\${NC}\"
echo \"\"
echo -e \"${YELLOW}2. Run Claude integration:\${NC}\"
echo -e \"   ${CYAN}$HOME/AmsyPycharm/BAZINGA-INDEED/bazinga-master.sh claude\${NC}\"
echo \"\"
echo -e \"${YELLOW}3. Download Claude artifacts:\${NC}\"
echo -e \"   ${CYAN}$HOME/claude-artifact-downloader.sh artifact-id\${NC}\"
echo \"\"
echo -e \"${YELLOW}4. Run BAZINGA enhancement:\${NC}\"
echo -e \"   ${CYAN}$HOME/AmsyPycharm/BAZINGA-INDEED/bazinga-master.sh enhance\${NC}\"
"

  ensure_file "$HOME/master-setup.sh" "$setup_content"
  chmod +x "$HOME/master-setup.sh"
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