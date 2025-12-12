class BazingaPatternManager:
    """
    Manages BAZINGA pattern codes and mappings between pattern names and numerical codes.
    Provides lookup, validation, and pattern utilities separate from encoding/decoding logic.
    """

    def __init__(self):
        """Initialize with default pattern mappings"""
        self.pattern_mapping = {
            "time-trust": "4.1.1.3.5.2.4",
            "harmonic": "3.2.2.1.5.3.2",
            "relationship": "6.1.1.2.3.4.5.2.1",
            "mandelbrot": "5.1.1.0.1.0.1"
        }

    def get_pattern_code(self, pattern_name: str) -> str:
        """
        Retrieves the numerical code for a named pattern.

        Args:
            pattern_name: The name of the pattern to retrieve (e.g., "mandelbrot", "time-trust")

        Returns:
            str: The numerical pattern code (e.g., "5.1.1.0.1.0.1")

        Raises:
            ValueError: If the pattern name is not recognized
        """
        # Normalize pattern name (lowercase, remove dashes/underscores)
        normalized_name = pattern_name.lower().replace('-', '').replace('_', '')

        # Try to match normalized pattern names
        for key, value in self.pattern_mapping.items():
            if key.lower().replace('-', '').replace('_', '') == normalized_name:
                return value

        # If not found, check if it's already a valid pattern code
        if self.is_valid_pattern_code(pattern_name):
            return pattern_name

        raise ValueError(f"Pattern '{pattern_name}' not recognized. Available patterns: {', '.join(self.pattern_mapping.keys())}")

    def is_valid_pattern_code(self, code: str) -> bool:
        """
        Validates if a string represents a valid pattern code.

        Args:
            code: String to check

        Returns:
            bool: True if valid pattern code, False otherwise
        """
        # Check if the code matches the pattern of numbers separated by dots
        import re
        return bool(re.match(r'^(\d+\.)+\d+$', code))

    def register_pattern(self, name: str, code: str) -> None:
        """
        Register a new pattern code or update an existing one.

        Args:
            name: Pattern name
            code: Numerical pattern code

        Raises:
            ValueError: If the code is not a valid pattern code
        """
        if not self.is_valid_pattern_code(code):
            raise ValueError(f"Invalid pattern code: {code}. Must be numbers separated by dots.")

        self.pattern_mapping[name] = code

    def get_all_patterns(self) -> dict:
        """
        Get all registered patterns.

        Returns:
            dict: Dictionary of pattern name to pattern code mappings
        """
        return self.pattern_mapping.copy()

    def get_pattern_segments(self, pattern_name: str) -> list:
        """
        Get the individual numerical segments of a pattern.

        Args:
            pattern_name: Pattern name or code

        Returns:
            list: List of integers representing the pattern segments
        """
        code = self.get_pattern_code(pattern_name)
        return [int(segment) for segment in code.split(".")]
