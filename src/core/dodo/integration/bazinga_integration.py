"""
BAZINGA-DODO Integration Module

Provides integration between BAZINGA and DODO systems
"""
from typing import Dict, Any
from ..dodo_system import DodoSystem


class BazingaDodoIntegration:
    """Integration layer between BAZINGA and DODO systems"""

    def __init__(self, dodo_system: DodoSystem = None):
        """Initialize the integration"""
        self.dodo = dodo_system if dodo_system else DodoSystem()
        self.integration_history = []

    def process_bazinga_pattern(self, pattern_data: Dict[str, Any]) -> Dict[str, Any]:
        """Process a BAZINGA pattern through the DODO system"""
        result = self.dodo.process_input(pattern_data)

        # Record integration
        self.integration_history.append({
            'input': pattern_data,
            'output': result
        })

        return result

    def get_integration_state(self) -> Dict[str, Any]:
        """Get current integration state"""
        return {
            'dodo_state': self.dodo.state.value,
            'interactions': len(self.integration_history)
        }
