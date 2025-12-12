#!/bin/bash
# Unified Resource Orchestrator for BAZINGA
# This script orchestrates tasks between local Mac resources, BAZINGA system, and AI assistants

# Configuration
LOG_FILE="orchestration_log_$(date +%Y%m%d_%H%M%S).txt"
CONFIG_FILE="resource_allocation_config.json"
AI_CACHE_DIR="./artifacts/claude_artifacts/cache"

# Create necessary directories
mkdir -p "$AI_CACHE_DIR"

# Log function
log() {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] $1" | tee -a "$LOG_FILE"
}

log "Starting Resource Orchestrator"
log "Analyzing available resources..."

# Detect system resources
CPU_CORES=$(sysctl -n hw.ncpu)
MEMORY_GB=$(( $(sysctl -n hw.memsize) / 1073741824 ))
log "Local resources: $CPU_CORES CPU cores, $MEMORY_GB GB RAM"

# Function to determine optimal resource allocation
allocate_resources() {
    local task_type="$1"
    local task_size="$2"  # small, medium, large
    local task_priority="$3"  # low, medium, high
    
    case "$task_type" in
        "data_processing")
            if [[ "$task_size" == "small" || "$task_size" == "medium" ]]; then
                echo "local"
            else
                echo "bazinga"
            fi
            ;;
        "ai_generation")
            echo "claude"
            ;;
        "visualization")
            echo "local"
            ;;
        "analysis")
            if [[ "$task_size" == "small" ]]; then
                echo "local"
            else
                echo "bazinga"
            fi
            ;;
        *)
            echo "local"  # Default to local processing
            ;;
    esac
}

# Function to execute task on local system
execute_local() {
    local task_script="$1"
    local input_data="$2"
    local output_file="$3"
    
    log "Executing locally: $task_script"
    bash "$task_script" "$input_data" > "$output_file"
    return $?
}

# Function to execute task on BAZINGA system
execute_bazinga() {
    local task_script="$1"
    local input_data="$2"
    local output_file="$3"
    
    log "Delegating to BAZINGA: $task_script"
    # Use existing BAZINGA integration scripts
    ./bazinga_integration.sh exec "$task_script" "$input_data" "$output_file"
    return $?
}

# Function to delegate to Claude via collector
execute_claude() {
    local prompt="$1"
    local output_file="$2"
    local cache_key=$(echo "$prompt" | md5)
    local cache_file="$AI_CACHE_DIR/$cache_key.json"
    
    # Check cache first
    if [[ -f "$cache_file" ]]; then
        log "Using cached AI response"
        cat "$cache_file" > "$output_file"
        return 0
    fi
    
    log "Delegating to Claude AI"
    python3 ./safe_claude_collector.py --prompt "$prompt" --output "$output_file" --cache "$cache_file"
    return $?
}

# Main orchestration function
orchestrate_task() {
    local task_name="$1"
    local task_type="$2"
    local task_size="$3"
    local task_script="$4"
    local input_data="$5"
    local output_file="$6"
    
    log "Orchestrating task: $task_name ($task_type, $task_size)"
    
    # Determine where to run the task
    local executor=$(allocate_resources "$task_type" "$task_size" "medium")
    log "Selected executor: $executor"
    
    # Execute based on allocation decision
    case "$executor" in
        "local")
            execute_local "$task_script" "$input_data" "$output_file"
            ;;
        "bazinga")
            execute_bazinga "$task_script" "$input_data" "$output_file"
            ;;
        "claude")
            execute_claude "$input_data" "$output_file"  # For AI, input_data is the prompt
            ;;
        *)
            log "Unknown executor: $executor. Defaulting to local."
            execute_local "$task_script" "$input_data" "$output_file"
            ;;
    esac
    
    local status=$?
    if [[ $status -eq 0 ]]; then
        log "Task completed successfully: $task_name"
    else
        log "Task failed with status $status: $task_name"
    fi
    
    return $status
}

# Function to analyze task and automatically determine characteristics
analyze_task() {
    local task_script="$1"
    
    # Simple analysis based on file size and content
    local file_size=$(wc -c < "$task_script")
    local contains_data_processing=$(grep -c "data\|parse\|transform" "$task_script")
    local contains_ai=$(grep -c "claude\|gpt\|ai\|llm" "$task_script")
    local contains_viz=$(grep -c "visual\|plot\|chart\|graph" "$task_script")
    
    # Determine task size
    if [[ $file_size -lt 5000 ]]; then
        local task_size="small"
    elif [[ $file_size -lt 20000 ]]; then
        local task_size="medium"
    else
        local task_size="large"
    fi
    
    # Determine task type
    if [[ $contains_ai -gt 5 ]]; then
        local task_type="ai_generation"
    elif [[ $contains_viz -gt 5 ]]; then
        local task_type="visualization"
    elif [[ $contains_data_processing -gt 5 ]]; then
        local task_type="data_processing"
    else
        local task_type="analysis"
    fi
    
    echo "$task_type $task_size"
}

# Function to monitor system resource usage
monitor_resources() {
    # CPU usage
    local cpu_usage=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | cut -d% -f1)
    
    # Memory usage
    local mem_usage=$(top -l 1 | grep "PhysMem" | awk '{print $2}' | cut -d'M' -f1)
    
    log "Current resource usage: CPU ${cpu_usage}%, Memory ${mem_usage}M"
    
    # Adjust allocation strategy if resources are strained
    if [[ $(echo "$cpu_usage > 80" | bc) -eq 1 ]]; then
        log "High CPU usage detected - offloading more tasks to BAZINGA"
        # Could modify the allocation strategy here
    fi
}

# Parse command line arguments
if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <task_script> <input_data> [output_file]"
    exit 1
fi

TASK_SCRIPT="$1"
INPUT_DATA="$2"
OUTPUT_FILE="${3:-output_$(date +%Y%m%d_%H%M%S).txt}"

# Auto-analyze the task if it exists
if [[ -f "$TASK_SCRIPT" ]]; then
    TASK_INFO=$(analyze_task "$TASK_SCRIPT")
    TASK_TYPE=$(echo "$TASK_INFO" | cut -d' ' -f1)
    TASK_SIZE=$(echo "$TASK_INFO" | cut -d' ' -f2)
else
    TASK_TYPE="unknown"
    TASK_SIZE="medium"
fi

# Monitor system resources before allocation
monitor_resources

# Execute the orchestration
orchestrate_task "$(basename $TASK_SCRIPT)" "$TASK_TYPE" "$TASK_SIZE" "$TASK_SCRIPT" "$INPUT_DATA" "$OUTPUT_FILE"

log "Orchestration complete"
exit $?
