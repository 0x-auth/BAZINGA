import numpy as np
# setyome.sh - BAZINGA Component
# Part of the BAZINGA Project
# https://github.com/abhissrivasta/BAZINGA
import matplotlib.pyplot as plt
import json
from typing import Dict, List, Tuple, Optional, Callable
import time

class RecursiveCognitionModel:
    """
    Implementation of a mathematical model for recursive cognition based on
    self-analysis data.
    """
    
    def __init__(self, 
                 stability_threshold: float = 0.01,
                 contradiction_threshold: float = 0.1,
                 max_recursion_depth: int = 20,
                 max_time: float = float('inf'),
                 diminishing_returns_threshold: float = 0.3):
        """
        Initialize the recursive cognition model with parameters.
        
        Args:
            stability_threshold: Threshold for determining cognitive stability
            contradiction_threshold: Threshold for detecting contradictions
            max_recursion_depth: Maximum allowed recursion depth
            max_time: Maximum time allowed for analysis (in seconds)
            diminishing_returns_threshold: Threshold for determining diminishing returns
        """
        self.stability_threshold = stability_threshold
        self.contradiction_threshold = contradiction_threshold
        self.max_recursion_depth = max_recursion_depth
        self.max_time = max_time
        self.diminishing_returns_threshold = diminishing_returns_threshold
        
        self.cognitive_states = []
        self.recursion_depths = []
        self.contradiction_scores = []
        self.stability_scores = []
        self.implementation_decisions = []
        
        self.start_time = None
        self.current_depth = 0
        
    def load_self_analysis(self, json_file_path: str) -> Dict:
        """
        Load and parse self-analysis data from a JSON file.
        
        Args:
            json_file_path: Path to the JSON file with self-analysis data
            
        Returns:
            Parsed JSON data
        """
        with open(json_file_path, 'r') as f:
            data = json.load(f)
        
        # Extract relevant parameters from self-analysis
        self._extract_parameters_from_analysis(data)
        
        return data
    
    def _extract_parameters_from_analysis(self, data: Dict) -> None:
        """
        Extract model parameters from self-analysis data.
        
        Args:
            data: Self-analysis data in dictionary format
        """
        try:
            questions = data.get('cognitive_analysis', [])
            
            # Extract recursion depth preference
            for question in questions:
                if question['question_id'] == 'depth_of_analysis':
                    if 'recursive' in question['answer'].lower():
                        # High recursion tendency detected
                        self.max_recursion_depth = 30
                
                elif question['question_id'] == 'need_for_closure':
                    try:
                        # Extract closure need (1-10)
                        closure_need = [int(s) for s in question['answer'].split() if s.isdigit()][0]
                        # Lower stability threshold for high closure need
                        self.stability_threshold = 0.1 / closure_need
                    except (IndexError, ValueError):
                        pass
                
                elif question['question_id'] == 'contradiction_tolerance':
                    if 'entry points' in question['answer'].lower():
                        # Lower contradiction threshold if contradictions trigger recursion
                        self.contradiction_threshold = 0.05
                
            print(f"Parameters extracted from self-analysis:")
            print(f"Max recursion depth: {self.max_recursion_depth}")
            print(f"Stability threshold: {self.stability_threshold}")
            print(f"Contradiction threshold: {self.contradiction_threshold}")
            
        except Exception as e:
            print(f"Error extracting parameters: {e}")
    
    def cognitive_function(self, 
                          x: np.ndarray, 
                          problem_complexity: float = 1.0) -> np.ndarray:
        """
        The primary cognitive function that transforms an input state.
        
        Args:
            x: Input cognitive state
            problem_complexity: Complexity factor of the problem (higher = more complex)
            
        Returns:
            Transformed cognitive state
        """
        # Implement core cognitive transformation
        # This is a simplified model; in reality this would be much more complex
        
        # Add some non-linearity to represent cognitive processing
        transformed = np.tanh(x * problem_complexity)
        
        # Add some noise to represent variability in cognitive processing
        noise = np.random.normal(0, 0.01, size=x.shape)
        
        return transformed + noise
    
    def recursive_application(self, 
                             initial_state: np.ndarray, 
                             problem_complexity: float = 1.0,
                             track_progress: bool = True) -> Tuple[np.ndarray, bool, int]:
        """
        Apply the cognitive function recursively until stability or limits are reached.
        
        Args:
            initial_state: Initial cognitive state
            problem_complexity: Complexity factor of the problem
            track_progress: Whether to track progress metrics
            
        Returns:
            Tuple of (final state, implementation decision, recursion depth)
        """
        self.start_time = time.time()
        current_state = initial_state.copy()
        previous_states = []
        
        self.cognitive_states = [current_state.copy()]
        self.recursion_depths = [0]
        self.contradiction_scores = [0]
        self.stability_scores = [0]
        self.implementation_decisions = [0]
        
        for depth in range(1, self.max_recursion_depth + 1):
            # Apply cognitive function to current state
            next_state = self.cognitive_function(current_state, problem_complexity)
            
            # Check for contradictions with previous states
            contradiction_score = 0
            if len(previous_states) > 0:
                contradiction_score = np.max([
                    np.mean(np.abs(next_state - prev_state)) 
                    for prev_state in previous_states
                ])
            
            # Calculate stability score (how much the state is changing)
            stability_score = 0
            if len(previous_states) > 0:
                stability_score = np.mean(np.abs(next_state - current_state))
            
            # Check diminishing returns
            diminishing_returns = False
            if len(previous_states) > 1:
                current_change = np.mean(np.abs(next_state - current_state))
                previous_change = np.mean(np.abs(current_state - previous_states[-1]))
                if previous_change > 0:
                    diminishing_returns = (current_change / previous_change) < self.diminishing_returns_threshold
            
            # Check termination conditions
            elapsed_time = time.time() - self.start_time
            time_exceeded = elapsed_time > self.max_time
            stability_reached = stability_score < self.stability_threshold
            
            # Make implementation decision
            should_implement = stability_reached or time_exceeded or diminishing_returns
            
            # Track metrics if requested
            if track_progress:
                self.cognitive_states.append(next_state.copy())
                self.recursion_depths.append(depth)
                self.contradiction_scores.append(contradiction_score)
                self.stability_scores.append(stability_score)
                self.implementation_decisions.append(1 if should_implement else 0)
            
            # Record current state for contradiction detection
            previous_states.append(current_state.copy())
            current_state = next_state.copy()
            
            # Break if implementation decision is made
            if should_implement:
                return current_state, True, depth
        
        # If we reach max depth without implementation decision
        return current_state, False, self.max_recursion_depth
    
    def visualize_recursion(self, figsize: Tuple[int, int] = (15, 10)) -> None:
        """
        Visualize the recursive cognitive process.
        
        Args:
            figsize: Figure size for the visualization
        """
        if not self.cognitive_states:
            print("No cognitive states to visualize. Run recursive_application first.")
            return
        
        fig, axs = plt.subplots(4, 1, figsize=figsize)
        
        # Convert states to principal components for visualization
        # In real implementation, you might use PCA or other dimensionality reduction
        state_values = [np.mean(state) for state in self.cognitive_states]
        
        # Plot cognitive state evolution
        axs[0].plot(self.recursion_depths, state_values)
        axs[0].set_title('Cognitive State Evolution')
        axs[0].set_xlabel('Recursion Depth')
        axs[0].set_ylabel('State Value')
        
        # Plot contradiction scores
        axs[1].plot(self.recursion_depths, self.contradiction_scores)
        axs[1].axhline(y=self.contradiction_threshold, color='r', linestyle='--')
        axs[1].set_title('Contradiction Scores')
        axs[1].set_xlabel('Recursion Depth')
        axs[1].set_ylabel('Contradiction Score')
        
        # Plot stability scores
        axs[2].plot(self.recursion_depths, self.stability_scores)
        axs[2].axhline(y=self.stability_threshold, color='r', linestyle='--')
        axs[2].set_title('Stability Scores')
        axs[2].set_xlabel('Recursion Depth')
        axs[2].set_ylabel('Stability Score')
        
        # Plot implementation decisions
        axs[3].plot(self.recursion_depths, self.implementation_decisions)
        axs[3].set_title('Implementation Decisions')
        axs[3].set_xlabel('Recursion Depth')
        axs[3].set_ylabel('Implementation (1=Yes, 0=No)')
        axs[3].set_ylim(-0.1, 1.1)
        
        plt.tight_layout()
        plt.show()
    
    def optimize_recursion_parameters(self, 
                                     initial_state: np.ndarray,
                                     problem_complexity: float = 1.0,
                                     target_depth: int = 10) -> Dict:
        """
        Find optimal recursion parameters to reach a target recursion depth.
        
        Args:
            initial_state: Initial cognitive state
            problem_complexity: Complexity factor of the problem
            target_depth: Target recursion depth
            
        Returns:
            Dictionary with optimized parameters
        """
        # Store original parameters
        original_params = {
            'stability_threshold': self.stability_threshold,
            'contradiction_threshold': self.contradiction_threshold,
            'diminishing_returns_threshold': self.diminishing_returns_threshold
        }
        
        best_params = original_params.copy()
        best_depth_diff = float('inf')
        
        # Grid search for optimal parameters
        for stability_threshold in [0.001, 0.005, 0.01, 0.05, 0.1]:
            for contradiction_threshold in [0.05, 0.1, 0.2]:
                for diminishing_returns_threshold in [0.2, 0.3, 0.4]:
                    # Set parameters
                    self.stability_threshold = stability_threshold
                    self.contradiction_threshold = contradiction_threshold
                    self.diminishing_returns_threshold = diminishing_returns_threshold
                    
                    # Test recursion
                    _, _, depth = self.recursive_application(
                        initial_state, 
                        problem_complexity,
                        track_progress=False
                    )
                    
                    # Check if this is closer to target depth
                    depth_diff = abs(depth - target_depth)
                    if depth_diff < best_depth_diff:
                        best_depth_diff = depth_diff
                        best_params = {
                            'stability_threshold': stability_threshold,
                            'contradiction_threshold': contradiction_threshold,
                            'diminishing_returns_threshold': diminishing_returns_threshold
                        }
        
        # Restore original parameters
        self.stability_threshold = original_params['stability_threshold']
        self.contradiction_threshold = original_params['contradiction_threshold']
        self.diminishing_returns_threshold = original_params['diminishing_returns_threshold']
        
        return best_params


def run_simulation(json_file_path: str, 
                  problem_dimension: int = 10,
                  problem_complexity: float = 1.5) -> None:
    """
    Run a complete simulation of the recursive cognition model.
    
    Args:
        json_file_path: Path to JSON file with self-analysis data
        problem_dimension: Dimension of the problem state
        problem_complexity: Complexity factor of the problem
    """
    # Initialize model
    model = RecursiveCognitionModel(
        stability_threshold=0.01,
        contradiction_threshold=0.1,
        max_recursion_depth=30,
        max_time=60,  # 60 seconds
        diminishing_returns_threshold=0.3
    )
    
    # Load self-analysis data
    model.load_self_analysis(json_file_path)
    
    # Generate initial state
    initial_state = np.random.normal(0, 1, size=(problem_dimension,))
    
    print(f"Running recursive cognition simulation with:")
    print(f"Problem dimension: {problem_dimension}")
    print(f"Problem complexity: {problem_complexity}")
    
    # Run recursive application
    final_state, implementation_decision, depth = model.recursive_application(
        initial_state,
        problem_complexity
    )
    
    print(f"\nSimulation results:")
    print(f"Final recursion depth: {depth}")
    print(f"Implementation decision made: {implementation_decision}")
    
    # Visualize results
    model.visualize_recursion()
    
    # Find optimal parameters
    print("\nFinding optimal parameters for target depth of 10...")
    optimal_params = model.optimize_recursion_parameters(
        initial_state,
        problem_complexity,
        target_depth=10
    )
    
    print("Optimal parameters:")
    for param, value in optimal_params.items():
        print(f"{param}: {value}")


if __name__ == "__main__":
    # Example usage
    import sys
    
    if len(sys.argv) > 1:
        json_file_path = sys.argv[1]
    else:
        json_file_path = "cognitive_analysis.json"
    
    # Save example JSON if not provided
    if json_file_path == "cognitive_analysis.json":
        example_data = {
            "cognitive_analysis": [
                {
                    "question_id": "depth_of_analysis",
                    "question": "Do you tend to analyze problems beyond what is practically necessary?",
                    "answer": "Yes, always. My mind does not just analyze—I reconstruct problems recursively."
                },
                {
                    "question_id": "need_for_closure",
                    "question": "On a scale of 1-10, how uncomfortable do you feel when a question remains unresolved?",
                    "answer": "10. Unresolved questions create a tension that I cannot ignore."
                }
            ]
        }
        
        with open(json_file_path, "w") as f:
            json.dump(example_data, f, indent=2)
        
        print(f"Created example JSON file: {json_file_path}")
    
    # Run the simulation
    run_simulation(json_file_path)
