# harmonics.py - Implementation of the Harmonic Framework
from typing import Dict, Any, List
import math

class HarmonicFramework:
    """Framework for calculating harmonic relationships in data"""

    def __init__(self):
        self.base_frequency = 1.0
        self.harmonic_cache = {}
        self.phi = 1.618033988749895  # Golden ratio

    def calculate(self, data: Dict[str, Any]) -> Dict[str, float]:
        """Calculate harmonics for the given data"""
        result = {}

        # Extract values for calculation
        values = self._extract_numeric_values(data)

        if not values:
            return {"base": self.base_frequency}

        # Calculate base frequency from data
        self.base_frequency = sum(values) / len(values)
        result["base"] = self.base_frequency

        # Calculate harmonics
        result["first"] = self.base_frequency * 2
        result["second"] = self.base_frequency * 3
        result["third"] = self.base_frequency * 4

        # Calculate resonance
        result["resonance"] = self._calculate_resonance(values)

        # Calculate phi_ratio (golden ratio resonance)
        result["phi_ratio"] = self._calculate_phi_ratio(values)

        return result

    def _extract_numeric_values(self, data: Dict[str, Any]) -> List[float]:
        """Extract numeric values from the data dictionary"""
        values = []

        def extract_recursively(item):
            if isinstance(item, (int, float)):
                values.append(float(item))
            elif isinstance(item, dict):
                for v in item.values():
                    extract_recursively(v)
            elif isinstance(item, (list, tuple)):
                for v in item:
                    extract_recursively(v)

        extract_recursively(data)
        return values

    def _calculate_resonance(self, values: List[float]) -> float:
        """Calculate the resonance value for a set of numbers"""
        if not values:
            return 0.0

        # Simple resonance calculation
        product = 1.0
        for v in values:
            product *= (1.0 + abs(v))

        return math.log(product) / len(values)

    def calculate_time_spacing(self, start: float, end: float) -> List[float]:
        """Calculate harmonic time spacings between start and end"""
        duration = end - start
        return [
            start + (duration * 0.382),  # Golden ratio first point
            start + (duration * 0.618),  # Golden ratio second point
            start + (duration * 0.5)     # Midpoint
        ]

    def _calculate_phi_ratio(self, values: List[float]) -> float:
        """Calculate golden ratio resonance from values"""
        if not values:
            return 0.5

        # Calculate how close the ratio of consecutive values is to phi
        phi_distances = []
        for i in range(len(values) - 1):
            if values[i] != 0:
                ratio = abs(values[i + 1] / values[i])
                distance = abs(ratio - self.phi)
                phi_distances.append(1.0 / (1.0 + distance))

        if phi_distances:
            return sum(phi_distances) / len(phi_distances)
        return 0.5
