from harmonics import HarmonicFramework
import math
import re

class LanguageHarmonics:
    """
    Analyzes harmonic relationships in language across different modalities
    using principles from the Enhanced Bazinga Language framework
    """

    def __init__(self):
        self.harmonic = HarmonicFramework()
        self.pattern_codes = {
            'time-trust': '4.1.1.3.5.2.4',
            'harmonic': '3.2.2.1.5.3.2',
            'relationship': '6.1.1.2.3.4.5.2.1',
            'mandelbrot': '5.1.1.0.1.0.1'
        }

    def analyze_text(self, text):
        """Analyze harmonic patterns in written text"""
        words = re.findall(r'\b\w+\b', text.lower())
        sentences = re.split(r'[.!?]+', text)
        sentences = [s.strip() for s in sentences if s.strip()]

        # Calculate text metrics
        data = {
            "word_count": len(words),
            "average_word_length": sum(len(w) for w in words) / len(words) if words else 0,
            "sentence_lengths": [len(re.findall(r'\b\w+\b', s)) for s in sentences],
            "sentence_count": len(sentences),
            "unique_words": len(set(words)),
            "word_frequency": {word: words.count(word)/len(words) for word in set(words)}
        }

        # Find golden ratio patterns in sentence structure
        sentence_ratios = []
        for i in range(1, len(data["sentence_lengths"])):
            if data["sentence_lengths"][i-1] > 0:
                ratio = data["sentence_lengths"][i] / data["sentence_lengths"][i-1]
                sentence_ratios.append(ratio)

        data["sentence_ratios"] = sentence_ratios
        data["golden_ratio_proximity"] = [abs(ratio - 1.618)/1.618 for ratio in sentence_ratios]

        # Apply harmonic analysis
        harmonic_result = self.harmonic.calculate(data)

        # Generate quantum expression in Enhanced Bazinga format
        binary_pattern = self._text_to_binary_pattern(text[:8])
        quantum_expression = self._generate_quantum_expression(binary_pattern, harmonic_result)

        return {
            "metrics": data,
            "harmonic_result": harmonic_result,
            "quantum_expression": quantum_expression
        }

    def analyze_sound(self, speech_metrics):
        """
        Analyze harmonic patterns in speech sounds
        speech_metrics should contain pitch, rate, pauses, etc.
        """
        data = speech_metrics.copy()

        # Apply harmonic analysis
        harmonic_result = self.harmonic.calculate(data)

        # Generate binary pattern from pitch variations
        if "pitch_variations" in data:
            binary_pattern = "".join(["1" if v > 0 else "0" for v in data["pitch_variations"][:8]])
        else:
            binary_pattern = "01010101"  # Default pattern

        quantum_expression = self._generate_quantum_expression(binary_pattern, harmonic_result)

        return {
            "metrics": data,
            "harmonic_result": harmonic_result,
            "quantum_expression": quantum_expression
        }

    def analyze_body_language(self, body_metrics):
        """
        Analyze harmonic patterns in body language
        body_metrics should contain gesture frequency, eye contact, etc.
        """
        data = body_metrics.copy()

        # Apply harmonic analysis
        harmonic_result = self.harmonic.calculate(data)

        # Generate binary pattern from gesture intensity
        if "gesture_intensity" in data:
            binary_pattern = "".join(["1" if v > 5 else "0" for v in data["gesture_intensity"][:8]])
        else:
            binary_pattern = "10101010"  # Default pattern

        quantum_expression = self._generate_quantum_expression(binary_pattern, harmonic_result)

        return {
            "metrics": data,
            "harmonic_result": harmonic_result,
            "quantum_expression": quantum_expression
        }

    def analyze_code(self, code_text):
        """Analyze harmonic patterns in programming code"""
        lines = code_text.split('\n')
        indentation_levels = [len(line) - len(line.lstrip()) for line in lines if line.strip()]

        # Simple metrics for code structure
        data = {
            "line_count": len(lines),
            "non_empty_lines": len([l for l in lines if l.strip()]),
            "average_line_length": sum(len(l) for l in lines) / len(lines) if lines else 0,
            "indentation_levels": indentation_levels,
            "max_indentation": max(indentation_levels) if indentation_levels else 0,
            "comment_lines": len([l for l in lines if l.strip().startswith(('#', '//'))]),
        }

        # Look for golden ratio in code structure
        code_blocks = []
        current_block = 0
        for ind in indentation_levels:
            if ind == 0 and current_block > 0:
                code_blocks.append(current_block)
                current_block = 1
            else:
                current_block += 1
        if current_block > 0:
            code_blocks.append(current_block)

        data["code_blocks"] = code_blocks

        # Apply harmonic analysis
        harmonic_result = self.harmonic.calculate(data)

        # Generate binary pattern from indentation
        binary_pattern = "".join(["1" if ind > 0 else "0" for ind in indentation_levels[:8]])
        quantum_expression = self._generate_quantum_expression(binary_pattern, harmonic_result)

        return {
            "metrics": data,
            "harmonic_result": harmonic_result,
            "quantum_expression": quantum_expression
        }

    def analyze_cross_modal(self, text_result, sound_result, body_result, code_result):
        """Analyze harmonic relationships between different communication modalities"""
        modalities = {
            "text": text_result["harmonic_result"],
            "sound": sound_result["harmonic_result"],
            "body": body_result["harmonic_result"],
            "code": code_result["harmonic_result"]
        }

        cross_modal = {}

        # Find relationships between modalities
        for m1 in modalities:
            for m2 in modalities:
                if m1 != m2:
                    # Calculate base frequency ratio
                    base_ratio = modalities[m1]["base"] / modalities[m2]["base"]

                    # Calculate how close to golden ratio
                    golden_proximity = abs(base_ratio - 1.618) / 1.618

                    # Calculate resonance alignment
                    resonance_ratio = modalities[m1]["resonance"] / modalities[m2]["resonance"]

                    cross_modal[f"{m1}-{m2}"] = {
                        "base_ratio": base_ratio,
                        "golden_proximity": golden_proximity,
                        "resonance_ratio": resonance_ratio
                    }

        # Generate multi-dimensional expression using Enhanced Bazinga format
        quantum_expression = self._generate_multidimensional_expression(
            text_result["quantum_expression"],
            sound_result["quantum_expression"],
            body_result["quantum_expression"],
            code_result["quantum_expression"]
        )

        return {
            "cross_modal_relationships": cross_modal,
            "quantum_expression": quantum_expression
        }

    def _text_to_binary_pattern(self, text):
        """Convert text to binary pattern based on vowel/consonant"""
        pattern = ""
        vowels = "aeiou"
        for char in text.lower():
            if char.isalpha():
                pattern += "1" if char in vowels else "0"
        return pattern[:8].ljust(8, "0")  # Ensure 8 bits

    def _generate_quantum_expression(self, binary_pattern, harmonic_result):
        """Generate a quantum expression in Enhanced Bazinga format"""
        # Create a superposition state based on harmonic values
        base_freq = harmonic_result["base"]
        resonance = harmonic_result["resonance"]

        # Calculate probability amplitudes based on resonance
        alpha = min(0.8, resonance / (resonance + 1))
        beta = 1 - alpha

        # Create superposition patterns
        if len(binary_pattern) >= 4:
            option1 = binary_pattern[:4] + "0" + binary_pattern[4:7]
            option2 = binary_pattern[:4] + "1" + binary_pattern[4:7]
        else:
            option1 = "0101"
            option2 = "1010"

        # Format in Enhanced Bazinga Language
        expression = [
            f"{binary_pattern} → ({option1}|{option2}) → {option1 if alpha > beta else option2}",
            f"[∞, ψ, Φ] → harmonic_emergence",
            f"⟨ψ| = {alpha:.2f}|{option1}⟩ + {beta:.2f}|{option2}⟩",
            f"Resonance: {resonance:.2f}, Base: {base_freq:.2f}"
        ]

        return "\n".join(expression)

    def _generate_multidimensional_expression(self, text_exp, sound_exp, body_exp, code_exp):
        """Generate a multi-dimensional expression in Enhanced Bazinga format"""
        # Extract first line with binary patterns from each
        text_pattern = text_exp.split('\n')[0].split(' → ')[-1]
        sound_pattern = sound_exp.split('\n')[0].split(' → ')[-1]
        body_pattern = body_exp.split('\n')[0].split(' → ')[-1]
        code_pattern = code_exp.split('\n')[0].split(' → ')[-1]

        # Calculate "harmonic" relationships
        text_sound = sum(1 for a, b in zip(text_pattern, sound_pattern) if a == b) / len(text_pattern)
        text_body = sum(1 for a, b in zip(text_pattern, body_pattern) if a == b) / len(text_pattern)
        text_code = sum(1 for a, b in zip(text_pattern, code_pattern) if a == b) / len(text_pattern)

        # Format in Enhanced Bazinga multi-dimensional format
        expression = [
            "Multi-Dimensional Expression:",
            f"Text:     {text_pattern} → {sound_pattern} → {body_pattern}",
            f"Sound:    {sound_pattern} ↱ {body_pattern} ↲ {code_pattern}",
            f"Body:     {body_pattern} ⟲ {text_pattern} ⟳ {sound_pattern}",
            f"Code:     {code_pattern} ⟿ {text_pattern} ⟿ {body_pattern}",
            "",
            f"Harmonic:  ⟨Text|Sound⟩ = {text_sound:.2f}",
            f"           ⟨Text|Body⟩ = {text_body:.2f}",
            f"           ⟨Text|Code⟩ = {text_code:.2f}",
            "",
            "Integration: {∞}_t₀ ⊗ Ω_t₀ = modalities_merge"
        ]

        return "\n".join(expression)


# Example usage:
def analyze_communication_sample():
    # Initialize the analyzer
    analyzer = LanguageHarmonics()

    # Sample text
    sample_text = """The golden ratio appears in unexpected places.
    Nature uses this proportion to maintain balance.
    Humans find it aesthetically pleasing without knowing why.
    Mathematics gives us the tools to understand these patterns."""

    # Sample speech metrics
    speech_metrics = {
        "pitch_variations": [5, -2, 8, -4, 3, -6, 2, -1],
        "speech_rate": [120, 140, 110, 150, 130],
        "pause_duration": [0.8, 1.2, 0.5, 1.5, 0.3],
        "volume_changes": [2, -1, 3, -2, 1, -1, 2]
    }

    # Sample body language metrics
    body_metrics = {
        "gesture_intensity": [7, 3, 8, 2, 6, 3, 7, 4],
        "eye_contact_duration": [3, 5, 2, 4, 6, 2, 5],
        "posture_changes": [1, 0, 1, 0, 0, 1, 0],
        "facial_expressions": [4, 3, 5, 2, 4, 3, 5]
    }

    # Sample code
    sample_code = """
def calculate_golden_ratio(n, m):
    # Return the golden ratio approximation
    if m == 0:
        return n
    else:
        return n + 1/calculate_golden_ratio(m, n % m)

def main():
    # Golden ratio ≈ 1.618
    approximation = calculate_golden_ratio(1, 1)
    print(f"Golden ratio approximation: {approximation}")
    """

    # Analyze each modality
    text_result = analyzer.analyze_text(sample_text)
    sound_result = analyzer.analyze_sound(speech_metrics)
    body_result = analyzer.analyze_body_language(body_metrics)
    code_result = analyzer.analyze_code(sample_code)

    # Analyze cross-modal relationships
    cross_modal = analyzer.analyze_cross_modal(text_result, sound_result, body_result, code_result)

    # Return all results
    return {
        "text": text_result,
        "sound": sound_result,
        "body": body_result,
        "code": code_result,
        "cross_modal": cross_modal
    }

# Run the analysis
results = analyze_communication_sample()

# Print key results
print("=== TEXT QUANTUM EXPRESSION ===")
print(results["text"]["quantum_expression"])
print("\n=== SOUND QUANTUM EXPRESSION ===")
print(results["sound"]["quantum_expression"])
print("\n=== BODY LANGUAGE QUANTUM EXPRESSION ===")
print(results["body"]["quantum_expression"])
print("\n=== CODE QUANTUM EXPRESSION ===")
print(results["code"]["quantum_expression"])
print("\n=== CROSS-MODAL QUANTUM EXPRESSION ===")
print(results["cross_modal"]["quantum_expression"])
