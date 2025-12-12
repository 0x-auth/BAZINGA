// src/core/trust-dimension.ts

import { Lambda } from './lambda';
import { Rule, ExpansionRules } from './lambda-rules';

/**
 * TrustLevel enum: Represents different levels of trust in the V-dimension
 */
export enum TrustLevel {
  None = 0,       // No trust
  Minimal = 1,    // Minimal trust with strict verification
  Bounded = 2,    // Trust with constraints
  Verified = 3,   // Trust with verification
  Conditional = 4, // Trust with conditions
  Absolute = 5    // Absolute trust
}

/**
 * V-Dimension implements the trust dimension functionality
 * Maps trust relationships to lambda calculus operations
 */
export class TrustDimension {
  /**
   * Creates a trust-based rule from a given trust level
   * @param level Trust level to use
   * @returns Rule that implements the trust semantics
   */
  static createTrustRule(level: TrustLevel): Rule {
    switch (level) {
      case TrustLevel.None:
        // No trust - constant function that ignores input
        return ExpansionRules.constant(0);

      case TrustLevel.Minimal:
        // Minimal trust - extreme bounds checking
        return (x: number) => {
          if (!Number.isFinite(x)) return 0;
          return Math.max(-100, Math.min(100, x));
        };

      case TrustLevel.Bounded:
        // Bounded trust - soft bounds
        return (x: number) => {
          if (!Number.isFinite(x)) return 0;
          // Sigmoid-like function to bound output
          return x / (1 + Math.abs(x));
        };

      case TrustLevel.Verified:
        // Verified trust - rounding for precision control
        return (x: number) => {
          if (!Number.isFinite(x)) return 0;
          return Math.round(x * 1000) / 1000;
        };

      case TrustLevel.Conditional:
        // Conditional trust - accept within certain parameters
        return (x: number) => {
          if (!Number.isFinite(x)) return 0;
          return x >= 0 ? x : 0; // Trust positive values only
        };

      case TrustLevel.Absolute:
        // Absolute trust - identity function
        return ExpansionRules.identity;
    }
  }

  /**
   * Combines a rule with a trust rule to create a trust-bounded rule
   * @param rule The rule to apply trust boundaries to
   * @param trustLevel The level of trust to apply
   * @returns A new rule that applies the original rule with trust boundaries
   */
  static applyTrustBoundary(rule: Rule, trustLevel: TrustLevel): Rule {
    const trustRule = this.createTrustRule(trustLevel);
    return ExpansionRules.compose(trustRule, rule);
  }

  /**
   * Creates a lambda from a trust level
   * @param trustLevel The trust level to create a lambda for
   * @returns Lambda representing the trust function
   */
  static createTrustLambda(trustLevel: TrustLevel): Lambda {
    const pattern = this.getTrustPattern(trustLevel);
    return Lambda.fromPattern(pattern);
  }

  /**
   * Maps a trust level to a 5-bit pattern
   * @param trustLevel The trust level
   * @returns 5-bit pattern string
   */
  private static getTrustPattern(trustLevel: TrustLevel): string {
    switch (trustLevel) {
      case TrustLevel.None:
        return '00000'; // No trust - all bits off
      case TrustLevel.Minimal:
        return '00101'; // TrustlessPattern
      case TrustLevel.Bounded:
        return '01110'; // TimeBoundTrust
      case TrustLevel.Verified:
        return '11011'; // VerifiableTrust
      case TrustLevel.Conditional:
        return '10001'; // ConditionedTrust
      case TrustLevel.Absolute:
        return '11111'; // AbsoluteTrust - all bits on
    }
  }

  /**
   * Check if a pattern belongs to the trust dimension
   * @param pattern 5-bit pattern
   * @returns true if the pattern represents a trust function
   */
  static isTrustPattern(pattern: string): boolean {
    const trustPatterns = [
      '00000', // None
      '00101', // Minimal
      '01110', // Bounded
      '11011', // Verified
      '10001', // Conditional
      '11111'  // Absolute
    ];
    return trustPatterns.includes(pattern);
  }

  /**
   * Creates a time-bound trust function
   * Implements the key insight from Time-Trust duality
   * @param trustLevel Base trust level
   * @param timeLimit Time bound in milliseconds
   * @returns A function that applies trust with time bounds
   */
  static createTimeBoundTrust(
    trustLevel: TrustLevel,
    timeLimit: number
  ): (input: any) => { value: any; trusted: boolean; } {
    const trustRule = this.createTrustRule(trustLevel);

    return (input: any) => {
      const startTime = Date.now();
      const result = typeof input === 'number' ? trustRule(input) : input;
      const endTime = Date.now();
      const executionTime = endTime - startTime;

      return {
        value: result,
        trusted: executionTime <= timeLimit
      };
    };
  }
}
