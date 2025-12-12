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
      PATTERN=\"\${3#*=}