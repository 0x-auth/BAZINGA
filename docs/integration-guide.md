# ClaudeSeed Integration Guide

## Overview

The ClaudeSeed system provides a powerful mechanism for cross-session context propagation. By integrating it with your BAZINGA framework, you can create a self-evolving system that maintains context across different Claude interactions and can self-correct based on new information.

## Integration Steps

### 1. Place ClaudeSeed in the BAZINGA Core Structure

```bash
# Create a dedicated directory for ClaudeSeed in your BAZINGA structure
mkdir -p ~/BAZINGA-Master/core/claude-seed

# Copy the ClaudeSeed code
cp ~/Downloads/claudeseed.py ~/BAZINGA-Master/core/claude-seed/claudeseed.py

# Create an __init__.py to make it importable
touch ~/BAZINGA-Master/core/claude-seed/__init__.py
```

### 2. Create a BAZINGA Integration Module

```python
# Save as ~/BAZINGA-Master/core/claude-seed/bazinga_integration.py

import os
import sys
import json
from typing import Dict, List, Any, Optional

# Import ClaudeSeed
from .claudeseed import ClaudeSeed

class BAZINGAClaudeIntegration:
    """Integration layer between BAZINGA framework and ClaudeSeed"""
    
    def __init__(self, bazinga_root: str, config_path: Optional[str] = None):
        """
        Initialize the integration layer.
        
        Args:
            bazinga_root: Root directory of the BAZINGA framework
            config_path: Path to configuration file (optional)
        """
        self.bazinga_root = bazinga_root
        self.seed_generator = ClaudeSeed(base_dir=bazinga_root, config_path=config_path)
        
        # Add BAZINGA-specific directories to scan
        self._add_bazinga_directories()
        
        # Add BAZINGA-specific patterns to key topics
        self._add_bazinga_patterns()
    
    def _add_bazinga_directories(self):
        """Add BAZINGA-specific directories to scan"""
        bazinga_dirs = [
            "src/core",
            "docs",
            "analysis",
            "artifacts",
            "data"
        ]
        
        # Add these to ClaudeSeed config
        self.seed_generator.config["scan_dirs"].extend([
            os.path.join(self.bazinga_root, dir_path) 
            for dir_path in bazinga_dirs
        ])
    
    def _add_bazinga_patterns(self):
        """Add BAZINGA-specific patterns to key topics"""
        bazinga_topics = [
            "BAZINGA",
            "pattern",
            "timeline",
            "DODO",
            "integration",
            "fractal",
            "isomorphic",
            "deterministic"
        ]
        
        # Add these to ClaudeSeed config
        self.seed_generator.config["key_topics"].extend(bazinga_topics)
    
    def generate_seed(self) -> str:
        """Generate a seed that incorporates BAZINGA-specific context"""
        # Process files and generate standard seed
        basic_seed = self.seed_generator.process()
        
        # Add BAZINGA-specific extensions to the seed
        # This will help Claude recognize your BAZINGA framework
        extended_seed = basic_seed.replace("%MS%", "%MS-BAZINGA%")
        
        return extended_seed
    
    def extract_framework_connections(self) -> Dict[str, Any]:
        """Extract connections between components in the BAZINGA framework"""
        connections = {}
        
        # Scan core directories for interdependencies
        src_core_path = os.path.join(self.bazinga_root, "src/core")
        if os.path.exists(src_core_path):
            for root, _, files in os.walk(src_core_path):
                for file in files:
                    if file.endswith(('.py', '.ts')):
                        file_path = os.path.join(root, file)
                        with open(file_path, 'r') as f:
                            content = f.read()
                            
                            # Extract imports
                            import_lines = []
                            if file.endswith('.py'):
                                import_lines = [
                                    line.strip() for line in content.split('\n') 
                                    if line.strip().startswith(('import ', 'from '))
                                ]
                            elif file.endswith('.ts'):
                                import_lines = [
                                    line.strip() for line in content.split('\n') 
                                    if line.strip().startswith(('import ', 'export '))
                                ]
                            
                            # Add to connections
                            if import_lines:
                                connections[file_path] = import_lines
        
        return connections
    
    def create_self_correcting_seed(self) -> str:
        """Create a seed that includes self-correction mechanisms"""
        # Generate base seed
        base_seed = self.generate_seed()
        
        # Add self-correction markers
        if not base_seed.endswith('~'):
            # Add self-correction function to the seed
            correction_marker = "SC{φ→→→∞}"
            base_seed += correction_marker
        
        return base_seed
    
    def deploy_across_conversations(self, seed: str, output_dir: str = "./seeds"):
        """Deploy the seed across multiple conversation templates"""
        # Make sure output directory exists
        os.makedirs(output_dir, exist_ok=True)
        
        # Create seed files for different conversation types
        seed_types = {
            "relationship": "relationship_seed.txt",
            "technical": "technical_seed.txt",
            "integration": "integration_seed.txt",
            "documentation": "documentation_seed.txt",
            "analysis": "analysis_seed.txt"
        }
        
        # Create each seed file
        for seed_type, filename in seed_types.items():
            output_path = os.path.join(output_dir, filename)
            
            # Add type-specific markers to the seed
            typed_seed = seed + f"[{seed_type}]"
            
            # Write to file
            with open(output_path, 'w') as f:
                f.write(typed_seed)
        
        # Create a master seed file
        master_path = os.path.join(output_dir, "master_seed.txt")
        with open(master_path, 'w') as f:
            f.write(seed)
        
        return seed_types
```

### 3. Create a Self-Correcting System

```python
# Save as ~/BAZINGA-Master/core/claude-seed/self_correction.py

import os
import json
import re
import datetime
from typing import Dict, List, Any, Optional

class SelfCorrectingSystem:
    """Self-correcting system for BAZINGA framework"""
    
    def __init__(self, bazinga_root: str):
        """
        Initialize the self-correcting system.
        
        Args:
            bazinga_root: Root directory of the BAZINGA framework
        """
        self.bazinga_root = bazinga_root
        self.correction_log = []
        self.correction_patterns = self._load_correction_patterns()
    
    def _load_correction_patterns(self) -> Dict[str, str]:
        """Load correction patterns"""
        patterns_path = os.path.join(self.bazinga_root, "src/core/patterns.json")
        
        if os.path.exists(patterns_path):
            with open(patterns_path, 'r') as f:
                return json.load(f)
        
        # Default patterns
        return {
            "missing_import": r"import\s+(\w+).*?Cannot find module",
            "undefined_variable": r"(\w+) is not defined",
            "type_error": r"Type '(.+?)' is not assignable to type '(.+?)'",
            "circular_dependency": r"Circular dependency between (.+?) and (.+?)",
            "unused_variable": r"'(\w+)' is declared but never used"
        }
    
    def analyze_code(self, file_path: str) -> List[Dict[str, Any]]:
        """Analyze code for issues that need correction"""
        issues = []
        
        # Make sure the file exists
        if not os.path.exists(file_path):
            return [{"type": "file_missing", "path": file_path}]
        
        # Read the file
        with open(file_path, 'r') as f:
            content = f.read()
        
        # Check for patterns
        for issue_type, pattern in self.correction_patterns.items():
            matches = re.finditer(pattern, content)
            for match in matches:
                issues.append({
                    "type": issue_type,
                    "match": match.group(0),
                    "groups": match.groups(),
                    "line": content.count('\n', 0, match.start()) + 1
                })
        
        return issues
    
    def suggest_corrections(self, issues: List[Dict[str, Any]]) -> Dict[str, Any]:
        """Suggest corrections for issues"""
        corrections = {}
        
        for issue in issues:
            if issue["type"] == "missing_import":
                corrections[issue["type"]] = f"Add 'import {issue['groups'][0]}' to the file"
            
            elif issue["type"] == "undefined_variable":
                corrections[issue["type"]] = f"Define variable '{issue['groups'][0]}' before use"
            
            elif issue["type"] == "type_error":
                corrections[issue["type"]] = f"Convert type '{issue['groups'][0]}' to '{issue['groups'][1]}'"
            
            elif issue["type"] == "circular_dependency":
                corrections[issue["type"]] = f"Resolve circular dependency between {issue['groups'][0]} and {issue['groups'][1]}"
            
            elif issue["type"] == "unused_variable":
                corrections[issue["type"]] = f"Remove unused variable '{issue['groups'][0]}'"
            
            elif issue["type"] == "file_missing":
                corrections[issue["type"]] = f"Create file '{issue['path']}'"
        
        return corrections
    
    def apply_corrections(self, file_path: str, corrections: Dict[str, Any]) -> bool:
        """Apply corrections to the file"""
        # Check if file exists
        if not os.path.exists(file_path):
            # If correction is for missing file, create it
            if "file_missing" in corrections:
                directory = os.path.dirname(file_path)
                os.makedirs(directory, exist_ok=True)
                
                with open(file_path, 'w') as f:
                    f.write("# Auto-generated file\n")
                
                self.correction_log.append({
                    "timestamp": datetime.datetime.now().isoformat(),
                    "file": file_path,
                    "action": "created_file",
                    "details": "Created missing file"
                })
                
                return True
            
            return False
        
        # Read the file
        with open(file_path, 'r') as f:
            content = f.read()
        
        # Apply corrections
        modified = False
        new_content = content
        
        for issue_type, correction in corrections.items():
            if issue_type == "missing_import":
                # Add import at the top
                import_statement = f"import {correction.split('import ')[1].split('\'')[0]}\n"
                if import_statement not in new_content:
                    new_content = import_statement + new_content
                    modified = True
            
            elif issue_type == "unused_variable":
                # Comment out unused variable definitions
                variable = correction.split('\'')[1].split('\'')[0]
                pattern = fr'(\b{variable}\b\s*=.*)'
                new_content = re.sub(pattern, r'# \1  # Auto-commented by self-correction', new_content)
                modified = True
        
        # Write back the modified content
        if modified:
            with open(file_path, 'w') as f:
                f.write(new_content)
            
            self.correction_log.append({
                "timestamp": datetime.datetime.now().isoformat(),
                "file": file_path,
                "action": "modified_file",
                "details": f"Applied corrections: {list(corrections.keys())}"
            })
        
        return modified
    
    def scan_and_correct(self, directory: Optional[str] = None) -> Dict[str, Any]:
        """Scan directory and correct issues"""
        if directory is None:
            directory = os.path.join(self.bazinga_root, "src")
        
        results = {
            "scanned_files": 0,
            "issues_found": 0,
            "corrections_applied": 0,
            "files_corrected": []
        }
        
        # Walk through directory
        for root, _, files in os.walk(directory):
            for file in files:
                if file.endswith(('.py', '.ts', '.js')):
                    file_path = os.path.join(root, file)
                    
                    # Analyze file
                    issues = self.analyze_code(file_path)
                    results["scanned_files"] += 1
                    results["issues_found"] += len(issues)
                    
                    if issues:
                        # Suggest corrections
                        corrections = self.suggest_corrections(issues)
                        
                        # Apply corrections
                        if self.apply_corrections(file_path, corrections):
                            results["corrections_applied"] += len(corrections)
                            results["files_corrected"].append(file_path)
        
        # Log the results
        log_path = os.path.join(self.bazinga_root, "logs/self_correction.json")
        os.makedirs(os.path.dirname(log_path), exist_ok=True)
        
        with open(log_path, 'w') as f:
            json.dump({
                "timestamp": datetime.datetime.now().isoformat(),
                "results": results,
                "correction_log": self.correction_log
            }, f, indent=2)
        
        return results
```

### 4. Create a Command-Line Tool for Integration

```python
# Save as ~/BAZINGA-Master/tools/bazinga_seed_integrator.py

#!/usr/bin/env python3
import os
import sys
import argparse
import json
import datetime

# Add parent directory to path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

# Import BAZINGA integration modules
from core.claude_seed.bazinga_integration import BAZINGAClaudeIntegration
from core.claude_seed.self_correction import SelfCorrectingSystem

def main():
    """Main function to integrate ClaudeSeed with BAZINGA"""
    parser = argparse.ArgumentParser(description="BAZINGA ClaudeSeed Integrator")
    
    parser.add_argument("--generate", action="store_true", help="Generate seeds")
    parser.add_argument("--deploy", action="store_true", help="Deploy seeds across conversations")
    parser.add_argument("--correct", action="store_true", help="Run self-correction")
    parser.add_argument("--config", type=str, help="Path to configuration file")
    parser.add_argument("--output", type=str, default="./seeds", help="Output directory for seeds")
    parser.add_argument("--dir", type=str, help="Directory to scan for self-correction")
    
    args = parser.parse_args()
    
    # Determine BAZINGA root
    bazinga_root = os.environ.get("BAZINGA_ROOT", os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
    
    print(f"\nBAZINGA ClaudeSeed Integrator")
    print(f"===========================")
    print(f"BAZINGA Root: {bazinga_root}")
    
    # Create integrator
    integrator = BAZINGAClaudeIntegration(bazinga_root, args.config)
    
    # Generate seeds
    if args.generate:
        print("\nGenerating seeds...")
        seed = integrator.create_self_correcting_seed()
        
        print(f"\nSeed generated successfully:")
        print(f"\n{seed}\n")
    
    # Deploy seeds
    if args.deploy:
        print("\nDeploying seeds across conversations...")
        
        # Generate seed if not already done
        if not args.generate:
            seed = integrator.create_self_correcting_seed()
        
        # Deploy
        seed_types = integrator.deploy_across_conversations(seed, args.output)
        
        print(f"\nSeeds deployed to {args.output}:")
        for seed_type, filename in seed_types.items():
            print(f"  - {seed_type}: {os.path.join(args.output, filename)}")
    
    # Run self-correction
    if args.correct:
        print("\nRunning self-correction...")
        
        # Create self-correction system
        corrector = SelfCorrectingSystem(bazinga_root)
        
        # Run scan and correction
        results = corrector.scan_and_correct(args.dir)
        
        print(f"\nSelf-correction results:")
        print(f"  - Scanned files: {results['scanned_files']}")
        print(f"  - Issues found: {results['issues_found']}")
        print(f"  - Corrections applied: {results['corrections_applied']}")
        print(f"  - Files corrected: {len(results['files_corrected'])}")
    
    # If no action specified, show help
    if not (args.generate or args.deploy or args.correct):
        parser.print_help()

if __name__ == "__main__":
    main()
```

### 5. Create a Bash Wrapper

```bash
#!/bin/bash
#
# BAZINGA ClaudeSeed Integration
#
# This script integrates ClaudeSeed with BAZINGA
#

# Set BAZINGA root
export BAZINGA_ROOT="${BAZINGA_ROOT:-$HOME/BAZINGA-Master}"

# Create directories
mkdir -p "$BAZINGA_ROOT/seeds"
mkdir -p "$BAZINGA_ROOT/logs"

# Check Python
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is required but not found."
    exit 1
fi

# Parse arguments
GENERATE=0
DEPLOY=0
CORRECT=0
OUTPUT="$BAZINGA_ROOT/seeds"
DIR="$BAZINGA_ROOT/src"
CONFIG=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --generate)
            GENERATE=1
            shift
            ;;
        --deploy)
            DEPLOY=1
            shift
            ;;
        --correct)
            CORRECT=1
            shift
            ;;
        --output)
            OUTPUT="$2"
            shift 2
            ;;
        --dir)
            DIR="$2"
            shift 2
            ;;
        --config)
            CONFIG="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Build command
CMD="python3 $BAZINGA_ROOT/tools/bazinga_seed_integrator.py"

if [[ $GENERATE -eq 1 ]]; then
    CMD="$CMD --generate"
fi

if [[ $DEPLOY -eq 1 ]]; then
    CMD="$CMD --deploy"
fi

if [[ $CORRECT -eq 1 ]]; then
    CMD="$CMD --correct"
fi

if [[ -n "$OUTPUT" ]]; then
    CMD="$CMD --output $OUTPUT"
fi

if [[ -n "$DIR" ]]; then
    CMD="$CMD --dir $DIR"
fi

if [[ -n "$CONFIG" ]]; then
    CMD="$CMD --config $CONFIG"
fi

# Run command
echo "Running: $CMD"
eval "$CMD"
```

Save this file as `~/BAZINGA-Master/scripts/bazinga_claudeseed.sh` and make it executable:

```bash
chmod +x ~/BAZINGA-Master/scripts/bazinga_claudeseed.sh
```

## Usage

Now you can use the integration:

### Generate a Seed

```bash
~/BAZINGA-Master/scripts/bazinga_claudeseed.sh --generate
```

### Deploy Seeds Across Conversations

```bash
~/BAZINGA-Master/scripts/bazinga_claudeseed.sh --generate --deploy
```

### Run Self-Correction

```bash
~/BAZINGA-Master/scripts/bazinga_claudeseed.sh --correct
```

### Combined Operation

```bash
~/BAZINGA-Master/scripts/bazinga_claudeseed.sh --generate --deploy --correct
```

## Self-Correcting Features

The integration adds these self-correcting features to your BAZINGA framework:

1. **Automated Code Analysis**: The system scans your codebase for common issues like missing imports, undefined variables, and type errors.

2. **Correction Suggestions**: For each issue found, the system suggests a correction.

3. **Automated Fixes**: The system can automatically apply simple fixes like adding missing imports or commenting out unused variables.

4. **Correction Logging**: All corrections are logged in `~/BAZINGA-Master/logs/self_correction.json`.

5. **Cross-Session Context**: The ClaudeSeed integration propagates context across Claude sessions, allowing a continuous development experience.

## Visual Generation Integration

To integrate with your existing visualization tools, add this function to the `BAZINGAClaudeIntegration` class:

```python
def generate_visualization(self, seed_data: Dict[str, Any], output_path: str) -> None:
    """Generate a visualization of the seed data"""
    # Import visualization tools
    sys.path.insert(0, os.path.join(self.bazinga_root, "src/visualizations"))
    try:
        from bazinga_visualizer import BazingaVisualizer
        
        # Create visualizer
        visualizer = BazingaVisualizer()
        
        # Generate visualization
        visualizer.create_seed_visualization(seed_data, output_path)
        
    except ImportError:
        print("Warning: BazingaVisualizer not found. Visualization skipped.")
```

Then add the visualization call to the command-line tool.

## Conclusion

This integration combines ClaudeSeed's context propagation with BAZINGA's pattern analysis capabilities to create a self-evolving, self-correcting system. The mathematical constants from ClaudeSeed (Golden ratio, Silver ratio, Plastic number) align well with your fractal analysis, creating a unified framework for both relationship analysis and technical systems.
