#!/usr/bin/env python3
"""
Test script for BAZINGA-DODO integration
"""
import sys
import os
from typing import Dict, Any
import json

# Add the current directory to the path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from src.core.dodo import DodoSystem, BazingaDodoIntegration, ProcessingState

def main():
    # Initialize the DODO system
    dodo_system = DodoSystem()

    # Test harmonic calculations
    print("Testing BAZINGA-DODO Integration")
    print("-" * 50)

    # Test harmonic time spacing
    print("Harmonic Time Spacing Example:")
    time_spacing = dodo_system.harmonics.calculate_time_spacing(1.0, 5)
    print(time_spacing)
    print()

    # Set up some test data
    test_data = {
        "name": "Test Input",
        "values": [1.0, 2.0, 3.0, 4.0],
        "metadata": {
            "source": "Unit Test",
            "timestamp": 1678901234
        }
    }

    # Process through DODO system
    print("DODO System Processing Result:")
    result = dodo_system.process_input(test_data)
    print(json.dumps(result, indent = 2))
    print()

    # Set up BAZINGA integration
    integration = BazingaDodoIntegration(dodo_system)

    # Register a mock component
    mock_component = type('MockComponent', (), {
        'process': lambda self, data, connections: {"processed": True, "data": data},
        'get_processing_breaks': lambda self: [{"point": "test", "reason": "Testing"}]
    })()

    integration.register_component("TestComponent", {
        "implementation": mock_component,
        "connections": ["dodo_output", "harmonics"]
    })

    # Process through integration
    print("BAZINGA-DODO Integration Result:")
    integration_result = integration.process_with_components(test_data)
    print(json.dumps(integration_result, indent = 2))
    print()

    # Get processing breaks
    breaks = integration.get_processing_breaks()
    print("Processing Breaks:")
    print(json.dumps(breaks, indent = 2))

if __name__ == "__main__":
    main()
