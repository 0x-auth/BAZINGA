#!/usr/bin/env python3
"""
error_arrow.py - Error-Guided Learning for BAZINGA

"Error of Time IS Arrow of Time"

Key insight: Errors aren't failures - they're the direction of time itself.
By healing errors through recursive memory, we learn while respecting
the arrow of time.

Errors → Opportunities → Harmony

Based on: Recursive State Monitor concept
"""

from typing import Dict, Any, List, Optional, Tuple
from dataclasses import dataclass, field
from datetime import datetime
from enum import Enum
import math


# Constants
PHI = 1.618033988749895


class StateType(Enum):
    """Types of states in the system"""
    NORMAL = "normal"
    ERROR = "error"
    HEALED = "healed"
    SEED = "seed"


@dataclass
class RecursiveState:
    """
    A state that knows ALL previous states.

    This creates recursive memory - each moment contains
    all of history, enabling error healing through pattern recognition.
    """
    id: int
    timestamp: datetime
    content: Any
    state_type: StateType
    description: str
    # RECURSIVE: This state knows ALL previous states
    history: List['RecursiveState'] = field(default_factory=list)
    # Metadata
    coherence: float = 0.0
    healed_from: Optional[int] = None  # ID of error this healed

    def memory_depth(self) -> int:
        """How many states does this state remember?"""
        return len(self.history)

    def __repr__(self):
        return f"<State {self.id}: {self.state_type.value} | depth={self.memory_depth()}>"


class ErrorArrowLearner:
    """
    Learns from errors through the arrow of time.

    Core principles:
    1. Error IS Arrow of Time - shows direction
    2. Recursive Memory - each state knows all history
    3. Auto-Healing - use past successes to fix errors
    4. Convergence - errors → opportunities → harmony

    "Errors are not failures. They are the compass pointing toward truth."
    """

    def __init__(self):
        self.state_history: List[RecursiveState] = []
        self.error_count = 0
        self.healed_count = 0

        # Learning patterns: error → healing solution
        self.healing_patterns: Dict[str, List[RecursiveState]] = {}

        # Phi-weighted learning rate
        self.learning_rate = 1 / PHI  # ~0.618

        # Initialize with SEED
        self._init_seed()

    def _init_seed(self):
        """Initialize the SEED state - the origin"""
        seed = RecursiveState(
            id=0,
            timestamp=datetime.now(),
            content="◊ SEED ◊",
            state_type=StateType.SEED,
            description=f"Initialized. φ = {PHI}",
            history=[],
            coherence=1.0
        )
        self.state_history.append(seed)

    def add_state(self, content: Any, state_type: StateType = StateType.NORMAL,
                  description: str = "", coherence: float = 0.5) -> RecursiveState:
        """
        Add a new state with RECURSIVE memory.

        Each new state knows ALL previous states - this is the key
        to error-guided learning.
        """
        state = RecursiveState(
            id=len(self.state_history),
            timestamp=datetime.now(),
            content=content,
            state_type=state_type,
            description=description,
            history=list(self.state_history),  # Copy ALL history
            coherence=coherence
        )

        self.state_history.append(state)

        # Track errors
        if state_type == StateType.ERROR:
            self.error_count += 1
            # Auto-heal attempt
            healed = self.attempt_healing(state)
            if healed:
                return healed

        return state

    def add_error(self, error_content: Any, description: str = "") -> RecursiveState:
        """Add an error state"""
        return self.add_state(
            content=f"ERROR: {error_content}",
            state_type=StateType.ERROR,
            description=description or "System anomaly detected",
            coherence=0.0  # Errors have zero coherence
        )

    def attempt_healing(self, error_state: RecursiveState) -> Optional[RecursiveState]:
        """
        Attempt to heal an error using recursive memory.

        The key insight: Past successful states contain the patterns
        needed to heal current errors. This is learning from the
        arrow of time.
        """
        if error_state.state_type != StateType.ERROR:
            return None

        # Extract error signature
        error_sig = self._extract_error_signature(error_state.content)

        # Search recursive memory for healing patterns
        past_successes = [
            s for s in error_state.history
            if s.state_type in [StateType.NORMAL, StateType.HEALED]
            and s.coherence >= 0.5
        ]

        if not past_successes:
            return None

        # Find best healing candidate using φ-weighted scoring
        best_healer = max(past_successes, key=lambda s: self._healing_score(s, error_state))

        # Apply healing
        self.healed_count += 1

        healing_content = self._generate_healing(best_healer, error_state)

        healed_state = RecursiveState(
            id=len(self.state_history),
            timestamp=datetime.now(),
            content=healing_content,
            state_type=StateType.HEALED,
            description=f"Auto-healed using pattern from state {best_healer.id}",
            history=list(self.state_history),
            coherence=best_healer.coherence * self.learning_rate,
            healed_from=error_state.id
        )

        self.state_history.append(healed_state)

        # Learn this pattern for future
        self.healing_patterns[error_sig] = self.healing_patterns.get(error_sig, []) + [healed_state]

        return healed_state

    def _extract_error_signature(self, error_content: Any) -> str:
        """Extract a signature from error for pattern matching"""
        content_str = str(error_content).lower()

        # Common error patterns
        signatures = {
            'permission': 'access_error',
            'not found': 'missing_error',
            'timeout': 'timing_error',
            'memory': 'resource_error',
            'invalid': 'validation_error',
            'connection': 'network_error',
            'overflow': 'boundary_error'
        }

        for pattern, sig in signatures.items():
            if pattern in content_str:
                return sig

        return 'general_error'

    def _healing_score(self, candidate: RecursiveState, error: RecursiveState) -> float:
        """
        Calculate how well a candidate can heal an error.

        Uses φ-weighted factors:
        - Recency (more recent = better)
        - Coherence (higher coherence = better)
        - Memory depth (deeper memory = more context)
        """
        # Recency score (φ-decay)
        time_diff = (error.timestamp - candidate.timestamp).total_seconds()
        recency = math.exp(-time_diff / (3600 * PHI))  # φ-hour decay

        # Coherence score
        coherence = candidate.coherence

        # Memory depth score
        depth_score = min(candidate.memory_depth() / 100, 1.0)

        # φ-weighted combination
        return (recency * PHI + coherence + depth_score / PHI) / (1 + PHI + 1/PHI)

    def _generate_healing(self, healer: RecursiveState, error: RecursiveState) -> str:
        """Generate healing solution from successful state"""
        return f"Healed[{error.id}→{healer.id}]: Applied pattern '{healer.content}'"

    def get_convergence(self) -> float:
        """
        Calculate convergence rate: healed / errors

        100% = all errors healed = perfect learning
        0% = no healing = no learning from errors
        """
        if self.error_count == 0:
            return 1.0  # No errors = perfect convergence
        return self.healed_count / self.error_count

    def get_arrow_of_time(self) -> Dict[str, Any]:
        """
        Get the current arrow of time state.

        The arrow points in the direction of increasing entropy (errors)
        but learning allows us to surf along it toward harmony.
        """
        convergence = self.get_convergence()

        # Arrow direction based on recent error rate
        recent_states = self.state_history[-10:] if len(self.state_history) >= 10 else self.state_history
        recent_errors = sum(1 for s in recent_states if s.state_type == StateType.ERROR)
        recent_healed = sum(1 for s in recent_states if s.state_type == StateType.HEALED)

        if recent_healed > recent_errors:
            direction = "toward_harmony"
            symbol = "◊◊◊"
        elif recent_healed == recent_errors:
            direction = "balanced"
            symbol = "◊◊"
        else:
            direction = "toward_entropy"
            symbol = "◊"

        return {
            'total_states': len(self.state_history),
            'error_count': self.error_count,
            'healed_count': self.healed_count,
            'convergence': convergence,
            'convergence_percent': f"{convergence * 100:.1f}%",
            'direction': direction,
            'symbol': symbol,
            'principle': "Errors → Opportunities → Harmony"
        }

    def learn_from_sequence(self, sequence: List[Tuple[Any, bool]]) -> Dict[str, Any]:
        """
        Learn from a sequence of (content, is_error) pairs.

        This simulates processing real data where some states
        are errors and others are successes.
        """
        results = {
            'processed': 0,
            'errors': 0,
            'healed': 0,
            'states': []
        }

        for content, is_error in sequence:
            if is_error:
                state = self.add_error(content)
                results['errors'] += 1
            else:
                state = self.add_state(content, coherence=0.7)

            results['processed'] += 1
            results['states'].append({
                'id': state.id,
                'type': state.state_type.value,
                'memory_depth': state.memory_depth()
            })

        # Count auto-healed
        results['healed'] = self.healed_count - (self.healed_count - results['errors'])
        results['arrow'] = self.get_arrow_of_time()

        return results

    def get_recursive_memory_stats(self) -> Dict[str, Any]:
        """Get statistics about recursive memory"""
        if not self.state_history:
            return {'total': 0}

        depths = [s.memory_depth() for s in self.state_history]
        coherences = [s.coherence for s in self.state_history]

        return {
            'total_states': len(self.state_history),
            'max_depth': max(depths),
            'avg_depth': sum(depths) / len(depths),
            'avg_coherence': sum(coherences) / len(coherences),
            'type_distribution': {
                'normal': sum(1 for s in self.state_history if s.state_type == StateType.NORMAL),
                'error': sum(1 for s in self.state_history if s.state_type == StateType.ERROR),
                'healed': sum(1 for s in self.state_history if s.state_type == StateType.HEALED),
                'seed': sum(1 for s in self.state_history if s.state_type == StateType.SEED)
            },
            'healing_patterns_learned': len(self.healing_patterns)
        }


# Standalone test
if __name__ == "__main__":
    print("=" * 60)
    print("ERROR ARROW LEARNING TEST")
    print("'Error of Time IS Arrow of Time'")
    print("=" * 60)
    print()

    learner = ErrorArrowLearner()

    print("Initial state:")
    print(f"  {learner.get_arrow_of_time()}")
    print()

    # Simulate a sequence of states and errors
    print("Processing sequence...")
    sequence = [
        ("System initialized", False),
        ("Processing data", False),
        ("Connection timeout", True),  # Error
        ("Retrying connection", False),
        ("Data validated", False),
        ("Memory overflow", True),  # Error
        ("Cleanup completed", False),
        ("Invalid input received", True),  # Error
        ("Input sanitized", False),
        ("Process completed", False),
    ]

    result = learner.learn_from_sequence(sequence)

    print(f"\nProcessed: {result['processed']} states")
    print(f"Errors encountered: {result['errors']}")
    print(f"Auto-healed: {learner.healed_count}")
    print()

    arrow = learner.get_arrow_of_time()
    print(f"Arrow of Time:")
    print(f"  Direction: {arrow['direction']}")
    print(f"  Convergence: {arrow['convergence_percent']}")
    print(f"  Symbol: {arrow['symbol']}")
    print(f"  Principle: {arrow['principle']}")
    print()

    memory = learner.get_recursive_memory_stats()
    print(f"Recursive Memory:")
    print(f"  Total states: {memory['total_states']}")
    print(f"  Max depth: {memory['max_depth']}")
    print(f"  Avg coherence: {memory['avg_coherence']:.3f}")
    print(f"  Patterns learned: {memory['healing_patterns_learned']}")
    print()

    print("=" * 60)
    print("Errors → Opportunities → Harmony")
    print("=" * 60)
