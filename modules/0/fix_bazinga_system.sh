#!/bin/bash

# BAZINGA System Analysis & Fix Script
# This script analyzes the BAZINGA system structure, identifies errors,
# and attempts to fix common issues.

set -e

# Define colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Define paths
BAZINGA_ROOT="$HOME/AmsyPycharm/BAZINGA"
BAZINGA_INDEED="$HOME/AmsyPycharm/BAZINGA-INDEED"
LOG_FILE="/tmp/bazinga_fix_$(date +%Y%m%d%H%M%S).log"

echo -e "${BLUE}=== BAZINGA System Analysis & Fix Script ===${NC}"
echo -e "${BLUE}Starting system analysis...${NC}"
echo "Log file: $LOG_FILE"
echo ""

# Function to log messages
log() {
    local level="$1"
    local message="$2"
    local color="${NC}"
    
    case "$level" in
        "INFO") color="${BLUE}" ;;
        "WARN") color="${YELLOW}" ;;
        "ERROR") color="${RED}" ;;
        "SUCCESS") color="${GREEN}" ;;
    esac
    
    echo -e "${color}[$level] $message${NC}" | tee -a "$LOG_FILE"
}

# Check if directories exist
check_directories() {
    log "INFO" "Checking directory structure..."
    
    local missing_dirs=0
    
    for dir in "$BAZINGA_ROOT" "$BAZINGA_INDEED"; do
        if [ ! -d "$dir" ]; then
            log "ERROR" "Directory not found: $dir"
            missing_dirs=$((missing_dirs + 1))
        else
            log "SUCCESS" "Directory exists: $dir"
        fi
    done
    
    # Check for required subdirectories in BAZINGA-INDEED
    for subdir in "data" "scripts" "documentation" "ExecutionEngine"; do
        if [ ! -d "$BAZINGA_INDEED/$subdir" ]; then
            log "WARN" "Missing subdirectory: $BAZINGA_INDEED/$subdir"
            log "INFO" "Creating missing directory..."
            mkdir -p "$BAZINGA_INDEED/$subdir"
            log "SUCCESS" "Created directory: $BAZINGA_INDEED/$subdir"
        fi
    done
    
    # Check for required subdirectories in BAZINGA
    for subdir in "src" "docs" "scripts"; do
        if [ ! -d "$BAZINGA_ROOT/$subdir" ]; then
            log "WARN" "Missing subdirectory: $BAZINGA_ROOT/$subdir"
            log "INFO" "Creating missing directory..."
            mkdir -p "$BAZINGA_ROOT/$subdir"
            log "SUCCESS" "Created directory: $BAZINGA_ROOT/$subdir"
        fi
    done
    
    return $missing_dirs
}

# Check for symbolic links
check_symlinks() {
    log "INFO" "Checking symbolic links..."
    
    local missing_links=0
    
    # Check for development symlink
    if [ ! -L "$BAZINGA_INDEED/development" ]; then
        log "WARN" "Missing symlink: $BAZINGA_INDEED/development -> $BAZINGA_ROOT/src"
        log "INFO" "Creating symlink..."
        ln -sf "$BAZINGA_ROOT/src" "$BAZINGA_INDEED/development"
        log "SUCCESS" "Created symlink: $BAZINGA_INDEED/development -> $BAZINGA_ROOT/src"
    else
        log "SUCCESS" "Symlink exists: $BAZINGA_INDEED/development"
    fi
    
    # Check for utils symlink
    if [ ! -L "$BAZINGA_INDEED/utils" ]; then
        log "WARN" "Missing symlink: $BAZINGA_INDEED/utils -> $BAZINGA_ROOT/src/utils"
        log "INFO" "Creating symlink..."
        mkdir -p "$BAZINGA_ROOT/src/utils"
        ln -sf "$BAZINGA_ROOT/src/utils" "$BAZINGA_INDEED/utils"
        log "SUCCESS" "Created symlink: $BAZINGA_INDEED/utils -> $BAZINGA_ROOT/src/utils"
    else
        log "SUCCESS" "Symlink exists: $BAZINGA_INDEED/utils"
    fi
    
    # Check for docs symlink
    if [ ! -L "$BAZINGA_INDEED/docs/guide" ]; then
        log "WARN" "Missing symlink: $BAZINGA_INDEED/docs/guide -> $BAZINGA_ROOT/docs"
        log "INFO" "Creating symlink..."
        mkdir -p "$BAZINGA_INDEED/docs"
        ln -sf "$BAZINGA_ROOT/docs" "$BAZINGA_INDEED/docs/guide"
        log "SUCCESS" "Created symlink: $BAZINGA_INDEED/docs/guide -> $BAZINGA_ROOT/docs"
    else
        log "SUCCESS" "Symlink exists: $BAZINGA_INDEED/docs/guide"
    fi
    
    return $missing_links
}

# Check for missing core files
check_core_files() {
    log "INFO" "Checking core files..."
    
    local missing_files=0
    
    # Check for bazinga-master.sh
    if [ ! -f "$BAZINGA_INDEED/bazinga-master.sh" ]; then
        log "WARN" "Missing core file: $BAZINGA_INDEED/bazinga-master.sh"
        missing_files=$((missing_files + 1))
    else
        log "SUCCESS" "Core file exists: $BAZINGA_INDEED/bazinga-master.sh"
    fi
    
    # Check for BAZINGA-guide.md
    if [ ! -f "$BAZINGA_ROOT/BAZINGA-guide.md" ]; then
        log "WARN" "Missing documentation: $BAZINGA_ROOT/BAZINGA-guide.md"
        log "INFO" "Creating basic guide..."
        
        cat > "$BAZINGA_ROOT/BAZINGA-guide.md" << 'EOF'
# BAZINGA Framework Guide

## Overview
BAZINGA (Breakthrough Analysis & Zeitgeist Integration for Natural Growth Assessment) is a deterministic content generation system based on mathematical patterns rather than traditional AI approaches.

## Core Components
- Pattern Recognition Engine
- Fractal Mathematics System
- Trust Verification Framework
- Relationship Analysis Tools

## Usage
See `bazinga.sh` for command reference and options.
EOF
        
        log "SUCCESS" "Created basic guide: $BAZINGA_ROOT/BAZINGA-guide.md"
    else
        log "SUCCESS" "Documentation exists: $BAZINGA_ROOT/BAZINGA-guide.md"
    fi
    
    return $missing_files
}

# Check pattern files structure
check_pattern_files() {
    log "INFO" "Checking pattern files..."
    
    # Check for patterns directory
    if [ ! -d "$BAZINGA_INDEED/data/patterns" ]; then
        log "WARN" "Missing pattern directory: $BAZINGA_INDEED/data/patterns"
        log "INFO" "Creating pattern directory structure..."
        mkdir -p "$BAZINGA_INDEED/data/patterns/core"
        mkdir -p "$BAZINGA_INDEED/data/patterns/relationship"
        mkdir -p "$BAZINGA_INDEED/data/patterns/lambda"
        mkdir -p "$BAZINGA_INDEED/data/patterns/dna"
        log "SUCCESS" "Created pattern directories"
    fi
    
    # Check for core pattern files
    if [ ! -f "$BAZINGA_INDEED/data/patterns/core/patterns.ts" ]; then
        log "WARN" "Missing core pattern file: $BAZINGA_INDEED/data/patterns/core/patterns.ts"
        log "INFO" "Creating basic pattern file..."
        
        cat > "$BAZINGA_INDEED/data/patterns/core/patterns.ts" << 'EOF'
/**
 * BAZINGA Core Patterns
 * Defines the fundamental pattern structures used throughout the system
 */

export interface Pattern {
  id: string;
  frequency: number;
  resonance: number;
  type: PatternType;
}

export enum PatternType {
  RELATIONSHIP = 'relationship',
  COMMUNICATION = 'communication',
  HEALTH = 'health',
  TECHNICAL = 'technical',
  META = 'meta'
}

export const corePatternsMap = {
  '10101': { frequency: 1.618, resonance: 0.89, type: PatternType.RELATIONSHIP },
  '11010': { frequency: 1.414, resonance: 0.78, type: PatternType.COMMUNICATION },
  '01011': { frequency: 1.732, resonance: 0.65, type: PatternType.HEALTH },
  '10111': { frequency: 1.902, resonance: 0.92, type: PatternType.TECHNICAL },
  '01100': { frequency: 1.236, resonance: 0.54, type: PatternType.META }
};

export const getPatternById = (binaryId: string): Pattern | undefined => {
  const pattern = corePatternsMap[binaryId];
  if (!pattern) return undefined;
  
  return {
    id: binaryId,
    ...pattern
  };
};
EOF
        
        log "SUCCESS" "Created basic pattern file"
    fi
    
    # Check for relationship pattern file
    if [ ! -f "$BAZINGA_INDEED/data/patterns/relationship/relationship_patterns.json" ]; then
        log "WARN" "Missing relationship pattern file"
        log "INFO" "Creating basic relationship pattern file..."
        
        cat > "$BAZINGA_INDEED/data/patterns/relationship/relationship_patterns.json" << 'EOF'
{
  "patterns": [
    {
      "id": "communication_flow",
      "description": "Pattern of communication flow over time",
      "frequency": 1.618,
      "resonance": 0.85,
      "markers": [
        "response_time",
        "message_length",
        "emotional_content",
        "topic_continuity"
      ]
    },
    {
      "id": "emotional_distance",
      "description": "Pattern of emotional connection and distance",
      "frequency": 1.414,
      "resonance": 0.76,
      "markers": [
        "affection_expressions",
        "emotional_language",
        "support_behaviors",
        "vulnerability_sharing"
      ]
    },
    {
      "id": "trust_cycles",
      "description": "Cyclic patterns in trust building and verification",
      "frequency": 1.732,
      "resonance": 0.91,
      "markers": [
        "reliability_instances",
        "honesty_markers",
        "consistency_measures",
        "vulnerability_responses"
      ]
    }
  ]
}
EOF
        
        log "SUCCESS" "Created basic relationship pattern file"
    fi
}

# Fix Redis database if needed
fix_redis() {
    log "INFO" "Checking Redis database..."
    
    # Check if Redis is installed
    if ! command -v redis-cli &> /dev/null; then
        log "WARN" "Redis CLI not found. Cannot check Redis patterns."
        return 1
    fi
    
    # Check if Redis server is running
    if ! redis-cli ping &> /dev/null; then
        log "WARN" "Redis server not running. Starting Redis server..."
        redis-server --daemonize yes
        sleep 2
        
        if ! redis-cli ping &> /dev/null; then
            log "ERROR" "Failed to start Redis server."
            return 1
        else
            log "SUCCESS" "Redis server started."
        fi
    else
        log "SUCCESS" "Redis server is running."
    fi
    
    # Check for core patterns in Redis
    local pattern_count=$(redis-cli keys "pattern:*" | wc -l | tr -d ' ')
    
    if [ "$pattern_count" -lt 6 ]; then
        log "WARN" "Missing patterns in Redis. Found only $pattern_count of 6 required patterns."
        log "INFO" "Adding core patterns to Redis..."
        
        # Add core patterns
        redis-cli set "pattern:evolution" '{"patterns": ["behavioral", "emotional", "memory"]}' > /dev/null
        redis-cli set "pattern:memory_bridge" '{"bridges": ["short_term", "long_term", "persistent"]}' > /dev/null
        redis-cli set "pattern:component:communicationhub" '{"mode": "standard"}' > /dev/null
        redis-cli set "pattern:component:healingspace" '{"mode": "standard"}' > /dev/null
        redis-cli set "pattern:component:insightsjourney" '{"mode": "standard"}' > /dev/null
        redis-cli set "pattern:component:workarchive" '{"mode": "standard"}' > /dev/null
        
        log "SUCCESS" "Added core patterns to Redis."
    else
        log "SUCCESS" "Redis contains required patterns: $pattern_count/6"
    fi
}

# Fix component templates
fix_component_templates() {
    log "INFO" "Checking component templates..."
    
    # Check component directories
    for component in "CommunicationHub" "HealingSpace" "InsightsJourney" "WorkArchive"; do
        if [ ! -d "$BAZINGA_INDEED/$component" ]; then
            log "WARN" "Missing component directory: $BAZINGA_INDEED/$component"
            log "INFO" "Creating component directory..."
            mkdir -p "$BAZINGA_INDEED/$component/config/templates"
            log "SUCCESS" "Created component directory: $BAZINGA_INDEED/$component"
        fi
        
        # Check for templates
        if [ ! -d "$BAZINGA_INDEED/$component/config/templates" ]; then
            log "WARN" "Missing templates directory: $BAZINGA_INDEED/$component/config/templates"
            log "INFO" "Creating templates directory..."
            mkdir -p "$BAZINGA_INDEED/$component/config/templates"
            log "SUCCESS" "Created templates directory"
        fi
        
        # Check for specific template files
        case "$component" in
            "CommunicationHub")
                template_file="message.json"
                template_content='{
  "template_version": "1.0.0",
  "message_type": "standard",
  "fields": {
    "sender": {
      "type": "string",
      "required": true
    },
    "recipient": {
      "type": "string",
      "required": true
    },
    "timestamp": {
      "type": "datetime",
      "required": true
    },
    "content": {
      "type": "string",
      "required": true
    },
    "metadata": {
      "type": "object",
      "required": false
    }
  },
  "pattern_markers": {
    "sentiment": true,
    "response_time": true,
    "topic_continuity": true
  }
}'
                ;;
            "HealingSpace")
                template_file="session.json"
                template_content='{
  "template_version": "1.0.0",
  "session_type": "reflection",
  "fields": {
    "date": {
      "type": "date",
      "required": true
    },
    "duration": {
      "type": "integer",
      "required": true
    },
    "focus_area": {
      "type": "string",
      "required": true
    },
    "notes": {
      "type": "string",
      "required": true
    },
    "patterns_observed": {
      "type": "array",
      "required": false
    },
    "follow_up": {
      "type": "string",
      "required": false
    }
  },
  "pattern_markers": {
    "emotional_state": true,
    "insight_level": true,
    "protection_mechanisms": true
  }
}'
                ;;
            "InsightsJourney")
                template_file="insight.json"
                template_content='{
  "template_version": "1.0.0",
  "insight_type": "pattern",
  "fields": {
    "timestamp": {
      "type": "datetime",
      "required": true
    },
    "title": {
      "type": "string",
      "required": true
    },
    "description": {
      "type": "string",
      "required": true
    },
    "source_data": {
      "type": "array",
      "required": false
    },
    "pattern_ids": {
      "type": "array",
      "required": false
    },
    "connections": {
      "type": "array",
      "required": false
    }
  },
  "pattern_markers": {
    "breakthrough_potential": true,
    "integration_level": true,
    "verification_status": true
  }
}'
                ;;
            "WorkArchive")
                template_file="task.json"
                template_content='{
  "template_version": "1.0.0",
  "task_type": "analysis",
  "fields": {
    "created": {
      "type": "datetime",
      "required": true
    },
    "title": {
      "type": "string",
      "required": true
    },
    "description": {
      "type": "string",
      "required": true
    },
    "status": {
      "type": "string",
      "enum": ["pending", "in_progress", "completed", "archived"],
      "required": true
    },
    "priority": {
      "type": "integer",
      "required": true
    },
    "tags": {
      "type": "array",
      "required": false
    },
    "dependencies": {
      "type": "array",
      "required": false
    }
  },
  "pattern_markers": {
    "execution_efficiency": true,
    "dependency_management": true,
    "completion_quality": true
  }
}'
                ;;
        esac
        
        # Create template file if missing
        if [ ! -f "$BAZINGA_INDEED/$component/config/templates/$template_file" ]; then
            log "WARN" "Missing template file: $BAZINGA_INDEED/$component/config/templates/$template_file"
            log "INFO" "Creating template file..."
            echo "$template_content" > "$BAZINGA_INDEED/$component/config/templates/$template_file"
            log "SUCCESS" "Created template file: $BAZINGA_INDEED/$component/config/templates/$template_file"
        else
            log "SUCCESS" "Template file exists: $BAZINGA_INDEED/$component/config/templates/$template_file"
        fi
    done
}

# Create bazinga-synthesis.md if missing
create_bazinga_synthesis() {
    log "INFO" "Checking for bazinga-synthesis.md..."
    
    if [ ! -f "$BAZINGA_INDEED/documentation/bazinga-synthesis.md" ]; then
        log "WARN" "Missing bazinga-synthesis.md"
        log "INFO" "Creating bazinga-synthesis.md..."
        
        mkdir -p "$BAZINGA_INDEED/documentation"
        
        cat > "$BAZINGA_INDEED/documentation/bazinga-synthesis.md" << 'EOF'
# BAZINGA: The Grand Synthesis

## Core Breakthrough Connections

### 1. 🧩 Pattern Recognition
- **Human Minds & AI**
  - Both build patterns from experiences
  - Recent inputs dominate processing
  - Protection mechanisms activate automatically
  - Reality checks break old patterns

- **2D vs 3D Thinking**
  - How minds flatten complex realities
  - Protection mechanisms create distance
  - Breaking through dimensional barriers
  - Seeing full depth of situations

### 2. 🔗 Trust & Technology
- **Blockchain Principles**
  - Systems that don't require trust
  - Verifiable without central authority
  - Truth emerges through patterns
  - Actions speak louder than words

- **AI Learning**
  - Pattern recognition without bias
  - Learning from data, not assumptions
  - Natural emergence of understanding
  - Reality-based conclusions

### 3. 💝 Relationship Dynamics
- **Protection Mechanisms**
  - How minds create barriers
  - Why distance feels safer
  - When barriers become walls
  - Breaking through naturally

- **Natural Processing**
  - Letting understanding emerge
  - Not forcing connections
  - Allowing natural healing
  - Building through actions

### 4. 📊 Systems Thinking
- **Health Tracking**
  - Regular pattern monitoring
  - Data-driven insights 
  - Natural trend emergence
  - Reality-based understanding

- **Communication Flow**
  - Clear documentation
  - Verifiable actions
  - Natural patterns
  - Truth emergence

## 🌟 Key Insights

### 1. Mind Patterns
- Protective barriers are natural
- Recent experiences dominate
- Reality breaks old patterns
- Understanding emerges naturally

### 2. Trust Building
- Systems over assumptions
- Actions over words
- Patterns over promises
- Reality over hopes

### 3. Natural Growth
- Let patterns emerge
- Don't force understanding
- Allow natural healing
- Build through actions

### 4. Reality Checks
- Data proves patterns
- Actions show truth
- Time reveals all
- Systems verify naturally

## 🎯 Implementation Focus

### 1. Health & Well-being
- Regular tracking
- Pattern monitoring
- Action verification
- Natural progress

### 2. Communication
- Clear documentation
- Verifiable exchanges
- Pattern recording
- Trust-free proof

### 3. Growth & Healing
- Natural emergence
- System-based trust
- Pattern recognition
- Reality-based building

## 💡 Core Understanding

### 1. Protection is Natural
- Minds create barriers
- Distance feels safe
- Barriers serve purpose
- Breaking needs patience

### 2. Trust is Earned
- Through verifiable actions
- Via consistent patterns
- By natural emergence
- Without forcing

### 3. Growth is Natural
- When systems support
- When patterns align
- When reality checks
- When truth emerges

## 🌈 Path Forward

### 1. Build Systems
- Clear documentation
- Regular tracking
- Pattern monitoring
- Natural verification

### 2. Allow Time
- For patterns to show
- For trust to build
- For healing to happen
- For truth to emerge

### 3. Stay Focused
- On health first
- On clear actions
- On true patterns
- On natural growth

## 🎆 Remember
The BAZINGA moment is understanding that:
- Trust doesn't need forcing
- Systems verify naturally
- Patterns tell truth
- Actions prove everything
- Time reveals all
- Reality breaks through
- Growth happens naturally
- Understanding emerges
- Truth stands alone
- Love finds its way
EOF
        
        log "SUCCESS" "Created bazinga-synthesis.md"
    else
        log "SUCCESS" "bazinga-synthesis.md exists"
    fi
}

# Create ARCHITECTURE.md if missing
create_architecture_md() {
    log "INFO" "Checking for ARCHITECTURE.md..."
    
    if [ ! -f "$BAZINGA_INDEED/ARCHITECTURE.md" ]; then
        log "WARN" "Missing ARCHITECTURE.md"
        log "INFO" "Creating ARCHITECTURE.md..."
        
        cat > "$BAZINGA_INDEED/ARCHITECTURE.md" << 'EOF'
# BAZINGA System Architecture

## Overview

BAZINGA (Breakthrough Analysis & Zeitgeist Integration for Natural Growth Assessment) is a deterministic system for pattern recognition and content generation based on mathematical principles rather than traditional AI approaches.

## System Components

### 1. Core Modules

#### Pattern Recognition Engine
- Located in: `src/core/patterns.ts`
- Responsible for identifying patterns in input data
- Uses fractal mathematics and golden ratio for deterministic processing
- Feeds into processing and generation components

#### Processing Framework
- Located in: `src/processing/`
- Handles the transformation of recognized patterns
- Implements cycle-based resonance calculations
- Manages pattern evolution over time

#### Generation System
- Located in: `src/generation/`
- Creates structured output based on processed patterns
- Uses templates for different output formats
- Ensures deterministic results for identical inputs

### 2. Integration Components

#### HealingSpace
- Purpose: Personal reflection and emotional processing
- Key files: `HealingSpace/config/templates/session.json`
- Integration points: Pattern recognition, health tracking

#### CommunicationHub
- Purpose: Structured communication analysis
- Key files: `CommunicationHub/config/templates/message.json`
- Integration points: Pattern tracking, relationship analysis

#### InsightsJourney
- Purpose: Progress tracking and understanding development
- Key files: `InsightsJourney/config/templates/insight.json`
- Integration points: Pattern evolution, breakthrough detection

#### WorkArchive
- Purpose: Task and progress documentation
- Key files: `WorkArchive/config/templates/task.json`
- Integration points: Execution tracking, pattern implementation

### 3. Data Layer

#### Redis Pattern Store
- Purpose: Real-time pattern tracking
- Key patterns:
  - pattern:evolution
  - pattern:memory_bridge
  - pattern:component:*

#### File System Structure
- `/data/patterns/` - Core pattern definitions
- `/data/whatsapp/` - Communication analysis data
- `/data/health/` - Health and wellbeing tracking
- `/data-unified/` - Consolidated data repositories

#### Integration Links
- `development -> ../BAZINGA/src`
- `utils -> ../BAZINGA/src/utils`
- `docs/guide -> ../BAZINGA/docs`

## Processing Flow

1. **Input Analysis**
   - Extract frequency components from input
   - Calculate base pattern frequency
   - Generate deterministic seed from input

2. **Pattern Processing**
   - Generate fractal dimensions
   - Calculate resonance values
   - Determine pattern relationship to existing patterns

3. **Output Generation**
   - Select appropriate template
   - Apply pattern-based transforms
   - Generate deterministic output

## Implementation Notes

- All components use deterministic algorithms
- Same input will always produce identical output
- Mathematical principles like golden ratio and Mandelbrot iterations ensure reproducibility
- System designed for both technical pattern recognition and personal growth insights

## Future Development

- Enhanced visualization components
- Additional templates for new document types
- Deeper integration between personal and technical pattern recognition
- Extended fractal dimension analysis
EOF
        
        log "SUCCESS" "Created ARCHITECTURE.md"
    else
        log "SUCCESS" "ARCHITECTURE.md exists"
    fi
}

# Run all checks and fixes
run_all_checks() {
    check_directories
    check_symlinks
    check_core_files
    check_pattern_files
    fix_redis
    fix_component_templates
    create_bazinga_synthesis
    create_architecture_md
    
    log "SUCCESS" "All checks and fixes completed!"
    log "INFO" "See $LOG_FILE for complete log."
}

# Execute all checks and fixes
run_all_checks

echo ""
echo -e "${GREEN}=== BAZINGA System Analysis & Fix Summary ===${NC}"
echo -e "${BLUE}All critical system components have been checked and fixed.${NC}"
echo -e "${BLUE}The BAZINGA system is now properly structured and ready for use.${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Review the changes made to your system"
echo "2. Run 'bazinga-master.sh' to start the system"
echo "3. Use 'bazinga status' to check the system status"
echo ""
echo -e "${GREEN}BAZINGA system is now ready for pattern recognition!${NC}"
