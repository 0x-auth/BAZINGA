"""
BAZINGA Universal Encoder/Decoder
A comprehensive utility for encoding and decoding BAZINGA numerical sequences

This module provides tools to:
1. Encode complex concepts into BAZINGA numerical format
2. Decode existing BAZINGA sequences into human-readable form
3. Generate new encodings for novel concepts
4. Validate sequences against the structured schema
"""

import json
import re
from typing import Dict, List, Union, Optional, Tuple, Any

class BazingaEncoder:
    """Encodes concepts and structures into BAZINGA numerical sequences."""

    def __init__(self, decoder_key_path: Optional[str] = None):
        """Initialize the encoder with a decoder key file or default structure."""
        self.decoder_key = self._load_decoder_key(decoder_key_path)
        self.section_counts = self._count_subsections()
        self.constants = {
            "golden_ratio": 1.618033988749895,
            "time_harmonic": 1.333333,
            "base_frequency": 432
        }

    def _load_decoder_key(self, path: Optional[str]) -> Dict[str, Any]:
        """Load the decoder key from a file or use default structure."""
        if path:
            try:
                with open(path, 'r') as f:
                    return json.load(f)
            except (FileNotFoundError, json.JSONDecodeError) as e:
                print(f"Error loading decoder key from {path}: {e}")
                # Fall back to default structure

        # Return default structure
        return {
            "1": {"name": "Domain Analysis", "subsections": {
                "1": {"name": "Main BAZINGA Project"},
                "2": {"name": "BAZINGA-INDEED Extended Project"},
                "3": {"name": "Integration Context"}
            }},
            "2": {"name": "Domain Name Analysis", "subsections": {
                "1": {"name": "Top Recommended Domain Names"},
                "2": {"name": "Secondary Domain Options"},
                "3": {"name": "Budget Considerations"}
            }},
            # Add more sections according to the documentation
            "3": {"name": "DODO Visual Pattern Integration", "subsections": {
                "1": {"name": "Key Elements & Significance"},
                "2": {"name": "Harmonic Framework"},
                "3": {"name": "Transformation Pairs"}
            }},
            "4": {"name": "Black Hole & Blockchain Parallels", "subsections": {
                "1": {"name": "Time & Trust Dimensions"},
                "2": {"name": "Gravity & Consensus"},
                "3": {"name": "Symmetry & Invariance"}
            }},
            "5": {"name": "DODO System Framework", "subsections": {
                "1": {"name": "Fundamental Dimensions"},
                "2": {"name": "System Models"},
                "3": {"name": "Implementation Goals"}
            }},
            "6": {"name": "Relationship Analysis Integration", "subsections": {
                "1": {"name": "Unified Data Components"},
                "2": {"name": "Analysis Techniques"},
                "3": {"name": "System Structure"}
            }},
            "7": {"name": "Key Mathematical Constants", "subsections": {
                "1": {"name": "Golden Ratio"},
                "2": {"name": "Time Harmonic"},
                "3": {"name": "Base Frequency"}
            }},
            "8": {"name": "Implementation Patterns", "subsections": {
                "1": {"name": "Integration Flow"},
                "2": {"name": "Component Connections"},
                "3": {"name": "Data Flow Patterns"}
            }},
            "9": {"name": "Project Outcomes", "subsections": {
                "1": {"name": "System Functionality"},
                "2": {"name": "Integration Results"},
                "3": {"name": "Future Expansion"}
            }}
        }

    def _count_subsections(self) -> Dict[str, int]:
        """Count the number of subsections for each section."""
        counts = {}
        for section, data in self.decoder_key.items():
            if "subsections" in data:
                counts[section] = len(data["subsections"])
        return counts

    def encode_concept(self, section: int, subsection: int, attributes: List[Union[int, float]]) -> str:
        """Encode a concept into a BAZINGA numerical sequence."""
        # Validate section and subsection
        section_str = str(section)
        subsection_str = str(subsection)

        if section_str not in self.decoder_key:
            raise ValueError(f"Invalid section: {section}")

        if "subsections" in self.decoder_key[section_str] and \
           subsection_str not in self.decoder_key[section_str]["subsections"]:
            raise ValueError(f"Invalid subsection: {subsection} for section {section}")

        # Handle special case for mathematical constants
        if section == 7:
            if subsection == 1:
                return f"7.1.{self.constants['golden_ratio']}"
            elif subsection == 2:
                return f"7.2.1.{self.constants['time_harmonic']}"
            elif subsection == 3:
                return f"7.3.{self.constants['base_frequency']}"

        # Build the encoding
        encoding = f"{section}.{subsection}"
        for attr in attributes:
            encoding += f".{attr}"

        return encoding

    def encode_fibonacci_sequence(self, max_terms: int = 6) -> str:
        """Generate a Fibonacci sequence encoding (e.g., 8.1.1.2.3.5.8.13)."""
        fibonacci = [1, 1]
        for i in range(2, max_terms):
            fibonacci.append(fibonacci[i-1] + fibonacci[i-2])

        # Remove the first 1 to match standard 8.1.1.2.3.5.8.13 pattern
        fibonacci[0] = 1

        encoding = "8.1"
        for num in fibonacci:
            encoding += f".{num}"

        return encoding

    def encode_system_component(self,
                              component_name: str,
                              attributes: Dict[str, Any]) -> str:
        """Encode a system component based on predefined mappings."""
        # This is a simplified example - would need more complex mappings
        # for a complete implementation

        section_mapping = {
            "visual": 3,
            "blockchain": 4,
            "system": 5,
            "data": 6,
            "math": 7,
            "integration": 8,
            "outcome": 9
        }

        # Determine section based on component_name
        section = 5  # Default to system framework
        for key, value in section_mapping.items():
            if key in component_name.lower():
                section = value
                break

        # Determine subsection based on attributes
        subsection = 1  # Default
        if "type" in attributes:
            type_mapping = {"core": 1, "extension": 2, "integration": 3}
            if attributes["type"].lower() in type_mapping:
                subsection = type_mapping[attributes["type"].lower()]

        # Generate attribute sequence
        attr_sequence = []
        if "priority" in attributes:
            attr_sequence.append(attributes["priority"])
        if "complexity" in attributes:
            attr_sequence.append(attributes["complexity"])
        if "connections" in attributes:
            attr_sequence.append(len(attributes["connections"]))

        # Fill with defaults if needed
        while len(attr_sequence) < 5:
            attr_sequence.append(1)

        return self.encode_concept(section, subsection, attr_sequence)

class BazingaDecoder:
    """Decodes BAZINGA numerical sequences into human-readable form."""

    def __init__(self, decoder_key_path: Optional[str] = None):
        """Initialize the decoder with a decoder key file or default structure."""
        self.encoder = BazingaEncoder(decoder_key_path)
        self.decoder_key = self.encoder.decoder_key
        self.pattern_matchers = self._init_pattern_matchers()

    def _init_pattern_matchers(self) -> Dict[str, callable]:
        """Initialize pattern matching functions."""
        return {
            r"8\.1\.\d+(\.\d+)+": self._match_fibonacci,
            r"7\.1\.\d+\.\d+": self._match_golden_ratio,
            r"7\.2\.1\.\d+": self._match_time_harmonic,
            r"7\.3\.\d+": self._match_base_frequency
        }

    def _match_fibonacci(self, sequence: str) -> Optional[Dict[str, Any]]:
        """Check if the sequence matches a Fibonacci pattern."""
        parts = sequence.split('.')
        if len(parts) < 4:
            return None

        nums = [int(p) for p in parts[2:]]
        # Check if it's a Fibonacci sequence
        for i in range(2, len(nums)):
            if nums[i] != nums[i-1] + nums[i-2]:
                return None

        return {
            "type": "fibonacci",
            "description": "Fibonacci sequence for integration steps",
            "sequence": nums
        }

    def _match_golden_ratio(self, sequence: str) -> Optional[Dict[str, Any]]:
        """Check if the sequence contains the golden ratio."""
        parts = sequence.split('.')
        if len(parts) < 3:
            return None

        try:
            value = float(parts[2])
            if abs(value - 1.618033988749895) < 0.0001:
                return {
                    "type": "mathematical_constant",
                    "name": "Golden Ratio",
                    "value": value,
                    "description": "Used for visual harmonics and spatial arrangements"
                }
        except:
            pass

        return None

    def _match_time_harmonic(self, sequence: str) -> Optional[Dict[str, Any]]:
        """Check if the sequence contains the time harmonic ratio."""
        parts = sequence.split('.')
        if len(parts) < 4:
            return None

        try:
            value = float(parts[3])
            if abs(value - 1.333333) < 0.0001:
                return {
                    "type": "mathematical_constant",
                    "name": "Time Harmonic Ratio",
                    "value": value,
                    "description": "Used for execution cycles"
                }
        except:
            pass

        return None

    def _match_base_frequency(self, sequence: str) -> Optional[Dict[str, Any]]:
        """Check if the sequence contains the base frequency."""
        parts = sequence.split('.')
        if len(parts) < 3:
            return None

        try:
            value = float(parts[2])
            if abs(value - 432) < 0.1:
                return {
                    "type": "mathematical_constant",
                    "name": "Base Frequency",
                    "value": value,
                    "description": "Used for sound harmonics (Hz)"
                }
        except:
            pass

        return None

    def decode_sequence(self, sequence: str) -> Dict[str, Any]:
        """Decode a BAZINGA numerical sequence into a human-readable structure."""
        # First, check for special patterns
        for pattern, matcher in self.pattern_matchers.items():
            if re.match(pattern, sequence):
                pattern_info = matcher(sequence)
                if pattern_info:
                    return pattern_info

        # Standard decoding
        parts = sequence.split('.')
        if len(parts) < 2:
            raise ValueError(f"Invalid BAZINGA sequence: {sequence}")

        section = parts[0]
        subsection = parts[1]
        attributes = parts[2:] if len(parts) > 2 else []

        # Look up section and subsection in decoder key
        if section not in self.decoder_key:
            return {
                "section": int(section),
                "subsection": int(subsection),
                "attributes": [float(a) if '.' in a else int(a) for a in attributes],
                "note": "Unknown section"
            }

        section_info = self.decoder_key[section]
        section_name = section_info.get("name", f"Section {section}")

        subsection_name = f"Subsection {subsection}"
        if "subsections" in section_info and subsection in section_info["subsections"]:
            subsection_name = section_info["subsections"][subsection].get("name", subsection_name)

        # Convert attributes to appropriate types
        typed_attributes = []
        for attr in attributes:
            try:
                if '.' in attr:
                    typed_attributes.append(float(attr))
                else:
                    typed_attributes.append(int(attr))
            except:
                typed_attributes.append(attr)

        return {
            "section": int(section),
            "section_name": section_name,
            "subsection": int(subsection),
            "subsection_name": subsection_name,
            "attributes": typed_attributes,
            "raw": sequence
        }

    def decode_multiple(self, sequences: List[str]) -> List[Dict[str, Any]]:
        """Decode multiple BAZINGA sequences."""
        return [self.decode_sequence(seq) for seq in sequences]

    def explain_sequence(self, sequence: str) -> str:
        """Provide a human-readable explanation of a BAZINGA sequence."""
        decoded = self.decode_sequence(sequence)

        # Handle special patterns
        if "type" in decoded:
            if decoded["type"] == "fibonacci":
                return f"Fibonacci sequence ({decoded['sequence']}) used for progressive integration steps"
            elif decoded["type"] == "mathematical_constant":
                return f"{decoded['name']} ({decoded['value']}): {decoded['description']}"

        # Standard sequence explanation
        explanation = f"Section {decoded['section']} ({decoded['section_name']}), "
        explanation += f"Subsection {decoded['subsection']} ({decoded['subsection_name']})"

        if decoded['attributes']:
            explanation += f" with attributes: {decoded['attributes']}"

        return explanation

class BazingaUniversalTool:
    """Combined tool for encoding, decoding, and working with BAZINGA sequences."""

    def __init__(self, decoder_key_path: Optional[str] = None):
        """Initialize the universal tool."""
        self.encoder = BazingaEncoder(decoder_key_path)
        self.decoder = BazingaDecoder(decoder_key_path)

    def encode(self, section: int, subsection: int, attributes: List[Union[int, float]]) -> str:
        """Encode a concept."""
        return self.encoder.encode_concept(section, subsection, attributes)

    def decode(self, sequence: str) -> Dict[str, Any]:
        """Decode a sequence."""
        return self.decoder.decode_sequence(sequence)

    def explain(self, sequence: str) -> str:
        """Explain a sequence in human-readable form."""
        return self.decoder.explain_sequence(sequence)

    def generate_fibonacci(self, max_terms: int = 6) -> str:
        """Generate a Fibonacci sequence encoding."""
        return self.encoder.encode_fibonacci_sequence(max_terms)

    def encode_component(self, name: str, attributes: Dict[str, Any]) -> str:
        """Encode a system component."""
        return self.encoder.encode_system_component(name, attributes)

    def create_conversation_encoding(self, concepts: List[Dict[str, Any]]) -> List[str]:
        """Create a full conversation encoding."""
        encodings = []
        for concept in concepts:
            section = concept.get("section", 5)  # Default to system framework
            subsection = concept.get("subsection", 1)
            attributes = concept.get("attributes", [1, 2, 3])
            encodings.append(self.encode(section, subsection, attributes))
        return encodings

    def decode_conversation(self, sequences: List[str]) -> List[Dict[str, Any]]:
        """Decode a conversation encoding."""
        return self.decoder.decode_multiple(sequences)

    def get_pattern_code(self, pattern_name):
        """Get pattern code by name"""


# Usage example
if __name__ == "__main__":
    # Create the universal tool
    bazinga_tool = BazingaUniversalTool()

    # Encode a concept
    encoding = bazinga_tool.encode(3, 2, [2, 1, 5, 3, 2])
    print(f"Encoded: {encoding}")

    # Decode a sequence
    decoded = bazinga_tool.decode("3.2.2.1.5.3.2")
    print(f"Decoded: {decoded}")

    # Explain a sequence
    explanation = bazinga_tool.explain("7.1.618033988749895")
    print(f"Explanation: {explanation}")

    # Generate a Fibonacci sequence
    fibonacci = bazinga_tool.generate_fibonacci()
    print(f"Fibonacci: {fibonacci}")

    # Sample conversation encoding
    concepts = [
        {"section": 1, "subsection": 2, "attributes": [3, 4, 5]},
        {"section": 2, "subsection": 1, "attributes": [1, 3, 5, 2]},
        {"section": 3, "subsection": 1, "attributes": [1, 2, 3, 1, 4]}
    ]

    conversation = bazinga_tool.create_conversation_encoding(concepts)
    print("Conversation encoding:")
    for seq in conversation:
        print(f"  {seq}: {bazinga_tool.explain(seq)}")
