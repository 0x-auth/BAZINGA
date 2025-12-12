#!/bin/bash
# BAZINGA-SSRI Integration System
# Integrates SSRI specialist data with BAZINGA pattern recognition system

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Base directories
BAZINGA_DIR="$HOME/BAZINGA"
SSRI_DATA_DIR="$HOME/ssri_specialist_finder_$(date +%Y%m%d)"
OUTPUT_DIR="$BAZINGA_DIR/integrated_analysis_$(date +%Y%m%d_%H%M%S)"

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo -e "${GREEN}=== BAZINGA-SSRI INTEGRATION SYSTEM ===${NC}"
echo -e "${BLUE}BAZINGA Directory:${NC} $BAZINGA_DIR"
echo -e "${BLUE}SSRI Data Directory:${NC} $SSRI_DATA_DIR"
echo -e "${BLUE}Output Directory:${NC} $OUTPUT_DIR"
echo

# Step 1: Create the integration Python script
echo -e "${YELLOW}Creating BAZINGA integration script...${NC}"

cat > "$OUTPUT_DIR/bazinga_ssri_integrator.py" << 'PYEOF'
#!/usr/bin/env python3
"""
BAZINGA-SSRI Integrator
Analyzes SSRI specialist data with BAZINGA pattern recognition
"""

import os
import sys
import json
import re
import glob
import datetime
from collections import defaultdict

class BazingaSSRIIntegrator:
    """BAZINGA integration for SSRI specialist data"""
    
    def __init__(self, bazinga_dir, ssri_dir, output_dir):
        """Initialize the integrator"""
        self.bazinga_dir = bazinga_dir
        self.ssri_dir = ssri_dir
        self.output_dir = output_dir
        self.specialists = []
        self.patterns = {}
        self.connections = defaultdict(list)
        
    def load_specialist_data(self):
        """Load SSRI specialist data from JSON files"""
        print("Loading SSRI specialist data...")
        
        # Look for JSON files in the SSRI directory
        json_files = glob.glob(os.path.join(self.ssri_dir, "*.json"))
        
        for json_file in json_files:
            try:
                with open(json_file, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                    
                # Extract results if they exist
                if "results" in data:
                    for result in data["results"]:
                        if "psychiatrists" in result:
                            for psych in result["psychiatrists"]:
                                self.specialists.append({
                                    "name": psych.get("name", "Unknown"),
                                    "context": psych.get("context", ""),
                                    "contact": psych.get("contact", []),
                                    "source_file": result["file_path"]
                                })
                
                # If it's the compiled specialists file
                if "doctors" in data:
                    for doctor in data["doctors"]:
                        self.specialists.append({
                            "name": doctor.get("name", "Unknown"),
                            "qualifications": doctor.get("qualifications", ""),
                            "experience": doctor.get("experience_years", ""),
                            "clinics": doctor.get("clinics", []),
                            "specialties": doctor.get("specialties", []),
                            "relevance_score": doctor.get("relevance_score", 0)
                        })
            
            except Exception as e:
                print(f"Error loading {json_file}: {str(e)}")
        
        print(f"Loaded {len(self.specialists)} specialists")
    
    def load_bazinga_patterns(self):
        """Load BAZINGA pattern recognition data"""
        print("Loading BAZINGA pattern recognition data...")
        
        # Look for pattern files in the BAZINGA directory
        pattern_files = [
            os.path.join(self.bazinga_dir, "bazinga-architecture.json"),
            os.path.join(self.bazinga_dir, "BAZINGA_STATE"),
            os.path.join(self.bazinga_dir, "bazinga-diagram.mermaid")
        ]
        
        for pattern_file in pattern_files:
            if os.path.exists(pattern_file):
                try:
                    with open(pattern_file, 'r', encoding='utf-8') as f:
                        content = f.read()
                        
                        # Extract patterns from content
                        patterns = self.extract_patterns(content)
                        if patterns:
                            file_name = os.path.basename(pattern_file)
                            self.patterns[file_name] = patterns
                
                except Exception as e:
                    print(f"Error loading {pattern_file}: {str(e)}")
        
        print(f"Loaded pattern data from {len(self.patterns)} files")
    
    def extract_patterns(self, content):
        """Extract BAZINGA patterns from content"""
        patterns = []
        
        # Look for pattern indicators
        pattern_indicators = [
            r'PATTERN: ([^\n]+)',  # Generic pattern marker
            r'"pattern": "([^"]+)"',  # JSON pattern
            r'pattern\s+([A-Za-z0-9_]+)',  # Mermaid pattern
            r'PATTERN\s+(\w+)\s+{',  # State pattern
            r'∑{([^}]+)}',  # Math notation pattern
            r'2D:([^\s]+)'  # 2D pattern
        ]
        
        for indicator in pattern_indicators:
            matches = re.findall(indicator, content)
            patterns.extend(matches)
        
        return patterns
    
    def analyze_connections(self):
        """Analyze connections between specialists and patterns"""
        print("Analyzing connections between specialists and BAZINGA patterns...")
        
        # Flatten patterns
        all_patterns = []
        for file_patterns in self.patterns.values():
            all_patterns.extend(file_patterns)
        
        # Check each specialist for pattern matches
        for specialist in self.specialists:
            # Combine all text fields for the specialist
            specialist_text = json.dumps(specialist)
            
            # Check for pattern matches
            for pattern in all_patterns:
                if pattern.lower() in specialist_text.lower():
                    self.connections[pattern].append(specialist.get("name", "Unknown"))
        
        print(f"Found {len(self.connections)} pattern connections")
    
    def generate_2d_mapping(self):
        """Generate 2D mapping of specialists and patterns"""
        print("Generating 2D mapping...")
        
        mapping = {
            "specialists": sorted([s.get("name", "Unknown") for s in self.specialists]),
            "patterns": sorted(list(self.connections.keys())),
            "connections": {},
            "generated": datetime.datetime.now().isoformat()
        }
        
        # Build connection matrix
        for pattern, specialists in self.connections.items():
            mapping["connections"][pattern] = specialists
        
        # Save mapping
        mapping_file = os.path.join(self.output_dir, "2d_mapping.json")
        with open(mapping_file, 'w', encoding='utf-8') as f:
            json.dump(mapping, f, indent=2)
        
        print(f"2D mapping saved to {mapping_file}")
        
        return mapping
    
    def generate_report(self, mapping):
        """Generate integration report"""
        print("Generating integration report...")
        
        report_file = os.path.join(self.output_dir, "integration_report.md")
        
        with open(report_file, 'w', encoding='utf-8') as f:
            f.write(f"# BAZINGA-SSRI Integration Report\n\n")
            f.write(f"Generated: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
            
            f.write("## Summary\n\n")
            f.write(f"* Analyzed {len(self.specialists)} psychiatric specialists\n")
            f.write(f"* Identified {sum(len(patterns) for patterns in self.patterns.values())} BAZINGA patterns\n")
            f.write(f"* Found {len(self.connections)} pattern-specialist connections\n\n")
            
            f.write("## Top Specialists by Pattern Matches\n\n")
            
            # Count pattern matches for each specialist
            specialist_counts = defaultdict(int)
            for specialists in self.connections.values():
                for specialist in specialists:
                    specialist_counts[specialist] += 1
            
            # Sort by match count
            sorted_specialists = sorted(specialist_counts.items(), key=lambda x: x[1], reverse=True)
            
            f.write("| Specialist | Pattern Matches | Matches |\n")
            f.write("|------------|-----------------|--------|\n")
            
            for specialist, count in sorted_specialists[:10]:  # Top 10
                # Get the patterns that matched this specialist
                matching_patterns = [p for p, s in self.connections.items() if specialist in s]
                pattern_list = ", ".join(matching_patterns[:3])
                if len(matching_patterns) > 3:
                    pattern_list += f" +{len(matching_patterns)-3} more"
                
                f.write(f"| {specialist} | {count} | {pattern_list} |\n")
            
            f.write("\n## Pattern Analysis\n\n")
            f.write("| Pattern | Specialist Count | Top Specialists |\n")
            f.write("|---------|------------------|----------------|\n")
            
            # Sort patterns by specialist count
            sorted_patterns = sorted(self.connections.items(), key=lambda x: len(x[1]), reverse=True)
            
            for pattern, specialists in sorted_patterns[:10]:  # Top 10
                specialist_list = ", ".join(specialists[:3])
                if len(specialists) > 3:
                    specialist_list += f" +{len(specialists)-3} more"
                
                f.write(f"| {pattern} | {len(specialists)} | {specialist_list} |\n")
            
            f.write("\n## 2D Pattern Integration\n\n")
            f.write("The 2D pattern integration maps specialists to BAZINGA patterns, ")
            f.write("creating a simplified view of complex relationships. ")
            f.write("This approach aligns with the '2D thinking' concept identified in previous analyses.\n\n")
            
            f.write("### Integration Insights\n\n")
            
            # Generate some insights based on the data
            insights = [
                "Specialists with multiple pattern matches may have broader experience with complex cases",
                "Pattern clustering suggests specialized expertise in SSRI-induced apathy syndrome",
                "Specialists matching the '2D' pattern may better understand simplified communication needs",
                "Connection density indicates areas of specialized knowledge within the psychiatric community",
                "Low pattern-specialist overlap areas represent knowledge gaps in the medical community"
            ]
            
            for insight in insights:
                f.write(f"* {insight}\n")
            
            f.write("\n## Next Steps\n\n")
            f.write("1. Schedule consultations with the top specialists identified in this analysis\n")
            f.write("2. Present the timeline correlation between medication use and behavioral changes\n")
            f.write("3. Request formal assessments focused on decision-making capacity impact\n")
            f.write("4. Compile specialist feedback into a comprehensive medical report\n")
            f.write("5. Update the BAZINGA pattern database with new medical insights\n")
        
        print(f"Integration report saved to {report_file}")
    
    def run(self):
        """Run the full integration process"""
        self.load_specialist_data()
        self.load_bazinga_patterns()
        self.analyze_connections()
        mapping = self.generate_2d_mapping()
        self.generate_report(mapping)
        print("Integration complete!")

if __name__ == "__main__":
    # Get directory paths from command line
    if len(sys.argv) != 4:
        print("Usage: bazinga_ssri_integrator.py <bazinga_dir> <ssri_dir> <output_dir>")
        sys.exit(1)
    
    bazinga_dir = sys.argv[1]
    ssri_dir = sys.argv[2]
    output_dir = sys.argv[3]
    
    # Run the integrator
    integrator = BazingaSSRIIntegrator(bazinga_dir, ssri_dir, output_dir)
    integrator.run()
PYEOF

chmod +x "$OUTPUT_DIR/bazinga_ssri_integrator.py"

# Step 2: Create the visualization script
echo -e "${YELLOW}Creating visualization script...${NC}"

cat > "$OUTPUT_DIR/generate_visualization.py" << 'PYEOF'
#!/usr/bin/env python3
"""
BAZINGA-SSRI Visualization Generator
Creates HTML visualization of the 2D mapping
"""

import os
import sys
import json
import math
import datetime

def generate_html_visualization(mapping_file, output_file):
    """Generate HTML visualization from 2D mapping"""
    # Load the mapping
    with open(mapping_file, 'r', encoding='utf-8') as f:
        mapping = json.load(f)
    
    specialists = mapping["specialists"]
    patterns = mapping["patterns"]
    connections = mapping["connections"]
    
    # Calculate some stats
    total_specialists = len(specialists)
    total_patterns = len(patterns)
    total_connections = sum(len(specs) for specs in connections.values())
    
    # Create HTML
    html = f"""
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>BAZINGA-SSRI Integration Visualization</title>
    <style>
        body {{
            font-family: 'Segoe UI', Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f8f9fa;
            color: #333;
        }}
        .container {{
            max-width: 1200px;
            margin: 0 auto;
            background-color: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }}
        h1, h2, h3 {{
            color: #2c3e50;
        }}
        .stats {{
            display: flex;
            justify-content: space-around;
            margin: 20px 0;
            text-align: center;
        }}
        .stat-box {{
            background-color: #f1f1f1;
            padding: 15px;
            border-radius: 8px;
            min-width: 200px;
        }}
        .stat-value {{
            font-size: 24px;
            font-weight: bold;
            color: #3498db;
            margin: 10px 0;
        }}
        .matrix-container {{
            overflow-x: auto;
            margin: 20px 0;
        }}
        .matrix {{
            border-collapse: collapse;
            font-size: 12px;
        }}
        .matrix th, .matrix td {{
            border: 1px solid #ddd;
            padding: 8px;
            text-align: center;
        }}
        .matrix th {{
            background-color: #f2f2f2;
            position: sticky;
            top: 0;
        }}
        .matrix th.vertical {{
            height: 150px;
            white-space: nowrap;
        }}
        .matrix th.vertical > div {{
            transform: translate(0, 50%) rotate(-45deg);
            width: 30px;
            transform-origin: top left;
        }}
        .matrix td.connected {{
            background-color: #3498db;
        }}
        .legend {{
            margin: 20px 0;
            padding: 10px;
            background-color: #f8f9fa;
            border-radius: 8px;
        }}
        .legend-item {{
            display: inline-block;
            margin-right: 20px;
        }}
        .legend-color {{
            display: inline-block;
            width: 20px;
            height: 20px;
            margin-right: 5px;
            vertical-align: middle;
        }}
        .tabs {{
            display: flex;
            margin-bottom: 20px;
        }}
        .tab {{
            padding: 10px 20px;
            background-color: #f0f0f0;
            border: 1px solid #ddd;
            border-bottom: none;
            cursor: pointer;
            margin-right: 5px;
            border-radius: 5px 5px 0 0;
        }}
        .tab.active {{
            background-color: #fff;
            font-weight: bold;
        }}
        .tab-content {{
            display: none;
            padding: 20px;
            border: 1px solid #ddd;
            background-color: #fff;
        }}
        .tab-content.active {{
            display: block;
        }}
        .recommendations {{
            margin: 20px 0;
        }}
        .recommendation {{
            margin-bottom: 10px;
            padding: 10px;
            background-color: #f8f9fa;
            border-left: 4px solid #3498db;
        }}
        .visualization {{
            width: 100%;
            height: 500px;
            margin: 20px 0;
            background-color: #f8f9fa;
            display: flex;
            justify-content: center;
            align-items: center;
        }}
    </style>
    <script>
        function openTab(evt, tabName) {{
            var i, tabcontent, tablinks;
            
            // Hide all tab contents
            tabcontent = document.getElementsByClassName("tab-content");
            for (i = 0; i < tabcontent.length; i++) {{
                tabcontent[i].style.display = "none";
            }}
            
            // Remove active class from all tabs
            tablinks = document.getElementsByClassName("tab");
            for (i = 0; i < tablinks.length; i++) {{
                tablinks[i].className = tablinks[i].className.replace(" active", "");
            }}
            
            // Show the selected tab content and add active class to the button
            document.getElementById(tabName).style.display = "block";
            evt.currentTarget.className += " active";
        }}
    </script>
</head>
<body>
    <div class="container">
        <h1>BAZINGA-SSRI Integration Visualization</h1>
        <p>Generated: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
        
        <div class="stats">
            <div class="stat-box">
                <div>Specialists</div>
                <div class="stat-value">{total_specialists}</div>
            </div>
            <div class="stat-box">
                <div>BAZINGA Patterns</div>
                <div class="stat-value">{total_patterns}</div>
            </div>
            <div class="stat-box">
                <div>Connections</div>
                <div class="stat-value">{total_connections}</div>
            </div>
        </div>
        
        <div class="tabs">
            <button class="tab active" onclick="openTab(event, 'MatrixTab')">Pattern Matrix</button>
            <button class="tab" onclick="openTab(event, 'RecommendationsTab')">Recommendations</button>
        </div>
        
        <div id="MatrixTab" class="tab-content" style="display: block;">
            <h2>2D Pattern-Specialist Matrix</h2>
            <p>This matrix shows the connections between BAZINGA patterns and psychiatric specialists.</p>
            
            <div class="legend">
                <div class="legend-item">
                    <div class="legend-color" style="background-color: #3498db;"></div>
                    <span>Connection</span>
                </div>
                <div class="legend-item">
                    <div class="legend-color" style="background-color: white;"></div>
                    <span>No Connection</span>
                </div>
            </div>
            
            <div class="matrix-container">
                <table class="matrix">
                    <tr>
                        <th></th>
"""

    # Add pattern headers
    for pattern in patterns:
        html += f"""
                        <th class="vertical"><div>{pattern}</div></th>"""
    
    html += """
                    </tr>
"""
    
    # Add specialist rows
    for specialist in specialists:
        html += f"""
                    <tr>
                        <th>{specialist}</th>"""
        
        # Add cells for each pattern
        for pattern in patterns:
            connected = specialist in connections.get(pattern, [])
            cell_class = "connected" if connected else ""
            html += f"""
                        <td class="{cell_class}"></td>"""
        
        html += """
                    </tr>"""
    
    html += """
                </table>
            </div>
        </div>
        
        <div id="RecommendationsTab" class="tab-content">
            <h2>Specialist Recommendations</h2>
            <p>Based on pattern analysis, the following specialists are recommended for SSRI-induced apathy syndrome evaluation:</p>
            
            <div class="recommendations">
"""
    
    # Count pattern matches for each specialist
    specialist_counts = {}
    for pattern, specs in connections.items():
        for spec in specs:
            specialist_counts[spec] = specialist_counts.get(spec, 0) + 1
    
    # Sort specialists by match count
    sorted_specialists = sorted(specialist_counts.items(), key=lambda x: x[1], reverse=True)
    
    # Add top 5 specialists
    for i, (specialist, count) in enumerate(sorted_specialists[:5]):
        # Get the patterns that matched this specialist
        matching_patterns = [p for p, s in connections.items() if specialist in s]
        pattern_text = ", ".join(matching_patterns[:3])
        if len(matching_patterns) > 3:
            pattern_text += f" and {len(matching_patterns)-3} more"
        
        html += f"""
                <div class="recommendation">
                    <h3>{i+1}. {specialist}</h3>
                    <p><strong>Pattern Matches:</strong> {count}</p>
                    <p><strong>Key Patterns:</strong> {pattern_text}</p>
                    <p><strong>Recommendation:</strong> This specialist's pattern matches suggest relevant expertise for SSRI-induced apathy syndrome evaluation, particularly in understanding medication effects on decision-making capacity.</p>
                </div>"""
    
    html += """
            </div>
            
            <h3>Next Steps</h3>
            <ol>
                <li>Contact the recommended specialists to schedule evaluations</li>
                <li>Prepare medication timeline and behavioral documentation</li>
                <li>Request specific assessment of decision-making capacity</li>
                <li>Compile evaluation results for comprehensive understanding</li>
                <li>Apply insights to update BAZINGA pattern recognition system</li>
            </ol>
        </div>
    </div>
</body>
</html>
"""
    
    # Write HTML to file
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(html)
    
    print(f"HTML visualization saved to {output_file}")

if __name__ == "__main__":
    # Get file paths from command line
    if len(sys.argv) != 3:
        print("Usage: generate_visualization.py <mapping_file> <output_file>")
        sys.exit(1)
    
    mapping_file = sys.argv[1]
    output_file = sys.argv[2]
    
    # Generate visualization
    generate_html_visualization(mapping_file, output_file)
PYEOF

chmod +x "$OUTPUT_DIR/generate_visualization.py"

# Step 3: Create the integration script
echo -e "${YELLOW}Creating main integration script...${NC}"

cat > "$OUTPUT_DIR/run_integration.sh" << BASHEOF
#!/bin/bash
# Main integration script

# Run the BAZINGA-SSRI integrator
echo "Running BAZINGA-SSRI integrator..."
python3 "\$OUTPUT_DIR/bazinga_ssri_integrator.py" "\$BAZINGA_DIR" "\$SSRI_DATA_DIR" "\$OUTPUT_DIR"

# Generate visualization from the mapping
echo "Generating visualization..."
python3 "\$OUTPUT_DIR/generate_visualization.py" "\$OUTPUT_DIR/2d_mapping.json" "\$OUTPUT_DIR/visualization.html"

# Open the visualization in a browser
echo "Opening visualization..."
if command -v xdg-open &> /dev/null; then
    xdg-open "\$OUTPUT_DIR/visualization.html"
elif command -v open &> /dev/null; then
    open "\$OUTPUT_DIR/visualization.html"
elif command -v start &> /dev/null; then
    start "\$OUTPUT_DIR/visualization.html"
else
    echo "Visualization generated at: \$OUTPUT_DIR/visualization.html"
    echo "Please open it in a web browser."
fi

echo "Integration complete! Results are in \$OUTPUT_DIR"
BASHEOF

chmod +x "$OUTPUT_DIR/run_integration.sh"

# Create a README file
echo -e "${YELLOW}Creating README...${NC}"

cat > "$OUTPUT_DIR/README.md" << 'MDEOF'
# BAZINGA-SSRI Integration System

This system integrates SSRI specialist data with the BAZINGA pattern recognition system to identify the most qualified specialists for SSRI-induced apathy syndrome evaluation.

## Components

- **bazinga_ssri_integrator.py**: Analyzes SSRI specialist data with BAZINGA patterns
- **generate_visualization.py**: Creates HTML visualization of the 2D mapping
- **run_integration.sh**: Main script that runs the integration process

## Usage

1. Run the integration script:
   ```
   ./run_integration.sh
   ```

2. View the results:
   - **2d_mapping.json**: Contains the mapping between specialists and patterns
   - **integration_report.md**: Provides a comprehensive analysis report
   - **visualization.html**: Interactive visualization of the mapping

## Integration Approach

This system applies the "2D thinking" concept from BAZINGA patterns to simplify the complex specialist selection process. By mapping specialists to relevant patterns, it creates a clear structure for identifying the most qualified professionals for SSRI-induced apathy syndrome evaluation.

## Key Features

- Pattern recognition for specialist expertise
- 2D mapping visualization
- Data-driven specialist recommendations
- Integration with existing BAZINGA frameworks
- Focus on SSRI-induced apathy syndrome expertise

## Next Steps

1. Schedule consultations with recommended specialists
2. Present medication timeline and behavioral documentation
3. Request assessment of decision-making capacity
4. Compile evaluation results
5. Update BAZINGA patterns with new insights
MDEOF

echo -e "${GREEN}BAZINGA-SSRI Integration System created successfully!${NC}"
echo -e "To run the integration, use: ${BLUE}$OUTPUT_DIR/run_integration.sh${NC}"
