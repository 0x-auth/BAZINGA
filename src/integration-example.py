#!/usr/bin/env python3
"""
BAZINGA Framework Integration with Meta-Pattern Recognition System

This script demonstrates how to integrate the Meta-Pattern Recognition System
with the BAZINGA Framework for relationship analysis and Claude AI integration.
"""

import os
import sys
import json
import logging

# Setup logging
logging.basicConfig(
    level = logging.INFO,
    format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger("bazinga_integration")

# Paths for integration
BAZINGA_HOME = os.environ.get("BAZINGA_HOME", os.path.expanduser("~/bazinga_unified"))
SYSTEM_PATH = os.path.join(os.path.dirname(__file__), "meta_pattern_detector.py")

# Make sure we can import from both paths
sys.path.append(BAZINGA_HOME)
sys.path.append(os.path.dirname(__file__))

# Import BAZINGA components
try:
    from integrations.claude.connector import ClaudeConnector
    from integrations.analysis.connector import RelationshipAnalysisConnector
except ImportError:
    logger.error(f"Cannot import BAZINGA components. Make sure BAZINGA_HOME is set correctly: {BAZINGA_HOME}")
    logger.error("Continuing with limited functionality")

# Import Meta-Pattern Recognition System
try:
    from meta_pattern_detector import (
        SystemRepresentation,
        IsomorphismDetector,
        PatternGenerator,
        StatePredictor,
        MetaPatternDetector,
        Context
    )
except ImportError:
    logger.error(f"Cannot import Meta-Pattern Recognition System. Make sure the file exists: {SYSTEM_PATH}")
    sys.exit(1)

class IntegratedDetector:
    """
    Integrates Meta-Pattern Recognition System with BAZINGA Framework

    This class connects the pattern recognition capabilities with both
    Claude AI and relationship analysis components.
    """

    def __init__(self, config_path = None):
        """Initialize the integrated detector"""
        # Default configuration path
        if config_path is None:
            config_path = os.path.join(BAZINGA_HOME, "config", "patterns.json")

        # Load configuration
        self.config = self._load_config(config_path)

        # Initialize Meta-Pattern Detector
        self.detector = MetaPatternDetector(
            isomorphism_threshold = self.config.get("isomorphism_threshold", 0.85),
            min_confidence = self.config.get("min_confidence", 0.75),
            max_generators = self.config.get("max_generators", 5),
            context_sensitivity = self.config.get("context_sensitivity", 0.8),
            prediction_horizon = self.config.get("prediction_horizon", 5)
        )

        # Initialize integrations if available
        try:
            self.claude = ClaudeConnector()
            self.analysis = RelationshipAnalysisConnector()
            self.integrated = True
            logger.info("Successfully initialized with BAZINGA integration")
        except (NameError, ImportError):
            self.claude = None
            self.analysis = None
            self.integrated = False
            logger.warning("Running without BAZINGA integration")

    def _load_config(self, config_path):
        """Load configuration from file"""
        try:
            with open(config_path, 'r') as f:
                return json.load(f)
        except (FileNotFoundError, json.JSONDecodeError):
            logger.warning(f"Config file not found or invalid: {config_path}")
            return {}

    def process_claude_content(self, content):
        """Process content using Claude and analyze patterns"""
        if not self.integrated:
            logger.error("BAZINGA integration not available")
            return None

        # Process content with Claude
        claude_result = self.claude.process_content(content)

        # Extract relationships from content
        relationship_data = self._extract_relationships(claude_result)

        # Convert to system representation
        system_data = self._convert_to_system(relationship_data)

        # Analyze system
        analysis = self.detector.analyze_system(system_data)

        # Generate insights from patterns
        insights = self._generate_insights(analysis["patterns"])

        return {
            "claude_result": claude_result,
            "relationship_data": relationship_data,
            "pattern_analysis": analysis,
            "insights": insights
        }

    def analyze_relationship_data(self, component, data):
        """Run relationship analysis and detect patterns"""
        if not self.integrated:
            logger.error("BAZINGA integration not available")
            return None

        # Run analysis on component
        analysis_result = self.analysis.run_analysis(component, data)

        # Convert to system representation
        system_data = self._convert_to_system(analysis_result)

        # Analyze system
        pattern_analysis = self.detector.analyze_system(system_data)

        # Predict future states
        context = Context(
            external_influence = 0.7,
            energy_level = 0.6,
            time_factor = 1.0
        )

        evolution = self.detector.predict_system_evolution(system_data, context.__dict__, steps = 3)

        # Generate insights
        insights = self._generate_insights(pattern_analysis["patterns"])

        return {
            "analysis_result": analysis_result,
            "pattern_analysis": pattern_analysis,
            "evolution": evolution,
            "insights": insights
        }

    def compare_relationship_patterns(self, data_a, data_b):
        """Compare patterns between two relationship datasets"""
        # Convert to system representations
        system_a = self._convert_to_system(data_a)
        system_b = self._convert_to_system(data_b)

        # Compare systems
        comparison = self.detector.compare_systems(system_a, system_b)

        # Generate insights
        insights = self._generate_comparison_insights(comparison)

        return {
            "comparison": comparison,
            "insights": insights
        }

    def _extract_relationships(self, claude_result):
        """Extract relationship data from Claude result"""
        # This would typically parse the Claude result to extract relationship info
        # Simplified implementation for example purposes
        relationships = {
            "persons": [],
            "interactions": [],
            "patterns": {}
        }

        # Parse content for persons, interactions, and patterns
        # In a real implementation, this would use NLP to extract structured data

        return relationships

    def _convert_to_system(self, relationship_data):
        """Convert relationship data to system representation"""
        # Create nodes for persons
        nodes = []
        if "persons" in relationship_data and relationship_data["persons"]:
            nodes = relationship_data["persons"]
        else:
            # Extract unique persons from interactions
            persons = set()
            if "interactions" in relationship_data:
                for interaction in relationship_data["interactions"]:
                    if "person_a" in interaction:
                        persons.add(interaction["person_a"])
                    if "person_b" in interaction:
                        persons.add(interaction["person_b"])
            nodes = list(persons)

        # Create edges for interactions
        edges = []
        if "interactions" in relationship_data:
            for interaction in relationship_data["interactions"]:
                if "person_a" in interaction and "person_b" in interaction:
                    edges.append((interaction["person_a"], interaction["person_b"]))

        # Create properties
        properties = {}
        if "patterns" in relationship_data:
            properties["patterns"] = relationship_data["patterns"]

        # Return system data
        return {
            "nodes": nodes,
            "edges": edges,
            "properties": properties
        }

    def _generate_insights(self, patterns):
        """Generate insights from detected patterns"""
        insights = []

        for pattern in patterns:
            pattern_type = pattern["type"]
            confidence = pattern["confidence"]

            if pattern_type == "cyclical" and confidence > 0.7:
                insights.append({
                    "type": "cyclical_pattern",
                    "description": "A recurring cycle of interactions was detected",
                    "confidence": confidence,
                    "implications": [
                        "This relationship shows a repetitive pattern that may persist without intervention",
                        "Breaking this cycle may require changing response patterns to similar triggers"
                    ]
                })

            elif pattern_type == "hierarchical" and confidence > 0.7:
                insights.append({
                    "type": "hierarchical_pattern",
                    "description": "A hierarchical power structure was detected",
                    "confidence": confidence,
                    "implications": [
                        "There appears to be an imbalance in decision-making or influence",
                        "Addressing this imbalance may require establishing more equal patterns of interaction"
                    ]
                })

            elif pattern_type == "network" and confidence > 0.7:
                insights.append({
                    "type": "network_pattern",
                    "description": "A complex network of interactions with distinct communities was detected",
                    "confidence": confidence,
                    "implications": [
                        "This relationship involves multiple interconnected aspects or domains",
                        "Changes in one area may have complex effects throughout the relationship"
                    ]
                })

            elif pattern_type == "fractal" and confidence > 0.7:
                insights.append({
                    "type": "fractal_pattern",
                    "description": "A self-similar pattern that repeats at different scales was detected",
                    "confidence": confidence,
                    "implications": [
                        "The same fundamental dynamics appear in different contexts and timeframes",
                        "Addressing core patterns could have effects across multiple scales of interaction"
                    ]
                })

        return insights

    def _generate_comparison_insights(self, comparison):
        """Generate insights from system comparison"""
        insights = []

        # Check if systems are isomorphic
        if comparison["isomorphism_analysis"]["isomorphic"]:
            insights.append({
                "type": "structural_similarity",
                "description": "The two relationship patterns have very similar structures",
                "similarity": comparison["isomorphism_analysis"]["similarity_score"],
                "implications": [
                    "Despite surface differences, these relationships follow the same fundamental pattern",
                    "Strategies that work in one context might be applicable to the other"
                ]
            })

        # Check for common patterns
        for pattern in comparison["common_patterns"]:
            if pattern["similarity"] > 0.8:
                insights.append({
                    "type": f"common_{pattern['type']}_pattern",
                    "description": f"A common {pattern['type']} pattern was detected in both relationships",
                    "similarity": pattern["similarity"],
                    "implications": [
                        "Both relationships exhibit similar underlying dynamics",
                        "This pattern appears to transcend the specific context of each relationship"
                    ]
                })

        return insights

def example_claude_integration():
    """Example of Claude integration"""
    print("\n===== Claude Integration Example =====")

    # Initialize integrated detector
    detector = IntegratedDetector()

    if not detector.integrated:
        print("BAZINGA integration not available. Skipping example.")
        return

    # Example content for processing
    content = """
    Analyze the following relationship pattern:

    Person A tends to withdraw when Person B expresses concerns.
    Person B becomes more insistent when Person A withdraws.
    This creates a pattern where B's concerns escalate and A withdraws further.
    The cycle repeats with increasing intensity until a breaking point.

    What patterns can you identify in this relationship dynamic?
    """

    # Process content
    result = detector.process_claude_content(content)

    # Print results
    print("\nDetected Patterns:")
    for pattern in result["pattern_analysis"]["patterns"]:
        print(f"  Type: {pattern['type']}")
        print(f"  Confidence: {pattern['confidence']:.2f}")

    print("\nGenerated Insights:")
    for insight in result["insights"]:
        print(f"  {insight['description']}")
        print(f"  Confidence: {insight['confidence']:.2f}")
        print(f"  Implications:")
        for implication in insight["implications"]:
            print(f"    - {implication}")

def example_relationship_analysis():
    """Example of relationship analysis integration"""
    print("\n===== Relationship Analysis Integration Example =====")

    # Initialize integrated detector
    detector = IntegratedDetector()

    if not detector.integrated:
        print("BAZINGA integration not available. Skipping example.")
        return

    # Example relationship data
    data = {
        "persons": ["A", "B", "C", "D"],
        "interactions": [
            {"person_a": "A", "person_b": "B", "context": "conflict", "intensity": 0.7},
            {"person_a": "B", "person_b": "A", "context": "conflict", "intensity": 0.8},
            {"person_a": "A", "person_b": "C", "context": "support", "intensity": 0.6},
            {"person_a": "B", "person_b": "D", "context": "support", "intensity": 0.5},
            {"person_a": "C", "person_b": "D", "context": "neutral", "intensity": 0.3},
            {"person_a": "D", "person_b": "A", "context": "conflict", "intensity": 0.4}
        ],
        "patterns": {
            "withdrawal_pursuit": 0.8,
            "triangulation": 0.6
        }
    }

    # Analyze relationship data
    result = detector.analyze_relationship_data("breakthrough-analysis", data)

    # Print results
    print("\nDetected Patterns:")
    for pattern in result["pattern_analysis"]["patterns"]:
        print(f"  Type: {pattern['type']}")
        print(f"  Confidence: {pattern['confidence']:.2f}")

    print("\nPredicted Evolution:")
    for i, step in enumerate(result["evolution"]["stability_trajectory"]):
        print(f"  Step {i+1} Stability: {step:.2f}")

    print("\nGenerated Insights:")
    for insight in result["insights"]:
        print(f"  {insight['description']}")
        print(f"  Implications:")
        for implication in insight["implications"]:
            print(f"    - {implication}")

def example_pattern_comparison():
    """Example of comparing relationship patterns"""
    print("\n===== Relationship Pattern Comparison Example =====")

    # Initialize integrated detector
    detector = IntegratedDetector()

    # Example relationship data for two different relationships
    relationship_a = {
        "persons": ["A", "B"],
        "interactions": [
            {"person_a": "A", "person_b": "B", "context": "conflict", "intensity": 0.7},
            {"person_a": "B", "person_b": "A", "context": "withdrawal", "intensity": 0.6},
            {"person_a": "A", "person_b": "B", "context": "pursuit", "intensity": 0.8},
            {"person_a": "B", "person_b": "A", "context": "withdrawal", "intensity": 0.9}
        ],
        "patterns": {
            "withdrawal_pursuit": 0.9
        }
    }

    relationship_b = {
        "persons": ["X", "Y"],
        "interactions": [
            {"person_a": "X", "person_b": "Y", "context": "criticism", "intensity": 0.6},
            {"person_a": "Y", "person_b": "X", "context": "defense", "intensity": 0.7},
            {"person_a": "X", "person_b": "Y", "context": "contempt", "intensity": 0.8},
            {"person_a": "Y", "person_b": "X", "context": "stonewalling", "intensity": 0.9}
        ],
        "patterns": {
            "four_horsemen": 0.8
        }
    }

    # Compare patterns
    result = detector.compare_relationship_patterns(relationship_a, relationship_b)

    # Print results
    print("\nComparison Results:")
    print(f"  Isomorphic: {result['comparison']['isomorphism_analysis']['isomorphic']}")
    print(f"  Similarity Score: {result['comparison']['isomorphism_analysis']['similarity_score']:.2f}")

    print("\nCommon Patterns:")
    for pattern in result['comparison']['common_patterns']:
        print(f"  Type: {pattern['type']}")
        print(f"  Similarity: {pattern['similarity']:.2f}")

    print("\nGenerated Insights:")
    for insight in result["insights"]:
        print(f"  {insight['description']}")
        print(f"  Similarity: {insight.get('similarity', 'N/A')}")
        print(f"  Implications:")
        for implication in insight["implications"]:
            print(f"    - {implication}")

def main():
    """Main function to run examples"""
    print("BAZINGA Framework Integration with Meta-Pattern Recognition System\n")

    try:
        example_claude_integration()
    except Exception as e:
        logger.error(f"Error running Claude integration example: {e}")

    try:
        example_relationship_analysis()
    except Exception as e:
        logger.error(f"Error running relationship analysis example: {e}")

    try:
        example_pattern_comparison()
    except Exception as e:
        logger.error(f"Error running pattern comparison example: {e}")

if __name__ == "__main__":
    main()
