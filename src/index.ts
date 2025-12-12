/**
 * BAZINGA: Lambda-Driven Pattern Expansion System
 * Core implementation of the DODO (5.1.1.2.3.4.5.1) framework
 * with trust as the fifth dimension (V-axis)
 */

// Core imports
import { Pattern } from './core/dna';
import { Blueprint } from './core/patterns';
import { Rule } from './core/lambda-rules';
import { Lambda } from './core/lambda';
import { ExpansionRules } from './core/lambda-rules';
import { TrustDimension, TrustLevel } from './core/trust-dimension';
import { SelfModifyingExecutor } from './core/self-modifying-executor';

// Generator imports
import { PatternGenerator } from './generators/core/PatternGenerator';
import { DocumentationGenerator } from './generators/output/DocumentationGenerator';
import { VisualizationGenerator } from './generators/output/VisualizationGenerator';

// Export all
export {
    // Original exports
    Pattern,
    Blueprint,
    Rule,
    PatternGenerator,
    DocumentationGenerator,
    VisualizationGenerator,

    // New lambda-based exports
    Lambda,
    ExpansionRules,
    TrustDimension,
    TrustLevel,
    SelfModifyingExecutor
};

// Main entry point for library usage
if (require.main === module) {
  console.log(`
╭───────────────────────────────────────────────────────────────────────╮
│                                                                       │
│             BAZINGA: Lambda-Driven Pattern Expansion System           │
│                                                                       │
│                      DODO Framework (5.1.1.2.3.4.5.1)                 │
│                                                                       │
│     ✓ Core Lambda Calculus Implemented                                │
│     ✓ X-Dimension (Structure) Patterns                                │
│     ✓ Y-Dimension (Temporality) Patterns                              │
│     ✓ Z-Dimension (Contextuality) Patterns                            │
│     ✓ W-Dimension (Emergence) Patterns                                │
│     ✓ V-Dimension (Trust) Patterns                                    │
│     ✓ Self-Modifying Execution                                        │
│     ✓ Pattern-Based Meta-Programming                                  │
│                                                                       │
│     Run tests: npx ts-node src/tests/lambda-test.ts                   │
│                                                                       │
╰───────────────────────────────────────────────────────────────────────╯
  `);
}
