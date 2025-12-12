#!/usr/bin/env python3
"""
Self-Correcting Visualization System for BAZINGA

This system automatically generates visualizations from patterns detected
in the BAZINGA framework and can self-correct based on feedback.

Features:
- Automatically detects patterns in the system
- Generates SVG, HTML, and interactive visualizations
- Self-corrects based on feedback and new data
- Integrates with CLDSeed for context propagation
"""

import os
import sys
import json
import math
import re
import datetime
import random
from typing import Dict, List, Any, Tuple, Optional, Union
import argparse

# Constants from CLDSeed
PHI = 1.618033988749895  # Golden ratio
SILVER = 2.5029          # Silver ratio
PLASTIC = 1.324717957244746  # Plastic number
DAY_CYCLE = 40           # Cycle parameter

class BAZINGAVisualizer:
    """Self-correcting visualization system for BAZINGA"""

    def __init__(self, bazinga_root: str, config_path: Optional[str] = None):
        """
        Initialize the visualization system.

        Args:
            bazinga_root: Root directory of the BAZINGA framework
            config_path: Path to configuration file (optional)
        """
        self.bazinga_root = bazinga_root
        self.config = self._load_config(config_path)
        self.generated_count = 0
        self.last_generated = None
        self.correction_history = []

    def _load_config(self, config_path: Optional[str]) -> Dict[str, Any]:
        """Load configuration from file or use defaults"""
        if config_path and os.path.exists(config_path):
            with open(config_path, 'r') as f:
                return json.load(f)

        # Default configuration
        config_path = os.path.join(self.bazinga_root, "src/core/claude-seed/bazinga_config.json")
        if os.path.exists(config_path):
            with open(config_path, 'r') as f:
                return json.load(f)

        # Bare defaults
        return {
            "visualization": {
                "output_formats": ["svg", "html"],
                "style": {
                    "color_scheme": "harmonics",
                    "node_size_factor": PHI,
                    "spacing_ratio": SILVER,
                    "animation_cycle": DAY_CYCLE
                }
            }
        }

    def detect_patterns(self, data_path: Optional[str] = None) -> Dict[str, Any]:
        """Detect patterns in the system or provided data"""
        patterns = {
            "domains": {},
            "connections": {},
            "clusters": {}
        }

        # If data path provided, analyze that data
        if data_path and os.path.exists(data_path):
            return self._analyze_data_file(data_path)

        # Otherwise, analyze the system structure
        src_path = os.path.join(self.bazinga_root, "src")
        if os.path.exists(src_path):
            patterns["domains"] = self._analyze_directory_structure(src_path)

        # Analyze integration points
        integrations_path = os.path.join(self.bazinga_root, "src/integrations")
        if os.path.exists(integrations_path):
            patterns["connections"] = self._analyze_integrations(integrations_path)

        # Look for relationship data
        relationship_path = os.path.join(self.bazinga_root, "data/timeline")
        if os.path.exists(relationship_path):
            patterns["relationship"] = self._analyze_relationship_data(relationship_path)

        return
