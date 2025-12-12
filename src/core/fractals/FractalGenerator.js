/**
 * FractalGenerator.js
 *
 * Integrated from BAZINGA artifacts
 * Original file: fractal-generator.js
 *
 * Part of the BAZINGA Fractal Relationship Analysis framework
 * BAZINGA Encoding: 5.2.1.3.7.8
 */

/**
 * Fractal Text Generator
 *
 * This program generates fractal text patterns based on seed sentences.
 * The algorithm creates recursive combinations that grow in complexity,
 * allowing for the expression of ideas in a rhythmic, meditative pattern.
 */

class FractalTextGenerator {
  constructor(baseSentences) {
    this.baseSentences = baseSentences;
    this.patterns = [];
  }

  // Generate the initial level of the fractal (individual sentences)
  generateLevel1() {
    return [...this.baseSentences];
  }

  // Generate pairs of sentences
  generateLevel2() {
    const result = [];
    for (let i = 0; i < this.baseSentences.length; i++) {
      for (let j = 0; j < this.baseSentences.length; j++) {
        if (i !== j) { // Avoid pairing a sentence with itself
          result.push(`${this.baseSentences[i]} ${this.baseSentences[j]}`);
        }
      }
    }
    return result;
  }

  // Generate triplets of sentences
  generateLevel3() {
    const result = [];
    for (let i = 0; i < this.baseSentences.length; i++) {
      for (let j = 0; j < this.baseSentences.length; j++) {
        for (let k = 0; k < this.baseSentences.length; k++) {
          if (i !== j && j !== k && i !== k) { // All different sentences
            result.push(`${this.baseSentences[i]} ${this.baseSentences[j]} ${this.baseSentences[k]}`);
          }
        }
      }
    }
    return result;
  }

  // Generate recursive combinations based on previous levels
  generateRecursiveCombinations(previousPatterns, depth = 1) {
    if (depth <= 0) return previousPatterns;

    const result = [];
    const level1 = this.generateLevel1();
    const level2 = this.generateLevel2();

    // Combine previous patterns with level 1 sentences
    for (const pattern of previousPatterns) {
      for (const sentence of level1) {
        result.push(`${pattern} ${sentence}`);
      }
    }

    // Add some level 2 combinations for variety
    for (const pattern of previousPatterns.slice(0, Math.floor(previousPatterns.length / 2))) {
      for (const pair of level2.slice(0, 3)) {
        result.push(`${pattern} ${pair}`);
      }
    }

    return this.generateRecursiveCombinations([...previousPatterns, ...result], depth - 1);
  }

  // Main method to generate the complete fractal text
  generateFractalText(recursionDepth = 3) {
    // Start with the base levels
    const level1 = this.generateLevel1();
    const level2 = this.generateLevel2();
    const level3 = this.generateLevel3().slice(0, 5); // Limit level 3 for brevity

    // Create recursive combinations
    const recursivePatternsL1 = this.generateRecursiveCombinations(level1, 1);
    const recursivePatternsL2 = this.generateRecursiveCombinations(level2, recursionDepth - 1);

    // Combine all patterns, with some filtering for variety and to avoid excessive length
    const allPatterns = [
      ...level1,
      ...level2.slice(0, 6),
      ...level3.slice(0, 3),
      ...recursivePatternsL1.slice(0, 10),
      ...recursivePatternsL2.slice(0, 15)
    ];

    // Remove duplicates
    const uniquePatterns = [...new Set(allPatterns)];

    // Sort by complexity (roughly by length)
    uniquePatterns.sort((a, b) => a.length - b.length);

    return uniquePatterns;
  }

  // Format the output as a readable text
  formatOutput(title) {
    const patterns = this.generateFractalText();
    let output = `## ${title}\n\n`;

    patterns.forEach(pattern => {
      output += pattern + '\n';
    });

    return output;
  }
}

// Example usage with emotional expressions
const emotionalSentences = [
  "Joy radiates from within.",
  "Sorrow deepens understanding.",
  "Wonder opens all doors."
];

const emotionalFractal = new FractalTextGenerator(emotionalSentences);
console.log(emotionalFractal.formatOutput("The Spectrum of Feeling"));

// Example with philosophical concepts
const philosophicalSentences = [
  "Existence precedes essence.",
  "Knowledge transforms being.",
  "Freedom requires responsibility."
];

const philosophicalFractal = new FractalTextGenerator(philosophicalSentences);
console.log(philosophicalFractal.formatOutput("Philosophical Meditations"));


// Add module exports for BAZINGA integration
module.exports = { FractalGenerator };
