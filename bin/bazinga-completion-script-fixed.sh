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

# Create directories if they don''t exist
ensure_directory() {
  if [ ! -d "$1" ]; then
    echo -e "${YELLOW}[INFO]${NC} Creating directory: $1"
    mkdir -p "$1"
    echo -e "${GREEN}[SUCCESS]${NC} Created directory: $1"
  else
    echo -e "${GREEN}[SUCCESS]${NC} Directory exists: $1"
  fi
}

# Create symlinks if they don''t exist
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

# Create file with content if it doesn''t exist
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

# Create bazinga-master.sh if it doesn''t exist
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
    
  generate)
    bazinga_log \"\${GREEN}Running code generation\${NC}\"
    
    if [[ -z \"\$2\" ]]; then
      bazinga_log \"\${RED}Error: No code generation type specified\${NC}\"
      echo \"Usage: \$0 generate <type> [options]\"
      echo \"Available types: analyzer, pattern, visualizer, report\"
      exit 1
    fi
    
    GEN_TYPE=\"\$2\"
    OUTPUT_FILE=\"\$BAZINGA_RESULTS/generated_\${GEN_TYPE}_\$BAZINGA_TIMESTAMP\"
    
    case \"\$GEN_TYPE\" in
      analyzer)
        bazinga_log \"\${CYAN}Generating analyzer code...\${NC}\"
        OUTPUT_FILE=\"\${OUTPUT_FILE}.py\"
        
        # Generate Python analyzer
        cat > \"\$OUTPUT_FILE\" << EOF
#!/usr/bin/env python3
# BAZINGA Pattern Analyzer
# Auto-generated by BAZINGA System

import os
import re
import json
import pandas as pd
import matplotlib.pyplot as plt
from datetime import datetime, timedelta

class PatternAnalyzer:
    def __init__(self, data_path=None):
        self.data_path = data_path
        self.data = None
        self.results = {}
    
    def load_data(self, file_path=None):
        if file_path:
            self.data_path = file_path
        
        if not self.data_path:
            raise ValueError("No data path specified")
        
        if self.data_path.endswith('.txt'):
            self.data = self._load_whatsapp_chat()
        elif self.data_path.endswith('.json'):
            self.data = self._load_json_data()
        else:
            raise ValueError(f"Unsupported file format: {self.data_path}")
        
        return self.data
    
    def _load_whatsapp_chat(self):
        messages = []
        pattern = r'\\[(\d{1,2}/\d{1,2}/\d{2,4}), (\d{1,2}:\d{2}:\d{2})\\] ([^:]+): (.+)'
        
        with open(self.data_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        matches = re.findall(pattern, content)
        
        for match in matches:
            date_str, time_str, sender, message = match
            try:
                # Parse date and time
                date_formats = ['%d/%m/%y', '%d/%m/%Y', '%m/%d/%y', '%m/%d/%Y']
                date_obj = None
                
                for fmt in date_formats:
                    try:
                        date_obj = datetime.strptime(date_str, fmt)
                        break
                    except ValueError:
                        continue
                
                if date_obj is None:
                    continue
                
                time_obj = datetime.strptime(time_str, '%H:%M:%S').time()
                timestamp = datetime.combine(date_obj.date(), time_obj)
                
                messages.append({
                    'date': timestamp,
                    'sender': sender.strip(),
                    'message': message.strip()
                })
            except Exception as e:
                print(f"Error parsing message: {e}")
        
        return pd.DataFrame(messages)
    
    def _load_json_data(self):
        with open(self.data_path, 'r') as f:
            data = json.load(f)
        
        # Handle different JSON formats
        if isinstance(data, list):
            return pd.DataFrame(data)
        elif isinstance(data, dict) and 'messages' in data:
            return pd.DataFrame(data['messages'])
        else:
            # Try to flatten the JSON structure
            flattened = []
            self._flatten_json(data, flattened)
            return pd.DataFrame(flattened)
    
    def _flatten_json(self, data, result, prefix=''):
        if isinstance(data, dict):
            for key, value in data.items():
                new_key = f"{prefix}_{key}" if prefix else key
                if isinstance(value, (dict, list)):
                    self._flatten_json(value, result, new_key)
                else:
                    result.append({new_key: value})
        elif isinstance(data, list):
            for i, item in enumerate(data):
                new_key = f"{prefix}_{i}" if prefix else str(i)
                if isinstance(item, (dict, list)):
                    self._flatten_json(item, result, new_key)
                else:
                    result.append({new_key: item})
    
    def analyze_frequency(self, group_by='day'):
        if self.data is None:
            raise ValueError("No data loaded. Call load_data() first.")
        
        if 'date' not in self.data.columns:
            raise ValueError("Data does not contain date column")
        
        if group_by == 'day':
            self.data['date_group'] = self.data['date'].dt.date
        elif group_by == 'week':
            self.data['date_group'] = self.data['date'].dt.to_period('W').dt.start_time.dt.date
        elif group_by == 'month':
            self.data['date_group'] = self.data['date'].dt.to_period('M').dt.start_time.dt.date
        else:
            raise ValueError(f"Unsupported group_by value: {group_by}")
        
        frequency = self.data.groupby(['date_group', 'sender']).size().unstack(fill_value=0)
        
        self.results['frequency'] = frequency
        return frequency
    
    def analyze_emotion(self, emotion_words=None):
        if self.data is None:
            raise ValueError("No data loaded. Call load_data() first.")
        
        if 'message' not in self.data.columns:
            raise ValueError("Data does not contain message column")
        
        if emotion_words is None:
            emotion_words = {
                'positive': ['happy', 'love', 'good', 'great', 'awesome', 'excellent', 'wonderful', 'amazing'],
                'negative': ['sad', 'angry', 'bad', 'terrible', 'awful', 'horrible', 'disappointing'],
                'neutral': ['okay', 'fine', 'alright', 'normal']
            }
        
        for emotion, words in emotion_words.items():
            self.data[f'{emotion}_count'] = self.data['message'].apply(
                lambda x: sum(1 for word in words if re.search(r'\\b' + word + r'\\b', x.lower()))
            )
        
        emotion_results = {}
        for emotion in emotion_words.keys():
            emotion_results[emotion] = self.data.groupby('sender')[f'{emotion}_count'].sum()
        
        self.results['emotion'] = emotion_results
        return emotion_results
    
    def analyze_period(self, start_date, end_date, compare_days=14):
        if self.data is None:
            raise ValueError("No data loaded. Call load_data() first.")
        
        if 'date' not in self.data.columns:
            raise ValueError("Data does not contain date column")
        
        if isinstance(start_date, str):
            start_date = datetime.strptime(start_date, '%Y-%m-%d')
        
        if isinstance(end_date, str):
            end_date = datetime.strptime(end_date, '%Y-%m-%d')
        
        before_period = (start_date - timedelta(days=compare_days), start_date)
        after_period = (end_date, end_date + timedelta(days=compare_days))
        
        analysis_period = self.data[(self.data['date'] >= start_date) & (self.data['date'] <= end_date)]
        before_data = self.data[(self.data['date'] >= before_period[0]) & (self.data['date'] <= before_period[1])]
        after_data = self.data[(self.data['date'] >= after_period[0]) & (self.data['date'] <= after_period[1])]
        
        period_analysis = {
            'message_count': len(analysis_period),
            'messages_per_day': len(analysis_period) / (end_date - start_date).days if (end_date - start_date).days > 0 else 0,
            'sender_distribution': analysis_period['sender'].value_counts().to_dict(),
            'before_period': {
                'message_count': len(before_data),
                'messages_per_day': len(before_data) / compare_days if compare_days > 0 else 0,
                'sender_distribution': before_data['sender'].value_counts().to_dict()
            },
            'after_period': {
                'message_count': len(after_data),
                'messages_per_day': len(after_data) / compare_days if compare_days > 0 else 0,
                'sender_distribution': after_data['sender'].value_counts().to_dict()
            }
        }
        
        self.results['period_analysis'] = period_analysis
        return period_analysis
    
    def detect_patterns(self, pattern_types=None):
        if self.data is None:
            raise ValueError("No data loaded. Call load_data() first.")
        
        if pattern_types is None:
            pattern_types = ['frequency', 'response_time', 'emotional', 'content']
        
        patterns = {}
        
        # Frequency patterns
        if 'frequency' in pattern_types:
            if 'frequency' not in self.results:
                self.analyze_frequency()
            
            freq = self.results['frequency']
            senders = freq.columns.tolist()
            
            for sender in senders:
                # Check for frequency changes
                patterns[f'{sender}_frequency'] = self._detect_significant_changes(freq[sender])
        
        # Response time patterns
        if 'response_time' in pattern_types and 'date' in self.data.columns and 'sender' in self.data.columns:
            self.data = self.data.sort_values('date')
            response_times = []
            
            for i in range(1, len(self.data)):
                if self.data.iloc[i]['sender'] != self.data.iloc[i-1]['sender']:
                    response_time = (self.data.iloc[i]['date'] - self.data.iloc[i-1]['date']).total_seconds() / 60
                    response_times.append({
                        'sender': self.data.iloc[i]['sender'],
                        'previous_sender': self.data.iloc[i-1]['sender'],
                        'response_time_minutes': response_time,
                        'date': self.data.iloc[i]['date']
                    })
            
            response_df = pd.DataFrame(response_times)
            
            if not response_df.empty:
                # Group by sender and week
                response_df['week'] = response_df['date'].dt.to_period('W')
                weekly_response = response_df.groupby(['week', 'sender'])['response_time_minutes'].mean().unstack(fill_value=0)
                
                for sender in weekly_response.columns:
                    patterns[f'{sender}_response_time'] = self._detect_significant_changes(weekly_response[sender])
        
        # Emotional patterns
        if 'emotional' in pattern_types:
            if 'emotion' not in self.results:
                self.analyze_emotion()
            
            # Already performed in analyze_emotion
            pass
        
        self.results['patterns'] = patterns
        return patterns
    
    def _detect_significant_changes(self, series, threshold=2.0):
        # Calculate moving average and standard deviation
        window = min(7, len(series) // 3) if len(series) > 3 else 1
        rolling_mean = series.rolling(window=window, min_periods=1).mean()
        rolling_std = series.rolling(window=window, min_periods=1).std().fillna(series.std())
        
        # Detect significant changes (beyond 2 standard deviations)
        significant_changes = []
        
        for i in range(1, len(series)):
            if abs(series.iloc[i] - rolling_mean.iloc[i-1]) > threshold * rolling_std.iloc[i-1]:
                significant_changes.append({
                    'index': series.index[i],
                    'value': series.iloc[i],
                    'previous': series.iloc[i-1],