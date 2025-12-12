#!/bin/bash
# BAZINGA Core Operations (Fixed Version)
# This script demonstrates the fundamental operations of the BAZINGA system

# Define colors for pretty output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}===== BAZINGA Core Operations =====${NC}"
echo "Demonstrating the fundamental pattern operations"
echo ""

# Define mathematical constants used by BAZINGA
PHI=1.618033988749895    # Golden ratio
SQRT_2=1.4142135623731   # Square root of 2
SQRT_5=2.2360679774998   # Square root of 5

# Function to generate a deterministic seed from input
generate_seed() {
    local input="$1"
    echo -e "${GREEN}Generating seed from: '$input'${NC}"
    
    # Create a deterministic hash from the input
    # Using cksum which is widely available
    local hash_val=$(echo -n "$input" | cksum | awk '{print $1}')
    local seed=$((hash_val % 1000))
    
    echo "Input hash: $hash_val"
    echo "Seed value: $seed"
    echo ""
    echo "$seed"
}

# Safe math calculation function that handles errors
safe_calc() {
    local expr="$1"
    local result
    
    # Try to calculate with bc
    result=$(echo "scale=6; $expr" | bc -l 2>/dev/null)
    
    # Check if result is empty (error occurred)
    if [ -z "$result" ]; then
        echo "1.0"  # Default value if calculation fails
    else
        echo "$result"
    fi
}

# Function to calculate pattern frequency
calculate_pattern_frequency() {
    local input="$1"
    local seed=$(generate_seed "$input")
    
    echo -e "${GREEN}Calculating pattern frequency${NC}"
    
    # Base calculation using seed
    local base_freq=$(safe_calc "1.0 + ($seed / 1000.0)")
    echo "Base frequency: $base_freq"
    
    # Apply golden ratio adjustment for aesthetic patterns
    local adjusted_freq=$(safe_calc "($base_freq + $PHI) / 2.0")
    echo "Golden ratio adjusted frequency: $adjusted_freq"
    
    # Final pattern frequency
    local final_freq=$(safe_calc "$adjusted_freq * $SQRT_2 / $SQRT_5")
    echo "Final pattern frequency: $final_freq"
    echo ""
    
    echo "$final_freq"
}

# Function to generate fractal dimensions
generate_fractal_dimensions() {
    local frequency="$1"
    local depth="$2"
    
    echo -e "${GREEN}Generating fractal dimensions (depth: $depth)${NC}"
    
    # Initial values for the Mandelbrot iteration
    local z_real="$frequency"
    local z_imag="0"
    local c_real="-0.8"
    local c_imag="0.156"
    
    echo "Starting with z = $z_real + ${z_imag}i, c = $c_real + ${c_imag}i"
    
    # Perform Mandelbrot iterations
    for ((i=1; i<=depth; i++)); do
        # z = z² + c
        local temp_real=$(safe_calc "$z_real * $z_real - $z_imag * $z_imag + $c_real")
        local temp_imag=$(safe_calc "2 * $z_real * $z_imag + $c_imag")
        z_real="$temp_real"
        z_imag="$temp_imag"
        
        echo "Iteration $i: z = $z_real + ${z_imag}i"
        
        # Calculate magnitude
        local magnitude=$(safe_calc "sqrt($z_real * $z_real + $z_imag * $z_imag)")
        
        # Check if we're escaping the set - using string comparison to be safe
        if (( $(echo "$magnitude > 2.0" | bc -l 2>/dev/null || echo "0") )); then
            echo "Escaped Mandelbrot set at iteration $i (magnitude: $magnitude)"
            break
        fi
    done
    
    echo "Final fractal dimensions: real=$z_real, imaginary=$z_imag"
    echo ""
}

# Function to calculate resonance values
calculate_resonance() {
    local pattern_freq="$1"
    local day="$2"
    
    echo -e "${GREEN}Calculating resonance values for day $day${NC}"
    
    # Convert day to phase in the cycle
    local cycle_days=42  # The default BAZINGA cycle length
    local cycle_phase=$(safe_calc "($day % $cycle_days) / $cycle_days * 2 * 3.14159")
    
    echo "Cycle phase: $cycle_phase radians"
    
    # Calculate sine and cosine values - Mac OS X bc doesn't have trig functions
    # So we'll fake it with some very rough approximations
    local sine_val="0.5"  # A default value 
    local cosine_val="0.5"  # A default value
    
    if command -v python3 &>/dev/null; then
        sine_val=$(python3 -c "import math; print(math.sin($cycle_phase))" 2>/dev/null || echo "0.5")
        cosine_val=$(python3 -c "import math; print(math.cos($cycle_phase))" 2>/dev/null || echo "0.5")
    fi
    
    echo "Sine: $sine_val, Cosine: $cosine_val"
    
    # Calculate the five BAZINGA principles
    local observation=$(safe_calc "(0.7 + 0.3 * $sine_val) * $pattern_freq")
    local operation=$(safe_calc "(0.6 + 0.4 * $cosine_val) * $pattern_freq")
    local verification=$(safe_calc "(0.5 + 0.5 * $sine_val * $cosine_val) * $pattern_freq")
    local integration=$(safe_calc "(0.4 + 0.6 * ($sine_val + $cosine_val)/2) * $pattern_freq")
    local execution=$(safe_calc "(0.3 + 0.7 * ($PHI * $sine_val)) * $pattern_freq")
    
    echo "Observation value: $observation"
    echo "Operation value: $operation"
    echo "Verification value: $verification"
    echo "Integration value: $integration"
    echo "Execution value: $execution"
    echo ""
    
    # Return the values for visualization
    echo "$observation $operation"
}

# Function to visualize pattern
visualize_pattern() {
    local pattern_freq="$1"
    local observation="$2"
    local operation="$3"
    
    echo -e "${GREEN}Pattern Visualization${NC}"
    echo "Pattern frequency: $pattern_freq"
    echo ""
    
    # Convert to integers for visualization
    local obs_bars=$(printf "%.0f" "$(safe_calc "$observation * 20")")
    local op_bars=$(printf "%.0f" "$(safe_calc "$operation * 20")")
    local pat_bars=$(printf "%.0f" "$(safe_calc "$pattern_freq * 10")")
    
    # Handle edge cases
    [ -z "$obs_bars" ] && obs_bars=10
    [ -z "$op_bars" ] && op_bars=10
    [ -z "$pat_bars" ] && pat_bars=10
    
    # Ensure we have at least 1 bar
    [ "$obs_bars" -lt 1 ] && obs_bars=1
    [ "$op_bars" -lt 1 ] && op_bars=1
    [ "$pat_bars" -lt 1 ] && pat_bars=1
    
    # Cap at reasonable maximum
    [ "$obs_bars" -gt 50 ] && obs_bars=50
    [ "$op_bars" -gt 50 ] && op_bars=50
    [ "$pat_bars" -gt 50 ] && pat_bars=50
    
    # Create ASCII visualization
    echo -n "Observation: "
    for ((i=0; i<obs_bars; i++)); do
        echo -n "#"
    done
    echo ""
    
    echo -n "Operation:   "
    for ((i=0; i<op_bars; i++)); do
        echo -n "#"
    done
    echo ""
    
    # Pattern fingerprint
    echo ""
    echo -n "Pattern fingerprint: "
    for ((i=0; i<pat_bars; i++)); do
        echo -n "*"
    done
    echo ""
}

# Main demonstration
echo -e "${YELLOW}Demonstrating BAZINGA core operations:${NC}"
echo "1. Seed generation"
echo "2. Pattern frequency calculation"
echo "3. Fractal dimension generation"
echo "4. Resonance calculation"
echo "5. Pattern visualization"
echo ""

# Get input text
INPUT_TEXT="Time-trust framework for distributed systems"
echo -e "${BLUE}Using input text: '$INPUT_TEXT'${NC}"
echo ""

# Calculate pattern frequency
PATTERN_FREQ=$(calculate_pattern_frequency "$INPUT_TEXT")

# Generate fractal dimensions
generate_fractal_dimensions "$PATTERN_FREQ" 10

# Calculate day
DAY=$(safe_calc "($PATTERN_FREQ * 100) % 42")
DAY=${DAY%.*}  # Remove decimal part
[ -z "$DAY" ] && DAY=21  # Default if calculation fails

# Calculate resonance values and capture returned observation and operation
RESONANCE_OUTPUT=$(calculate_resonance "$PATTERN_FREQ" "$DAY")
OBSERVATION=$(echo "$RESONANCE_OUTPUT" | awk '{print $1}')
OPERATION=$(echo "$RESONANCE_OUTPUT" | awk '{print $2}')

# Visualize pattern
visualize_pattern "$PATTERN_FREQ" "$OBSERVATION" "$OPERATION"

echo -e "${BLUE}===== Core Operations Complete =====${NC}"
echo "This demonstrates the fundamental mathematical operations"
echo "that power the BAZINGA pattern recognition system."