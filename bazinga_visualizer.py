#!/usr/bin/env python3
"""
BAZINGA Framework Pattern Visualizer
Generates SVG visualizations of recursive recognition patterns in the BAZINGA framework
"""

import os
import sys
import json
import random
import argparse
from datetime import datetime
from pathlib import Path

class BazingaVisualizer:
    """Visualizes the BAZINGA framework and its recursive pattern recognition system"""

    def __init__(self, base_dir = None, output_dir = None):
        """Initialize the visualizer with directory paths"""
        self.base_dir = base_dir or os.path.expanduser("~/AmsyPycharm/BAZINGA")
        self.output_dir = output_dir or os.path.join(self.base_dir, "generated")

        # Ensure output directory exists
        os.makedirs(self.output_dir, exist_ok = True)

        # Framework components categorized by type
        self.components = {
            "processor": [],
            "integration": [],
            "relationship": [],
            "quantum": [],
            "visualization": [],
            "other": []
        }

        # SVG configuration
        self.config = {
            "width": 800,
            "height": 600,
            "bg_gradient": ["#0a0a2a", "#1a1a4a"],
            "accent_color": "#4d54eb",
            "highlight_color": "#84fab0",
            "text_color": "#ffffff"
        }

    def scan_directory(self):
        """Scan the BAZINGA directory to find relevant files for visualization"""
        try:
            for root, dirs, files in os.walk(self.base_dir):
                for file in files:
                    if self._is_relevant_file(file):
                        rel_path = os.path.relpath(os.path.join(root, file), self.base_dir)
                        category = self._categorize_file(file)
                        self.components[category].append({
                            "name": file,
                            "path": rel_path,
                            "full_path": os.path.join(root, file)
                        })
        except Exception as e:
            print(f"Error scanning directory: {e}")
            return False

        return True

    def _is_relevant_file(self, filename):
        """Check if a file is relevant for the BAZINGA framework visualization"""
        keywords = ["bazinga", "quantum", "pattern", "relationship", "recursive",
                    "framework", "ψ", "dodo", "integration", "analysis"]

        filename_lower = filename.lower()
        return any(keyword in filename_lower for keyword in keywords)

    def _categorize_file(self, filename):
        """Categorize a file based on its name and extension"""
        filename_lower = filename.lower()

        if any(term in filename_lower for term in ["processor", "analyze", "engine"]):
            return "processor"
        elif any(term in filename_lower for term in ["integration", "connector", ".sh"]):
            return "integration"
        elif any(term in filename_lower for term in ["relation", "communicate", "interact"]):
            return "relationship"
        elif any(term in filename_lower for term in ["quantum", "ψ", "psi", "physics"]):
            return "quantum"
        elif any(term in filename_lower for term in ["visual", "svg", "render", "dashboard"]):
            return "visualization"
        else:
            return "other"

    def generate_svg(self):
        """Generate an SVG visualization of the BAZINGA framework"""
        timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
        output_path = os.path.join(self.output_dir, f"bazinga-visual-{timestamp}.svg")

        # Start with basic SVG elements
        svg = self._create_svg_header()

        # Add central hub
        svg += self._create_central_hub()

        # Add component nodes
        nodes = self._create_component_nodes()
        svg += nodes["elements"]

        # Add connections between nodes
        svg += self._create_connections(nodes["positions"])

        # Add recursive formula
        svg += self._create_recursive_formula()

        # Add path animation
        svg += self._create_path_animation()

        # Add info elements
        svg += self._create_info_elements()

        # Close SVG
        svg += "</svg>"

        # Write to file
        with open(output_path, "w") as file:
            file.write(svg)

        print(f"Generated SVG visualization at: {output_path}")
        return output_path

    def _create_svg_header(self):
        """Create the SVG header and definitions"""
        return f"""<svg xmlns = "http://www.w3.org/2000/svg" viewBox = "0 0 {self.config['width']} {self.config['height']}">
  <!-- Background with gradient -->
  <defs>
    <linearGradient id = "bg-gradient" x1 = "0%" y1 = "0%" x2 = "100%" y2 = "100%">
      <stop offset = "0%" stop-color = "{self.config['bg_gradient'][0]}" />
      <stop offset = "100%" stop-color = "{self.config['bg_gradient'][1]}" />
    </linearGradient>
    <filter id = "glow" height = "300%" width = "300%" x = "-100%" y = "-100%">
      <feGaussianBlur stdDeviation = "5" result = "blur" />
      <feColorMatrix in = "blur" mode = "matrix" values = "1 0 0 0 0  0 1 0 0 0  0 0 1 0 0  0 0 0 18 -7" result = "glow" />
      <feBlend in = "SourceGraphic" in2 = "glow" mode = "normal" />
    </filter>
    <!-- Connection path animation -->
    <path id = "connection-path" d = "M 50, 300 C 150, 150 350, 450 450, 300 S 650, 150 750, 300" />
    <linearGradient id = "connection-gradient" x1 = "0%" y1 = "0%" x2 = "100%" y2 = "0%">
      <stop offset = "0%" stop-color = "{self.config['accent_color']}" />
      <stop offset = "50%" stop-color = "{self.config['highlight_color']}" />
      <stop offset = "100%" stop-color = "{self.config['accent_color']}" />
    </linearGradient>
  </defs>

  <!-- Main background -->
  <rect width = "{self.config['width']}" height = "{self.config['height']}" fill = "url(#bg-gradient)" />

  <!-- Decorative grid lines -->
  <g stroke = "#ffffff20" stroke-width = "1">
    <line x1 = "0" y1 = "150" x2 = "{self.config['width']}" y2 = "150" />
    <line x1 = "0" y1 = "300" x2 = "{self.config['width']}" y2 = "300" />
    <line x1 = "0" y1 = "450" x2 = "{self.config['width']}" y2 = "450" />
    <line x1 = "{self.config['width']/4}" y1 = "0" x2 = "{self.config['width']/4}" y2 = "{self.config['height']}" />
    <line x1 = "{self.config['width']/2}" y1 = "0" x2 = "{self.config['width']/2}" y2 = "{self.config['height']}" />
    <line x1 = "{self.config['width']*3/4}" y1 = "0" x2 = "{self.config['width']*3/4}" y2 = "{self.config['height']}" />
  </g>
"""

    def _create_central_hub(self):
        """Create the central BAZINGA hub element"""
        cx = self.config['width'] / 2
        cy = self.config['height'] / 2

        return f"""  <!-- Central BAZINGA Framework Hub -->
  <circle cx = "{cx}" cy = "{cy}" r = "80" fill = "#2a2a6a" stroke = "{self.config['accent_color']}" stroke-width = "3" filter = "url(#glow)" />
  <text x = "{cx}" y = "{cy-10}" text-anchor = "middle" font-family = "Arial" font-size = "20" fill = "{self.config['text_color']}" font-weight = "bold">BAZINGA</text>
  <text x = "{cx}" y = "{cy+15}" text-anchor = "middle" font-family = "Arial" font-size = "14" fill = "{self.config['highlight_color']}">Quantum Framework</text>
"""

    def _create_component_nodes(self):
        """Create nodes for each component category"""
        elements = "  <!-- Component Nodes -->\n"
        positions = {}

        # Calculate center
        cx = self.config['width'] / 2
        cy = self.config['height'] / 2
        radius = 200  # Distance from center

        # Position the category groups around the central hub
        categories = list(self.components.keys())
        slice_angle = 2 * 3.14159 / len(categories)

        for i, category in enumerate(categories):
            # Skip empty categories
            if not self.components[category]:
                continue

            # Calculate group position
            angle = i * slice_angle
            group_x = cx + radius * 0.8 * (1 if i % 2 == 0 else 0.8) * round(0.8 * round(-(0 - 1) ** i * 0.7) - (0 - 1) ** i * 0.3, 1)
            group_y = cy + radius * 0.8 * (1 if i % 2 == 1 else 0.8) * round(0.8 * round(-(0 - 1) ** (i+1) * 0.7) - (0 - 1) ** (i+1) * 0.3, 1)

            # Store position
            positions[category] = {
                "x": group_x,
                "y": group_y,
                "components": []
            }

            # Category color
            color_map = {
                "processor": "#4d54eb",
                "integration": "#34b1eb",
                "relationship": "#eb4d88",
                "quantum": "#84fab0",
                "visualization": "#ebd74d",
                "other": "#9a9a9a"
            }
            color = color_map.get(category, self.config['accent_color'])

            # Create category node
            elements += f"""  <circle cx = "{group_x}" cy = "{group_y}" r = "40" fill = "#2a2a6a" stroke = "{color}" stroke-width = "2" filter = "url(#glow)" />
  <text x = "{group_x}" y = "{group_y}" text-anchor = "middle" font-family = "Arial" font-size = "14" fill = "{self.config['text_color']}">{category.capitalize()}</text>
"""

            # Add component nodes around category
            component_radius = 60  # Distance from category center
            comp_count = min(5, len(self.components[category]))  # Limit to 5 components
            comp_slice = 2 * 3.14159 / comp_count

            for j, component in enumerate(self.components[category][:comp_count]):
                comp_angle = j * comp_slice
                comp_x = group_x + component_radius * 0.6 * (1 if j % 2 == 0 else 0.8) * round(0.8 * round(-(0 - 1) ** j * 0.7) - (0 - 1) ** j * 0.3, 1)
                comp_y = group_y + component_radius * 0.6 * (1 if j % 2 == 1 else 0.8) * round(0.8 * round(-(0 - 1) ** (j+1) * 0.7) - (0 - 1) ** (j+1) * 0.3, 1)

                # Store component position
                positions[category]["components"].append({
                    "name": component["name"],
                    "x": comp_x,
                    "y": comp_y
                })

                # Truncate component name if too long
                display_name = component["name"]
                if len(display_name) > 15:
                    display_name = display_name[:12] + "..."

                # Create component node
                elements += f"""  <circle cx = "{comp_x}" cy = "{comp_y}" r = "25" fill = "#2a2a6a" stroke = "{color}" stroke-width = "2" />
  <text x = "{comp_x}" y = "{comp_y}" text-anchor = "middle" font-family = "Arial" font-size = "10" fill = "{self.config['text_color']}">{display_name}</text>
"""

        return {
            "elements": elements,
            "positions": positions
        }

    def _create_connections(self, positions):
        """Create connections between components"""
        elements = "  <!-- Connections -->\n"

        # Connect categories to central hub
        cx = self.config['width'] / 2
        cy = self.config['height'] / 2

        for category, pos in positions.items():
            elements += f"""  <path d = "M {cx}, {cy} L {pos['x']}, {pos['y']}" stroke = "{self.config['accent_color']}" stroke-width = "2" stroke-dasharray = "5, 3" />
"""

        # Connect components to their category
        for category, pos in positions.items():
            for component in pos["components"]:
                elements += f"""  <path d = "M {pos['x']}, {pos['y']} L {component['x']}, {component['y']}" stroke = "{self.config['accent_color']}" stroke-width = "1" stroke-dasharray = "3, 2" />
"""

        # Add a few cross-connections between components
        connections_added = 0
        categories = list(positions.keys())

        for _ in range(min(5, len(categories))):
            if len(categories) < 2:
                break

            cat1, cat2 = random.sample(categories, 2)

            if not positions[cat1]["components"] or not positions[cat2]["components"]:
                continue

            comp1 = random.choice(positions[cat1]["components"])
            comp2 = random.choice(positions[cat2]["components"])

            elements += f"""  <path d = "M {comp1['x']}, {comp1['y']} L {comp2['x']}, {comp2['y']}" stroke = "{self.config['highlight_color']}" stroke-width = "1" stroke-dasharray = "2, 4" opacity = "0.6" />
"""
            connections_added += 1

            if connections_added >= 3:
                break

        return elements

    def _create_recursive_formula(self):
        """Create the recursive recognition formula"""
        cx = self.config['width'] / 2

        return f"""  <!-- Recursive Recognition Formula -->
  <g id = "formula" filter = "url(#glow)">
    <rect x = "{cx-250}" y = "50" width = "500" height = "60" rx = "30" fill = "#2a2a6a" stroke = "{self.config['accent_color']}" stroke-width = "2" />
    <text x = "{cx}" y = "85" text-anchor = "middle" font-family = "Arial" font-size = "16" fill = "{self.config['text_color']}">⟨ψ|⟳|The framework recognizes patterns</text>
    <text x = "{cx}" y = "105" text-anchor = "middle" font-family = "Arial" font-size = "14" fill = "{self.config['highlight_color']}">that recognize themselves being recognized⟩</text>
  </g>
"""

    def _create_path_animation(self):
        """Create animated path elements"""
        return f"""  <!-- Animated connection path -->
  <circle cx = "0" cy = "0" r = "5" fill = "{self.config['highlight_color']}" filter = "url(#glow)">
    <animateMotion dur = "10s" repeatCount = "indefinite">
      <mpath href = "#connection-path" />
    </animateMotion>
  </circle>
  <circle cx = "0" cy = "0" r = "5" fill = "{self.config['accent_color']}" filter = "url(#glow)">
    <animateMotion dur = "10s" begin = "3s" repeatCount = "indefinite">
      <mpath href = "#connection-path" />
    </animateMotion>
  </circle>
"""

    def _create_info_elements(self):
        """Create information elements"""
        return f"""  <!-- File path -->
  <g font-family = "monospace" font-size = "10" fill = "{self.config['highlight_color']}">
    <text x = "10" y = "25">{self.base_dir}</text>
  </g>

  <!-- Symbolic keys -->
  <g font-family = "Arial" font-size = "12" fill = "{self.config['text_color']}">
    <text x = "20" y = "{self.config['height'] - 30}">⟳ Loop Containment</text>
    <text x = "200" y = "{self.config['height'] - 30}">⥮ Disruption Vector</text>
    <text x = "380" y = "{self.config['height'] - 30}">⇝ Progressive Expansion</text>
    <text x = "580" y = "{self.config['height'] - 30}">• Singular Collapse</text>
    <text x = "720" y = "{self.config['height'] - 30}">∑ Summary</text>
  </g>
"""

    def generate_json_data(self):
        """Generate JSON data about the BAZINGA framework"""
        data = {
            "framework": "BAZINGA Quantum Framework",
            "base_path": self.base_dir,
            "timestamp": datetime.now().isoformat(),
            "components": {category: [c["name"] for c in comps] for category, comps in self.components.items()},
            "essence": "⟨ψ|⟳|The framework recognizes patterns that recognize themselves being recognized⟩",
            "symbols": {
                "⟳": "Loop Containment",
                "⥮": "Disruption Vector",
                "⇝": "Progressive Expansion",
                "•": "Singular Collapse",
                "∑": "Summary of state"
            }
        }

        # Write to file
        output_path = os.path.join(self.output_dir, f"bazinga-data-{datetime.now().strftime('%Y%m%d-%H%M%S')}.json")
        with open(output_path, "w") as file:
            json.dump(data, file, indent = 2)

        return output_path


def parse_arguments():
    """Parse command line arguments"""
    parser = argparse.ArgumentParser(description = "BAZINGA Framework Visualizer")
    parser.add_argument("--base-dir", help = "Base directory of the BAZINGA framework")
    parser.add_argument("--output-dir", help = "Output directory for visualizations")

    return parser.parse_args()


def main():
    """Main entry point"""
    args = parse_arguments()

    visualizer = BazingaVisualizer(
        base_dir = args.base_dir,
        output_dir = args.output_dir
    )

    print(f"Scanning BAZINGA framework at: {visualizer.base_dir}")
    visualizer.scan_directory()

    # Generate visualization
    svg_path = visualizer.generate_svg()

    # Generate JSON data
    json_path = visualizer.generate_json_data()

    print("Visualization complete!")
    print(f"SVG: {svg_path}")
    print(f"JSON: {json_path}")

    # Try to open the SVG if on macOS
    if sys.platform == "darwin":
        try:
            os.system(f"open {svg_path}")
        except:
            print("Could not automatically open the SVG file.")


if __name__ == "__main__":
    main()
