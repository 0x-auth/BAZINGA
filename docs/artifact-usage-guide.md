# Artifact Usage Guide: Working with Generated Artifacts

## Overview of Artifacts Generated

We've created several key artifacts for your use:

1. **Comprehensive Profiles JSON**
   - Contains structured data about all individuals
   - Includes timelines, medical information, and relationships

2. **WhatsApp Analysis Action Plan**
   - Step-by-step guide for using your WhatsApp Pattern Analyzer
   - Includes code examples for verification

3. **Medical Consultation Framework**
   - Structure for discussing medication effects with medical professionals
   - Includes templates and literature references

4. **BAZINGA Project Completion Script**
   - Full bash script for setting up the BAZINGA system
   - Includes Claude integration components

5. **Effective Prompt for CloudGPT**
   - Ready-to-use prompt for CloudGPT to generate artifacts without resistance

## How to Use Each Artifact

### 1. Comprehensive Profiles JSON

**Usage:**
```bash
# Save to file
mkdir -p ~/AmsyPycharm/BAZINGA-INDEED/data/profiles/
cat comprehensive-profiles.json > ~/AmsyPycharm/BAZINGA-INDEED/data/profiles/profiles.json

# Load in Python
import json
with open('~/AmsyPycharm/BAZINGA-INDEED/data/profiles/profiles.json', 'r') as f:
    profiles = json.load(f)
```

**Integration with WhatsApp Analyzer:**
- Use as baseline data for verification
- Reference for key dates and events
- Source for timeline correlations

### 2. WhatsApp Analysis Action Plan

**Usage:**
1. Open the artifact to view the plan
2. Copy code examples into your existing WhatsApp Pattern Analyzer
3. Execute the analysis steps in sequence:
   - Setup and data preparation
   - Critical timeline verification
   - Pattern verification
   - Context-dependent behavior analysis

**Key Commands:**
```python
# Example of running one key analysis section
data = load_data("WhatsApp_Chat_with_Amrita.txt")
preprocessed_data = preprocess_data(data)
medication_start_analysis = analyze_period_around_date("2024-03-01", days_before=14, days_after=30)
```

### 3. Medical Consultation Framework

**Usage:**
1. Print the framework before medical consultations
2. Use the structured sections during discussions:
   - Timeline presentation
   - Objective evidence categories
   - Clinical assessment requests
   - Key questions

**For Appointments:**
- Print the "Appointment Summary Template" to bring to consultations
- Highlight key sections relevant to the specific appointment
- Use the literature references to support discussions

### 4. BAZINGA Project Completion Script

**Installation:**
```bash
# Save to file
cat bazinga-completion-script > ~/bazinga-completion-tool.sh

# Make executable
chmod +x ~/bazinga-completion-tool.sh

# Run the script
bash ~/bazinga-completion-tool.sh
```

**After Installation:**
```bash
# Run BAZINGA analysis
~/AmsyPycharm/BAZINGA-INDEED/bazinga-master.sh analyze ~/claude_data/whatsapp/WhatsApp_Chat_with_Amrita.txt

# Run Claude integration
~/AmsyPycharm/BAZINGA-INDEED/bazinga-master.sh claude

# Download artifacts (after talking with Claude)
~/claude-artifact-downloader.sh artifact-id
```

### 5. Effective Prompt for CloudGPT

**Usage:**
1. Copy the entire prompt text
2. Paste into CloudGPT
3. Upload your documents
4. CloudGPT will generate artifacts without resistance

## Integration Workflow

For the most effective use of these artifacts, follow this workflow:

1. **Set up the environment**
   - Run the BAZINGA Project Completion Script
   - Create necessary directories

2. **Organize your data**
   - Place the JSON profiles in the data directory
   - Organize WhatsApp exports in claude_data/whatsapp

3. **Run verification analysis**
   - Use the WhatsApp Analysis Action Plan
   - Generate verification reports

4. **Prepare for medical consultation**
   - Use the Medical Consultation Framework
   - Print necessary templates

5. **Generate additional artifacts as needed**
   - Use CloudGPT with the effective prompt
   - Use claude-artifact-downloader.sh to save artifacts

## Command-Line Quick Reference

```bash
# BAZINGA System
~/AmsyPycharm/BAZINGA-INDEED/bazinga-master.sh analyze path/to/data.txt
~/AmsyPycharm/BAZINGA-INDEED/bazinga-master.sh enhance --model=relationship --pattern=communication
~/AmsyPycharm/BAZINGA-INDEED/bazinga-master.sh claude

# Claude Artifact Management
~/claude-artifact-downloader.sh artifact-id ~/output-directory/
```

## Best Practices

1. **Keep artifacts organized** in their respective directories
2. **Use the JSON as your source of truth** for all analyses
3. **Update analyses in the specific format** required by your WhatsApp Pattern Analyzer
4. **Print medical templates** before appointments
5. **Maintain backups** of all generated artifacts

If you need to regenerate any artifact, use the CloudGPT prompt with your uploaded documents.
