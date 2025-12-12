// src/core/fractals/index.js
/**
 * BAZINGA Fractal Framework Integration Module
 * Encoding: 5.2.1.3.7.8
 *
 * This module integrates all fractal generators and analysis components.
 */

const path = require('path');
const fs = require('fs');

// Import BAZINGA core
const { BazingaUniversalTool } = require('../bazinga/bazinga_universal');
const DodoSystem = require('../dodo').DodoSystem;

// Import fractal components
const RelationshipFractalAnalyzer = require('./RelationshipFractalAnalyzer');
const UniversalFractalGenerator = require('./UniversalFractalGenerator');
const FractalDeterministicCommunication = require('./FractalDeterministicCommunication');
const PerfectCommunicationSystem = require('./PerfectCommunicationSystem');
const WisdomVisualization = require('./WisdomVisualization');

// Mathematical constants
const constants = {
  phi: 1.618033988749895,  // Golden ratio
  e: 2.718281828459045,    // Euler's number
  pi: 3.141592653589793,   // Pi
  phi_squared: 2.618033988749895,  // φ²
  inv_phi: 0.618033988749895,      // 1/φ
  phi_minus_1: 0.618033988749895,  // φ-1
  phi_plus_1: 2.618033988749895,   // φ+1
  inv_e: 0.36787944117144233,      // 1/e
  e_squared: 7.3890560989306495,   // e²
  ln_2: 0.6931471805599453,        // ln(2)
  e_to_pi: 23.140692632779267,     // e^π
  pi_half: 1.5707963267948966,     // π/2
  two_pi: 6.283185307179586,       // 2π
  pi_squared: 9.869604401089358,   // π²
  pi_quarter: 0.7853981633974483,  // π/4
};

/**
 * Initialize a new BAZINGA Fractal system
 */
function createFractalSystem(options = {}) {
  const bazingaTool = options.bazingaTool || new BazingaUniversalTool();
  const dodoSystem = options.dodoSystem || new DodoSystem();

  // Create analyzer
  const fractalAnalyzer = new RelationshipFractalAnalyzer(bazingaTool, dodoSystem);

  // Create generators
  const fractalGenerator = new UniversalFractalGenerator();
  const communicationSystem = new FractalDeterministicCommunication();

  return {
    analyzer: fractalAnalyzer,
    generator: fractalGenerator,
    communication: communicationSystem,
    visualization: WisdomVisualization,
    constants: constants,

    // Convenience function to analyze text
    analyzeText(text) {
      const witnessDuality = fractalAnalyzer.analyzeWitnessDuality(text);
      const perceptionGap = fractalAnalyzer.calculatePerceptionRealityGap(text);
      const temporalPattern = fractalAnalyzer.analyzeTemporalPatterns(text);

      const seed = fractalAnalyzer.generateSeed(text);
      const signature = fractalAnalyzer.generateMandelbrotSignature(seed);

      return fractalAnalyzer.generateBazingaInsight(
        witnessDuality,
        perceptionGap,
        temporalPattern,
        signature
      );
    },

    // Generate fractal pattern
    generatePattern(seed, type = "mandelbrot") {
      return fractalGenerator.generate(seed, type);
    },

    // Integrate with DODO system
    enhanceDodo(data) {
      return fractalAnalyzer.enhanceDodoResult(data);
    }
  };
}

module.exports = {
  createFractalSystem,
  RelationshipFractalAnalyzer,
  UniversalFractalGenerator,
  FractalDeterministicCommunication,
  PerfectCommunicationSystem,
  WisdomVisualization,
  constants
};
