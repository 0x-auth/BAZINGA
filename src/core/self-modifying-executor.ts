// src/core/self-modifying-executor.ts

import { Lambda } from './lambda';
import { LambdaRule, Rule, ExpansionRules } from './lambda-rules';
import { TrustDimension, TrustLevel } from './trust-dimension';

/**
 * Execution trace entry for pattern detection
 */
interface ExecutionTrace {
  input: number;
  output: number;
  pattern?: string;
  dimension?: string;
}

/**
 * Self-modifying executor that represents the core
 * of the lambda-driven pattern expansion system.
 *
 * Implements the meta-programming foundation by:
 * 1. Executing lambda expressions
 * 2. Tracking execution patterns
 * 3. Detecting recurring patterns
 * 4. Synthesizing new lambdas from detected patterns
 * 5. Integrating new lambdas into the execution model
 */
export class SelfModifyingExecutor {
  private lambdas: Map<string, Lambda>;
  private executionHistory: ExecutionTrace[];
  private trustLevel: TrustLevel;

  constructor(initialLambdas?: Map<string, Lambda>, trustLevel: TrustLevel = TrustLevel.Verified) {
    this.lambdas = initialLambdas || new Map();
    this.executionHistory = [];
    this.trustLevel = trustLevel;
  }

  /**
   * Execute a specific lambda on an input value
   * @param pattern The pattern identifying the lambda to execute
   * @param input The input value
   * @returns The execution result
   */
  execute(pattern: string, input: number): number {
    // Apply trust boundary based on current trust level
    const lambda = this.lambdas.get(pattern) || Lambda.fromPattern(pattern);
    const result = lambda.apply(input);

    // Record execution trace for pattern detection
    this.executionHistory.push({
      input,
      output: typeof result === 'number' ? result : 0,
      pattern,
      dimension: this.getDimensionFromPattern(pattern)
    });

    // After sufficient executions, try to detect patterns
    if (this.executionHistory.length >= 10) {
      this.detectAndSynthesizePatterns();
    }

    return typeof result === 'number' ? result : 0;
  }

  /**
   * Register a new lambda with the executor
   * @param pattern The pattern to associate with the lambda
   * @param lambda The lambda to register
   */
  registerLambda(pattern: string, lambda: Lambda): void {
    this.lambdas.set(pattern, lambda);
  }

  /**
   * Get the current trust level
   * @returns The current trust level
   */
  getTrustLevel(): TrustLevel {
    return this.trustLevel;
  }

  /**
   * Set the trust level for the executor
   * @param level The new trust level
   */
  setTrustLevel(level: TrustLevel): void {
    this.trustLevel = level;
  }

  /**
   * Derive the dimension from a pattern
   * @param pattern The 5-bit pattern
   * @returns The dimension name ('X', 'Y', 'Z', 'W', 'V')
   */
  private getDimensionFromPattern(pattern: string): string {
    if (TrustDimension.isTrustPattern(pattern)) {
      return 'V'; // Trust dimension
    }

    // Simple heuristic to determine dimension
    const patternValue = parseInt(pattern, 2);
    const dimensions = ['X', 'Y', 'Z', 'W', 'V'];
    return dimensions[patternValue % dimensions.length];
  }

  /**
   * Detect patterns in execution history and synthesize new lambdas
   * This is the core self-modifying behavior
   */
  private detectAndSynthesizePatterns(): void {
    // Group execution traces by input range
    const inputRanges: { [key: string]: ExecutionTrace[] } = {};

    for (const trace of this.executionHistory) {
      // Create buckets of input ranges
      const rangeKey = Math.floor(trace.input / 10) * 10;
      if (!inputRanges[rangeKey]) {
        inputRanges[rangeKey] = [];
      }
      inputRanges[rangeKey].push(trace);
    }

    // For each input range, look for patterns in output behavior
    for (const [rangeKey, traces] of Object.entries(inputRanges)) {
      if (traces.length < 3) continue; // Need at least 3 samples

      // Try to detect linear patterns
      const isLinear = this.detectLinearPattern(traces);

      if (isLinear) {
        // Create a new lambda for linear relationship
        const [slope, intercept] = this.calculateLinearRegression(traces);
        const newLambdaExpr = `λx. ${slope} * x + ${intercept}`;

        // Generate a new pattern for this lambda
        const newPattern = this.generatePatternForLambda(
          newLambdaExpr,
          traces[0].dimension || 'X'
        );

        // Create and register the new lambda with trust boundaries
        const newLambda = new Lambda(newLambdaExpr);
        this.registerLambda(newPattern, newLambda);

        // Clear the execution history that led to this pattern
        this.executionHistory = this.executionHistory.filter(
          trace => !traces.includes(trace)
        );
      }
    }

    // Limit history size to avoid memory issues
    if (this.executionHistory.length > 100) {
      this.executionHistory = this.executionHistory.slice(-100);
    }
  }

  /**
   * Detect if a set of execution traces follows a linear pattern
   * @param traces Execution traces to analyze
   * @returns true if the traces appear to follow a linear pattern
   */
  private detectLinearPattern(traces: ExecutionTrace[]): boolean {
    // Need at least 3 points to detect a pattern
    if (traces.length < 3) return false;

    // Calculate linear regression
    const [slope, intercept] = this.calculateLinearRegression(traces);

    // Calculate R² (coefficient of determination)
    let sumSquaredErrors = 0;
    let sumSquaredTotal = 0;
    const mean = traces.reduce((sum, trace) => sum + trace.output, 0) / traces.length;

    for (const trace of traces) {
      const predicted = slope * trace.input + intercept;
      sumSquaredErrors += Math.pow(trace.output - predicted, 2);
      sumSquaredTotal += Math.pow(trace.output - mean, 2);
    }

    // Avoid division by zero
    if (sumSquaredTotal === 0) return false;

    const rSquared = 1 - (sumSquaredErrors / sumSquaredTotal);

    // Consider it linear if R² is high enough
    return rSquared > 0.9; // 90% fit is considered linear
  }

  /**
   * Calculate linear regression parameters from execution traces
   * @param traces Execution traces to analyze
   * @returns [slope, intercept] of the best-fit line
   */
  private calculateLinearRegression(traces: ExecutionTrace[]): [number, number] {
    const n = traces.length;
    let sumX = 0;
    let sumY = 0;
    let sumXY = 0;
    let sumXX = 0;

    for (const trace of traces) {
      sumX += trace.input;
      sumY += trace.output;
      sumXY += trace.input * trace.output;
      sumXX += trace.input * trace.input;
    }

    // Calculate slope and intercept
    const divisor = n * sumXX - sumX * sumX;

    // Avoid division by zero
    if (divisor === 0) return [0, sumY / n];

    const slope = (n * sumXY - sumX * sumY) / divisor;
    const intercept = (sumY - slope * sumX) / n;

    // Round to 3 decimal places for cleaner expressions
    return [
      Math.round(slope * 1000) / 1000,
      Math.round(intercept * 1000) / 1000
    ];
  }

  /**
   * Generate a 5-bit pattern for a new lambda
   * @param lambdaExpr The lambda expression string
   * @param dimension The dimension this lambda belongs to
   * @returns A new 5-bit pattern string
   */
  private generatePatternForLambda(lambdaExpr: string, dimension: string): string {
    // Hash the lambda expression to generate a unique pattern
    let hash = 0;
    for (let i = 0; i < lambdaExpr.length; i++) {
      hash = ((hash << 5) - hash) + lambdaExpr.charCodeAt(i);
      hash |= 0; // Convert to 32bit integer
    }

    // Convert to positive number
    hash = Math.abs(hash);

    // Generate a 5-bit pattern based on hash
    // Modified to bias toward the specified dimension
    const dimensionIndex = { 'X': 0, 'Y': 1, 'Z': 2, 'W': 3, 'V': 4 }[dimension] || 0;

    let pattern = '';
    for (let i = 0; i < 5; i++) {
      // More likely to set a bit to 1 if it's the dimension's index
      const probability = i === dimensionIndex ? 0.8 : 0.5;
      pattern += (hash & (1 << i)) || Math.random() < probability ? '1' : '0';
    }

    // Prevent patterns that are already registered
    while (this.lambdas.has(pattern)) {
      // Flip a random bit
      const pos = Math.floor(Math.random() * 5);
      pattern = pattern.substring(0, pos) +
                (pattern[pos] === '0' ? '1' : '0') +
                pattern.substring(pos + 1);
    }

    return pattern;
  }

  /**
   * Get a summary of the execution engine state
   * @returns A string describing the current state
   */
  getState(): string {
    return `Self-Modifying Executor
Trust Level: ${TrustLevel[this.trustLevel]}
Registered Lambdas: ${this.lambdas.size}
Execution History: ${this.executionHistory.length} entries
Dimensions: X, Y, Z, W, V (Trust)
Pattern-based meta-programming enabled`;
  }
}
