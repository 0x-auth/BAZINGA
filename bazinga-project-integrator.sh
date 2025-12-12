#!/bin/bash

# BAZINGA Project Integrator
# This script discovers, analyzes, and connects your various BAZINGA-related projects
# It helps identify patterns across projects and creates a unified index

# Colors for better output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}=====================================================${NC}"
echo -e "${GREEN}             BAZINGA PROJECT INTEGRATOR             ${NC}"
echo -e "${BLUE}=====================================================${NC}"
echo -e "Discovering and connecting your BAZINGA ecosystem\n"

# Create directory for the integrator if it doesn't exist
INTEGRATOR_DIR="$HOME/bazinga-integrator"
mkdir -p "$INTEGRATOR_DIR"
mkdir -p "$INTEGRATOR_DIR/patterns"
mkdir -p "$INTEGRATOR_DIR/connections"
mkdir -p "$INTEGRATOR_DIR/insights"

# Discover BAZINGA projects
echo -e "${YELLOW}Scanning for BAZINGA-related projects...${NC}"

# Start with known directories
SEARCH_DIRS=(
  "$HOME/GolandProjects"
  "$HOME/AmsyPycharm"
  "$HOME/BAZINGA"
)

# Store discovered projects
discovered_projects=()

for dir in "${SEARCH_DIRS[@]}"; do
  if [ -d "$dir" ]; then
    echo -e "Scanning $dir"
    # Find directories that might be BAZINGA-related
    for project in $(find "$dir" -type d -maxdepth 2 \( -name "*bazinga*" -o -name "*healing*" -o -name "*dodo*" -o -name "*relationship*" -o -name "*quantum*" -o -name "*analysis*" \) 2>/dev/null); do
      if [ -d "$project" ]; then
        echo -e "  ${GREEN}Found${NC}: $project"
        discovered_projects+=("$project")
      fi
    done
  fi
done

total_projects=${#discovered_projects[@]}
echo -e "\n${GREEN}Discovered $total_projects BAZINGA-related projects${NC}"

# Analyze projects for common patterns
echo -e "\n${YELLOW}Analyzing projects for common patterns...${NC}"

# Pattern identifiers
declare -A pattern_counts
pattern_identifiers=(
  "5.1.1.2.3.4.5"  # DODO pattern
  "4.1.1.3.5.2.4"  # BAZINGA core pattern
  "healing space"
  "quantum relationship"
  "trust dimension"
  "time dimension"
)

# Check patterns
for project in "${discovered_projects[@]}"; do
  project_name=$(basename "$project")
  echo -e "${BLUE}Analyzing${NC}: $project_name"
  
  # Create project analysis file
  analysis_file="$INTEGRATOR_DIR/patterns/$project_name.json"
  
  # Initialize JSON structure
  echo "{" > "$analysis_file"
  echo "  \"name\": \"$project_name\"," >> "$analysis_file"
  echo "  \"path\": \"$project\"," >> "$analysis_file"
  echo "  \"patterns\": {" >> "$analysis_file"
  
  # Check each pattern
  pattern_found=false
  first_pattern=true
  
  for pattern in "${pattern_identifiers[@]}"; do
    pattern_count=$(find "$project" -type f -name "*.md" -o -name "*.py" -o -name "*.js" -o -name "*.html" -o -name "*.go" -o -name "*.sh" 2>/dev/null | xargs grep -l "$pattern" 2>/dev/null | wc -l)
    
    # Skip if pattern not found
    if [ "$pattern_count" -eq 0 ]; then
      continue
    fi
    
    pattern_found=true
    if [ "$first_pattern" = true ]; then
      first_pattern=false
    else
      echo "," >> "$analysis_file"
    fi
    
    sanitized_pattern=$(echo "$pattern" | tr -d '.')
    echo "    \"$sanitized_pattern\": $pattern_count" >> "$analysis_file"
    
    # Track global pattern counts
    if [ -z "${pattern_counts[$pattern]}" ]; then
      pattern_counts[$pattern]=0
    fi
    pattern_counts[$pattern]=$((pattern_counts[$pattern] + pattern_count))
  done
  
  # Close JSON structure
  echo "  }" >> "$analysis_file"
  echo "}" >> "$analysis_file"
  
  if [ "$pattern_found" = true ]; then
    echo -e "  ${GREEN}Found BAZINGA patterns${NC}"
  else
    echo -e "  ${RED}No matching patterns${NC}"
  fi
done

# Generate summary
echo -e "\n${YELLOW}Generating pattern summary...${NC}"
summary_file="$INTEGRATOR_DIR/pattern_summary.json"

echo "{" > "$summary_file"
echo "  \"total_projects\": $total_projects," >> "$summary_file"
echo "  \"analyzed_timestamp\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\"," >> "$summary_file"
echo "  \"pattern_distribution\": {" >> "$summary_file"

first_pattern=true
for pattern in "${!pattern_counts[@]}"; do
  if [ "$first_pattern" = true ]; then
    first_pattern=false
  else
    echo "," >> "$summary_file"
  fi
  
  sanitized_pattern=$(echo "$pattern" | tr -d '.')
  echo "    \"$sanitized_pattern\": ${pattern_counts[$pattern]}" >> "$summary_file"
done

echo "  }" >> "$summary_file"
echo "}" >> "$summary_file"

# Identify potential connections between projects
echo -e "\n${YELLOW}Identifying connections between projects...${NC}"

# Map projects to create a network
network_file="$INTEGRATOR_DIR/project_network.json"

echo "{" > "$network_file"
echo "  \"nodes\": [" >> "$network_file"

# Add nodes (projects)
first_node=true
for project in "${discovered_projects[@]}"; do
  project_name=$(basename "$project")
  
  if [ "$first_node" = true ]; then
    first_node=false
  else
    echo "," >> "$network_file"
  fi
  
  echo "    {" >> "$network_file"
  echo "      \"id\": \"$project_name\"," >> "$network_file"
  echo "      \"path\": \"$project\"" >> "$network_file"
  echo "    }" >> "$network_file"
done

echo "  ]," >> "$network_file"
echo "  \"links\": [" >> "$network_file"

# Add links (connections between projects)
link_count=0

for ((i=0; i<${#discovered_projects[@]}; i++)); do
  for ((j=i+1; j<${#discovered_projects[@]}; j++)); do
    project1=${discovered_projects[$i]}
    project2=${discovered_projects[$j]}
    
    project1_name=$(basename "$project1")
    project2_name=$(basename "$project2")
    
    # Check for shared patterns or references
    connection_strength=0
    
    for pattern in "${pattern_identifiers[@]}"; do
      count1=$(find "$project1" -type f -name "*.md" -o -name "*.py" -o -name "*.js" -o -name "*.html" -o -name "*.go" -o -name "*.sh" 2>/dev/null | xargs grep -l "$pattern" 2>/dev/null | wc -l)
      count2=$(find "$project2" -type f -name "*.md" -o -name "*.py" -o -name "*.js" -o -name "*.html" -o -name "*.go" -o -name "*.sh" 2>/dev/null | xargs grep -l "$pattern" 2>/dev/null | wc -l)
      
      if [ "$count1" -gt 0 ] && [ "$count2" -gt 0 ]; then
        connection_strength=$((connection_strength + count1 + count2))
      fi
    done
    
    # Check for direct references
    ref1=$(find "$project1" -type f -name "*.md" -o -name "*.py" -o -name "*.js" -o -name "*.html" -o -name "*.go" -o -name "*.sh" 2>/dev/null | xargs grep -l "$project2_name" 2>/dev/null | wc -l)
    ref2=$(find "$project2" -type f -name "*.md" -o -name "*.py" -o -name "*.js" -o -name "*.html" -o -name "*.go" -o -name "*.sh" 2>/dev/null | xargs grep -l "$project1_name" 2>/dev/null | wc -l)
    
    connection_strength=$((connection_strength + ref1 + ref2))
    
    # Only include connections with strength > 0
    if [ "$connection_strength" -gt 0 ]; then
      if [ "$link_count" -gt 0 ]; then
        echo "," >> "$network_file"
      fi
      
      echo "    {" >> "$network_file"
      echo "      \"source\": \"$project1_name\"," >> "$network_file"
      echo "      \"target\": \"$project2_name\"," >> "$network_file"
      echo "      \"strength\": $connection_strength" >> "$network_file"
      echo "    }" >> "$network_file"
      
      link_count=$((link_count+1))
    fi
  done
done

echo "  ]" >> "$network_file"
echo "}" >> "$network_file"

# Generate insights file
echo -e "\n${YELLOW}Generating insights...${NC}"
insights_file="$INTEGRATOR_DIR/insights.md"

cat > "$insights_file" << EOL
# BAZINGA Project Ecosystem Insights

Analysis generated on $(date)

## Overview

This document provides insights into your BAZINGA project ecosystem based on automated analysis.

## Projects Discovered: $total_projects

The following BAZINGA-related projects were discovered:

EOL

for project in "${discovered_projects[@]}"; do
  project_name=$(basename "$project")
  echo "* **$project_name** - \`$project\`" >> "$insights_file"
done

cat >> "$insights_file" << EOL

## Pattern Distribution

The following BAZINGA patterns were identified across your projects:

EOL

for pattern in "${!pattern_counts[@]}"; do
  echo "* **$pattern**: ${pattern_counts[$pattern]} occurrences" >> "$insights_file"
done

cat >> "$insights_file" << EOL

## Project Connections

$link_count connections were identified between projects, based on shared patterns and direct references.

## Potential Integration Opportunities

Based on the analysis, here are some integration opportunities:

1. **Unified Pattern Library** - Create a centralized library of BAZINGA patterns that all projects can reference
2. **Shared Configuration System** - Implement a common configuration approach across projects
3. **Cross-Project Visualization** - Develop tools to visualize relationships between different BAZINGA components
4. **Documentation Standardization** - Establish consistent documentation practices across all projects

## Next Steps

1. Review the full analysis in the \`bazinga-integrator\` directory
2. Identify high-value integration points
3. Consider creating a unified project index
4. Explore opportunities to apply successful patterns across more projects
EOL

# Create a shell script to visualize the network
viz_script="$INTEGRATOR_DIR/visualize_network.html"

cat > "$viz_script" << 'EOL'
<!DOCTYPE html>
<html>
<head>
  <title>BAZINGA Project Network</title>
  <style>
    body { margin: 0; font-family: Arial, sans-serif; }
    #graph { width: 100%; height: 100vh; }
    .node { fill: #69b3a2; }
    .node:hover { fill: #28666e; }
    .link { stroke: #999; stroke-opacity: 0.6; }
  </style>
</head>
<body>
  <div id="graph"></div>
  
  <script src="https://d3js.org/d3.v7.min.js"></script>
  <script>
    // Load the network data
    fetch('project_network.json')
      .then(response => response.json())
      .then(data => createVisualization(data));
    
    function createVisualization(data) {
      const width = window.innerWidth;
      const height = window.innerHeight;
      
      const svg = d3.select("#graph")
        .append("svg")
        .attr("width", width)
        .attr("height", height);
      
      // Create a force simulation
      const simulation = d3.forceSimulation(data.nodes)
        .force("link", d3.forceLink(data.links).id(d => d.id).distance(100))
        .force("charge", d3.forceManyBody().strength(-300))
        .force("center", d3.forceCenter(width / 2, height / 2));
      
      // Draw links
      const link = svg.append("g")
        .selectAll("line")
        .data(data.links)
        .enter()
        .append("line")
        .attr("class", "link")
        .attr("stroke-width", d => Math.sqrt(d.strength));
      
      // Draw nodes
      const node = svg.append("g")
        .selectAll("circle")
        .data(data.nodes)
        .enter()
        .append("circle")
        .attr("class", "node")
        .attr("r", 8)
        .call(d3.drag()
          .on("start", dragstarted)
          .on("drag", dragged)
          .on("end", dragended));
      
      // Add labels
      const label = svg.append("g")
        .selectAll("text")
        .data(data.nodes)
        .enter()
        .append("text")
        .attr("dx", 12)
        .attr("dy", ".35em")
        .text(d => d.id);
      
      // Update positions on tick
      simulation.on("tick", () => {
        link
          .attr("x1", d => d.source.x)
          .attr("y1", d => d.source.y)
          .attr("x2", d => d.target.x)
          .attr("y2", d => d.target.y);
        
        node
          .attr("cx", d => d.x)
          .attr("cy", d => d.y);
        
        label
          .attr("x", d => d.x)
          .attr("y", d => d.y);
      });
      
      // Drag functions
      function dragstarted(event, d) {
        if (!event.active) simulation.alphaTarget(0.3).restart();
        d.fx = d.x;
        d.fy = d.y;
      }
      
      function dragged(event, d) {
        d.fx = event.x;
        d.fy = event.y;
      }
      
      function dragended(event, d) {
        if (!event.active) simulation.alphaTarget(0);
        d.fx = null;
        d.fy = null;
      }
    }
  </script>
</body>
</html>
EOL

# Create a consolidated README file
readme_file="$INTEGRATOR_DIR/README.md"

cat > "$readme_file" << EOL
# BAZINGA Project Integrator

This tool helps you discover, analyze, and connect your various BAZINGA-related projects.

## Contents

- \`patterns/\`: Analysis of BAZINGA patterns found in each project
- \`connections/\`: Identified connections between projects
- \`insights/\`: Generated insights and recommendations
- \`pattern_summary.json\`: Summary of pattern distribution across projects
- \`project_network.json\`: Network representation of project connections
- \`insights.md\`: Key insights and integration opportunities
- \`visualize_network.html\`: Interactive visualization of project connections

## Usage

1. Run the integrator again to update the analysis:
   \`\`\`
   ./bazinga-project-integrator.sh
   \`\`\`

2. View the insights document:
   \`\`\`
   open insights.md
   \`\`\`

3. Explore the network visualization:
   \`\`\`
   open visualize_network.html
   \`\`\`

## Integration Opportunities

See the \`insights.md\` file for identified integration opportunities between your BAZINGA projects.
EOL

# Copy this script to the integrator directory
cp "$0" "$INTEGRATOR_DIR/bazinga-project-integrator.sh"
chmod +x "$INTEGRATOR_DIR/bazinga-project-integrator.sh"

# Completion message
echo -e "\n${GREEN}BAZINGA Project Integrator has completed successfully!${NC}"
echo -e "Results are available in: ${BLUE}$INTEGRATOR_DIR${NC}"
echo -e "\nKey files:"
echo -e "- ${YELLOW}insights.md${NC}: Summary of findings and recommendations"
echo -e "- ${YELLOW}visualize_network.html${NC}: Interactive visualization of project connections"
echo -e "\nRun this script again anytime to update the analysis."
echo -e "${BLUE}=====================================================${NC}"
