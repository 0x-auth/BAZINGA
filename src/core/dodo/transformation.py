# transformation.py - Transformation functionality for DODO System
from typing import Dict, Any, Callable
from .states import ProcessingState

class TransformationPair:
    """Represents a pair of transformations that can be applied to data"""

    def __init__(self, name: str, forward_transform: Callable,
                 reverse_transform: Callable, applicable_states = None):
        self.name = name
        self.forward = forward_transform
        self.reverse = reverse_transform
        self.applicable_states = applicable_states or [
            ProcessingState.TWO_D,
            ProcessingState.PATTERN,
            ProcessingState.TRANSITION,
            ProcessingState.QUANTUM
        ]

    def is_applicable(self, data: Dict[str, Any], state: ProcessingState) -> bool:
        """Check if this transformation pair is applicable to the data in the current state"""
        return state in self.applicable_states

    def apply(self, data: Dict[str, Any], reverse = False) -> Dict[str, Any]:
        """Apply the transformation to the data"""
        transform_func = self.reverse if reverse else self.forward
        return transform_func(data)
