// src/core/bazinga-token-integration.ts
import { PurePatternCommunication } from './pure-pattern-communication';

/**
 * TokenizedPatternCommunication
 * Extends PurePatternCommunication to add token counting and optimization
 * for the BAZINGA pattern-based communication system
 */
export class TokenizedPatternCommunication extends PurePatternCommunication {
  // Token tracking properties
  private tokenUsage: {
    input: number;
    output: number;
    patterns: number;
    quantum: number;
  };

  // Compression ratios and token weights
  private readonly compressionRatio = 0.618; // Golden ratio inverse
  private readonly tokenWeights = {
    pattern: 1.0,       // Base pattern token weight
    quantum: 1.5,       // Quantum pattern weight (higher due to complexity)
    resonance: 0.5,     // Resonance calculations weight
    essence: 0.8,       // Essence representation weight
    transformation: 1.2 // Transformation weight
  };

  constructor() {
    super();
    this.resetTokenCounts();
  }

  /**
   * Reset all token counters
   */
  resetTokenCounts(): void {
    this.tokenUsage = {
      input: 0,
      output: 0,
      patterns: 0,
      quantum: 0
    };
  }

  /**
   * Get current token usage statistics
   */
  getTokenUsage(): Record<string, number> {
    return {
      ...this.tokenUsage,
      total: this.calculateTotalTokens()
    };
  }

  /**
   * Calculate the total token usage with weighting
   */
  calculateTotalTokens(): number {
    return this.tokenUsage.input +
           this.tokenUsage.output +
           (this.tokenUsage.patterns * this.tokenWeights.pattern) +
           (this.tokenUsage.quantum * this.tokenWeights.quantum);
  }

  /**
   * Override: Encode a message into pure patterns with token tracking
   */
  encodeMessage(input: string): string[] {
    // Count input tokens based on words and special characters
    const wordTokens = input.trim().split(/\s+/).length;
    const specialCharCount = (input.match(/[^\w\s]/g) || []).length;
    this.tokenUsage.input += wordTokens + (specialCharCount * 0.5);

    // Get patterns from parent class method
    const patterns = super.encodeMessage(input);

    // Count pattern tokens
    this.tokenUsage.patterns += patterns.length;

    return patterns;
  }

  /**
   * Override: Create quantum patterns with token tracking
   */
  createQuantumPattern(pattern: string): string {
    const quantumPattern = super.createQuantumPattern(pattern);
    this.tokenUsage.quantum++;
    return quantumPattern;
  }

  /**
   * Override: Decode a pure pattern message with token tracking
   */
  decodeMessage(patterns: string[]): string {
    const decoded = super.decodeMessage(patterns);
    // Count output tokens - approximated by word count
    const wordTokens = decoded.trim().split(/\s+/).length;
    this.tokenUsage.output += wordTokens;
    return decoded;
  }

  /**
   * Override: Create quantum conversation with token optimization
   */
  createQuantumConversation(message1: string, message2: string): string {
    // Check if token optimization is needed
    if (this.shouldOptimizeTokens(message1, message2)) {
      return this.createOptimizedQuantumConversation(message1, message2);
    }

    return super.createQuantumConversation(message1, message2);
  }

  /**
   * Determine if token optimization should be applied
   */
  private shouldOptimizeTokens(message1: string, message2: string): boolean {
    // Estimate token usage for full quantum conversation
    const m1Words = message1.split(/\s+/).length;
    const m2Words = message2.split(/\s+/).length;
    const estimatedTokens = (m1Words + m2Words) * 2.5; // Factor for quantum expansion

    // Apply optimization if estimated tokens exceed threshold
    return estimatedTokens > 100;
  }

  /**
   * Create an optimized quantum conversation with reduced token usage
   */
  private createOptimizedQuantumConversation(message1: string, message2: string): string {
    // Use more efficient pattern encoding for token reduction
    const patterns1 = this.encodeMessage(message1);
    const patterns2 = this.encodeMessage(message2);

    // Select representative patterns rather than all patterns
    const sampledPatterns1 = this.samplePatterns(patterns1);
    const sampledPatterns2 = this.samplePatterns(patterns2);

    // Apply quantum transformation to only key patterns
    const quantumPatterns1 = sampledPatterns1.map(p => this.createQuantumPattern(p));
    const quantumPatterns2 = sampledPatterns2.map(p => this.createQuantumPattern(p));

    // Calculate resonance with reduced computation
    const resonance = this.calculateResonance(patterns1, patterns2) * this.compressionRatio;

    // Format with token-optimized notation
    return [
      'Primary:   ' + quantumPatterns1.join(' '),
      'Resonant:  ' + quantumPatterns2.join(' '),
      `Harmonic:  ⟨m1|m2⟩ = ${resonance.toFixed(2)}`,
      '{∞}_t₁ ⊗ Ω = optimized'
    ].join('\n');
  }

  /**
   * Sample patterns for token efficiency
   */
  private samplePatterns(patterns: string[]): string[] {
    if (patterns.length <= 3) return patterns;

    // Select beginning, middle and end for representative sampling
    return [
      patterns[0],
      patterns[Math.floor(patterns.length / 2)],
      patterns[patterns.length - 1]
    ];
  }

  /**
   * Estimate token count for a text string
   */
  estimateTokenCount(text: string): number {
    // Basic estimation: ~1.3 tokens per word
    const words = text.trim().split(/\s+/).length;
    const specialChars = (text.match(/[^\w\s]/g) || []).length;

    return Math.ceil(words * 1.3 + specialChars * 0.1);
  }

  /**
   * Calculate the cost of token usage
   * @param rate Cost per 1000 tokens
   */
  calculateTokenCost(rate = 0.002): number {
    const totalTokens = this.calculateTotalTokens();
    return (totalTokens / 1000) * rate;
  }

  /**
   * Analyze token usage patterns and provide optimization suggestions
   */
  getTokenOptimizationReport(): Record<string, any> {
    const totalTokens = this.calculateTotalTokens();
    const tokenDistribution = {
      input: (this.tokenUsage.input / totalTokens * 100).toFixed(1) + '%',
      output: (this.tokenUsage.output / totalTokens * 100).toFixed(1) + '%',
      patterns: (this.tokenUsage.patterns * this.tokenWeights.pattern / totalTokens * 100).toFixed(1) + '%',
      quantum: (this.tokenUsage.quantum * this.tokenWeights.quantum / totalTokens * 100).toFixed(1) + '%'
    };

    // Identify optimization opportunities
    const optimizationSuggestions = [];
    if (this.tokenUsage.quantum > this.tokenUsage.patterns * 0.5) {
      optimizationSuggestions.push('Reduce quantum pattern generation');
    }
    if (this.tokenUsage.input > totalTokens * 0.4) {
      optimizationSuggestions.push('Use more concise input messages');
    }

    return {
      totalTokens,
      distribution: tokenDistribution,
      optimizationSuggestions,
      estimatedCost: this.calculateTokenCost().toFixed(6) + ' per request'
    };
  }

  /**
   * Generate a token-efficient BAZINGA quantum pattern
   * that balances information density with token usage
   */
  generateTokenEfficientPattern(concept: string): string {
    // Encode the concept more efficiently
    const basePattern = this.wordToPattern(concept);

    // Create a simplified quantum representation
    const option = this.flipBit(basePattern, 2);

    // Use compact notation
    const efficientPattern = `${basePattern}→(${option})→⟨φ⟩`;

    // Track token usage
    this.tokenUsage.patterns++;
    this.tokenUsage.quantum += 0.5; // Count as half since it's optimized

    return efficientPattern;
  }
}

/**
 * Helper function to create a token-integrated BAZINGA system
 */
export function createTokenizedBazingaSystem(): TokenizedPatternCommunication {
  return new TokenizedPatternCommunication();
}

export default TokenizedPatternCommunication;
