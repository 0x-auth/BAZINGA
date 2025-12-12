
def get_pattern_code(self, pattern_name):
    """Get pattern code by name"""
    pattern_codes = {
        'time-trust': '4.1.1.3.5.2.4',
        'harmonic': '3.2.2.1.5.3.2',
        'relationship': '6.1.1.2.3.4.5.2.1',
        'mandelbrot': '5.1.1.0.1.0.1'
    }
    return pattern_codes.get(pattern_name, '1.1.1.1.1')
