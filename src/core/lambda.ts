// src/core/lambda.ts
import { LambdaRule } from './lambda-rules';

/**
 * Lambda class representing a lambda calculus expression
 * Provides core functionality for pattern-based transformations
 */
export class Lambda {
  private expression: string;
  private rules: Map<string, LambdaRule>;

  constructor(expression: string, rules?: Map<string, LambdaRule>) {
    this.expression = expression;
    this.rules = rules || new Map();
  }

  /**
   * Apply this lambda to an argument
   * @param arg The argument to apply
   * @returns Result of application
   */
  apply(arg: any): any {
    // Parse the expression to extract variable and body
    const match = this.expression.match(/λ([a-z]).\s*(.*)/);
    if (!match) {
      throw new Error(`Invalid lambda expression: ${this.expression}`);
    }

    const [_, variable, body] = match;

    // Substitute the argument for the variable in the body
    // This is a simplified implementation - a real one would handle
    // variable capture and other complexities
    return this.evaluate(body.replace(new RegExp(variable, 'g'), arg.toString()));
  }

  /**
   * Evaluate a lambda expression
   * @param expr Expression to evaluate
   * @returns Evaluated result
   */
  private evaluate(expr: string): any {
    // This is a simplified evaluator - a complete one would
    // implement proper lambda calculus evaluation rules

    // Check if we have a rule for this expression
    for (const [pattern, rule] of this.rules.entries()) {
      if (expr.includes(pattern)) {
        return rule(expr);
      }
    }

    // Basic evaluation for arithmetic operations
    try {
      return eval(expr);
    } catch (e) {
      return expr; // Return as is if it can't be evaluated
    }
  }

  /**
   * Compose this lambda with another
   * @param other Lambda to compose with
   * @returns Composed lambda
   */
  compose(other: Lambda): Lambda {
    // Create a new lambda that applies this lambda to the result of the other
    const composed = `λx. ${this.expression.replace(/λ[a-z].\s*/, '')}(${other.expression.replace(/λ[a-z].\s*/, '')}(x))`;
    return new Lambda(composed, this.mergeRules(other.rules));
  }

  /**
   * Merge rule sets from two lambdas
   * @param otherRules Rules to merge with
   * @returns Merged rule map
   */
  private mergeRules(otherRules: Map<string, LambdaRule>): Map<string, LambdaRule> {
    const merged = new Map(this.rules);
    for (const [pattern, rule] of otherRules.entries()) {
      merged.set(pattern, rule);
    }
    return merged;
  }

  /**
   * Create a lambda from a 5-bit pattern
   * @param pattern 5-bit pattern
   * @returns Lambda instance
   */
  static fromPattern(pattern: string): Lambda {
    switch (pattern) {
      // X-Dimension: Structure (physical arrangement)
      case '10101': // Divergence/Growth
        return new Lambda('λx. x + 1');
      case '11010': // Convergence/Synthesis
        return new Lambda('λx. x * 2');
      case '01011': // Balance/Refinement
        return new Lambda('λx. x - 3');

      // Y-Dimension: Temporality (temporal relationship)
      case '10111': // Recency/Distribution
        return new Lambda('λx. x / 5');
      case '01100': // BigPicture/Cycling
        return new Lambda('λx. x % 7');

      // Z-Dimension: Contextuality (contextual relationship)
      case '11100': // Context/Framing
        return new Lambda('λx. Math.pow(x, 2)');
      case '00111': // Relation/Binding
        return new Lambda('λx. Math.sqrt(Math.abs(x))');

      // W-Dimension: Emergence (emergent properties)
      case '10110': // Transform/Emergence
        return new Lambda('λx. Math.sin(x * Math.PI / 4)');
      case '01101': // Pattern/Recognition
        return new Lambda('λx. Math.log(Math.abs(x) + 1)');

      // V-Dimension: Trust (trust relationship)
      case '11111': // AbsoluteTrust
        return new Lambda('λx. x === x ? x : Number.NaN'); // Returns x only if x is deterministic
      case '10001': // ConditionedTrust
        return new Lambda('λx. x >= 0 ? x : -x'); // Trust only positive values
      case '01110': // TimeBoundTrust
        return new Lambda('λx. Math.min(x, 1000)'); // Trust but with upper bounds
      case '11011': // VerifiableTrust
        return new Lambda('λx. Math.round(x * 100) / 100'); // Trust with verification/rounding
      case '00101': // TrustlessPattern
        return new Lambda('λx. Number.isFinite(x) ? x : 0'); // Trust only if finite

      default:
        // Try to derive a pattern-based lambda from the bit pattern
        if (pattern.length === 5) {
          return this.deriveDynamicLambda(pattern);
        }
        throw new Error(`Unknown pattern: ${pattern}`);
    }
  }

  /**
   * Derive a dynamic lambda expression from a 5-bit pattern
   * Implements the meta-programming foundation of the system
   * @param pattern 5-bit pattern
   * @returns Lambda instance
   */
  private static deriveDynamicLambda(pattern: string): Lambda {
    // Count the number of 1s in the pattern for complexity
    const complexity = pattern.split('').filter(bit => bit === '1').length;

    // Use the position of bits to determine characteristics
    const hasFirstBit = pattern[0] === '1';
    const hasLastBit = pattern[4] === '1';
    const hasMiddleBit = pattern[2] === '1';

    // Determine if pattern represents X, Y, Z, W, or V dimension
    const dimensionIndex = parseInt(pattern, 2) % 5;
    const dimensions = ['X', 'Y', 'Z', 'W', 'V'];
    const dimension = dimensions[dimensionIndex];

    // Create a lambda expression based on pattern properties
    let expr = 'λx. ';

    if (dimension === 'V') {
      // V-Dimension: Trust (trust relationship)
      if (complexity >= 3) {
        expr += 'Math.abs(x) / (1 + Math.abs(x))'; // Bounded trust function
      } else {
        expr += 'x >= 0 ? x : 0'; // Simple trust function (trust only positive values)
      }
    } else if (dimension === 'W') {
      // W-Dimension: Emergence (emergent properties)
      if (hasMiddleBit) {
        expr += 'Math.sin(x * Math.PI / ' + (complexity + 1) + ')';
      } else {
        expr += 'Math.cos(x * Math.PI / ' + (complexity + 1) + ')';
      }
    } else if (dimension === 'Z') {
      // Z-Dimension: Contextuality (contextual relationship)
      if (hasFirstBit && hasLastBit) {
        expr += 'x * ' + (complexity + 1);
      } else {
        expr += 'x / ' + (complexity + 1);
      }
    } else if (dimension === 'Y') {
      // Y-Dimension: Temporality (temporal relationship)
      if (hasMiddleBit) {
        expr += 'x % ' + (complexity + 2);
      } else {
        expr += 'x + ' + complexity;
      }
    } else {
      // X-Dimension: Structure (physical arrangement)
      if (hasFirstBit) {
        expr += 'x + ' + complexity;
      } else {
        expr += 'x - ' + complexity;
      }
    }

    return new Lambda(expr);
  }
}
