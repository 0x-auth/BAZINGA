# dodo_system.py - Core implementation of DODO System
from typing import Dict, Any, Callable, List
from .harmonics import HarmonicFramework
from .states import ProcessingState
from .transformation import TransformationPair
from .time_trust import TimeTracker, TrustTracker

class DodoSystem:
    """Core implementation of the DODO System for 2D processing"""

    def __init__(self):
        self.state = ProcessingState.TWO_D
        self.harmonics = HarmonicFramework()  # Changed to match what test is looking for
        self.time_tracker = TimeTracker()
        self.trust_tracker = TrustTracker()
        self.transformation_pairs = []
        self.data_cache = {}

    def add_transformation_pair(self, pair: TransformationPair) -> None:
        """Add a transformation pair to the system"""
        self.transformation_pairs.append(pair)

    def process_input(self, input_data: Dict[str, Any]) -> Dict[str, Any]:
        """Process input through the system based on current state"""
        # Track time
        self.time_tracker.add_time_point({"input": input_data, "state": self.state})

        # Apply transformations based on state
        result = None
        if self.state == ProcessingState.TWO_D:
            result = self._process_2d(input_data)
        elif self.state == ProcessingState.PATTERN:
            result = self._process_pattern(input_data)
        elif self.state == ProcessingState.TRANSITION:
            result = self._process_transition(input_data)
        else:
            result = self._process_quantum(input_data)

        # Update trust
        trust_level = self.trust_tracker.update_trust_level(result)
        result["trust_level"] = trust_level

        return result

    def _process_2d(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Process in 2D linear thinking mode"""
        result = {"success": True, "mode": "2D", "data": {}}

        # Apply each transformation pair
        for pair in self.transformation_pairs:
            if pair.is_applicable(data, self.state):
                transform_result = pair.apply(data)
                result["data"][pair.name] = transform_result

        # Apply harmonics
        harmonic_values = self.harmonics.calculate(data)
        result["harmonics"] = harmonic_values

        return result

    def _process_pattern(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Process in pattern recognition mode"""
        # Simplified implementation
        return {"success": True, "mode": "PATTERN"}

    def _process_transition(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Process in transition mode"""
        # Simplified implementation
        return {"success": True, "mode": "TRANSITION"}

    def _process_quantum(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Process in quantum mode"""
        # Simplified implementation
        return {"success": True, "mode": "QUANTUM"}

    def change_state(self, new_state: ProcessingState) -> None:
        """Change the processing state of the system"""
        self.state = new_state
