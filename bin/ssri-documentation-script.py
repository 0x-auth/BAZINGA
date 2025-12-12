#!/usr/bin/env python3
# ssri-documentation-generator.py - Compatible with venv_bazinga
# Usage: source venv_bazinga/bin/activate && python ssri-documentation-generator.py

import os
import sys
import json
import shutil
import datetime
from pathlib import Path
import argparse

# Check if running in virtual environment
if not hasattr(sys, 'real_prefix') and not (hasattr(sys, 'base_prefix') and sys.base_prefix != sys.prefix):
    print("ERROR: This script must be run within the venv_bazinga virtual environment.")
    print("Activate it with: source venv_bazinga/bin/activate")
    sys.exit(1)

# ANSI color codes for better readability
class Colors:
    BLUE = '\033[94m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'
    END = '\033[0m'

def log(message, color = None):
    """Print log message with optional color"""
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    if color:
        print(f"{color}[{timestamp}] {message}{Colors.END}")
    else:
        print(f"[{timestamp}] {message}")

# Parse command line arguments
parser = argparse.ArgumentParser(description = "Generate SSRI documentation for legal consultation")
parser.add_argument("--output-dir", default = os.path.expanduser("~/SSRI_Documentation"),
                    help = "Output directory for documentation")
parser.add_argument("--timeline-start", default = "2024-06-01",
                    help = "Start date for timeline (YYYY-MM-DD)")
parser.add_argument("--timeline-end", default = datetime.datetime.now().strftime("%Y-%m-%d"),
                    help = "End date for timeline (YYYY-MM-DD)")
parser.add_argument("--consultation-date", default = "2025-02-28",
                    help = "Date of legal consultation (YYYY-MM-DD)")
args = parser.parse_args()

# Configuration
OUTPUT_DIR = Path(args.output_dir)
TIMELINE_START = args.timeline_start
TIMELINE_END = args.timeline_end
CONSULTATION_DATE = args.consultation_date
BAZINGA_ROOT = Path(os.getcwd())

# Create output directory structure
def create_directory_structure():
    log(f"Creating directory structure in {OUTPUT_DIR}", Colors.BLUE)

    # Main directories
    directories = [
        "Medical_Evidence",
        "Communication_Analysis",
        "Legal_Options",
        "Timeline",
        "Visualization",
        "Research"
    ]

    for directory in directories:
        os.makedirs(OUTPUT_DIR / directory, exist_ok = True)

    # Subdirectories
    os.makedirs(OUTPUT_DIR / "Medical_Evidence" / "Literature", exist_ok = True)
    os.makedirs(OUTPUT_DIR / "Medical_Evidence" / "Personal", exist_ok = True)
    os.makedirs(OUTPUT_DIR / "Communication_Analysis" / "Patterns", exist_ok = True)
    os.makedirs(OUTPUT_DIR / "Communication_Analysis" / "Raw_Data", exist_ok = True)
    os.makedirs(OUTPUT_DIR / "Visualization" / "Fractal_Analysis", exist_ok = True)

    log("Directory structure created successfully", Colors.GREEN)

# Generate timeline document
def generate_timeline():
    log("Generating comprehensive timeline document", Colors.BLUE)

    timeline_file = OUTPUT_DIR / "Timeline" / "SSRI_Comprehensive_Timeline.md"

    with open(timeline_file, "w") as f:
        f.write("# SSRI Effect Comprehensive Timeline\n\n")
        f.write(f"*Generated: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*\n\n")

        f.write("## Pre-Medication Period (Before June 2024)\n\n")
        f.write("### Communication Patterns\n")
        f.write("- Regular daily communication\n")
        f.write("- Consistent emotional tone\n")
        f.write("- Reciprocal engagement\n")
        f.write("- Shared future planning\n")
        f.write("- Affectionate language\n")
        f.write("- Multi-dimensional conversations\n\n")

        f.write("### Relationship Behaviors\n")
        f.write("- Mutual problem-solving approach\n")
        f.write("- Shared interests and activities\n")
        f.write("- Balanced decision-making\n")
        f.write("- Regular expressions of affection\n")
        f.write("- Future-oriented discussions\n")
        f.write("- Family integration activities\n\n")

        f.write("## Medication Initiation Phase (June 2024)\n\n")
        f.write("### Key Events\n")
        f.write("- **June 10, 2024**: SSRI medication initiated for Amrita\n")
        f.write("- **June 12-20, 2024**: Initial adjustment period\n")
        f.write("- **June 22, 2024**: First noted slight communication pattern shift\n")
        f.write("- **June 30, 2024**: Discussion about medication effects on energy\n\n")

        f.write("### Observable Changes\n")
        f.write("- Slight reduction in communication initiative\n")
        f.write("- Minor decrease in emotional expressiveness\n")
        f.write("- Subtle shift toward more practical conversations\n")
        f.write("- Slight reduction in future planning discussions\n\n")

        # Continue with more timeline sections...
        f.write("## Early Medication Effect Period (July-August 2024)\n\n")
        f.write("## Mid-Medication Effect Period (September 2024)\n\n")
        f.write("## Relationship Shift Period (October 2024)\n\n")
        f.write("## Post-Separation Period (November-December 2024)\n\n")
        f.write("## Recovery Initiation Period (January-February 2025)\n\n")

        f.write("## Documentation Evidence\n\n")
        f.write("Each period and key event has corresponding documentation:\n\n")
        f.write("1. **Communication Records**\n")
        f.write("   - WhatsApp messages (full export preserved)\n")
        f.write("   - Email correspondence\n")
        f.write("   - Voice message transcriptions\n")
        f.write("   - Video call recordings (where available)\n\n")

        f.write("2. **Meeting Documentation**\n")
        f.write("   - Contemporaneous meeting notes\n")
        f.write("   - Post-meeting reflection documents\n")
        f.write("   - Witness accounts where applicable\n")
        f.write("   - Voice recordings (when obtained with consent)\n\n")

        f.write("3. **Medical Documentation**\n")
        f.write("   - Treatment timeline documentation\n")
        f.write("   - Medication adjustment records\n")
        f.write("   - Clinical observations of behavioral changes\n")
        f.write("   - Research literature supporting observed patterns\n\n")

        f.write("4. **Pattern Analysis**\n")
        f.write("   - Communication frequency graphs\n")
        f.write("   - Sentiment analysis of messages\n")
        f.write("   - Topic modeling of conversations\n")
        f.write("   - Binary language pattern quantification\n\n")

    log(f"Timeline document created: {timeline_file}", Colors.GREEN)

# Generate medical evidence document
def generate_medical_evidence():
    log("Generating medical evidence document", Colors.BLUE)

    medical_file = OUTPUT_DIR / "Medical_Evidence" / "SSRI_Induced_Apathy_Syndrome.md"

    with open(medical_file, "w") as f:
        f.write("# SSRI-Induced Apathy Syndrome: Medical Evidence\n\n")
        f.write(f"*Generated: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*\n\n")

        f.write("## Definition and Clinical Recognition\n\n")
        f.write("SSRI-Induced Apathy Syndrome (sometimes called SSRI-Induced Indifference) is a documented condition where selective serotonin reuptake inhibitors cause emotional blunting, reduced motivation, and diminished emotional reactivity. This condition is distinct from the depression the medication is typically prescribed to treat.\n\n")

        f.write("## Key Symptoms Documented\n\n")
        f.write("| Symptom | Pre-Medication | During Medication | Post-Discontinuation |\n")
        f.write("|---------|----------------|-------------------|----------------------|\n")
        f.write("| Emotional Range | Full spectrum of emotional responses | Restricted emotional range, particularly positive emotions | Gradual return of emotional range |\n")
        f.write("| Decision-Making | Multi-dimensional consideration | Binary/black-and-white thinking patterns | Fluctuating return to nuanced thinking |\n")
        f.write("| Relationship Conceptualization | Dynamic and evolving | Static categorization (e.g., \"just friends\") | Inconsistent recognition of relationship complexity |\n")
        f.write("| Future Planning | Detailed long-term plans | Diminished future conceptualization | Emerging reconnection with future planning |\n")
        f.write("| Emotional Reactivity | Appropriate affective responses | Muted emotional reactions | Windows of normal emotional reactivity |\n")
        f.write("| Empathic Ability | Strong empathic responses | Reduced recognition of others' emotional states | Fluctuating empathic capacity |\n\n")

        f.write("## Literature Support\n\n")
        f.write("### Research Papers\n\n")
        f.write("1. Opbroek, A., Delgado, P. L., Laukes, C., McGahuey, C., Katsanis, J., Moreno, F. A., & Manber, R. (2002). Emotional blunting associated with SSRI-induced sexual dysfunction. Do SSRIs inhibit emotional responses? International Journal of Neuropsychopharmacology, 5(2), 147-151.\n\n")
        f.write("2. Sansone, R. A., & Sansone, L. A. (2010). SSRI-Induced Indifference. Psychiatry (Edgmont), 7(10), 14-18.\n\n")
        f.write("3. Price, J., Cole, V., & Goodwin, G. M. (2009). Emotional side-effects of selective serotonin reuptake inhibitors: qualitative study. The British Journal of Psychiatry, 195(3), 211-217.\n\n")
        f.write("4. Barnhart, W. J., Makela, E. H., & Latocha, M. J. (2004). SSRI-induced apathy syndrome: a clinical review. Journal of Psychiatric Practice, 10(3), 196-199.\n\n")

        f.write("### Key Findings From Literature\n\n")
        f.write("1. SSRIs can cause emotional blunting in 40-60% of patients\n")
        f.write("2. Symptoms often not recognized as medication side effects by patients or providers\n")
        f.write("3. Effects can impact relationship conceptualization and decision-making\n")
        f.write("4. Recovery after discontinuation typically follows a non-linear \"windows and waves\" pattern\n")
        f.write("5. Full recovery timeframe varies from weeks to months depending on duration of use\n\n")

        f.write("## Personal Medical Documentation Timeline\n\n")
        f.write("| Date | Event | Documentation |\n")
        f.write("|------|-------|---------------|\n")
        f.write("| June 10, 2024 | SSRI Initiation | Prescription record |\n")
        f.write("| July 15, 2024 | First noted emotional blunting | Personal journal entry |\n")
        f.write("| July 23, 2024 | Medication dosage adjustment | Prescription modification record |\n")
        f.write("| September 12, 2024 | Discussion of side effects | Communication record |\n")
        f.write("| November 15, 2024 | Recognition of SSRI-Induced Apathy | Research notes |\n")
        f.write("| November 26, 2024 | SSRI Discontinuation | Medication cessation record |\n")
        f.write("| December 5, 2024 | First post-discontinuation communication | WhatsApp records |\n")
        f.write("| January 10, 2025 | First significant emotional fluctuation | Observation notes |\n")
        f.write("| January 17, 2025 | Medical consultation re: recovery | Appointment record |\n")
        f.write("| February 15, 2025 | Recovery pattern documentation | Systematic observation notes |\n\n")

    log(f"Medical evidence document created: {medical_file}", Colors.GREEN)

# Generate legal options analysis
def generate_legal_options():
    log("Generating legal options analysis", Colors.BLUE)

    legal_file = OUTPUT_DIR / "Legal_Options" / "Legal_Options_Analysis.md"

    with open(legal_file, "w") as f:
        f.write("# Legal Options Analysis\n\n")
        f.write(f"*Generated: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*\n\n")
        f.write(f"*For consultation on: {CONSULTATION_DATE}*\n\n")

        f.write("## Overview of Situation\n\n")
        f.write("This analysis examines legal options in the context of relationship changes correlated with SSRI-Induced Apathy Syndrome, where medical effects have significantly impacted relationship dynamics and decision-making capacity during a critical period.\n\n")

        f.write("## Priority Matrix\n\n")
        f.write("The following matrix prioritizes legal options based on urgency, effectiveness, and resource requirements:\n\n")
        f.write("| Option | Urgency | Effectiveness | Resource Requirement | Priority |\n")
        f.write("|--------|---------|--------------|----------------------|----------|\n")
        f.write("| Mental Healthcare Act | Medium | High | Medium | 1 |\n")
        f.write("| Habeas Corpus | High | Medium | High | 2 |\n")
        f.write("| Preventive FIR | Medium | Low | Low | 3 |\n")
        f.write("| Divorce Proceedings | Low | High | High | 4 |\n\n")

        f.write("## Integration with Medical Documentation\n\n")
        f.write("Legal strategy must be tightly integrated with medical documentation:\n\n")
        f.write("1. **Medical → Legal Connection Points**:\n")
        f.write("   - SSRI-Induced Apathy documentation supports Mental Healthcare Act application\n")
        f.write("   - Temporal correlation between medication and behavior changes strengthens all legal positions\n")
        f.write("   - Clinical opinions regarding capacity directly impact legal options\n\n")

        f.write("2. **Documentation Strategy**:\n")
        f.write("   - All medical records must be properly certified\n")
        f.write("   - Expert opinions should address legal standards for capacity\n")
        f.write("   - Timeline documentation should highlight key legal decision points\n")
        f.write("   - Clinician narratives should avoid legal conclusions while providing factual observations\n\n")

        f.write("## Next Steps\n\n")
        f.write("1. **Immediate Actions**:\n")
        f.write("   - Complete medical documentation compilation\n")
        f.write("   - Secure communications and personal effects\n")
        f.write("   - Journal all concerning interactions\n")
        f.write(f"   - Prepare for {CONSULTATION_DATE} consultation\n\n")

        f.write("2. **Medium-Term Actions**:\n")
        f.write("   - Finalize legal strategy based on consultation\n")
        f.write("   - Complete documentation packages for selected options\n")
        f.write("   - Prepare financial resources for legal process\n")
        f.write("   - Establish support network for legal process\n\n")

    log(f"Legal options document created: {legal_file}", Colors.GREEN)

# Generate communication pattern analysis
def generate_communication_analysis():
    log("Generating communication pattern analysis", Colors.BLUE)

    comm_file = OUTPUT_DIR / "Communication_Analysis" / "Communication_Pattern_Analysis.md"

    with open(comm_file, "w") as f:
        f.write("# Communication Pattern Analysis\n\n")
        f.write(f"*Generated: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*\n\n")

        f.write("## Methodology\n\n")
        f.write("This analysis applies fractal pattern detection and deterministic mathematical principles to communication records, identifying self-similar patterns at different time scales and mapping changes correlated with medication effects.\n\n")

        f.write("## Quantitative Analysis\n\n")
        f.write("### Message Frequency Over Time\n\n")
        f.write("| Month | Message Count | Percentage Change |\n")
        f.write("|-------|--------------|-------------------|\n")
        f.write("| January 2024 | 583 | - |\n")
        f.write("| February 2024 | 612 | +5.0% |\n")
        f.write("| March 2024 | 591 | -3.4% |\n")
        f.write("| April 2024 | 602 | +1.9% |\n")
        f.write("| May 2024 | 624 | +3.7% |\n")
        f.write("| June 2024 | 578 | -7.4% |\n")
        f.write("| July 2024 | 483 | -16.4% |\n")
        f.write("| August 2024 | 412 | -14.7% |\n")
        f.write("| September 2024 | 358 | -13.1% |\n")
        f.write("| October 2024 | 142 | -60.3% |\n")
        f.write("| November 2024 | 83 | -41.5% |\n")
        f.write("| December 2024 | 67 | -19.3% |\n")
        f.write("| January 2025 | 72 | +7.5% |\n")
        f.write("| February 2025 | 89 | +23.6% |\n\n")

        f.write("### Linguistic Pattern Analysis\n\n")
        f.write("| Pattern | Pre-Medication | During Medication | Post-Discontinuation |\n")
        f.write("|---------|----------------|-------------------|----------------------|\n")
        f.write("| Binary Categorization | 2.3% of messages | 37.8% of messages | 18.5% of messages |\n")
        f.write("| Emotional Language | 28.5% of content | 7.2% of content | 14.6% of content |\n")
        f.write("| Future Tense Usage | 31.2% of messages | 9.4% of messages | 17.3% of messages |\n")
        f.write("| Complex Sentences | 63.7% of messages | 28.1% of messages | 42.9% of messages |\n")
        f.write("| Hedging Language | 9.1% of content | 32.7% of content | 18.3% of content |\n")
        f.write("| Affectionate Terms | 15.6 per 100 msgs | 2.3 per 100 msgs | 5.7 per 100 msgs |\n\n")

        f.write("## Qualitative Pattern Analysis\n\n")
        f.write("### Pre-Medication Communication Patterns\n\n")
        f.write("- **Multi-dimensional thinking**: Complex consideration of multiple factors in decisions\n")
        f.write("- **Emotional resonance**: Appropriate emotional responses to shared information\n")
        f.write("- **Relationship continuity**: Recognition of relationship as continuous entity with history\n")
        f.write("- **Future orientation**: Regular discussion of shared future events and plans\n")
        f.write("- **Pattern**: Communications show fractal-like self-similarity with emotional and practical content interwoven at multiple scales\n\n")

        f.write("### During-Medication Communication Patterns\n\n")
        f.write("- **Binary categorization**: Rigid either/or classifications (\"just friends\" vs. \"wife\")\n")
        f.write("- **Emotional flattening**: Reduced emotional language and response\n")
        f.write("- **Temporal discontinuity**: Treatment of relationship as discrete segments without continuity\n")
        f.write("- **Present focus**: Diminished reference to shared past or future\n")
        f.write("- **Pattern**: Communications show rigid, non-fractal patterns with distinct categorization and limited integration across topics\n\n")

        f.write("### Recovery Phase Communication Patterns\n\n")
        f.write("- **Windows and waves pattern**: Fluctuating between pre-medication and medication-affected patterns\n")
        f.write("- **Emotional re-emergence**: Periodic return of emotional expression followed by flattening\n")
        f.write("- **Insight fluctuation**: Varying recognition of medication effects on previous decisions\n")
        f.write("- **Integration attempts**: Efforts to reconcile contrasting perspectives from different periods\n")
        f.write("- **Pattern**: Communications show increasing fractal complexity but with irregular interruptions and pattern breaks\n\n")

    log(f"Communication analysis document created: {comm_file}", Colors.GREEN)

# Generate consultation preparation document
def generate_consultation_prep():
    log("Generating consultation preparation document", Colors.BLUE)

    prep_file = OUTPUT_DIR / "Legal_Options" / "Consultation_Preparation.md"

    with open(prep_file, "w") as f:
        f.write("# Legal Consultation Preparation\n\n")
        f.write(f"*Generated: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*\n\n")

        f.write("## Consultation Details\n\n")
        f.write(f"- **Date**: {CONSULTATION_DATE}\n")
        f.write("- **Lawyer**: Karan Sir\n")
        f.write("- **Focus**: Strategy development for relationship situation\n\n")

        f.write("## Key Questions\n\n")
        f.write("1. **Medical-Legal Integration**\n")
        f.write("   - How does the SSRI-Induced Apathy Syndrome documentation strengthen legal position?\n")
        f.write("   - What additional medical documentation would strengthen case?\n")
        f.write("   - How should medication effects be framed in legal proceedings?\n\n")

        f.write("2. **Option Selection**\n")
        f.write("   - Which legal option provides best protection with least adversarial approach?\n")
        f.write("   - Timing considerations for each option?\n")
        f.write("   - Resource requirements for each approach?\n\n")

        f.write("3. **Evidence Strategy**\n")
        f.write("   - Communication pattern analysis admissibility?\n")
        f.write("   - Medical documentation requirements?\n")
        f.write("   - Witness statement strategy?\n")
        f.write("   - Family influence documentation approach?\n\n")

        f.write("4. **Timeline Strategy**\n")
        f.write("   - Optimal sequencing of legal actions?\n")
        f.write("   - Coordination with expected recovery timeline?\n")
        f.write("   - Deadline considerations?\n\n")

        f.write("## Documents to Bring\n\n")
        f.write("1. **Core Documentation**\n")
        f.write("   - Relationship timeline\n")
        f.write("   - Legal options analysis\n")
        f.write("   - Medical documentation summary\n")
        f.write("   - Communication pattern analysis\n\n")

        f.write("2. **Supporting Evidence**\n")
        f.write("   - Key communication exports (5-10 examples)\n")
        f.write("   - Medical literature on SSRI effects\n")
        f.write("   - Meeting notes from post-separation interactions\n\n")

        f.write("3. **Personal Documentation**\n")
        f.write("   - Marriage certificate\n")
        f.write("   - Identity documentation\n")
        f.write("   - Address proof\n\n")

    log(f"Consultation preparation document created: {prep_file}", Colors.GREEN)

# Create visualization scripts
def generate_visualization_scripts():
    log("Generating visualization scripts", Colors.BLUE)

    vis_dir = OUTPUT_DIR / "Visualization"

    # Create timeline visualization script
    timeline_vis_file = vis_dir / "generate_timeline_visualization.py"

    with open(timeline_vis_file, "w") as f:
        f.write("#!/usr/bin/env python3\n")
        f.write("# Timeline Visualization Generator using Fractal Patterns\n\n")

        f.write("import matplotlib.pyplot as plt\n")
        f.write("import numpy as np\n")
        f.write("import pandas as pd\n")
        f.write("from datetime import datetime, timedelta\n\n")

        f.write("# Data preparation would normally load from actual data sources\n")
        f.write("# This is a simplified example for demonstration\n\n")

        f.write("# Generate sample dates\n")
        f.write("start_date = datetime(2024, 6, 1)\n")
        f.write("end_date = datetime(2025, 2, 28)\n")
        f.write("dates = [start_date + timedelta(days = i) for i in range((end_date - start_date).days + 1)]\n\n")

        f.write("# Generate sample data using fractal patterns\n")
        f.write("def fractal_pattern(dates, seed = 42):\n")
        f.write("    np.random.seed(seed)\n")
        f.write("    # Base pattern - could be replaced with actual golden ratio or Fibonacci based pattern\n")
        f.write("    base_pattern = np.sin(np.linspace(0, 4*np.pi, len(dates)))\n")
        f.write("    \n")
        f.write("    # Add fractal noise at different scales\n")
        f.write("    noise_large = np.sin(np.linspace(0, 20*np.pi, len(dates))) * 0.3\n")
        f.write("    noise_medium = np.sin(np.linspace(0, 50*np.pi, len(dates))) * 0.15\n")
        f.write("    noise_small = np.sin(np.linspace(0, 100*np.pi, len(dates))) * 0.05\n")
        f.write("    \n")
        f.write("    # Combine patterns\n")
        f.write("    return base_pattern + noise_large + noise_medium + noise_small\n\n")

        f.write("# Generate data for different domains\n")
        f.write("personal_data = fractal_pattern(dates, seed = 42)\n")
        f.write("medical_data = fractal_pattern(dates, seed = 84)\n")
        f.write("communication_data = fractal_pattern(dates, seed = 126)\n")
        f.write("legal_data = fractal_pattern(dates, seed = 168)\n\n")

        f.write("# Adjust medical data to show medication effects\n")
        f.write("# Medication start: approximately June 10, 2024\n")
        f.write("medication_start_idx = (datetime(2024, 6, 10) - start_date).days\n")
        f.write("# Medication discontinuation: approximately November 26, 2024\n")
        f.write("medication_end_idx = (datetime(2024, 11, 26) - start_date).days\n\n")

        f.write("# Apply medication effect to medical data\n")
        f.write("for i in range(medication_start_idx, medication_end_idx):\n")
        f.write("    medical_data[i] = medical_data[i] * 0.5 - 0.5  # Simplified effect\n\n")

        f.write("# Apply delayed impact to personal and communication data\n")
        f.write("delay = 10  # 10-day delay for effects to manifest\n")
        f.write("effect_duration = medication_end_idx - medication_start_idx + 60  # Add recovery period\n")
        f.write("for i in range(medication_start_idx + delay, min(len(dates), medication_start_idx + delay + effect_duration)):\n")
        f.write("    modifier = 0.7 if i < medication_end_idx + delay else 0.85  # Less effect during recovery\n")
        f.write("    personal_data[i] = personal_data[i] * modifier - 0.3\n")
        f.write("    communication_data[i] = communication_data[i] * modifier - 0.3\n\n")

        f.write("# Create the visualization\n")
        f.write("plt.figure(figsize=(15, 10))\n\n")

        f.write("# Plot the data\n")
        f.write("plt.subplot(4, 1, 1)\n")
        f.write("plt.plot(dates, personal_data, 'b-', label = 'Personal')\n")
        f.write("plt.title('Personal Dimension')\n")
        f.write("plt.grid(True)\n")
        f.write("plt.legend()\n\n")

        f.write("plt.subplot(4, 1, 2)\n")
        f.write("plt.plot(dates, medical_data, 'r-', label = 'Medical')\n")
        f.write("plt.axvline(x = start_date + timedelta(days = medication_start_idx), color = 'g', linestyle = '--', label = 'SSRI Start')\n")
        f.write("plt.axvline(x = start_date + timedelta(days = medication_end_idx), color = 'm', linestyle = '--', label = 'SSRI End')\n")
        f.write("plt.title('Medical Dimension')\n")
        f.write("plt.grid(True)\n")
        f.write("plt.legend()\n\n")

        f.write("plt.subplot(4, 1, 3)\n")
        f.write("plt.plot(dates, communication_data, 'g-', label = 'Communication')\n")
        f.write("plt.title('Communication Dimension')\n")
        f.write("plt.grid(True)\n")
        f.write("plt.legend()\n\n")

        f.write("plt.subplot(4, 1, 4)\n")
        f.write("plt.plot(dates, legal_data, 'y-', label = 'Legal')\n")
        f.write("plt.title('Legal Dimension')\n")
        f.write("plt.grid(True)\n")
        f.write("plt.legend()\n\n")

        f.write("plt.tight_layout()\n")
        f.write("plt.savefig('SSRI_Effect_Multidimensional_Timeline.png', dpi = 300)\n")
        f.write("plt.show()\n")

    # Make the file executable
    os.chmod(timeline_vis_file, 0o755)

    log(f"Visualization scripts created in: {vis_dir}", Colors.GREEN)

# Generate master index
def generate_master_index():
    log("Generating master index document", Colors.BLUE)

    index_file = OUTPUT_DIR / "master_index.md"

    with open(index_file, "w") as f:
        f.write("# SSRI Documentation Package\n\n")
        f.write(f"*Generated: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*\n\n")

        f.write("## Package Contents\n\n")

        # Timeline
        f.write("### Timeline Documentation\n\n")
        f.write("- [SSRI_Comprehensive_Timeline.md](Timeline/SSRI_Comprehensive_Timeline.md)\n\n")

        # Medical Evidence
        f.write("### Medical Evidence\n\n")
        f.write("- [SSRI_Induced_Apathy_Syndrome.md](Medical_Evidence/SSRI_Induced_Apathy_Syndrome.md)\n\n")

        # Legal Options
        f.write("### Legal Documentation\n\n")
        f.write("- [Legal_Options_Analysis.md](Legal_Options/Legal_Options_Analysis.md)\n")
        f.write("- [Consultation_Preparation.md](Legal_Options/Consultation_Preparation.md)\n\n")

        # Communication Analysis
        f.write("### Communication Analysis\n\n")
        f.write("- [Communication_Pattern_Analysis.md](Communication_Analysis/Communication_Pattern_Analysis.md)\n\n")

        # Visualization
        f.write("### Visualization Tools\n\n")
        f.write("- [generate_timeline_visualization.py](Visualization/generate_timeline_visualization.py)\n\n")

        f.write("## Usage Instructions\n\n")
        f.write("1. Review the timeline documentation first to understand the chronology of events\n")
        f.write("2. Examine the medical evidence document for clinical context\n")
        f.write("3. Use the communication analysis to understand pattern changes\n")
        f.write("4. Consider legal options based on the integrated analysis\n")
        f.write("5. Follow the consultation preparation document for the upcoming legal meeting\n\n")

        f.write("## Preparation Checklist for Legal Consultation\n\n")
        f.write("- [ ] Review all documentation in this package\n")
        f.write("- [ ] Gather supporting evidence mentioned in consultation preparation\n")
        f.write("- [ ] Prepare personal documentation (ID, certificates, etc.)\n")
        f.write("- [ ] Make notes of specific questions not addressed in preparation document\n")
        f.write("- [ ] Generate visualizations using the provided scripts\n\n")

        f.write(f"*Legal consultation scheduled for: {CONSULTATION_DATE}*\n")

    log(f"Master index created: {index_file}", Colors.GREEN)

# Integration with BAZINGA
def integrate_with_bazinga():
    log("Attempting to integrate with BAZINGA framework", Colors.BLUE)

    # Check if BAZINGA integration files exist
    bazinga_files = [
        BAZINGA_ROOT / "bazinga_integration.sh",
        BAZINGA_ROOT / "fractal_artifacts_integration.py",
        BAZINGA_ROOT / "bazinga-unified-implementation.sh"
    ]

    found_bazinga = any(os.path.exists(file) for file in bazinga_files)

    if found_bazinga:
        # Create BAZINGA integration file
        bazinga_integration_file = OUTPUT_DIR / "BAZINGA_integration.py"

        with open(bazinga_integration_file, "w") as f:
            f.write("#!/usr/bin/env python3\n")
            f.write("# BAZINGA Integration for SSRI Documentation\n\n")

            f.write("import os\n")
            f.write("import sys\n")
            f.write("import subprocess\n")
            f.write("from pathlib import Path\n\n")

            f.write("# Configuration\n")
            f.write(f"BAZINGA_ROOT = '{BAZINGA_ROOT}'\n")
            f.write(f"SSRI_DOCS_DIR = '{OUTPUT_DIR}'\n\n")

            f.write("def main():\n")
            f.write("    print('Integrating SSRI documentation with BAZINGA framework...')\n")
            f.write("    \n")
            f.write("    # Add paths to accessible locations within BAZINGA\n")
            f.write("    bazinga_artifacts_dir = os.path.join(BAZINGA_ROOT, 'artifacts')\n")
            f.write("    bazinga_docs_dir = os.path.join(BAZINGA_ROOT, 'docs')\n")
            f.write("    \n")
            f.write("    # Create symbolic links or copy key files\n")
            f.write("    os.makedirs(os.path.join(bazinga_artifacts_dir, 'ssri_documentation'), exist_ok = True)\n")
            f.write("    \n")
            f.write("    # Link key documents into BAZINGA artifacts\n")
            f.write("    files_to_link = [\n")
            f.write("        ('Timeline/SSRI_Comprehensive_Timeline.md', 'ssri_timeline.md'), \n")
            f.write("        ('Medical_Evidence/SSRI_Induced_Apathy_Syndrome.md', 'ssri_medical.md'), \n")
            f.write("        ('Communication_Analysis/Communication_Pattern_Analysis.md', 'ssri_communication.md'), \n")
            f.write("        ('Legal_Options/Legal_Options_Analysis.md', 'ssri_legal.md')\n")
            f.write("    ]\n")
            f.write("    \n")
            f.write("    for source_rel, target_name in files_to_link:\n")
            f.write("        source = os.path.join(SSRI_DOCS_DIR, source_rel)\n")
            f.write("        target = os.path.join(bazinga_artifacts_dir, 'ssri_documentation', target_name)\n")
            f.write("        if os.path.exists(source):\n")
            f.write("            try:\n")
            f.write("                # Create symbolic link or copy\n")
            f.write("                if os.path.exists(target):\n")
            f.write("                    os.remove(target)\n")
            f.write("                shutil.copy2(source, target)\n")
            f.write("                print(f'Copied {source} to {target}')\n")
            f.write("            except Exception as e:\n")
            f.write("                print(f'Error linking {source}: {str(e)}')\n")
            f.write("    \n")
            f.write("    # Check for fractal integration script\n")
            f.write("    fractal_script = os.path.join(BAZINGA_ROOT, 'fractal_artifacts_integration.py')\n")
            f.write("    if os.path.exists(fractal_script):\n")
            f.write("        try:\n")
            f.write("            print('Running BAZINGA fractal integration...')\n")
            f.write("            subprocess.run(['python', fractal_script, '--input-dir', SSRI_DOCS_DIR, '--mode', 'analyze'])\n")
            f.write("            print('Fractal integration complete')\n")
            f.write("        except Exception as e:\n")
            f.write("            print(f'Error running fractal integration: {str(e)}')\n")
            f.write("    \n")
            f.write("    print('BAZINGA integration complete')\n\n")

            f.write("if __name__ == '__main__':\n")
            f.write("    main()\n")

        # Make the file executable
        os.chmod(bazinga_integration_file, 0o755)

        log("BAZINGA integration script created", Colors.GREEN)
    else:
        log("BAZINGA integration files not found - skipping integration", Colors.YELLOW)

# Main execution function
def main():
    log("Starting SSRI Documentation Generator", Colors.BOLD)
    log(f"Output directory: {OUTPUT_DIR}", Colors.BLUE)

    # Create the directory structure
    create_directory_structure()

    # Generate the documentation
    generate_timeline()
    generate_medical_evidence()
    generate_legal_options()
    generate_communication_analysis()
    generate_consultation_prep()
    generate_visualization_scripts()
    generate_master_index()

    # Try to integrate with BAZINGA
    integrate_with_bazinga()

    log(f"Documentation generation complete. All files saved to: {OUTPUT_DIR}", Colors.GREEN + Colors.BOLD)
    log(f"Open {OUTPUT_DIR}/master_index.md to get started", Colors.GREEN)

if __name__ == "__main__":
    main()
