# Cloudy Extractor: Complete User Guide

## Overview

The Cloudy Extractor is a tool for extracting and processing data from Claude artifacts. It works with the Bazinga ecosystem to safely collect, analyze, and integrate insights from your conversations.

## Installation & Setup

1. **Create the directory structure:**
```bash
mkdir -p ~/AmsyPycharm/BAZINGA/cloudy_extractor
cd ~/AmsyPycharm/BAZINGA/cloudy_extractor
```

2. **Consolidate the extractor components:**
```bash
cp ~/Downloads/bazinga_claude_analyzer.py ./
cp ~/Downloads/safe_claude_collector.py ./
cp ~/Downloads/improved-clipboard-fix.py ./
cp ~/bazinga-insight-extractor.sh ./
chmod +x *.py *.sh
```

3. **Create the configuration file:**
```bash
cat > config.json << 'EOF'
{
  "artifact_dir": "~/AmsyPycharm/BAZINGA/artifacts/claude_artifacts",
  "output_dir": "~/AmsyPycharm/BAZINGA/cloudy_output",
  "backup_dir": "~/AmsyPycharm/BAZINGA/backups",
  "enable_clipboard_safety": true,
  "max_artifacts_per_run": 50,
  "logging_level": "INFO"
}
EOF
```

## Usage Instructions

### Basic Collection

To collect artifacts from Claude:

```bash
cd ~/AmsyPycharm/BAZINGA/cloudy_extractor
./safe_claude_collector.py --url "https://claude.site/artifacts/your-artifact-id"
```

### Batch Collection

For collecting multiple artifacts at once:

```bash
cd ~/AmsyPycharm/BAZINGA/cloudy_extractor
./safe_claude_collector.py --file artifact_urls.txt
```

Where `artifact_urls.txt` contains URLs, one per line:
```
https://claude.site/artifacts/id1
https://claude.site/artifacts/id2
...
```

### Analysis Mode

To analyze collected artifacts:

```bash
cd ~/AmsyPycharm/BAZINGA/cloudy_extractor
./bazinga_claude_analyzer.py --directory ~/AmsyPycharm/BAZINGA/artifacts/claude_artifacts
```

### Full Extraction Pipeline

For a complete extraction and analysis:

```bash
cd ~/AmsyPycharm/BAZINGA/cloudy_extractor
./bazinga-insight-extractor.sh
```

This will:
1. Check and fix clipboard issues
2. Collect artifacts from configured sources
3. Process and analyze artifacts
4. Generate reports and analysis files
5. Integrate with TimeSpaceIntegrator (if available)

## Advanced Configuration

### Changing Output Format

Edit `config.json` to modify the output format:

```json
{
  "output_format": "json",  // Options: json, csv, markdown
  "include_metadata": true,
  "compression": false
}
```

### Enabling Quantum Analysis

For advanced harmonic pattern analysis:

```bash
./bazinga_claude_analyzer.py --enable-quantum --dimensions 5
```

## Troubleshooting

### Clipboard Issues

If experiencing clipboard problems:

```bash
./improved-clipboard-fix.py --force-reset
```

### Missing Dependencies

If you encounter missing dependencies:

```bash
pip install pandas numpy matplotlib networkx nltk
```

### Permission Errors

If you encounter permission errors:

```bash
chmod +x *.py *.sh
```

## Integration with Bazinga Core

The Cloudy Extractor integrates with the TimeSpaceIntegrator through the integration bridge. To enable this:

1. Ensure the integration bridge is running
2. Use the `--integrate` flag when running the extractor
3. Check integration reports in the output directory

```bash
./bazinga-insight-extractor.sh --integrate
```

## Maintenance

Regularly clear cached data:

```bash
rm -rf ~/AmsyPycharm/BAZINGA/cloudy_extractor/cache/*
```

Backup your artifacts:

```bash
./safe_claude_collector.py --backup
```
