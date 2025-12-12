# states.py - Processing States for DODO System
from enum import Enum

class ProcessingState(Enum):
    TWO_D = "2D"           # Linear thinking, direct processing
    PATTERN = "PATTERN"    # Pattern recognition state
    TRANSITION = "TRANSITION"  # Moving between states
    COMPLEX = "COMPLEX"    # Multi-dimensional thinking
