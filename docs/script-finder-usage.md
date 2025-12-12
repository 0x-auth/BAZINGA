# Script Finder and Analyzer: Usage Guide

## Overview

The Script Finder and Analyzer tool uses BAZINGA's fractal pattern principles to discover, analyze, and categorize scripts across your system. It identifies four fundamental patterns in your scripts: Time-Trust, Harmonic, Relationship, and Mandelbrot.

## Installation

1. Save the script as `script-finder.sh` in your preferred location
2. Make it executable:
   ```bash
   chmod +x script-finder.sh
   ```

## Usage

### Basic Usage

Simply run the script without any arguments:

```bash
./script-finder.sh
```

The script will:
1. Find all shell and Python scripts in common directories
2. Analyze the scripts for pattern recognition
3. Generate a comprehensive HTML report
4. Create a JSON database of scripts with pattern information

### Command-line Options

```bash
./script-finder.sh [options]

Options:
  -p, --path PATH       Specify a custom search path
  -d, --depth DEPTH     Set search depth (default: 3)
  -o, --output DIR      Set custom output directory
  -q, --quiet           Suppress verbose output
  -h, --help            Show help information
```

### Environment Variables

The script respects the following environment variables:

- `SCRIPT_FINDER_PATHS`: Colon-separated list of paths to search
- `SCRIPT_FINDER_OUTPUT`: Custom output directory path
- `SCRIPT_FINDER_DEPTH`: Maximum directory depth to search

Example:
```bash
SCRIPT_FINDER_PATHS="/projects:/home/user/scripts" ./script-finder.sh
```

## Understanding the Results

### Pattern Types

The script identifies four pattern types:

1. **Time-Trust Pattern**: Scripts dealing with temporal logic and security considerations
   - Keywords: security, auth, token, timeout, expiry, schedule

2. **Harmonic Pattern**: Scripts affecting multiple systems in balanced ways
   - Keywords: integration, system, balance, sync, orchestrate

3. **Relationship Pattern**: Scripts with complex dependencies 
   - Keywords: dependency, require, import, module, reference

4. **Mandelbrot Pattern**: Scripts with recursive or self-similar elements
   - Keywords: recursive, loop, iterate, fractal, nested, tree

### Output Files

The script generates several output files in the results directory:

- `script_paths.txt`: List of all discovered script paths
- `script_analysis.json`: Raw analysis data in JSON format
- `script_analysis_report.html`: Interactive HTML report with visualizations
- `script_database.json`: Structured database of scripts with pattern information

## Fixing Common Issues

If you encounter errors related to file paths being captured with console output, apply this fix:

```bash
sed -i '' 's/echo "\$.*_FILE"/printf "%s" "&"/' script-finder.sh
```

Or manually modify the functions to use `printf` instead of `echo` when returning file paths.

## Integration with Other Tools

### Using with Jira

The script database can be integrated with Jira for script management:

```bash
jq -r '.scripts[] | select(.dominant_pattern=="time_trust") | .path' script_database.json > security_review_scripts.txt
```

### Using with BAZINGA

To integrate with other BAZINGA components:

```bash
# Find all scripts with high Time-Trust scores
jq '.scripts[] | select(.dominant_pattern=="time_trust" and .pattern_score > 5)' script_database.json > time_trust_scripts.json

# Generate patterns for feeding into BAZINGA's pattern detection system
jq -r '.scripts | to_entries[] | "\(.key),\(.value.dominant_pattern),\(.value.pattern_score)"' script_database.json > bazinga_patterns.csv
```

## Advanced Usage

### Custom Pattern Detection

Create a custom pattern definition file:

```json
{
  "custom_pattern": {
    "description": "My Custom Pattern",
    "keywords": ["specific", "terms", "to", "match"]
  }
}
```

Then run with the custom patterns:
```bash
./script-finder.sh --patterns my_patterns.json
```

### Generating Reports for Specific Pattern Types

```bash
# Extract only Time-Trust pattern scripts
jq '.results[] | select(.dominant_pattern=="time_trust")' script_analysis.json > time_trust_analysis.json

# Generate a focused report
python3 report_generator.py time_trust_analysis.json time_trust_report.html
```

## Performance Tips

- For large repositories, use path filtering to narrow the search
- Exclude vendor/third-party code directories using the ignore pattern
- Run during off-hours for large codebases as pattern analysis can be CPU-intensive
- Consider using the depth parameter to limit deep directory searches

## Troubleshooting

- **Missing Python Dependencies**: Install with `pip install json numpy matplotlib`
- **Script Not Finding Files**: Check permissions in search directories
- **HTML Report Not Opening**: Open manually from the output directory
- **Analysis Taking Too Long**: Use path restrictions or increase depth limit
