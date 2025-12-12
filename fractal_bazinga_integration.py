#!/usr/bin/env python
# fractal_bazinga_integration.py - Integrate Fractal Relationship Analysis with BAZINGA

from src.core.bazinga import BazingaUniversalTool
from src.core.dodo import DodoSystem, ProcessingState
import os
import json
import math

print("=== BAZINGA Fractal Relationship Integration ===\n")

# Initialize our tools
bazinga = BazingaUniversalTool()
dodo = DodoSystem()

# Create directory for generated output if it doesn't exist
output_dir = "generated/fractals"
if not os.path.exists(output_dir):
    os.makedirs(output_dir)

# Define mathematical constants needed for fractal analysis
constants = {
    "phi": 1.618033988749895,  # Golden ratio
    "e": 2.718281828459045,    # Euler's number
    "pi": 3.141592653589793,   # Pi
    "phi_squared": 2.618033988749895,  # φ²
    "inv_phi": 0.618033988749895,      # 1/φ
    "phi_minus_1": 0.618033988749895,  # φ-1
    "phi_plus_1": 2.618033988749895,   # φ+1
    "inv_e": 0.36787944117144233,      # 1/e
    "e_squared": 7.3890560989306495,   # e²
    "ln_2": 0.6931471805599453,        # ln(2)
    "e_to_pi": 23.140692632779267,     # e^π
    "pi_half": 1.5707963267948966,     # π/2
    "two_pi": 6.283185307179586,       # 2π
    "pi_squared": 9.869604401089358,   # π²
    "pi_quarter": 0.7853981633974483,  # π/4
}

print("Step 1: Creating Fractal Relationship Analyzer class")

# Create a mock implementation of the RelationshipFractalAnalyzer class
class RelationshipFractalAnalyzer:
    def __init__(self, bazinga_tool, dodo_system = None):
        self.bazinga_tool = bazinga_tool
        self.dodo_system = dodo_system
        self.constants = constants

    def analyze_witness_duality(self, text):
        """Analyze witness-doer duality in text"""
        # Simulate witness & doer word counting
        witness_words = ['observe', 'notice', 'witness', 'aware', 'see', 'experience', 'feel', 'sense']
        doer_words = ['make', 'do', 'control', 'change', 'act', 'force', 'manage', 'handle']

        # Simple simulation for demo
        witness_count = sum(text.lower().count(word) for word in witness_words)
        doer_count = sum(text.lower().count(word) for word in doer_words)

        # Prevent division by zero
        if doer_count == 0:
            doer_count = 1

        ratio = witness_count / doer_count

        # Classify orientation
        if ratio > self.constants["phi"]:
            orientation = "Witness-dominant"
        elif ratio > self.constants["inv_phi"]:
            orientation = "Balanced"
        else:
            orientation = "Doer-dominant"

        return {
            "ratio": ratio,
            "witness_count": witness_count,
            "doer_count": doer_count,
            "orientation": orientation,
            "phi_proximity": abs(ratio - self.constants["phi"]) / self.constants["phi"]
        }

    def calculate_perception_reality_gap(self, text):
        """Calculate perception-reality gap in text"""
        # Simulate perception & reality word counting
        perception_words = ['think', 'feel', 'believe', 'imagine', 'seems', 'appears']
        reality_words = ['is', 'actually', 'fact', 'true', 'real', 'concrete']

        # Simple simulation for demo
        perception_count = sum(text.lower().count(word) for word in perception_words)
        reality_count = sum(text.lower().count(word) for word in reality_words)

        # Prevent division by zero
        total_count = perception_count + reality_count
        if total_count == 0:
            total_count = 1

        gap_magnitude = abs(perception_count - reality_count) / total_count

        # Classify gap
        if gap_magnitude > 0.5:
            classification = "High gap"
        elif gap_magnitude > 0.2:
            classification = "Medium gap"
        else:
            classification = "Low gap"

        return {
            "gap_magnitude": gap_magnitude,
            "perception_count": perception_count,
            "reality_count": reality_count,
            "classification": classification,
            "e_proximity": abs(gap_magnitude - self.constants["inv_e"]) / self.constants["inv_e"]
        }

    def analyze_temporal_patterns(self, text):
        """Analyze temporal patterns in text"""
        # Simulate temporal word counting
        past_words = ['was', 'did', 'had', 'happened', 'before', 'previously']
        present_words = ['is', 'am', 'are', 'now', 'currently', 'today']
        future_words = ['will', 'going to', 'plan', 'expect', 'soon', 'tomorrow']
        cyclical_words = ['again', 'repeat', 'cycle', 'pattern', 'always', 'never']

        # Simple simulation for demo
        past_count = sum(text.lower().count(word) for word in past_words)
        present_count = sum(text.lower().count(word) for word in present_words)
        future_count = sum(text.lower().count(word) for word in future_words)
        cyclical_count = sum(text.lower().count(word) for word in cyclical_words)

        total_count = past_count + present_count + future_count + cyclical_count
        if total_count == 0:
            total_count = 1

        past_pct = past_count / total_count
        present_pct = present_count / total_count
        future_pct = future_count / total_count
        cyclical_pct = cyclical_count / total_count

        # Determine dominant orientation
        orientations = {
            "Past": past_pct,
            "Present": present_pct,
            "Future": future_pct,
            "Cyclical": cyclical_pct
        }

        dominant = max(orientations, key = orientations.get)

        # Classify based on dominant percentage
        if dominant == "Cyclical" and cyclical_pct > 0.3:
            classification = "Pattern-recursive"
        elif max(orientations.values()) > 0.4:
            classification = f"{dominant}-dominated"
        else:
            classification = "Temporal integration"

        return {
            "past": past_pct,
            "present": present_pct,
            "future": future_pct,
            "cyclical": cyclical_pct,
            "dominant": dominant,
            "classification": classification,
            "pi_proximity": abs(cyclical_pct * 10 - self.constants["pi"]) / self.constants["pi"]
        }

    def generate_mandelbrot_signature(self, seed):
        """Generate a Mandelbrot signature for a relationship state"""
        signature = []

        for i in range(16):
            # Initialize z and c values
            z_real, z_imag = 0, 0
            c_real = -2 + (seed % 100) / 25
            c_imag = -1.2 + (seed % 100) / 50

            # Perform iterations
            iteration = 0
            max_iterations = 32

            while iteration < max_iterations:
                # z = z² + c
                real = z_real * z_real - z_imag * z_imag + c_real
                imag = 2 * z_real * z_imag + c_imag

                z_real, z_imag = real, imag

                if real * real + imag * imag > 4:
                    break

                iteration += 1

            signature.append(iteration / max_iterations)
            c_real += 0.1
            c_imag += 0.05

        return signature

    def generate_bazinga_insight(self, witness_duality, perception_gap, temporal_pattern, signature):
        """Generate BAZINGA insight from relationship analysis"""
        # Calculate the most significant fractal pattern
        witness_ratio = witness_duality["ratio"]
        phi_approximation = abs(witness_ratio - self.constants["phi"]) / self.constants["phi"]
        e_approximation = abs(perception_gap["gap_magnitude"] - (1/self.constants["e"])) / (1/self.constants["e"])
        pi_approximation = abs(temporal_pattern["cyclical"] * 10 - self.constants["pi"]) / self.constants["pi"]

        approximations = [
            {"constant": "phi", "value": phi_approximation},
            {"constant": "e", "value": e_approximation},
            {"constant": "pi", "value": pi_approximation}
        ]

        # Find the closest mathematical constant
        approximations.sort(key = lambda x: x["value"])
        dominant_constant = approximations[0]["constant"]

        # Generate BAZINGA encoding
        if dominant_constant == "phi":
            encoding = self.bazinga_tool.encode(6, 1, [3, 2, 5, 4])
        elif dominant_constant == "e":
            encoding = self.bazinga_tool.encode(7, 5, [3, 2, 1, 4])
        else:
            encoding = self.bazinga_tool.encode(8, 3, [1, 4, 2, 5])

        # Generate insight
        insight = {
            "title": f"🚀 BAZINGA: ",
            "description": "",
            "dominant_constant": dominant_constant,
            "fractal_signature": signature[:5],
            "witness_duality_pattern": witness_duality["orientation"],
            "perception_gap_pattern": perception_gap["classification"],
            "temporal_pattern": temporal_pattern["dominant"],
            "bazinga_encoding": encoding
        }

        # Complete insight based on dominant constant
        if dominant_constant == "phi":
            insight["title"] += "Golden Ratio Bifurcation"
            insight["description"] = "The relationship dynamic shows a golden ratio (φ) pattern, suggesting a harmonious balance between witnessing and doing. This is a bifurcation point where small changes can lead to qualitatively different relationship states."
        elif dominant_constant == "e":
            insight["title"] += "Natural Decay Pattern"
            insight["description"] = "The relationship dynamic follows natural exponential decay (e), suggesting organic growth and decline in perception-reality alignment. This is characteristic of systems that evolve according to natural logarithmic laws."
        else:
            insight["title"] += "Cyclical Boundary Pattern"
            insight["description"] = "The relationship dynamic exhibits pi-based cyclical patterns, suggesting recurring temporal orientations. This cyclical nature indicates potential for transformation through phase shifts in communication timing."

        return insight

# Create an instance of the analyzer
fractal_analyzer = RelationshipFractalAnalyzer(bazinga, dodo)

print("Step 2: Testing Fractal Analysis with sample text")

# Sample text for analysis
sample_text = """You are not engaging with me as I am today. You are engaging with a version of me that existed in your mind when that version had the strongest presence. I observe that our perception of each other seems different from reality. I believe we keep repeating the same pattern of communication. Let's try to make a change by noticing what's happening now and planning differently for our future interactions."""

# Analyze the text
witness_duality = fractal_analyzer.analyze_witness_duality(sample_text)
perception_gap = fractal_analyzer.calculate_perception_reality_gap(sample_text)
temporal_pattern = fractal_analyzer.analyze_temporal_patterns(sample_text)
signature = fractal_analyzer.generate_mandelbrot_signature(
    hash(sample_text) % 1000  # Generate a seed from the text
)

# Generate BAZINGA insight
insight = fractal_analyzer.generate_bazinga_insight(
    witness_duality,
    perception_gap,
    temporal_pattern,
    signature
)

# Display results
print("\nFractal Analysis Results:")
print(f"Witness-Doer Ratio: {witness_duality['ratio']:.2f} ({witness_duality['orientation']})")
print(f"Perception-Reality Gap: {perception_gap['gap_magnitude']:.2f} ({perception_gap['classification']})")
print(f"Temporal Orientation: {temporal_pattern['dominant']} ({temporal_pattern['classification']})")
print(f"Mandelbrot Signature (first 5): {[round(s, 2) for s in signature[:5]]}")

print("\nBAZINGA Insight:")
print(f"{insight['title']}")
print(f"BAZINGA Encoding: {insight['bazinga_encoding']}")
print(f"{insight['description']}")

print("\nStep 3: Integrating with DODO system")

# Integrate with DODO
dodo.change_state(ProcessingState.PATTERN)
integration_result = dodo.process_input({
    "relationship_data": True,
    "witness_ratio": witness_duality["ratio"],
    "perception_gap": perception_gap["gap_magnitude"],
    "temporal_orientation": temporal_pattern["dominant"]
})

print(f"DODO Integration Result: {integration_result}")

# Visualize the integration
class FractalDashboardGenerator:
    def __init__(self, output_dir):
        self.output_dir = output_dir

    def generate_witness_duality_dashboard(self, data):
        # For demonstration, we'll just create a simple HTML visualization
        html_content = f"""<!DOCTYPE html>
<html>
<head>
    <title>Witness-Doer Duality Analysis</title>
    <style>
        body {{ font-family: Arial, sans-serif; margin: 20px; }}
        .container {{ max-width: 800px; margin: 0 auto; }}
        .card {{ border: 1px solid #ccc; border-radius: 8px; padding: 20px; margin-bottom: 20px; }}
        .card-title {{ font-size: 1.5em; margin-bottom: 10px; }}
        .meter {{ height: 20px; background: #e0e0e0; border-radius: 10px; margin: 10px 0; position: relative; }}
        .meter-fill {{ height: 100%; border-radius: 10px; background: linear-gradient(to right, #4CAF50, #FFC107); width: {min(data["ratio"] / 3, 1) * 100}%; }}
        .meter-marker {{ position: absolute; top: -10px; width: 2px; height: 40px; background: #000; }}
        .phi-marker {{ left: {(constants["phi"] / 3) * 100}%; }}
        .ratio-marker {{ left: {(data["ratio"] / 3) * 100}%; }}
        .label {{ display: inline-block; width: 150px; font-weight: bold; }}
        .value {{ font-family: monospace; }}
    </style>
</head>
<body>
    <div class = "container">
        <h1>Witness-Doer Duality Analysis</h1>

        <div class = "card">
            <div class = "card-title">Witness-Doer Ratio</div>
            <div class = "meter">
                <div class = "meter-fill"></div>
                <div class = "meter-marker phi-marker" title = "Golden Ratio (φ)"></div>
                <div class = "meter-marker ratio-marker" title = "Current Ratio"></div>
            </div>
            <p><span class = "label">Current Ratio:</span> <span class = "value">{data["ratio"]:.3f}</span></p>
            <p><span class = "label">Orientation:</span> <span class = "value">{data["orientation"]}</span></p>
            <p><span class = "label">Golden Ratio (φ):</span> <span class = "value">{constants["phi"]:.3f}</span></p>
            <p><span class = "label">φ Proximity:</span> <span class = "value">{data["phi_proximity"]:.2%}</span></p>
        </div>

        <div class = "card">
            <div class = "card-title">Word Counts</div>
            <p><span class = "label">Witness Words:</span> <span class = "value">{data["witness_count"]}</span></p>
            <p><span class = "label">Doer Words:</span> <span class = "value">{data["doer_count"]}</span></p>
        </div>
    </div>
</body>
</html>
"""
        # Save the dashboard
        dashboard_path = os.path.join(self.output_dir, "witness_duality_dashboard.html")
        with open(dashboard_path, "w") as f:
            f.write(html_content)
        return dashboard_path

    def generate_comprehensive_fractal_dashboard(self, insight_data):
        # Create a comprehensive dashboard with all analyses
        html_content = f"""<!DOCTYPE html>
<html>
<head>
    <title>BAZINGA Fractal Relationship Analysis</title>
    <style>
        body {{ font-family: Arial, sans-serif; margin: 0; padding: 0; background: #f5f5f5; }}
        .container {{ max-width: 1000px; margin: 0 auto; padding: 20px; }}
        .header {{ background: #5469d4; color: white; padding: 20px; border-radius: 10px 10px 0 0; }}
        .header h1 {{ margin: 0; }}
        .header p {{ margin: 5px 0 0; opacity: 0.8; }}
        .card {{ background: white; border-radius: 10px; box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1); margin-bottom: 20px; overflow: hidden; }}
        .card-body {{ padding: 20px; }}
        .card-title {{ font-size: 1.5em; margin-bottom: 15px; color: #333; }}
        .insight-title {{ font-size: 1.8em; margin-bottom: 10px; color: #5469d4; }}
        .insight-encoding {{ display: inline-block; background: #5469d4; color: white; padding: 5px 10px; border-radius: 20px; font-family: monospace; margin-bottom: 10px; }}
        .insight-description {{ line-height: 1.6; color: #555; }}
        .meter {{ height: 20px; background: #e0e0e0; border-radius: 10px; margin: 15px 0; position: relative; }}
        .meter-fill {{ height: 100%; border-radius: 10px; }}
        .meter-label {{ position: absolute; top: -20px; transform: translateX(-50%); font-size: 0.8em; color: #666; }}
        .label {{ display: inline-block; width: 180px; font-weight: bold; color: #555; }}
        .value {{ font-family: monospace; color: #333; }}
        .signature-point {{ display: inline-block; width: 20px; height: 20px; border-radius: 50%; margin-right: 5px; }}
        .metric {{ margin-bottom: 10px; }}
        .columns {{ display: flex; gap: 20px; }}
        .column {{ flex: 1; }}
        @media (max-width: 800px) {{ .columns {{ flex-direction: column; }} }}
    </style>
</head>
<body>
    <div class = "container">
        <div class = "card">
            <div class = "header">
                <h1>BAZINGA Fractal Relationship Analysis</h1>
                <p>Deterministic Analysis through Mathematical Constants</p>
            </div>

            <div class = "card-body">
                <div class = "insight-title">{insight_data["title"]}</div>
                <div class = "insight-encoding">{insight_data["bazinga_encoding"]}</div>
                <p class = "insight-description">{insight_data["description"]}</p>

                <div class = "columns">
                    <div class = "column">
                        <div class = "card-title">Dominant Pattern</div>
                        <div class = "metric">
                            <span class = "label">Mathematical Constant:</span>
                            <span class = "value">{insight_data["dominant_constant"].upper()}</span>
                        </div>
                        <div class = "metric">
                            <span class = "label">Witness-Doer Pattern:</span>
                            <span class = "value">{insight_data["witness_duality_pattern"]}</span>
                        </div>
                        <div class = "metric">
                            <span class = "label">Perception-Gap Pattern:</span>
                            <span class = "value">{insight_data["perception_gap_pattern"]}</span>
                        </div>
                        <div class = "metric">
                            <span class = "label">Temporal Pattern:</span>
                            <span class = "value">{insight_data["temporal_pattern"]}</span>
                        </div>
                    </div>

                    <div class = "column">
                        <div class = "card-title">Mandelbrot Signature</div>
                        <div style = "margin-top: 15px;">
                            {" ".join([f'<span class = "signature-point" style = "background: rgba(84, 105, 212, {s});"></span>' for s in insight_data["fractal_signature"]])}
                        </div>
                        <div style = "font-family: monospace; margin-top: 10px; color: #666;">
                            {", ".join([f"{s:.2f}" for s in insight_data["fractal_signature"]])}
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
"""
        # Save the dashboard
        dashboard_path = os.path.join(self.output_dir, "fractal_relationship_dashboard.html")
        with open(dashboard_path, "w") as f:
            f.write(html_content)
        return dashboard_path

# Create dashboard generator
dashboard_generator = FractalDashboardGenerator(output_dir)

# Generate dashboards
witness_dashboard_path = dashboard_generator.generate_witness_duality_dashboard(witness_duality)
comprehensive_dashboard_path = dashboard_generator.generate_comprehensive_fractal_dashboard(insight)

print(f"\nWitness-Doer Dashboard: {witness_dashboard_path}")
print(f"Comprehensive Dashboard: {comprehensive_dashboard_path}")

print("\nStep 4: Creating TypeScript implementation files")

# Create TypeScript implementation of the fractal analyzer
ts_implementation = """// src/core/fractals/RelationshipFractalAnalyzer.ts
import { BazingaUniversalTool } from '../bazinga/bazinga_universal';
import { DodoSystem } from '../dodo';

// Mathematical constants
const constants = {
  phi: 1.618033988749895,  // Golden ratio
  e: 2.718281828459045,    // Euler's number
  pi: 3.141592653589793,   // Pi
  phi_squared: 2.618033988749895,  // φ²
  inv_phi: 0.618033988749895,      // 1/φ
  phi_minus_1: 0.618033988749895,  // φ-1
  phi_plus_1: 2.618033988749895,   // φ+1
  inv_e: 0.36787944117144233,      // 1/e
  e_squared: 7.3890560989306495,   // e²
  ln_2: 0.6931471805599453,        // ln(2)
  e_to_pi: 23.140692632779267,     // e^π
  pi_half: 1.5707963267948966,     // π/2
  two_pi: 6.283185307179586,       // 2π
  pi_squared: 9.869604401089358,   // π²
  pi_quarter: 0.7853981633974483,  // π/4
};

// Define result types
export interface WitnessDualityResult {
  ratio: number;
  witness_count: number;
  doer_count: number;
  orientation: string;
  phi_proximity: number;
}

export interface PerceptionGapResult {
  gap_magnitude: number;
  perception_count: number;
  reality_count: number;
  classification: string;
  e_proximity: number;
}

export interface TemporalPatternResult {
  past: number;
  present: number;
  future: number;
  cyclical: number;
  dominant: string;
  classification: string;
  pi_proximity: number;
}

export interface BazingaInsight {
  title: string;
  description: string;
  dominant_constant: string;
  fractal_signature: number[];
  witness_duality_pattern: string;
  perception_gap_pattern: string;
  temporal_pattern: string;
  bazinga_encoding: string;
}

export class RelationshipFractalAnalyzer {
  constructor(
    private bazingaTool: BazingaUniversalTool,
    private dodoSystem?: DodoSystem
  ) {}

  analyzeWitnessDuality(text: string): WitnessDualityResult {
    // Witness & doer word counting
    const witness_words = ['observe', 'notice', 'witness', 'aware', 'see', 'experience', 'feel', 'sense'];
    const doer_words = ['make', 'do', 'control', 'change', 'act', 'force', 'manage', 'handle'];

    // Count occurrences
    const witness_count = witness_words.reduce((count, word) => {
      return count + (text.toLowerCase().match(new RegExp(word, 'g')) || []).length;
    }, 0);

    const doer_count = doer_words.reduce((count, word) => {
      return count + (text.toLowerCase().match(new RegExp(word, 'g')) || []).length;
    }, 0);

    // Prevent division by zero
    const safe_doer_count = doer_count === 0 ? 1 : doer_count;

    const ratio = witness_count / safe_doer_count;

    // Classify orientation
    let orientation: string;
    if (ratio > constants.phi) {
      orientation = "Witness-dominant";
    } else if (ratio > constants.inv_phi) {
      orientation = "Balanced";
    } else {
      orientation = "Doer-dominant";
    }

    return {
      ratio,
      witness_count,
      doer_count,
      orientation,
      phi_proximity: Math.abs(ratio - constants.phi) / constants.phi
    };
  }

  calculatePerceptionRealityGap(text: string): PerceptionGapResult {
    // Perception & reality word counting
    const perception_words = ['think', 'feel', 'believe', 'imagine', 'seems', 'appears'];
    const reality_words = ['is', 'actually', 'fact', 'true', 'real', 'concrete'];

    // Count occurrences
    const perception_count = perception_words.reduce((count, word) => {
      return count + (text.toLowerCase().match(new RegExp(word, 'g')) || []).length;
    }, 0);

    const reality_count = reality_words.reduce((count, word) => {
      return count + (text.toLowerCase().match(new RegExp(word, 'g')) || []).length;
    }, 0);

    // Prevent division by zero
    const total_count = perception_count + reality_count || 1;

    const gap_magnitude = Math.abs(perception_count - reality_count) / total_count;

    // Classify gap
    let classification: string;
    if (gap_magnitude > 0.5) {
      classification = "High gap";
    } else if (gap_magnitude > 0.2) {
      classification = "Medium gap";
    } else {
      classification = "Low gap";
    }

    return {
      gap_magnitude,
      perception_count,
      reality_count,
      classification,
      e_proximity: Math.abs(gap_magnitude - constants.inv_e) / constants.inv_e
    };
  }

  analyzeTemporalPatterns(text: string): TemporalPatternResult {
    // Temporal word counting
    const past_words = ['was', 'did', 'had', 'happened', 'before', 'previously'];
    const present_words = ['is', 'am', 'are', 'now', 'currently', 'today'];
    const future_words = ['will', 'going to', 'plan', 'expect', 'soon', 'tomorrow'];
    const cyclical_words = ['again', 'repeat', 'cycle', 'pattern', 'always', 'never'];

    // Count occurrences
    const past_count = past_words.reduce((count, word) => {
      return count + (text.toLowerCase().match(new RegExp(word, 'g')) || []).length;
    }, 0);

    const present_count = present_words.reduce((count, word) => {
      return count + (text.toLowerCase().match(new RegExp(word, 'g')) || []).length;
    }, 0);

    const future_count = future_words.reduce((count, word) => {
      return count + (text.toLowerCase().match(new RegExp(word, 'g')) || []).length;
    }, 0);

    const cyclical_count = cyclical_words.reduce((count, word) => {
      return count + (text.toLowerCase().match(new RegExp(word, 'g')) || []).length;
    }, 0);

    const total_count = past_count + present_count + future_count + cyclical_count || 1;

    const past = past_count / total_count;
    const present = present_count / total_count;
    const future = future_count / total_count;
    const cyclical = cyclical_count / total_count;

    // Determine dominant orientation
    const orientations = {
      Past: past,
      Present: present,
      Future: future,
      Cyclical: cyclical
    };

    const dominant = Object.keys(orientations).reduce((a, b) => {
      return orientations[a as keyof typeof orientations] > orientations[b as keyof typeof orientations] ? a : b;
    });

    // Classify based on dominant percentage
    let classification: string;
    if (dominant === "Cyclical" && cyclical > 0.3) {
      classification = "Pattern-recursive";
    } else if (orientations[dominant as keyof
