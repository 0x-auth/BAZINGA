#!/bin/bash
# SSRI Documentation Tool Runner
# This script helps you quickly generate documentation about SSRI-induced apathy
# using the ssri-doc-gen.py tool shared with Claude

# Paths and settings - modify as needed
SCRIPT_PATH="$HOME/ssri-doc-gen.py"
OUTPUT_DIR="$HOME/ssri_documentation"
CONFIG_FILE="$HOME/ssri_config.json"

# Colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if the script exists
check_script() {
    if [ ! -f "$SCRIPT_PATH" ]; then
        echo -e "${RED}Error: Script not found at $SCRIPT_PATH${NC}"
        echo "Would you like to create it from your chat with Claude? (y/n)"
        read response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            create_script
        else
            echo "Please manually copy the script to $SCRIPT_PATH and run this tool again."
            exit 1
        fi
    else
        echo -e "${GREEN}Found script at $SCRIPT_PATH${NC}"
    fi
}

# Function to create the script from Claude chat
create_script() {
    echo -e "${BLUE}Creating script from Claude chat...${NC}"
    cat > "$SCRIPT_PATH" << 'EOF'
#!/usr/bin/env python3
# SSRI Apathy Syndrome Documentation Generator v2.0

import os
import json
import datetime
import argparse
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from fpdf import FPDF

class SSRIApathyDocumentation:
    def __init__(self, config_file=None):
        # Default configuration
        self.config = {
            "patient_name": "Amrita",
            "medication": "Sertraline",
            "dosage": "25mg",
            "start_date": "2024-03-15",  # Approximate date from documentation
            "discontinuation_date": "2024-11-26",  # From documentation
            "doctor": "Dr. Krishna Teja",
            "clinic": "Sukoon Clinic",
            "output_dir": "./ssri_documentation",
            "include_references": True,
            "include_visualizations": True
        }
        
        # Load custom configuration if provided
        if config_file and os.path.exists(config_file):
            try:
                with open(config_file, 'r') as f:
                    custom_config = json.load(f)
                    self.config.update(custom_config)
            except Exception as e:
                print(f"Error loading configuration: {e}")
        
        # Create output directory
        os.makedirs(self.config["output_dir"], exist_ok=True)
        
        # Initialize timeline data structure
        self.timeline_data = {
            "pre_ssri": [],
            "early_ssri": [],
            "middle_ssri": [],
            "late_ssri": [],
            "post_discontinuation": []
        }
        
        # Initialize symptom tracking
        self.symptom_data = {
            "emotional_blunting": [],
            "cognitive_changes": [],
            "behavioral_changes": [],
            "physical_symptoms": []
        }
        
        # Setup dates for analysis
        self.start_date = datetime.datetime.strptime(self.config["start_date"], "%Y-%m-%d").date()
        self.discontinuation_date = datetime.datetime.strptime(self.config["discontinuation_date"], "%Y-%m-%d").date()
        
        # Calculate key timeline points
        self.early_period_end = self.start_date + datetime.timedelta(days=90)  # 3 months
        self.middle_period_end = self.early_period_end + datetime.timedelta(days=90)  # 6 months

        # Rest of the initialization code...

    # Main method to generate the full documentation
    def generate_documentation(self):
        """Generate complete documentation including markdown and PDF"""
        # Populate with default data if needed
        if not any(self.timeline_data.values()):
            self.populate_default_timeline()
        
        if not any(self.symptom_data.values()):
            self.populate_default_symptoms()
        
        # Generate visualizations
        timeline_image = self.generate_timeline_visualization()
        symptom_image = self.generate_symptom_visualization()
        comparison_image = self.generate_meeting_comparison_visualization()
        recovery_image = self.generate_recovery_phase_visualization()
        
        # Generate markdown documentation
        md_file = self.generate_markdown_documentation()
        
        # Generate PDF documentation
        pdf_file = self.generate_pdf_documentation(
            timeline_image, symptom_image, comparison_image, recovery_image
        )
        
        return {
            "markdown": md_file,
            "pdf": pdf_file,
            "visualizations": {
                "timeline": timeline_image,
                "symptoms": symptom_image,
                "comparison": comparison_image,
                "recovery": recovery_image
            }
        }

    # Add these methods to implement the functionality based on your needs:
    # populate_default_timeline()
    # populate_default_symptoms()
    # generate_timeline_visualization()
    # generate_symptom_visualization()
    # generate_meeting_comparison_visualization()
    # generate_recovery_phase_visualization()
    # generate_markdown_documentation()
    # generate_pdf_documentation()


# If running directly
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate SSRI apathy syndrome documentation")
    parser.add_argument("-c", "--config", help="Path to configuration file")
    parser.add_argument("-o", "--output", help="Output directory")
    args = parser.parse_args()
    
    # Create documentation generator
    config_file = args.config
    doc_generator = SSRIApathyDocumentation(config_file)
    
    # Override output directory if specified
    if args.output:
        doc_generator.config["output_dir"] = args.output
    
    # Generate documentation
    output = doc_generator.generate_documentation()
    
    print(f"Documentation generated successfully!")
    print(f"Markdown: {output['markdown']}")
    print(f"PDF: {output['pdf']}")
    print(f"Visualizations: {len(output['visualizations'])} generated")
EOF
    chmod +x "$SCRIPT_PATH"
    echo -e "${GREEN}Script created at $SCRIPT_PATH${NC}"
}

# Function to create a default configuration
create_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo -e "${BLUE}Creating default configuration file...${NC}"
        cat > "$CONFIG_FILE" << EOF
{
    "patient_name": "Amrita",
    "medication": "Sertraline",
    "dosage": "25mg",
    "start_date": "2024-03-15",
    "discontinuation_date": "2024-11-26",
    "doctor": "Dr. Krishna Teja",
    "clinic": "Sukoon Clinic",
    "output_dir": "$OUTPUT_DIR",
    "include_references": true,
    "include_visualizations": true
}
EOF
        echo -e "${GREEN}Configuration file created at $CONFIG_FILE${NC}"
    else
        echo -e "${GREEN}Configuration file already exists at $CONFIG_FILE${NC}"
    fi
}

# Function to check dependencies
check_dependencies() {
    echo -e "${BLUE}Checking Python dependencies...${NC}"
    python3 -c "import pandas, numpy, matplotlib, fpdf" 2>/dev/null
    if [ $? -ne 0 ]; then
        echo -e "${YELLOW}Installing required Python packages...${NC}"
        pip3 install pandas numpy matplotlib fpdf
    else
        echo -e "${GREEN}All required Python packages are installed${NC}"
    fi
}

# Function to generate documentation
generate_documentation() {
    echo -e "${BLUE}Generating SSRI documentation...${NC}"
    mkdir -p "$OUTPUT_DIR"
    
    python3 "$SCRIPT_PATH" --config "$CONFIG_FILE" --output "$OUTPUT_DIR"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Documentation generated successfully!${NC}"
        echo -e "Output directory: ${YELLOW}$OUTPUT_DIR${NC}"
    else
        echo -e "${RED}Error generating documentation${NC}"
        exit 1
    fi
}

# Function to view documentation
view_documentation() {
    if [ -f "$OUTPUT_DIR/ssri_apathy_documentation.pdf" ]; then
        echo -e "${BLUE}Opening PDF documentation...${NC}"
        open "$OUTPUT_DIR/ssri_apathy_documentation.pdf" 2>/dev/null || \
        xdg-open "$OUTPUT_DIR/ssri_apathy_documentation.pdf" 2>/dev/null || \
        echo -e "${YELLOW}Could not open PDF automatically. Please open manually at:${NC} $OUTPUT_DIR/ssri_apathy_documentation.pdf"
    elif [ -f "$OUTPUT_DIR/ssri_apathy_documentation.md" ]; then
        echo -e "${BLUE}Opening Markdown documentation...${NC}"
        open "$OUTPUT_DIR/ssri_apathy_documentation.md" 2>/dev/null || \
        xdg-open "$OUTPUT_DIR/ssri_apathy_documentation.md" 2>/dev/null || \
        echo -e "${YELLOW}Could not open Markdown automatically. Please open manually at:${NC} $OUTPUT_DIR/ssri_apathy_documentation.md"
    else
        echo -e "${RED}No documentation found. Please generate it first.${NC}"
    fi
}

# Function to display the main menu
show_menu() {
    clear
    echo -e "${BLUE}======================================${NC}"
    echo -e "${BLUE}     SSRI Documentation Tool${NC}"
    echo -e "${BLUE}======================================${NC}"
    echo -e "1) Generate Documentation"
    echo -e "2) View Documentation"
    echo -e "3) Edit Configuration"
    echo -e "4) Exit"
    echo -e "${BLUE}======================================${NC}"
    echo -n "Enter your choice [1-4]: "
    read choice
    
    case $choice in
        1) check_script && check_dependencies && create_config && generate_documentation && view_documentation ;;
        2) view_documentation ;;
        3) nano "$CONFIG_FILE" ;;
        4) echo "Exiting..." && exit 0 ;;
        *) echo -e "${RED}Invalid choice${NC}" && sleep 2 && show_menu ;;
    esac
    
    echo -e "${BLUE}Press Enter to return to menu...${NC}"
    read
    show_menu
}

# Main execution
mkdir -p "$OUTPUT_DIR"
show_menu
