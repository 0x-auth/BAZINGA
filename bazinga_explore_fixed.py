#!/usr/bin/env python
# bazinga_explore_fixed2.py - Explore BAZINGA system capabilities

from src.core.bazinga import BazingaUniversalTool
from src.core.dodo import DodoSystem, ProcessingState

print("=== BAZINGA System Exploration ===\n")

# Initialize our tools
bazinga = BazingaUniversalTool()
dodo = DodoSystem()

# 1. Creating encodings for different scenarios
print("1. Creating Different Encodings:")
relationship_pattern = bazinga.encode(3, 1, [2, 4, 1, 3])
time_trust_pattern = bazinga.encode(4, 1, [1, 3, 5, 2, 4])
concept_integration = bazinga.encode(9, 2, [8, 6, 1, 3, 7])

print(f"  Relationship Pattern: {relationship_pattern}")
print(f"  → {bazinga.explain(relationship_pattern)}")

print(f"  Time-Trust Pattern: {time_trust_pattern}")
print(f"  → {bazinga.explain(time_trust_pattern)}")

print(f"  Concept Integration: {concept_integration}")
print(f"  → {bazinga.explain(concept_integration)}")

# 2. Process patterns through DODO system
print("\n2. Processing Patterns through DODO:")
# Set DODO to pattern mode
dodo.change_state(ProcessingState.PATTERN)

# Process a pattern
pattern_result = dodo.process_input({
    "values": [1, 1, 2, 3, 5, 8],
    "source": "fibonacci"
})
print("  Pattern Processing Result:")
print(f"  {pattern_result}")

# Change to transition mode
dodo.change_state(ProcessingState.TRANSITION)
transition_result = dodo.process_input({
    "from_pattern": "10101",
    "to_pattern": "11010"
})
print("\n  Transition Processing Result:")
print(f"  {transition_result}")

# 3. Looking at the test output, let's try to get harmonic values via processing
print("\n3. Accessing Harmonic Values:")
dodo.change_state(ProcessingState.PATTERN)
harmonic_result = dodo.process_input({
    "harmonic_request": True,
    "dimensions": 3
})
print(f"  Harmonic Processing Result: {harmonic_result}")

# 4. Working with Trust Levels - Accessing the trust_level property directly
print("\n4. Working with Trust Levels:")
# Based on error, it seems trust_tracker has a trust_level property instead of get_trust_level method
initial_trust = dodo.trust_tracker.trust_level
print(f"  Initial Trust Level: {initial_trust}")

# Update trust based on verification
updated_trust = dodo.trust_tracker.update_trust_level({
    "success": True,
    "verification_method": "cryptographic",
    "confidence": 0.85
})
print(f"  Updated Trust Level: {updated_trust}")

# 5. Create a conversation flow
print("\n5. Creating a Conversation Flow:")
concepts = [
    {"section": 1, "subsection": 2, "attributes": [3, 4, 5]},
    {"section": 4, "subsection": 1, "attributes": [1, 3, 5, 2, 4]},
    {"section": 3, "subsection": 2, "attributes": [2, 1, 5, 3, 2]},
]
conversation = bazinga.create_conversation_encoding(concepts)
print("  Conversation Flow:")
for i, seq in enumerate(conversation, 1):
    print(f"  Step {i}: {seq} → {bazinga.explain(seq)}")

# 6. Let's try using BazingaDodoIntegration
print("\n6. Using BAZINGA-DODO Integration:")
try:
    from src.core.dodo import BazingaDodoIntegration

    # Initialize integration
    integration = BazingaDodoIntegration(dodo)

    # Define a test component class
    class TestComponent:
        def process(self, data, connections = None):
            return {"processed": True, "data": data}

        def get_processing_breaks(self):
            return [{"point": "test", "reason": "Testing", "component": "TestComponent"}]

    # Register component
    test_component = TestComponent()
    integration.register_component("TestComponent", {
        "implementation": test_component,
        "connections": ["dodo_output", "harmonics"]
    })

    # Process with components
    integration_result = integration.process_with_components({"test": "data"})
    print("  Integration Result:")
    print(f"  {integration_result}")

    # Check processing breaks
    breaks = integration.get_processing_breaks()
    print("\n  Processing Breaks:")
    print(f"  {breaks}")

except ImportError:
    print("  Integration module not found, skipping this test.")
except Exception as e:
    print(f"  Error testing integration: {str(e)}")

# 7. Try encoding with specific patterns
print("\n7. Encoding with Specific Patterns:")
try:
    # Accessing patterns from the configuration
    for pattern_name in ["Divergence/Growth", "Convergence/Synthesis", "Balance/Refinement"]:
        pattern_code = bazinga.get_pattern_code(pattern_name)
        if pattern_code:
            print(f"  Pattern '{pattern_name}' → {pattern_code}")
            pattern_result = bazinga.encode_with_pattern(pattern_code)
            print(f"  Result: {pattern_result}")
except Exception as e:
    print(f"  Error working with patterns: {str(e)}")
    print("  Try instead:")
    special_encoding = bazinga.encode(5, 1, [1, 0, 1, 0, 1])
    print(f"  Special Pattern Encoding: {special_encoding}")
    print(f"  → {bazinga.explain(special_encoding)}")

print("\n=== Exploration Complete ===")
