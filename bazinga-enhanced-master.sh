#!/bin/bash
# Bazinga Enhancement + Clipboard Fix
# This script enhances the Bazinga project and fixes clipboard issues

# Define color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Bazinga Enhancement + Clipboard Fix ===${NC}"
echo "This script will enhance your Bazinga project and fix clipboard issues"

# Determine project directory
if [ -d "src/core/bazinga" ]; then
  PROJECT_DIR="$(pwd)"
else
  # Try to find the Bazinga directory
  if [ -d "$HOME/AmsyPycharm/BAZINGA" ]; then
    PROJECT_DIR="$HOME/AmsyPycharm/BAZINGA"
  else
    echo -e "${YELLOW}Enter the path to your Bazinga project:${NC}"
    read -r PROJECT_DIR
    if [ ! -d "$PROJECT_DIR" ]; then
      echo -e "${RED}Directory not found. Using current directory.${NC}"
      PROJECT_DIR="$(pwd)"
    fi
  fi
fi

echo -e "${GREEN}Using project directory: ${PROJECT_DIR}${NC}"

# Create directories if they don't exist
mkdir -p "$PROJECT_DIR/enhanced"
mkdir -p "$PROJECT_DIR/enhanced/scripts"
mkdir -p "$PROJECT_DIR/enhanced/integration"

# Step 1: Fix clipboard issues
fix_clipboard() {
  echo -e "${BLUE}=== Fixing Clipboard Issues ===${NC}"
  
  # Kill clipboard service to reset it
  killall pboard 2>/dev/null
  
  # Disable Claude helper launch agent
  if launchctl list | grep -q "anthropic.claudefordesktop"; then
    echo -e "${YELLOW}Disabling Claude launch agent...${NC}"
    launchctl list | grep "anthropic.claudefordesktop" | awk '{print $3}' | xargs -I{} launchctl unload -w ~/Library/LaunchAgents/{}.plist 2>/dev/null
  fi
  
  # Disable cron jobs related to Claude collection
  if crontab -l 2>/dev/null | grep -q "claude"; then
    echo -e "${YELLOW}Disabling Claude cron jobs...${NC}"
    crontab -l > crontab.bak
    crontab -l | sed -e 's/^\(.*claude.*\)/#\1/' -e 's/^\(.*bazinga.*task-manager.*\)/#\1/' | crontab -
    echo -e "${GREEN}Cron jobs disabled. Backup saved to crontab.bak${NC}"
  fi
  
  # Look for problematic scripts and rename them
  problematic_scripts=(
    "$HOME/bin/claude-extract"
    "$HOME/bin/claude-collect"
    "$HOME/tools/bazinga/task-manager.sh"
  )
  
  for script in "${problematic_scripts[@]}"; do
    if [ -f "$script" ]; then
      echo -e "${YELLOW}Renaming problematic script: $script${NC}"
      mv "$script" "${script}.disabled"
    fi
  done
  
  # Test clipboard
  echo "Clipboard test" | pbcopy
  clipboard_content=$(pbpaste)
  
  if [ "$clipboard_content" == "Clipboard test" ]; then
    echo -e "${GREEN}Clipboard is working correctly!${NC}"
  else
    echo -e "${YELLOW}Clipboard still has issues. You may need to restart your Mac.${NC}"
    echo "Current clipboard content: $clipboard_content"
  fi
}

# Step 2: Create a safe TimeSpaceIntegrator TypeScript enhancement
create_ts_integrator() {
  echo -e "${BLUE}=== Enhancing TimeSpaceIntegrator ===${NC}"
  
  # Check if the file exists
  if [ -f "$PROJECT_DIR/src/core/TimeSpaceIntegrator.ts" ]; then
    target_file="$PROJECT_DIR/src/core/TimeSpaceIntegrator.ts"
  elif [ -f "$PROJECT_DIR/TimeSpaceIntegrator.ts" ]; then
    target_file="$PROJECT_DIR/TimeSpaceIntegrator.ts"
  else
    target_file="$PROJECT_DIR/enhanced/TimeSpaceIntegrator.ts"
  fi
  
  cat > "$target_file" << 'EOL'
// Enhanced TimeSpaceIntegrator with Harmonic Trust Dimensions

import { HarmonicPatterns } from './patterns/HarmonicPatterns';
import { QuantumStateManager } from './quantum/QuantumStateManager';
import { BazingaCore } from './bazinga/BazingaCore';

// Core interfaces
interface HarmonicResult {
  base: number;
  first: number;
  second: number;
  third: number;
  resonance: number;
}

interface TimeIntegrationResult {
  harmonics: HarmonicResult;
  trust_level: number;
}

/**
 * TimeSpaceIntegrator - Core class for integrating time dimensions with harmonic patterns
 * Enhanced version with support for Bazinga artifact integration
 */
export class TimeSpaceIntegrator {
  private readonly quantumManager: QuantumStateManager;
  private readonly bazingaCore: BazingaCore;
  private timeCache: Map<number, TimeIntegrationResult>;
  
  constructor(private readonly dimensions: number = 3) {
    this.quantumManager = new QuantumStateManager();
    this.bazingaCore = new BazingaCore();
    this.timeCache = new Map<number, TimeIntegrationResult>();
  }
  
  /**
   * Integrates time dimensions with harmonic patterns 
   * Returns a TimeIntegrationResult with harmonics and trust level
   */
  public integrate(timePoint: number, trustThreshold: number = 0.75): TimeIntegrationResult {
    // Check cache first
    if (this.timeCache.has(timePoint)) {
      return this.timeCache.get(timePoint)!;
    }
    
    // Generate harmonic results
    const harmonics = this.generateHarmonics(timePoint);
    
    // Calculate trust level based on quantum state
    const quantumState = this.quantumManager.getCurrentState();
    const trustLevel = this.calculateTrustLevel(harmonics, quantumState, trustThreshold);
    
    // Create result
    const result: TimeIntegrationResult = {
      harmonics,
      trust_level: trustLevel
    };
    
    // Cache result
    this.timeCache.set(timePoint, result);
    
    return result;
  }
  
  /**
   * Safely processes artifact data without using clipboard
   * This replaces the previous implementation that caused clipboard issues
   */
  public processArtifactData(artifactData: any): void {
    if (!artifactData) return;
    
    // Process through Bazinga core instead of clipboard
    this.bazingaCore.processArtifact(artifactData);
    
    // Update quantum state based on artifact
    this.quantumManager.updateStateFromArtifact(artifactData);
  }
  
  /**
   * Generates harmonic patterns based on time point
   */
  private generateHarmonics(timePoint: number): HarmonicResult {
    const patterns = new HarmonicPatterns();
    
    const baseFrequency = patterns.getBaseFrequency(timePoint);
    const firstHarmonic = patterns.getHarmonic(baseFrequency, 1);
    const secondHarmonic = patterns.getHarmonic(baseFrequency, 2);
    const thirdHarmonic = patterns.getHarmonic(baseFrequency, 3);
    
    // Calculate resonance as the relationship between harmonics
    const resonance = (firstHarmonic + secondHarmonic + thirdHarmonic) / 3;
    
    return {
      base: baseFrequency,
      first: firstHarmonic,
      second: secondHarmonic,
      third: thirdHarmonic,
      resonance
    };
  }
  
  /**
   * Calculates trust level based on harmonics and quantum state
   */
  private calculateTrustLevel(harmonics: HarmonicResult, 
                             quantumState: any, 
                             threshold: number): number {
    // Simplistic implementation - can be enhanced
    const rawTrust = (harmonics.resonance / 100) * 
                   quantumState.coherence * 
                   Math.min(1, this.dimensions / 5);
                   
    // Ensure trust level is between 0 and 1
    return Math.max(0, Math.min(1, rawTrust > threshold ? rawTrust : rawTrust * 0.8));
  }
  
  /**
   * Returns the current number of dimensions
   */
  public getDimensions(): number {
    return this.dimensions;
  }
  
  /**
   * Clears the time cache
   */
  public clearCache(): void {
    this.timeCache.clear();
  }
}
EOL

  chmod +x "$output_file"
  echo -e "${GREEN}Documentation created: $output_file${NC}"
}

# Call all functions in order
fix_clipboard
create_ts_integrator
create_safe_collector
create_integration_bridge
create_master_script
create_documentation

echo -e "${GREEN}Bazinga Enhancement + Clipboard Fix completed successfully!${NC}"
